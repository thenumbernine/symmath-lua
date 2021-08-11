#!/usr/bin/env lua
--[[
here's the standalone version that runs an instance of my lua-http server
while simultaneously keeping track of its own symmath state
the full version would ideally be separate of this, launch one of these per worksheet, and be able to interrupt and reset execution.
--]]

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
local HTTP = require 'http.class'
local json = require 'dkjson'

local worksheetFilename = ...
assert(worksheetFilename, "expected a filename")


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

local Cell = class()

function Cell:init()
	self.uid = nextValidUID
	nextValidUID = nextValidUID + 1

	self.input = ''
	self.output = ''
	self.outputtype = 'html'
	self.hidden = false
end


local SymmathHTTP = class(HTTP)

function SymmathHTTP:init(args)

-- [[
args = table(args):setmetatable(nil)
args.log = 10
--]]

	SymmathHTTP.super.init(self, args)

	self.worksheetFilename = worksheetFilename 

	-- TODO here, determine the url or something, and ask the OS to open it
	-- one of these should work ... not both, right?
	-- TODO non-ffi windows detect plz?
	if string.trim(io.readproc'uname':lower()) == 'linux' then
		os.execute('xdg-open http://localhost:'..self.port)
	else
		os.execute('open http://localhost:'..self.port)
	end
	
	-- docroot is already set to cwd by parent class
	self.symmathPath = assert(os.getenv'SYMMATH_PATH', 'SYMMATH_PATH not defined')
	self.symmathPath = self.symmathPath:gsub(os.sep, '/')

	self:setupSandbox()


	-- single worksheet instance.  TODO make modular:
	self.cells = table()
	if self.worksheetFilename then
		local data = file[self.worksheetFilename]
		self:log(5, 'file', self.worksheetFilename,' has data ', data)
		if data then
			self:readCellsFromData(data)
		end
	end
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


-- this is only called by the server upon loading data
-- so it is safe to mess with the 'nextValidUID'
function SymmathHTTP:readCellsFromData(data)
	nextValidUID = 0
	self.cells = table(fromlua(data)):mapi(function(cell)
		nextValidUID = math.max(nextValidUID, cell.uid)
		-- TODO if i don't refresh the uid then there's a chance a new one could overlap an old one?
		-- or TODO just use the max as the last uid, and keep increasing?
		return setmetatable(cell, Cell)
	end)
	nextValidUID = nextValidUID + 1
end

function SymmathHTTP:writeCellsToFile(filename)
	file[filename] = tolua(table(self.cells):mapi(function(cell)
		return table(cell):setmetatable(nil)
	end):setmetatable(nil))
end

--[===[ directory interaction and multiple editing files would be nice eventually ...
-- ... but for now, one at a time, and 1-1 with symmath lua state

function SymmathHTTP:handleDirectoryTemplate()
	local code = SymmathHTTP.super.handleDirectoryTemplate(self)
	-- TODO a better way?  I guess encode the dom as a tree ... 
	-- am I reinventing kepler project?
	code = code:gsub('</head>', [[
		<script type="text/javascript">
function addnewworksheet() {
	var name = prompt("what's the name?");
	if (name === null) return;
	
	// TODO ajax request to a url that the server interprets as 'create a doc'
	location.href = "createnew?name="+name;
}
		</script>
	</head>
]])
	code = code:gsub('<table>', [[
	<button onclick="addnewworksheet()">Add New Worksheet</button><br>
	<table>
]])
	return code
end

local suffix = 'symmath'

function SymmathHTTP:handleFile(...)
	local filename,
		localfilename,
		ext,
		dir,
		headers,
		reqHeaders,
		POST = ...

	if ext:lower() ~= suffix then
		return SymmathHTTP.super.handleFile(self, ...)
	end

	return '200/OK', coroutine.wrap(function()
		coroutine.yield'you are here'
	end)
end

function SymmathHTTP:handleRequest(...)
	local filename,
		headers,
		reqHeaders,
		method,
		proto,
		GET,
		POST = ...

	-- TODO ajax/json response
	if filename == '/createnew' then
		local gt = self:makeGETTable(GET)
		local name = assert(gt.name)
		-- force extension? TODO only do this if it wasn't given a (dif) extension?
		if not name:match(string.patescape('.'..suffix)..'$') then
			name = name .. '.' .. suffix
		end
		local destfn = self.docroot .. filename .. '/' .. name
		if os.fileexists(destfn) then
			return '404 Not Found', coroutine.wrap(function() coroutine.yield"file already exists" end)
		end
	
		-- TODO make the file here
		-- then open it for editing
		-- then launch an instance associated with it
		-- blah blah blah
	end

	print('handleRequest'..tolua{
		filename = filename,
		headers = headers,
		reqHeaders = reqHeaders,
		method = method,
		proto = proto,
		GET = GET,
		POST = POST,
	})
	
	return SymmathHTTP.super.handleRequest(self, ...)
end
--]===]

function SymmathHTTP:save()
	self:writeCellsToFile(self.worksheetFilename)
end

function SymmathHTTP:getCellForUID(gt, POST)
	local uid = assert(tonumber(gt.uid or POST.uid))
	local cellIndex, cell = self.cells:find(nil, function(cell) 
		return cell.uid == uid 
	end)
	assert(cell, "failed to find cell with uid "..uid)
	-- switch k,v to v,k
	return cell, cellIndex
end

function SymmathHTTP:updateAllCells(POST)
	if not POST then
		error("expected POST, got "..tolua(POST))
	end
	-- save any updates to text not yet saved by 'run' or 'remove' or 'add'
	local newcells = json.decode(POST.cells)
	if not newcells then
		error("expected POST cells field, got "..tolua(POST))
	end
	self:log(2, 'updateAllCells got '..tolua(newcells))	
	
	nextValidUID = 0
	for _,cell in ipairs(newcells) do
		nextValidUID = math.max(nextValidUID, cell.uid)
		setmetatable(cell, Cell)
	end
	nextValidUID = nextValidUID + 1
	self.cells = newcells
	setmetatable(self.cells, table)
end

--[[
runs the cell
captures any output produced by print() or io.write() global calls
in case the cell contains an expression, also adds to the output the tostring() of the expression
in case the cell is an assignment, also adds to the output the tostring() of the lhs of the assignment

ok now how about interrupting?
to prevent runaway loops, I should add a way to interrupt execution to the gui.
this also means keeping a separate lua instance as an intermediate to all the commands.
this would also double for a webserver that handles directory listings.

so you've got the main process that 
- handles directories,
- opens files
- handles ajax requests

and, upon opening a file, it spawns a new process per file being opened, and relays cell input and output to that process
so that separate process holds the state.
this way that sub-process' lua env can get as muddied as the script wants ,and the main process lua env can be safe.

so about preventing runaway loops ...
default lua interperter overrides SIGINT during dofile->dochunk->docall operations.
only once.
and after being interrupted once, any subsequent interrupt calls will kill the whole process.
seems dangerous.
seems like I might have to interject my own signal handler as soon as the docall() code stars, which is entirely possible and straightforward:
  
default:

	docall() {
		...
	  setsignal(SIGINT, laction);  /* set C-signal handler */
		...
	}

	static void laction (int i) {
	  int flag = LUA_MASKCALL | LUA_MASKRET | LUA_MASKLINE | LUA_MASKCOUNT;
	  setsignal(i, SIG_DFL); /* if another SIGINT happens, terminate process */
	  lua_sethook(globalL, lstop, flag, 1);
	}

then my replacement, first instructions upon that pcall, call some C code from a require'd .so
to just not reset to the default signal:

	static void laction (int i) {
	  int flag = LUA_MASKCALL | LUA_MASKRET | LUA_MASKLINE | LUA_MASKCOUNT;
	  // *** don't reset the signal handler *** 
	  lua_sethook(globalL, lstop, flag, 1);
	}

Though in some ways maybe it can be fine without messing with signals at all.
because one interrupt per docall should be all I need, right?  assuming that one interrupt does work.
the parent process will just have to keep track of whether it's sent that one SIGINT to the child per docall(), to make sure it doesn't send two and kill the child.
--]]
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

function SymmathHTTP:getSearchPaths()
	return table{
		self.docroot,
		self.symmathPath,
	}
end

function SymmathHTTP:handleRequest(...)
	local filename,
		headers,
		reqHeaders,
		method,
		proto,
		GET,
		POST = ...
	self:log(2, 'SymmathHTTP.handleRequest', filename)
		
	local gt = self:makeGETTable(GET)

	-- TODO trap all errors and return any error back 
	-- TODO more modular, client and server response in same lua object
	-- TODO load function?  for reloading from last save?
	-- TODO run-all?  and run-from-location, and run-until-location?
	-- TODO save height of textarea in the file

	-- ok jquery ajax post is a mess
	-- it encodes data weird
	-- and if you don't provide 'data' and do ask for 'post' then it stalls indefinitely

	if filename == '/writecells' then
		self:updateAllCells(POST)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/save' then	-- assumes cells are already up to date
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/getcells' then
		local cellsjson = json.encode(self.cells)
		self:log(5, "getcells returning "..cellsjson)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(cellsjson)
		end)
	elseif filename == '/newcell' then
		self:log(2, "adding new cell before "..(gt.uid or 'end'))
		local newcell = Cell()
		
		if gt.uid then
			local _, pos = self:getCellForUID(gt, nil)
			self.cells:insert(pos, newcell)
		else
			self.cells:insert(newcell)
		end

		return '200/OK', coroutine.wrap(function()
			coroutine.yield(json.encode(newcell))
		end)
	elseif filename == '/remove' then
		local uid = assert(tonumber(gt.uid))
		assert(self.cells:removeObject(nil, function(cell) return cell.uid == uid end))
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/run' then
		-- re-evaluate the cell
		local cell = self:getCellForUID(gt, POST)
		cell.input = assert(POST.cellinput)
			:gsub('\r\n', '\r')
			:gsub('\r', '\n')
		self:runCell(cell)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(json.encode(cell))
		end)
	elseif filename == '/setoutputtype' then
		local cell = self:getCellForUID(gt, POST)
		cell.outputtype = assert(gt.outputtype)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(json.encode(cell))
		end)
	elseif filename == '/sethidden' then
		local cell = self:getCellForUID(gt, POST)
		cell.hidden = fromlua(gt.hidden)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/quit' then
		-- hmm, guess we won't be sending a response
		-- unless I add coroutines threadmanager and have some idle loop / timeout, and run exit() in there ...
		os.exit()
	elseif filename == '/newworksheet' then
		self.cells = table()
		self:setupSandbox()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/resetenv' then
		self:setupSandbox()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/getworksheet' then
		self:log(5, "getworksheet "..gt.filename)
	
		-- TODO search dir based on symmath dir
		local data = assert(file[self.symmathPath..'/'..gt.filename])
		data = assert(fromlua(data))
		local cellsjson = json.encode(data)
		self:log(5, "getworksheet returning "..cellsjson)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(cellsjson)
		end)
	elseif filename == '/' then
		return '200/OK', coroutine.wrap(function()
			-- TODO this is also accessible as its filename, so ... ? 
			coroutine.yield(
				template(
					-- TODO just call this 'index.html.lua' , but index to what, considering it is in a separate search path.
					file[self.symmathPath..'/server/standalone.html.lua'],
					self
				)
			)
		end)
	else
		self:log(2, 'calling SymmathHTTP.super.handleRequest')
		return SymmathHTTP.super.handleRequest(self, ...)
	end
end

SymmathHTTP():run() 
