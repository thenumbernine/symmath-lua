--[[
here's the standalone version that runs an instance of my lua-http server
while simultaneously keeping track of its own symmath state
--]]

local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local file = require 'ext.file'
local tolua = require 'ext.tolua'
local fromlua = require 'ext.fromlua'
local HTTP = require 'http.class'
local json = require 'dkjson'

local filename = ...
assert(filename, "expected a filename")


-- store original _G.print here so this file scope can use it (before overriding it later)
local print = print
local orig_io = require 'io'
local orig_io_write = io.write
local ext_io = require 'ext.io'
local ext_io_write = ext_io.write


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

function SymmathHTTP:init(...)
	SymmathHTTP.super.init(self, ...)
	
	self.loglevel = 10

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
	

	require 'ext.env'(self.env)


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
	self:writeCellsToFile(filename)
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
	xpcall(function()
		assert(load(cell.input, nil, nil, self.env))()
		cell.output = self.env.io.stdout.buffer
	end, function(err)
print('got error '..err)
		cell.output = err..'\n'..debug.traceback()
		cell.haserror = true	-- use this flag to override the output type, so that when the error goes away the output will go back to what it was
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
		
	local gt = self:makeGETTable(GET)

	-- TODO trap all errors and return any error back 
	-- TODO more modular, client and server response in same lua object
	-- TODO load function?  for reloading from last save?
	-- TODO run-all?  and run-from-location, and run-until-location?
	-- TODO save height of textarea in the file

	if filename == '/save' then
		self:updateAllCells(POST)
		self:save()
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
		end)
	elseif filename == '/runall' then
		self:updateAllCells(POST)
		for _,cell in ipairs(self.cells) do
			self:runCell(cell)
		end
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
		self.cells:insert(assert(tonumber(gt.pos)), Cell())
		return '200/OK', coroutine.wrap(function()
			coroutine.yield'{ok:true}'
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
var cells = [];
var ctrls = [];
var worksheetDiv;

function refreshAllCells() {
	$.ajax({
		url : "getcells"
	})
	.fail(fail)
	.done(function(cellsjson) {
console.log("getcells got", arguments);
		
		cells = $.parseJSON(cellsjson);
		ctrls = [];

		worksheetDiv.html('');
		var addNewCellButton = function(pos) {
			worksheetDiv.append($('<button>', {
				text : '+',
				click : function() {
					$.ajax({
						url : "newcell?pos="+pos
					}).done(refreshAllCells)		//TODO only update the newly added cell
					.fail(fail);
				}
			}));
			worksheetDiv.append($('<br>'));
		};
		var addCell = function(cell) {
			var output;
			var refreshOutput = function() {
				var outputtype = cell.outputtype;
				if (cell.haserror) outputtype = 'text';

				if (outputtype == 'html') {
					output.html(cell.output);
					MathJax.Hub.Queue(["Typeset", MathJax.Hub, output.attr('id')]);

				//should there even be a 'latex' type? or just 'html' and mathjax?
				} else if (outputtype == 'latex') {
					output.html(cell.output);
					MathJax.Hub.Queue(["Typeset", MathJax.Hub, output.attr('id')]);
				
				} else {
					output.html('');
					var outputstr = cell.output;
					if (outputtype != 'text') {
						outputstr = 'UNKNOWN OUTPUT TYPE: '+outputtype+'\n';
					}
					output.append($('<pre>', {text : outputstr}));
				}
			};

			var refreshJustThisCell = function(celldata) {
				var newcell = $.parseJSON(celldata);
				cell = newcell;
				for (var i = 0; i < cells.length; ++i) {
					if (cells[i].uid == cell.uid) {
						cells[i] = newcell;
					}
				}
				refreshOutput();
			};

			var run = function() {
				var cellinput = textarea.val();
				$.ajax({
					type : "POST",
					url : "run",
					data : {
						uid : cell.uid,
						cellinput : cellinput
					}
				}).done(function(celldata) {
					//update all?
					//refreshAllCells();
					
					//update only this one?
					refreshJustThisCell(celldata);
				
					//...annddd... select the next cell
console.log("after run response");
console.log("for cell", cell);
					for (var j = 0; j < cells.length-1; ++j) {
						if (cells[j].uid == cell.uid) {
console.log("focusing on next textarea...");
							ctrls[j+1].setHidden(false);
							ctrls[j+1].textarea.focus();
							break;
						}
					}
				})
				.fail(fail);
			}

			var textarea = $('<textarea>', {
				css : {
					width : '100%',
					display : cell.hidden ? 'none' : 'block'
				},
				text : cell.input
			});
			var updateTextAreaLines = function() {
				var numlines = textarea.val().split('\n').length;
				textarea.attr('rows', numlines + 1);
			};
			updateTextAreaLines();
			textarea.keydown(function(e) {
				if (e.keyCode == 9) {
					e.preventDefault();
					var start = this.selectionStart;
					var end = this.selectionEnd;
					var oldval = textarea.val();
					textarea.val(oldval.substring(0, start) + "\t" + oldval.substring(end));
					this.selectionStart = this.selectionEnd = start + 1;				
				} else if (e.keyCode == 13) {
					if (e.ctrlKey) {
						e.preventDefault();
						run();
						return;
					}
				}
				updateTextAreaLines();
			});


			worksheetDiv.append($('<hr>'));
			var setHidden = function(hidden) {
				cell.hidden = !cell.hidden;
				if (cell.hidden) {
					textarea.hide();
				} else {
					textarea.show();
				}
				$.ajax({
					url : "sethidden?uid="+cell.uid+"&hidden="+cell.hidden
				});
			};
			worksheetDiv.append($('<button>', {
				text : 'v',
				click : function() {
					setHidden(!cell.hidden);
				}
			}));
	
			worksheetDiv.append($('<button>', {
				text : 'run',
				click : run
			}));
			
			var setoutputtype = $('<select>', {
				html : $.map(['text', 'html', 'latex'], function(s,i) {
					return '<option>'+s+'</option>'
				}).join(''),
				change : function(e) {
					var val = this.value;
					$.ajax({
						url : "setoutputtype?uid="+cell.uid+"&outputtype="+val
					}).done(function(celldata) {
						//all?
						//refreshAllCells

						//only this cell?
						refreshJustThisCell(celldata);
					})
					.fail(fail);
				}
			});
			setoutputtype.val(cell.outputtype);
			worksheetDiv.append(setoutputtype);
		
			worksheetDiv.append($('<button>', {
				text : '-',
				click : function() {
					$.ajax({
						url : "remove?uid="+cell.uid
					}).done(refreshAllCells)
					.fail(fail);
				}
			}));

			worksheetDiv.append($('<br>'));


			worksheetDiv.append(textarea);
			worksheetDiv.append($('<br>'));


			var outputID = 'mj'+(++mjid);
			output = $('<div>', {
				id : outputID
			});
			output.addClass('symmath-output');
			worksheetDiv.append(output);
			refreshOutput();
		
			ctrls.push({
				cell : cell,
				textarea : textarea,
				setHidden : setHidden
			});
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

function updateAllCellInputs() {
	if (ctrls.length != cells.length) throw "got a mismatch in size between ctrls and cells";
	$.each(ctrls, function(i,ctrl) {
		var cell = ctrl.cell;
		cell.input = ctrl.textarea.val();
	});
}

function init() {
	$(document.body).append($('<button>', {
		text : 'save',
		click : function() {
			updateAllCellInputs();
			//TODO here - disable controls until save is finished
			$.ajax({
				type : "POST",
				url : "save",
				data : {
					cells : JSON.stringify(cells)
				}
			}).done(function() {
				//TODO on done, re-enable page controls
			}).fail(fail);
				//TODO on fail, popup warning and re-enable controls
		}
	}));
	
	$(document.body).append($('<button>', {
		text : 'run all',
		click : function() {
			updateAllCellInputs();
			$.ajax({
				type : "POST",
				url : "runall",
				data : {
					cells : JSON.stringify(cells)	//jquery ajax is choking on encoding nested tables, so ...
				}
			}).done(function() {
				//TODO or just return the 
				refreshAllCells();
			}).fail(fail);
		}
	}));

	$(document.body).append($('<br>'));
	$(document.body).append($('<br>'));

	worksheetDiv = $('<div>', {});
	worksheetDiv.addClass('worksheet');
	$(document.body).append(worksheetDiv);
	$(document.body).append($('<br>'));

	refreshAllCells();
}

$(document).ready(function() {
	tryToFindMathJax({
		done : init,
		fail : fail
	});
});

		</script>
		<style>
.worksheet {
	padding: 10px;
	margin: auto;
	background-color:rgb(240,240,240);
}

.symmath-output {
	padding: 10px;
	margin: 10px solid grey;
	background-color:rgb(255,255,255);
}

textarea, pre {
	-moz-tab-size : 4;
	-o-tab-size : 4;
	tab-size : 4;
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
