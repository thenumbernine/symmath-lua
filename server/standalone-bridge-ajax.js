//this connects standalone.js with the standalone.lua server
//
//alternatively use the bridge for connecting with lua-in-javascript

import {init as initStandalone, fail, serverBase} from '/server/standalone.js';

class RemoteServer {
	/*
	args:
		done
		fail
	*/
	getCells(args) {
		fetch('getcells')
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		uid
		outputtype
		done
		fail
	*/
	setOutputType(args) {
		fetch("setoutputtype?uid="+args.uid+"&outputtype="+args.outputtype)
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		uid
		done
		fail
	*/
	remove(args) {
		fetch("remove?uid="+args.uid)
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		uid,
		cellinput,
		done
		fail
	*/
	run(args) {
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
	}

	/*
	args:
		uid
		hidden
	*/
	setHidden(args) {
		fetch("sethidden?uid="+args.uid+"&hidden="+args.hidden)
		.then(response => {
			if (!response.ok) return Promise.reject('not ok');
console.log('sethidden', args.done);
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		uid (optional) cell to insert before
		done,
		fail
	*/
	newCell(args) {
		fetch("newcell" + (args.uid !== undefined ? ("?" + args.uid) : ""))
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => {args.fail?.(e); });
	}

	/*
	args:
		(don't pass cells, i'll just read from the global)
		done
		fail
	*/
	writeCells(args) {
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
	}

	/*
	args:
		done
		fail
	*/
	save(args) {
		fetch('save')
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); })
		}).catch(e => { args.fail?.(e); });
	}

	quit(args) {
		fetch("quit")
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); })
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		done
		fail
	*/
	newWorksheet(args) {
		fetch('newworksheet')
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		done
		fail
	*/
	resetEnv(args) {
		fetch('resetenv')
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}

	/*
	args:
		filename
		done
		fail
	*/
	getWorksheet(args) {
		fetch('getworksheet?filename='+encodeURIComponent(args.filename))
		.then(response => {
			if (!response.ok) throw 'not ok';
			response.text()
			.then(text => { args.done?.(text); });
		}).catch(e => { args.fail?.(e); });
	}
}

/*
args:
	worksheetFilename
	symmathPath
	worksheets
*/
const init = (args) =>
	initStandalone({
		server : new RemoteServer(),
		root : document.body,
		worksheets : args.worksheets,
		worksheetFilename : args.worksheetFilename,
		symmathPath : args.symmathPath,
	});

export {init};
