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
assert(filename, "expected a filename")

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
	self.outputtype = 'html'
end


local SymmathHTTP = class(HTTP)

function SymmathHTTP:init(...)
	SymmathHTTP.super.init(self, ...)
	-- TODO here, determine the url or something, and ask the OS to open it
	os.execute('open http://localhost:'..self.port)


	self:setupSandbox()


	-- single worksheet instance.  TODO make modular:
	self.cells = table()
	if filename then
		local data = file[filename]
		print('file', filename,' has data ', data)
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

	local orig_io = require 'io'

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
		self.env.io.write'\n'
		self.env.io.flush()
	end
	--]]

	symmath.setup{env=self.env, implicitVars=true, fixVariableNames=true}
	symmath.tostring = symmath.export.MathJax
end


function SymmathHTTP:readCellsFromData(data)
	self.cells = table(require 'ext.fromlua'(data)):mapi(function(cell)
		-- TODO if i don't refresh the uid then there's a chance a new one could overlap an old one?
		-- or TODO just use the max as the last uid, and keep increasing?
		return setmetatable(cell, Cell)
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

function SymmathHTTP:save()
	self:writeCellsToFile(filename)
end

function SymmathHTTP:handleRequest(...)
	local filename,
		headers,
		reqHeaders,
		method,
		proto,
		GET,
		POST = ...
		
	local gt = self:makeGETTable(GET)

	local function getCellForUID()
		local uid = assert(tonumber(gt.uid))
		local _, cell = self.cells:find(nil, function(cell) 
			return cell.uid == uid 
		end)
		return assert(cell, "failed to find cell with uid "..uid)
	end

	if filename == '/getcells' then
		local cellsjson = json.encode(self.cells)
print("getcells returning "..cellsjson)
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(cellsjson)
		end)
	elseif filename == '/newcell' then
print("GET "..GET)
print("adding new cell at "..gt.pos)
		self.cells:insert(assert(tonumber(gt.pos)), Cell())
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/remove' then
		local uid = assert(tonumber(gt.uid))
		assert(self.cells:removeObject(nil, function(cell) return cell.uid == uid end))
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/run' then
		-- re-evaluate the cell
		local cell = getCellForUID()
		cell.input = assert(gt.input)
		self.env.io.stdout.buffer = ''
		assert(load(cell.input, nil, nil, self.env))()
		cell.output = self.env.io.stdout.buffer
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(json.encode(cell))
		end)
	elseif filename == '/setoutputtype' then
		local cell = getCellForUID()
		cell.outputtype = assert(gt.outputtype)
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield(json.encode(cell))
		end)
	elseif filename == '/' then
		return '200/OK', coroutine.wrap(function()
			coroutine.yield[[
<html>
	<head>
		<title>Symmath Worksheet</title>
		<!-- TODO where to put these files? and where should the cwd be? -->
		<!-- maybe set a SYMMATH_STANDALONE_SERVER_ROOT env var and put them there? -->
		<script type="text/javascript" src="output/jquery-1.11.1.min.js"></script>
		<script type="text/javascript" src="output/tryToFindMathJax.js"></script>
		<script type="text/javascript">

var mjid = 0;
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
			var run = function() {
				$.ajax({
					url : "run?uid="+cell.uid+"&input="+textarea.val()
				}).done(refresh)
				.fail(fail);
			}

			var textarea = $('<textarea>', {
				css : {width:'100%'},
				text : cell.input
			});
			textarea.attr('rows', 5);
			textarea.keydown(function(e) {
				if (e.keyCode == 13 && e.ctrlKey) {
					e.preventDefault();
					run();
				}
			});

			$(document.body).append(textarea);
			$(document.body).append($('<br>'));
			//TODO here dropdown for what kind of output it is: text, LaTex, HTML 
			$(document.body).append($('<button>', {
				text : 'run',
				click : run
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
			var setoutputtype = $('<select>', {
				html : $.map(['text', 'html', 'latex'], function(s,i) {
					return '<option>'+s+'</option>'
				}).join(''),
				change : function(e) {
					var val = this.value;
					$.ajax({
						url : "setoutputtype?uid="+cell.uid+"&outputtype="+val
					}).done(refresh)
					.fail(fail);
				}
			});
			setoutputtype.val(cell.outputtype);
			$(document.body).append(setoutputtype);
			$(document.body).append($('<br>'));
			
			var outputID = 'mj'+(++mjid);
			var output = $('<div>', {
				id : outputID
			});
			output.addClass('symmath-output');
			$(document.body).append(output);

			if (cell.outputtype == 'html') {
				output.html(cell.output);
				MathJax.Hub.Queue(["Typeset", MathJax.Hub, outputID]);

			//should there even be a 'latex' type? or just 'html' and mathjax?
			} else if (cell.outputtype == 'latex') {
				output.html(cell.output);
				MathJax.Hub.Queue(["Typeset", MathJax.Hub, outputID]);
			
			} else {
				var outputstr = cell.output;
				if (cell.outputtype != 'text') {
					outputstr = 'UNKNOWN OUTPUT TYPE: '+cell.outputtype+'\n';
				}
				output.append($('<pre>', {text : outputstr}));
			}

		}
console.log("cells", cells);
console.log("cells.length "+cells.length);
		$.each(cells, function(i,cell) {
			addNewCellButton(i+1);
			$(document.body).append($('<br>'));
			addCell(cell);
		});
		addNewCellButton(cells.length+1);
	});
}

function fail() {
	console.log(arguments);
	throw 'failed';
}

$(document).ready(function() {
	tryToFindMathJax({
		done : refresh,
		fail : fail
	});
});

		</script>
		<style>
.symmath-output {
	margin: 10px solid grey;
	padding: 10px;
}
		</style>
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
