//this connects standalone.js with the standalone.lua server
//
//alternatively use the bridge for connecting with lua-in-javascript

import {init, fail, serverBase} from '/server/standalone.js';

function RemoteServer() {
}
RemoteServer.prototype = {
	/*
	args:
		done
		fail
	*/
	getCells : function(args) {
		fetch('getcells')
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		uid
		outputtype
		done
		fail
	*/
	setOutputType : function(args) {
		fetch("setoutputtype?uid="+args.uid+"&outputtype="+args.outputtype)
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		uid
		done
		fail
	*/
	remove : function(args) {
		fetch("remove?uid="+args.uid)
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		uid,
		cellinput,
		done
		fail
	*/
	run : function(args) {
		const data = new FormData();
		data.set('uid', args.uid);
		data.set('cellinput', args.cellinput);
		fetch("run", {
			method : 'POST',
			headers : {
				accept : 'application/json',
				'content-type' : 'application/json',
			},
			body : JSON.stringify({
				uid : args.uid,
				cellinput : args.cellinput,
			}),
		}).then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		uid
		hidden
	*/
	setHidden : function(args) {
		fetch("sethidden?uid="+args.uid+"&hidden="+args.hidden)
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
console.log('sethidden', args.done);
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		uid (optional) cell to insert before
		done,
		fail
	*/
	newCell : function(args) {
		fetch("newcell" + (args.uid !== undefined ? ("?" + args.uid) : ""))
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => {args.fail?.(e); });
	},

	/*
	args:
		(don't pass cells, i'll just read from the global)
		done
		fail
	*/
	writeCells : function(args) {
		fetch("writecells", {
			method : 'POST',
			headers : {
				accept : 'application/json',
				'content-type' : 'application/json',
			},
			body : JSON.stringify({
				cells : JSON.stringify(serverBase.cells)
			}),
		}).then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		done
		fail
	*/
	save : function(args) {
		fetch('save')
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); })
		}).catch(e => { args.fail?.(e); });
	},

	quit : function(args) {
		fetch("quit")
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); })
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		done
		fail
	*/
	newWorksheet : function(args) {
		fetch('newworksheet')
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		done
		fail
	*/
	resetEnv : function(args) {
		fetch('resetenv')
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	},

	/*
	args:
		filename
		done
		fail
	*/
	getWorksheet : function(args) {
		fetch('getworksheet?filename='+encodeURIComponent(args.filename))
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}
};

//TODO this is in common with the otehr standalone-bridge
//TODO would be nice to find mathjax async, and rebuild all mathjax cell outputs once mathjax is loaded
import {tryToFindMathJax} from'/server/tryToFindMathJax.js';
tryToFindMathJax.init({
	done : () => {
		init({
			server : new RemoteServer(),
			root : document.body,
			worksheets : window.symmathWorksheets,
		});
	},
	fail : fail,
});
