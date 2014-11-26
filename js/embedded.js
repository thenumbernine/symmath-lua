/*
args: 
	callback = what to execute
	output = where to redirect output
	error = where to redirect errors
*/
var interpretter;
var capture = function(args) {
	oldPrint = interpretter.print;
	oldError = interpretter.printErr;
	var oldPrint = interpretter.print;
	var oldError = interpretter.printErr;
	if (args.output !== undefined) interpretter.print = args.output;
	if (args.error !== undefined) interpretter.printErr = args.error;
	args.callback();
	interpretter.print = oldPrint;
	interpretter.printErr = oldError;
}

var nextID = 1;

var SymLuaEmbeddedLuaInterpreter = makeClass({
	super : EmbeddedLuaInterpreter,
	print : function(s) {
		this.printOutAndErr(s);
	},
	printErr : function(s) {
		this.printOutAndErr(s);
	},
	printOutAndErr : function(s) {
		if (s[0] !== '<' && s[s.length-1] !== '>') {
			if (s.substr(0,2) !== '\\(' && s.substr(-2) !== '\\)') {
				if (this.output.html() !== '') s += '\n';
			}
		}
		s.replace(/\n/g, '<br>');
		this.mjid = (this.mjid || 0) + 1;
		var mjid = ''+this.mjid;
		var div = $('<div>', {
			id : mjid,
			html : s
		}).appendTo(this.output);	
		this.output.append(div);
		MathJax.Hub.Queue(["Typeset", MathJax.Hub, mjid]);
		this.output.scrollTop(99999999);
	},
	//add in the [Output] for viewing cached LaTeX output
	createDivForTestRow : function(info) {
		var div = SymLuaEmbeddedLuaInterpreter.superProto.createDivForTestRow.apply(this, arguments);
		var lastSlash = info.url.lastIndexOf('/');
		assert(lastSlash !== -1);
		var path = info.url.substr(0, lastSlash+1);
		var filename = info.url.substring(lastSlash+1, info.url.length-4);
		$('<a>', {
			href : 'test-output/' + filename + '.html',
			text : '[Output]',
			target : '_blank',
			css : {'margin-right' : '10px'}
		}).insertAfter(div.children().get(0));
		return div;
	}
});

interpretter = new SymLuaEmbeddedLuaInterpreter({
	id : 'lua-vm-container',
	packages : ['ext', 'symmath', 'tensor'],
	packageTests : ['symmath'],
	autoLaunch : true,
	done : function() {
		Lua.execute(mlstr(function(){/*
-- META!!! This is Lua code interpretted in JavaScript embedded in HTML served from a Lua server
LUA_IN_HTML = true -- maybe this should set in lua.vm-util.js 
package.path = package.path .. ';./?/init.lua'
symmath = require 'symmath'
do
	local MathJax = require 'symmath.tostring.MathJax'
	symmath.tostring = MathJax
	MathJax.header = ''
end
*/}));
		{
			Lua.execute(mlstr(function(){/*
--[[ hide symmath, and don't allow scripts to change ToStringMethod from MathJax
do
	local oldsymmath = symmath
	local newsymmath = {}
	_G.symmath = symmath
	package.loaded.symmath = newsymmath
	setmetatable(newsymmath, {
		__index = function(self, key)
			return oldsymmath[key]
		end,
		__newindex = function(self, key, value)
			if key == 'tostring' then return end
			oldsymmath[key] = value
		end,
	})
end
--]]
*/}));
		}
		var open = $.url().param('open');
		if (open !== undefined) {
			this.executeAndPrint("dofile '" + open + "'");
			this.print('<br>');
		}

		var execute = $.url().param('execute');
		if (execute !== undefined) {
			this.executeAndPrint(execute);
			this.print('<br>');
		}
	}
});


