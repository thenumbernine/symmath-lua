--[[
here's the standalone version that runs an instance of my lua-http server
while simultaneously keeping track of its own symmath state
--]]

local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local file = require 'ext.file'
local HTTP = require 'http.class'
local json = require 'dkjson'

local filename = ...


local symmath = require 'symmath'


local Cell = class()

function Cell:init()
	local mt = getmetatable(self)
	setmetatable(self, nil)
	local uid = tonumber(tostring(self):sub(8), 16)
	setmetatable(self, mt)
	
	self.uid = uid
	self.input = ''
	self.output = ''
end


local SymmathHTTP = class(HTTP)

function SymmathHTTP:init(...)
	SymmathHTTP.super.init(self, ...)
	-- TODO here, determine the url or something, and ask the OS to open it
	os.execute('open http://localhost:'..self.port)


	self.env = {}
	symmath.setup{env=self.env}
	symmath.tostring = symmath.export.MathJax


	-- single worksheet instance.  TODO make modular:
	self.cells = table()
	if filename then
		local data = file[filename]
		if data then
			self:readCellsFromData(data)
		end
	end
end

function SymmathHTTP:readCellsFromData(data)
	self.cells = table(require 'ext.fromlua'(data)):mapi(function(cell)
		-- TODO if i don't refresh the uid then there's a chance a new one could overlap an old one?
		setmetatable(cell, Cell)
	end)
end

function SymmathHTTP:writeCellsToFile(filename)
	file[filename] = require 'ext.tolua'(table(self.cells):mapi(function(cell)
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

function SymmathHTTP:handleFilename(...)
	local filename,
		localfilename,
		ext,
		dir,
		headers,
		reqHeaders,
		POST = ...

	if ext:lower() ~= suffix then
		return SymmathHTTP.super.handleFilename(self, ...)
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

	print('handleRequest'..require 'ext.tolua'{
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

function SymmathHTTP:handleRequest(...)
	local filename,
		headers,
		reqHeaders,
		method,
		proto,
		GET,
		POST = ...
		
	local gt = self:makeGETTable(GET)

	if filename == '/getcells' then
		local cellsjson = json.encode(self.cells)
print("getcells returning "..cellsjson)
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(cellsjson)
		end)
	elseif filename == '/newcell' then
print("GET "..GET)
print("adding new cell at "..gt.pos)
		self.cells:insert(assert(gt.pos), Cell())
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/remove' then
		local uid = assert(gt.uid)
		assert(self.cells:removeObject(nil, function(cell) return cell.uid == uid end))
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/run' then
		-- re-evaluate the cell
		local uid = assert(tonumber(gt.uid))
		local _, cell = self.cells:find(nil, function(cell) 
			return cell.uid == uid 
		end)
		assert(cell, "failed to find cell with uid "..uid)
		cell.input = assert(gt.input)
		cell.output = tostring(assert(load(cell.input, nil, nil, self.env))())
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(json.encode(cell))
		end)
	elseif filename == '/' then
		return '200/OK', coroutine.wrap(function()
			coroutine.yield[[
<html>
	<head>
		<title>Symmath Worksheet</title>
		<script type="text/javascript" src="jquery-1.11.1.min.js"></script>
		<script type="text/javascript">

function refresh() {
	$.ajax({
		url : "getcells"
	})
	.fail(fail)
	.done(function(cellsjson) {
console.log("getcells got", arguments);
		var cells = $.parseJSON(cellsjson);
		document.body.innerHTML = '';
		var addNewCellButton = function(pos) {
			$(document.body).append($('<button>', {
				text : '+',
				click : function() {
					$.ajax({
						url : "newcell?pos="+pos
					}).done(refresh)
					.fail(fail);
				}
			}));
			$(document.body).append($('<br>'));
		};
		var addCell = function(cell) {
			var textarea = $('<textarea>', {
				text : cell.input
			});
			$(document.body).append(textarea);
			$(document.body).append($('<br>'));
			//TODO here dropdown for what kind of output it is: text, LaTex, HTML 
			$(document.body).append($('<button>', {
				text : 'run',
				click : function() {
					$.ajax({
						url : "run?uid="+cell.uid+"&input="+textarea.val()
					}).done(refresh)
					.fail(fail);
				}
			}));
			$(document.body).append($('<button>', {
				text : '-',
				click : function() {
					$.ajax({
						url : "remove?uid="+cell.uid
					}).done(refresh)
					.fail(fail);
				}
			}));
			$(document.body).append($('<br>'));
			$(document.body).append($('<div>', {
				style : {border:'1px solid black'},
				html : cell.output
			}));
			//TODO here queue the MathJax for rendering ... if it is LaTeX output
		}
console.log("cells", cells);
console.log("cells.length "+cells.length);
		$.each(cells, function(i,cell) {
			addNewCellButton(i+1);
			addCell(cell);
		});
		addNewCellButton(cells.length+1);
	});
}

function fail() {
	console.log(arguments);
	throw 'failed';
}

$(document).ready(refresh);

		</script>
	</head>
	<body>
	</body>
</html>
]]
		end)
	else
		return SymmathHTTP.super.handleRequest(self, ...)
	end
end

SymmathHTTP():run() 
