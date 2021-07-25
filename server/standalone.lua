--[[
here's the standalone version that runs an instance of my lua-http server
while simultaneously keeping track of its own symmath state
the full version would ideally be separate of this, launch one of these per worksheet, and be able to interrupt and reset execution.
--]]

local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local file = require 'ext.file'
local os = require 'ext.os'
local tolua = require 'ext.tolua'
local fromlua = require 'ext.fromlua'
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


local Cell = class()

function Cell:init()
	local mt = getmetatable(self)
	setmetatable(self, nil)
	local uid = tonumber(tostring(self):sub(8), 16)
	setmetatable(self, mt)
	
	self.uid = uid
	self.input = ''
	self.output = ''
	self.outputtype = 'html'
	self.hidden = false
end


local SymmathHTTP = class(HTTP)

function SymmathHTTP:init(args)

args = table(args):setmetatable(nil)
args.log = 10

	SymmathHTTP.super.init(self, args)

	-- TODO here, determine the url or something, and ask the OS to open it
	os.execute('open http://localhost:'..self.port)

	
	-- docroot is already set to cwd by parent class
	self.symmathPath = assert(os.getenv'SYMMATH_PATH', 'SYMMATH_PATH not defined')
	self.symmathPath = self.symmathPath:gsub(os.sep, '/')

	self:setupSandbox()


	-- single worksheet instance.  TODO make modular:
	self.cells = table()
	if worksheetFilename then
		local data = file[worksheetFilename]
		print('file', worksheetFilename,' has data ', data)
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


function SymmathHTTP:readCellsFromData(data)
	self.cells = table(fromlua(data)):mapi(function(cell)
		-- TODO if i don't refresh the uid then there's a chance a new one could overlap an old one?
		-- or TODO just use the max as the last uid, and keep increasing?
		return setmetatable(cell, Cell)
	end)
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
	self:writeCellsToFile(worksheetFilename)
end

function SymmathHTTP:getCellForUID(gt, POST)
	local uid = assert(tonumber(gt.uid or POST.uid))
	local _, cell = self.cells:find(nil, function(cell) 
		return cell.uid == uid 
	end)
	return assert(cell, "failed to find cell with uid "..uid)
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
print('updateAllCells got '..tolua(newcells))	
	for _,cell in ipairs(newcells) do
		setmetatable(cell, Cell)
	end
	self.cells = newcells
	setmetatable(self.cells, table)
end

function SymmathHTTP:runCell(cell)
	print('running...')
print(require 'template.showcode'(cell.input))
	self.env.io.stdout.buffer = ''
	cell.haserror = nil
	
	-- TODO use this in cell env print() and io.write()
	currentBlockNewLineSymbol = 
		cell.outputtype == 'html' and '<br>\n'
		or '\n'
	
	xpcall(function()

		-- put a ; at the end to suppress assignment output.  sound familiar?
		local suppressOutput = cell.input:sub(-1) == ';'
print('suppressOutput = ', suppressOutput) 
		
		local results
				
		-- first try loading the code with 'return ' in front - just like lua interpreter
		-- but don't if we are suppressing output -- because the 'return' is only used for just that
		if not suppressOutput then
			xpcall(function()
				results = table.pack(assert(load('return '..cell.input, nil, nil, self.env))())
print("run() got a single expression")
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

print("run() found a assign-stmt")
print("lhs = ", lhs)
print("rhs = ", rhs)

				-- if it failed then there's an error in it ... so we want to report the error ...
				-- also we don't need 'results' ... since we're going to get it from the xpcall on lhs
				-- but maybe we should save 'results', since without 'results' it will be run twice as a non-expr, non-assign-stmt ...
				results = table.pack(assert(load(cell.input, nil, nil, self.env))())
print("run() successfully handled assign-stmt")
			
				if not suppressOutput then
					-- try to append the lhs's tostring to the output
					-- hide errors maybe?
					-- since return-stmt and assign-stmt are exclusive in lua (you can't do "return a=b" like C),
					-- ... just assign 'results' here
					xpcall(function()
						results = table.pack(assert(load("return tostring("..lhs..")", nil, nil, self.env))())
print("run() successfully handled tostring(lhs)")
					end, function(err)
					end)
				end
			end
		end

		-- if expression fails, and assign-statement fails, then try without ... in case it's multi-statement
		if not results then
print("run() handling multi-stmt")
			results = table.pack(assert(load(cell.input, nil, nil, self.env))())
		end

		cell.output = self.env.io.stdout.buffer
print("run() cell.output", cell.output)

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
print('got error '..err)
		cell.output = err..'\n'..debug.traceback()
		cell.haserror = true	-- use this flag to override the output type, so that when the error goes away the output will go back to what it was
	end)
end

function SymmathHTTP:getSearchPaths()
	return table{
		self.docroot,
		self.symmathPath..'/server',
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
print('SymmathHTTP.handleRequest', filename)
		
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
print("getcells returning "..cellsjson)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(cellsjson)
		end)
	elseif filename == '/newcell' then
print("GET "..GET)
print("adding new cell at "..gt.pos)
		local newcell = Cell()
		self.cells:insert(assert(tonumber(gt.pos)), newcell)
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
	elseif filename == '/' then
		return '200/OK', coroutine.wrap(function()
			coroutine.yield([[
<html>
	<head>
		<title>Symmath Worksheet - ]]..worksheetFilename..[[</title>
		<script type="text/javascript" src="jquery-1.11.1.min.js"></script>
		<script type="text/javascript" src="tryToFindMathJax.js"></script>
		<script type="text/javascript" src="standalone.js"></script>
		<link rel="stylesheet" href="standalone.css"/>
	</head>
	<body>
		File: ]]..worksheetFilename..[[<br>
		<br>
	</body>
</html>
]])
		end)
	else
print('calling SymmathHTTP.super.handleRequest')
		return SymmathHTTP.super.handleRequest(self, ...)
	end
end

SymmathHTTP():run() 