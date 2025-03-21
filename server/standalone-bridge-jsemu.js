// local / emulated lua in javascript ?
import {EmbeddedLuaInterpreter, luaVmPackageInfos} from '/js/lua.vm-util.js';
import {require, getIDs, removeFromParent} from '/js/util.js';
import {init as initStandalone, fail, serverBase} from './standalone.js';

/*
initArgs:
	worksheetFilename
	symmathPath
*/
const init = async (initArgs) => {

// https://docs.mathjax.org/en/latest/web/configuration.html
// specify mathjax initial args ...
window.MathJax = {
	tex: {
		inlineMath: [['$', '$'], ['\\(', '\\)']]
	},
	svg: {
		fontCache: 'global'
	}
};
// ... then load mathjax ...
await require('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js');


class EmulatedServer {
	constructor() {
		this.nextValidUID = 1;
	}

	onLuaInit(lua) {
		this.lua = lua;

// before anything, since this is js, and afaik there's no luajit in js, let me disable my buggy luaffi
lua.execute(`package.loaded.ffi = nil`);

// now add langfix so any subsequent loads will be using langfix syntax
lua.execute(`require 'langfix'`);

console.log("executing lua and defining global symmathHTTP")
		lua.execute(`
-- embedded-javascript version of standalone.lua
-- TODO superclass some of this with standalone.lua ?

-- here gnuplot
--somehow change the in-lua gnuplot execution to instead call the emscripten lua gnuplot ...
package.loaded.gnuplot = function(args)
	-- override os.execute to instead forward to gnuplot.run
	-- TODO the gnuplot is in its own emscripten, how about building that as a side-module
	-- call js from lua
	--[[
	local gnuplot = js.global.gnuplot
	gnuplot:run(inscript, e => {
		gnuplot:getFile(outputFilename, e => {
			error'TODO insert output svg here'
		});
	});
	--]]
end

-- TODO verify the need for this with the new build ... maybe just use the lua.print/lua.printErr/lua.capture?
-- for emscripten, store this as a global
orig_print = print

-- TODO verify this with the new build
-- emscripten js throws errors on calling io.popen
-- and ext.os is using popen to determine windows or not ...
-- so instead I am just going to override it here
function io.popen(procname)
	return {
		read = function()
			return ''
		end,
	}
end

local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local path = require 'ext.path'
local io = require 'ext.io'
local os = require 'ext.os'
local tolua = require 'ext.tolua'
local fromlua = require 'ext.fromlua'
local template = require 'template'
local showcode = require 'template.showcode'

-- store original _G.print here so this file scope can use it (before overriding it later)
local print = print
local orig_io = require 'io'
local orig_io_write = io.write
local ext_io = require 'ext.io'
local ext_io_write = ext_io.write


-- kind of a mess ...
-- not multithread safe at all
-- write this before load()'ing cell block code, based on the cell type
local currentBlockNewLineSymbol

-- initialize this to the highest UID of any cell, + 1
-- then inc it as we go
local nextValidUID = 1

local SymmathHTTP = class()

function SymmathHTTP:init()
	self:setupSandbox()


	-- single worksheet instance.  TODO make modular:
	self.cells = table()
end


local FakeFile = class()
function FakeFile:init()
	self.buffer = ''
end
function FakeFile:close() end
function FakeFile:flush() end	-- do immediately?
function FakeFile:lines() return coroutine.wrap(function() end) end
function FakeFile:read() end
function FakeFile:seek() end
function FakeFile:setvbuf() end
function FakeFile:write() end

function SymmathHTTP:setupSandbox()

	-- here's the execution environment.  really this is what you have to parallel ... well ... maybe sandbox this
	self.env = {}


	for k,v in pairs(_G) do
		self.env[k] = v
	end


	-- do this after we've hijacked ext.io
	-- TODO sandbox the package.loaded and require table?
	require 'ext.env'(self.env)


	local orig_io = require 'io'
	-- TODO FIXME this is resetting ext.io, but what about io itself?
	-- I guess its hidden if we always require 'ext' on the env
	local orig_io = require 'ext.io'

	self.env.io = {}
	for k,v in pairs(orig_io) do
		self.env.io[k] = v
	end

	-- file handle object
	self.env.io.stdin = FakeFile()
	self.env.io.stdout = FakeFile()

	--[[ well, this doesn't work, guess i have to override everything I use in io ...
	self.env.io.output(self.env.io.stdout)
	self.env.io.input(self.env.io.stdin)
	--]]
	-- [[
	function self.env.io.stdout:write(...)
		for i=1,select('#', ...) do
			self.buffer = self.buffer .. tostring((select(i, ...)))
		end
	end

	function self.env.io.read(...)
		return self.env.io.stdin:read(...)
	end

	function self.env.io.write(...)
		return self.env.io.stdout:write(...)
	end

	function self.env.io.flush(...)
		return self.env.io.stdout:flush(...)
	end

	function self.env.print(...)
		for i=1,select('#', ...) do
			if i > 1 then self.env.io.write'\\t' end
			self.env.io.write(tostring((select(i, ...))))
		end
		self.env.io.write(currentBlockNewLineSymbol or '\\n')
		self.env.io.flush()
	end
	--]]


	-- for the sake of printElem()
	-- and GnuPlot's former behavior (maybe go back to former?)
	_G.print = self.env.print
	require 'io'.write = self.env.io.write
	require 'ext.io'.write = self.env.io.write


	local symmath = require 'symmath'
	symmath.setup{env=self.env, implicitVars=true, fixVariableNames=true}
	symmath.tostring = symmath.export.MathJax
end

function SymmathHTTP:log() end

function SymmathHTTP:runCell(cell)
	self:log(2, 'running...')
	self:log(2, showcode(cell.input))
	self.env.io.stdout.buffer = ''
	cell.haserror = nil

	-- TODO use this in cell env print() and io.write()
	currentBlockNewLineSymbol =
		cell.outputtype == 'html' and '<br>\\n'
		or '\\n'

	xpcall(function()

		-- put a ; at the end to suppress assignment output.  sound familiar?
		local suppressOutput = cell.input:sub(-1) == ';'
	self:log(1, 'suppressOutput = ', suppressOutput)

		local results

		-- first try loading the code with 'return ' in front - just like lua interpreter
		-- but don't if we are suppressing output -- because the 'return' is only used for just that
		if not suppressOutput then
			xpcall(function()
				results = table.pack(assert(load('return '..cell.input, nil, nil, self.env))())
				self:log(2, "run() got a single expression")
			end, function(err)
				-- hide any errors and try later on fail
			end)
		end

		-- if it's not a single-expression, how about an assignment?  in that case, try to capture the lhs
		if not results then
			-- first strip out comments, then search for =
			local findlhs = cell.input

			-- strip out block comments
			while true do
				local before, equals, afterstart = findlhs:match'(.-)%-%-%[(=*)%[(.*)'
				if not before then break end
self:log(5, "before block comment start: "..before)
self:log(5, "block comment start equals: "..equals)
self:log(5, "after block comment start: "..afterstart)
				local comment, aftercomment = afterstart:match('(.-)%]'..equals..'%](.*)')
self:log(5, "comment: "..comment)
self:log(5, "aftercomment: "..aftercomment)
				if not comment then
					-- error: unfinished long comment
				else
					findlhs = before .. aftercomment
self:log(5, "cellinput is now "..findlhs)
				end
			end

			-- strip out single-line comments
			findlhs = findlhs:gsub('%-%-[^\\r\\n]*', '')

			local lhs, rhs = findlhs:match'([^=]-)=(.*)'
			if lhs then
				lhs = string.trim(lhs)

				self:log(2, "run() found a assign-stmt")
				self:log(5, "lhs = ", lhs)
				self:log(5, "rhs = ", rhs)

				-- if it failed then there's an error in it ... so we want to report the error ...
				-- also we don't need 'results' ... since we're going to get it from the xpcall on lhs
				-- but maybe we should save 'results', since without 'results' it will be run twice as a non-expr, non-assign-stmt ...
				results = table.pack(assert(load(cell.input, nil, nil, self.env))())
				self:log(2, "run() successfully handled assign-stmt")

				if not suppressOutput then
					--[[ rely on return tostring()
					-- try to append the lhs's tostring to the output
					-- hide errors maybe?
					-- since return-stmt and assign-stmt are exclusive in lua (you can't do "return a=b" like C),
					-- ... just assign 'results' here
					xpcall(function()
						results = table.pack(assert(load("return tostring("..lhs..")", nil, nil, self.env))())
						self:log(2, "run() successfully handled tostring(lhs)")
					end, function(err)
					end)
					--]]
					-- [[ tostring() already handled below? vararg this way:
					xpcall(function()
						results = table.pack(assert(load("return "..lhs, nil, nil, self.env))())
						self:log(2, "run() successfully handled tostring(lhs)")
					end, function(err)
					end)
					--]]
					--[[ rely on print() (handles mult ret better)
					local pushOutput = self.env.io.stdout.buffer
					self.env.io.stdout.buffer = ''

					-- try to append the lhs's tostring to the output
					-- hide errors maybe?
					-- since return-stmt and assign-stmt are exclusive in lua (you can't do "return a=b" like C),
					-- ... just assign 'results' here
					xpcall(function()
						table.pack(assert(load("print("..lhs..")", nil, nil, self.env))())
						self:log(2, "run() successfully handled tostring(lhs)")
						-- assign here so that we don't assign if we get an error
						results = self.env.io.stdout.buffer
					end, function(err)
					end)

					self.env.io.stdout.buffer = pushOutput
					--]]
				end
			end
		end

		-- if expression fails, and assign-statement fails, then try without ... in case it's multi-statement
		if not results then
			self:log(2, "run() handling multi-stmt")
			results = table.pack(assert(load(cell.input, nil, nil, self.env))())
		end

		cell.output = self.env.io.stdout.buffer
		self:log(2, "run() cell.output", cell.output)

		if results.n > 0 then
			--[[ if we returned anything from this block then print it -- just like lua interpreter
			-- turns out print() already inserted one of these <br>s so if we're mixing print() and return then no need to insert twice
			-- TODO in this case ... who should handle the error?
			if #cell.output > 0 then
				cell.output = cell.output .. currentBlockNewLineSymbol
			end
			--]]
			-- TODO new question to ask, should this be inserted at the top or bottom of the output?
			for i=1,results.n do
				if i > 1 then
					cell.output = cell.output .. '\\t'
				end
				cell.output = cell.output .. tostring(
					results[i]
				)
			end
		end

	end, function(err)
		self:log(0, 'got error '..err)
		cell.output = err..'\\n'..debug.traceback()
		cell.haserror = true	-- use this flag to override the output type, so that when the error goes away the output will go back to what it was
	end)
end

-- in standalone.lua these commands are handled in handleRequsts()

-- global:
symmathhttp = SymmathHTTP()

`);

console.log("querying global symmathhttp")
		lua.execute("orig_print(symmathhttp)");
console.log("outputBuffer", lua.outputBuffer);
lua.outputBuffer = '';
	}

	getCellForUID(uid) {
		let ctrl = serverBase.findCtrlForUID(uid);
		if (!ctrl) return;
		return ctrl.cell;
	}

	/*
	args:
		done : function(cellsjson)
		fail
	*/
	getCells(args) {
		args.done(JSON.stringify(serverBase.cells));
	}

	/*
	args:
		uid
		outputtype
		done
		fail
	*/
	setOutputType(args) {
		let cell = this.getCellForUID(args.uid);
		if (!cell) args.fail();
		cell.outputtype = args.outputtype;
		args.done(JSON.stringify(cell));
	}

	/*
	args:
		uid
		done
		fail
	*/
	remove(args) {
		//callback is going to remove the js cell anyways, so
		args.done();
	}

	encodeString(s) {
		// TODO search for the # of ='s that isn't used in the string
		return '[=======[' + s + ']=======]';
	}

	/*
	args:
		uid,
		cellinput,
		done
		fail
	*/
	run(args) {
		const lua = this.lua;
		let thiz = this;
		let cell = this.getCellForUID(args.uid);
		cell.input = args.cellinput;
		//here's where the lua interpretter comes in


		let output = '';
		this.lua.capture({
			callback : () => {
				thiz.lua.execute(
`
currentRunningCell = {
	uid=` + cell.uid + `,
	input=` + thiz.encodeString(cell.input) + `,
	output='',
	outputtype=` + thiz.encodeString(cell.outputtype) + `,
	hidden=` + (cell.hidden ? "true" : "false") + `
}
symmathhttp:runCell(currentRunningCell)
orig_print(currentRunningCell.output)
`
);
			},
			output : s => {
				s += '\n';
console.log("output", s);
				output += s;
			},
			error : s => {
				//I don't' think this is ever hit
				s += '\n';
console.log("error", s);
				output += s;
			}
		});
		cell.output = output;

		this.lua.capture({
			callback : () => {
				thiz.lua.execute("orig_print(currentRunningCell.haserror and 'true' or 'false')");
			},
			output : s => {
console.log("haserror?", s);
				cell.haserror = s == 'true';
			},
		});

		//let the browser handle some input
		setTimeout(() => {
			args.done(JSON.stringify(cell));
		}, 0);
	}

	/*
	args:
		uid
		hidden
	*/
	setHidden(args) {
		let cell = this.getCellForUID(args.uid);
		if (!cell) (args.fail || fail)();
		cell.hidden = args.hidden;
		if (args.done) args.done();
	}

	/*
	args:
		uid (optional) cell to insert before
		done : function(celljson),
		fail
	*/
	newCell(args) {
		//make sure this matches standalone.lua's Cell ctor
		args.done(JSON.stringify({
			uid : ++this.nextValidUID,
			input : '',
			output : '',
			outputtype : 'html',
			hidden : false
		}));
	}

	/*
	args:
		(don't pass cells, i'll just read from the global)
		done
		fail
	*/
	writeCells(args) {
		args.done();
	}

	/*
	args:
		done
		fail
	*/
	save(args) {
		args.done();
	}

	quit() {
	}

	/*
	args:
		done
		fail
	*/
	newWorksheet(args) {
		this.lua.execute("symmathhttp:setupSandbox()");
		args.done();
	}

	/*
	args:
		done
		fail
	*/
	resetEnv(args) {
		this.lua.execute("symmathhttp:setupSandbox()");
		args.done();
	}

	/*
	args:
		filename
		done
		fail
	*/
	getWorksheet(args) {
		const lua = this.lua;
console.log("getWorksheet", args);
		//TODO read file from the lua.vm-util.js preloader
		//and then convert it from a lua object to a json object
		//and then return it
		//alright, I might finally need dkjson.lua ...
		let result = '';
		this.lua.capture({
			callback : () => {
				lua.execute(
`
local data
data = 'symmath/`+args.filename+`'
data = require 'ext.io'.readfile(data)
data = require 'ext.fromlua'(data)
data = require 'dkjson'.encode(data)
orig_print(data)
`
);
			},
			output : s => {
				result += s + '\n';
console.log("output", s);
			},
			error : s => {
console.log("error", s);
			}
		});
console.log("getWorksheet results", result);
		args.done(result);
	}

	fwdInit(args) {
		return initStandalone(args);
	}
}


//from here down is specific to my website...

const ids = getIDs();

//Lua is the lua.vm.js compiled-to-js lua
//lua is my wrapper of it
document.querySelectorAll('[class="page"]').forEach(page => {
	removeFromParent(page);	//used for the page title
});
//ids.bodydiv.style.paddingLeft = '200px';	//make this match the menu width
ids.bodydiv.style.width = '100%';

//const gnuplot = new Gnuplot("gnuplot-JS/gnuplot.js");

const lua = new EmbeddedLuaInterpreter({
	packages : [
		'dkjson',
		'template',
		'ext',
		'parser',
		'langfix',
		'bignumber',
		'complex',
		'gnuplot',
		'symmath',
	],
	packageTests : [
		'symmath'
	],
	autoLaunch : true,
	done : function() {
console.log('removing loading');
		removeFromParent(ids.loading);

		this.print = s => {console.log(s);};
		this.printErr = s => {console.log(s);};

		const server = new EmulatedServer();

		//load the standalone.lua equiv in pure js
		server.onLuaInit(this);
		//TODO maybe put everything in this function inside here?

		// mkdir where to store the user worksheets
		//FS.mkdir('user-worksheets');

		// copy premade worksheets into the folder ... or not? or only if there's no local storage? or idk? a locak storage flag for initializing them?
		// or put them in their own folder ?
		// then copy local storage worksheets that the user has made

		// TODO replace this with lua-packages.js
		const worksheets = luaVmPackageInfos.symmath.tests.map(info => {
			if (info.dest.substr(0,14) != 'symmath/tests/') throw "expected all test file prefixes to start with symmath/tests/ but found "+info.dest;
			return info.dest.substr(14);
		}).filter(fn => {
			return fn.substring(fn.length-8) == '.symmath';
		}).map(fn => {
			return fn.substring(0, fn.length-8);
		});
		worksheets.sort();

		//init on the standalone html frontend to symmath
		// TODO give it an object?  so its not just a global?
		server.fwdInit({
			server : server,
			root : ids.bodydiv,
			done : () => {
				const worksheetDiv = document.querySelector('[class="worksheetDiv"]');
				worksheetDiv.style.padding = '10px';
				worksheetDiv.style.marginRight = '10px';
			},
			worksheets : worksheets,
			worksheetFilename : initArgs.worksheetFilename,
			symmathPath : initArgs.symmathPath,
			disableQuit : true,	// no need to quit in js ...
		});
	},
});

};
export {init};
