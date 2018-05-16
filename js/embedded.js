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
		var localPath = info.url.replace( /\/symbolic-lua\/src\/tests\/(.*)\.lua/, 'test-output/$1.html');
		$('<a>', {
			href : localPath,
			text : '[Output]',
			target : '_blank',
			css : {'margin-right' : '10px'}
		}).insertAfter(div.children().get(0));
		return div;
	}
});

interpretter = new SymLuaEmbeddedLuaInterpreter({
	id : 'lua-vm-container',
	packages : ['ext', 'gnuplot', 'symmath'],
	packageTests : ['symmath'],
	autoLaunch : true,
	done : function() {
		interpretter.execute(mlstr(function(){/*
-- META!!! This is Lua code interpretted in JavaScript embedded in HTML served from a Lua server
LUA_IN_HTML = true -- maybe this should set in lua.vm-util.js 
require 'symmath'.setup{implicitVars=true, MathJax={header=''}}
*/}));
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
