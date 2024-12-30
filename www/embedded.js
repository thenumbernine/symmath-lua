import {EmbeddedLuaInterpreter} from '/js/lua.vm-util.js';
import {DOM} from '/js/util.js';
const urlparams = new URLSearchParams(window.location.search);

/*
args: 
	callback = what to execute
	output = where to redirect output
	error = where to redirect errors
*/
let interpretter;
let capture = function(args) {
	oldPrint = interpretter.print;
	oldError = interpretter.printErr;
	let oldPrint = interpretter.print;
	let oldError = interpretter.printErr;
	if (args.output !== undefined) interpretter.print = args.output;
	if (args.error !== undefined) interpretter.printErr = args.error;
	args.callback();
	interpretter.print = oldPrint;
	interpretter.printErr = oldError;
}

let nextID = 1;

const insertAfter = (node, sibling) => {
	sibling.parentNode.insertBefore(node, sibling.nextSibling);
};

// this is also in symmath/server/standalone.js ...
// https://docs.mathjax.org/en/latest/web/typeset.html#typeset-async
// new MathJax is a bit more restrictive of how to handle concurrent rendering ...
function typeset(code) {
	MathJax.startup.promise = MathJax.startup.promise
		.then(() => MathJax.typesetPromise(code()))
		.catch((err) => console.log('Typeset failed: ' + err.message));
	return MathJax.startup.promise;
}

class SymLuaEmbeddedLuaInterpreter extends EmbeddedLuaInterpreter {
	print(s) {
		this.printOutAndErr(s);
	}
	printErr(s) {
		this.printOutAndErr(s);
	}
	printOutAndErr(s) {
		if (s[0] !== '<' && s[s.length-1] !== '>') {
			if (s.substr(0,2) !== '\\(' && s.substr(-2) !== '\\)') {
				if (this.output.innerHTML !== '') s += '\n';
			}
		}
		s.replace(/\n/g, '<br>');
		// TODO still needed? .mjid is also in symmath/server/standalone.js
		this.mjid = (this.mjid || 0) + 1;
		let mjid = ''+this.mjid;
		let div = DOM('div', {
			html : s,
			appendTo : this.output,
		});
		this.output.append(div);
		typeset(() => [div]);
		window.scrollTo(0, document.body.scrollHeight);
	}
	//add in the [Output] for viewing cached LaTeX output
	createDivForTestRow(info) {
		let div = super.createDivForTestRow.apply(this, arguments);
		let url = unescape(info.url);
		let localPath = url.replace( /\/symbolic-lua\/src\/tests\/(.*)\.lua/, '/symbolic-lua/src/tests/output/$1.html');
		const a = DOM('a', {
			href : localPath,
			text : '[Output]',
			target : '_blank',
			css : {'margin-right' : '10px'},
		});
		insertAfter(a, div.children[0]);
		return div;
	}
}

interpretter = new SymLuaEmbeddedLuaInterpreter({
	//id : 'lua-vm-container',
	packages : ['ext', 'gnuplot', 'symmath'],
	packageTests : ['symmath'],
	autoLaunch : true,
	done : function() {
		interpretter.execute(`
-- META!!! This is Lua code interpretted in JavaScript embedded in HTML served from a Lua server
LUA_IN_HTML = true -- maybe this should set in lua.vm-util.js 
require 'symmath'.setup{implicitVars=true, MathJax={header=''}}
`);
		let open = urlparams.get('open');
		if (open !== undefined) {
			this.executeAndPrint("dofile '" + open + "'");
			this.print('<br>');
		}

		let execute = urlparams.get('execute');
		if (execute !== undefined) {
			this.executeAndPrint(execute);
			this.print('<br>');
		}
	},
});
