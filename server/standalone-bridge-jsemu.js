// local / emulated lua in javascript ?

function EmulatedServer() {
}
EmulatedServer.prototype = {
	onLuaInit : function() {

		//similar code in metric and symbolic-lua
		//maybe superclass?
		lua.capture = function(args) {
			var oldPrint = lua.print;
			var oldError = lua.printErr;
			if (args.output !== undefined) lua.print = args.output;
			if (args.error !== undefined) lua.printErr = args.error;
			args.callback();
			lua.print = oldPrint;
			lua.printErr = oldError;
		};

console.log("outputBuffer", lua.outputBuffer);
lua.outputBuffer = '';

console.log("executing lua and defining global symmathhttp")
		lua.execute(mlstr(function(){/*

-- embedded-javascript version of standalone.lua
-- TODO superclass some of this with standalone.lua ?

-- for emscripten, store this as a global
orig_print = print

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
local file = require 'ext.file'
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
			if i > 1 then self.env.io.write'\t' end
			self.env.io.write(tostring((select(i, ...))))
		end
		self.env.io.write(currentBlockNewLineSymbol or '\n')
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
		cell.outputtype == 'html' and '<br>\n'
		or '\n'
	
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
			findlhs = findlhs:gsub('%-%-[^\r\n]*', '')
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
			-- if we returned anything from this block then print it -- just like lua interpreter
			-- TODO in this case ... who should handle the error?
			if #cell.output > 0 then
				cell.output = cell.output .. currentBlockNewLineSymbol
			end
			for i=1,results.n do
				if i > 1 then
					cell.output = cell.output .. '\t'
				end
				cell.output = cell.output .. tostring(
					results[i]
				)
			end
		end
	
	end, function(err)
		self:log(0, 'got error '..err)
		cell.output = err..'\n'..debug.traceback()
		cell.haserror = true	-- use this flag to override the output type, so that when the error goes away the output will go back to what it was
	end)
end

-- in standalone.lua these commands are handled in handleRequsts()

-- global:
symmathhttp = SymmathHTTP()

*/}));

console.log("querying global symmathhttp")
		lua.execute("orig_print(symmathhttp)");
console.log("outputBuffer", lua.outputBuffer);
lua.outputBuffer = '';

	},

	nextValidUID : 1,

	getCellForUID : function(uid) {
		var ctrl = findCtrlForUID(uid);
		if (!ctrl) return;
		return ctrl.cell;
	},

	/*
	args:
		done : function(cellsjson)
		fail
	*/
	getCells : function(args) {
		args.done(JSON.stringify(cells));
	},

	/*
	args:
		uid
		outputtype
		done
		fail
	*/
	setOutputType : function(args) {
		var cell = this.getCellForUID(args.uid);
		if (!cell) args.fail();
		cell.outputtype = args.outputtype;
		args.done(JSON.stringify(cell));
	},

	/*
	args:
		uid
		done
		fail
	*/
	remove : function(args) {
		//callback is going to remove the js cell anyways, so
		args.done();
	},

	encodeString : function(s) {
		// TODO search for the # of ='s that isn't used in the string
		return '[=======[' + s + ']=======]';
	},

	/*
	args:
		uid,
		cellinput,
		done
		fail
	*/
	run : function(args) {
		var thiz = this;
		var cell = this.getCellForUID(args.uid);
		cell.input = args.cellinput;
		//here's where the lua interpretter comes in

		
		var output = '';
		lua.capture({
			callback : function() {
				lua.execute(
				""
				+ "currentRunningCell = {"
				+ "	uid=" + cell.uid + ",\n"
				+ "	input=" + thiz.encodeString(cell.input) + ",\n"
				+ "	output='',\n"
				+ "	outputtype=" + thiz.encodeString(cell.outputtype) + ",\n"
				+ "	hidden=" + (cell.hidden ? "true" : "false") + "\n"
				+ "}\n"
				+ "symmathhttp:runCell(currentRunningCell)\n"
				+ "orig_print(currentRunningCell.output)\n"
				);
			},
			output : function(s) {
				s += '\n';
console.log("output", s);
				output += s;
			},
			error : function(s) {
				//I don't' think this is ever hit
				s += '\n';
console.log("error", s);
				output += s;
			}
		});
		cell.output = output;
	
		lua.capture({
			callback : function() {
				lua.execute("orig_print(currentRunningCell.haserror and 'true' or 'false')");
			},
			output : function(s) {
console.log("haserror?", s);
				cell.haserror = s == 'true';
			}
		});
		
		args.done(JSON.stringify(cell));
	},

	/*
	args:
		uid
		hidden
	*/
	setHidden : function(args) {
		var cell = this.getCellForUID(args.uid);
		if (!cell) (args.fail || fail)();
		cell.hidden = args.hidden;
		if (args.done) args.done();
	},

	/*
	args:
		uid (optional) cell to insert before
		done : function(celljson),
		fail
	*/
	newCell : function(args) {
		//make sure this matches standalone.lua's Cell ctor
		args.done(JSON.stringify({
			uid : ++this.nextValidUID,
			input : '',
			output : '',
			outputtype : 'html',
			hidden : false
		}));
	},

	/*
	args:
		(don't pass cells, i'll just read from the global)
		done
		fail
	*/
	writeCells : function(args) {
		args.done();
	},

	/*
	args:
		done
		fail
	*/
	save : function(args) {
		args.done();
	},

	quit : function() {
	}
};

server = new EmulatedServer();
