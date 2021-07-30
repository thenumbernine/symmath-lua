//this connects standalone.js with the standalone.lua server
//
//alternatively use the bridge for connecting with lua-in-javascript

// remote?

function RemoteServer() {
}
RemoteServer.prototype = {
	/*
	args:
		done
		fail
	*/
	getCells : function(args) {
		$.ajax({
			url : "getcells"
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		uid
		outputtype
		done
		fail
	*/
	setOutputType : function(args) {
		$.ajax({
			url : "setoutputtype?uid="+args.uid+"&outputtype="+args.outputtype
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		uid
		done
		fail
	*/
	remove : function(args) {
		$.ajax({
			url : "remove?uid="+args.uid
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		uid,
		cellinput,
		done
		fail
	*/
	run : function(args) {
		$.ajax({
			type : "POST",
			url : "run",
			data : {
				uid : args.uid,
				cellinput : args.cellinput,
			}
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		uid
		hidden
	*/
	setHidden : function(args) {
		$.ajax({
			url : "sethidden?uid="+args.uid+"&hidden="+args.hidden
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		uid (optional) cell to insert before
		done,
		fail
	*/
	newCell : function(args) {
		$.ajax({
			url : "newcell" + (args.uid !== undefined ? ("?" + args.uid) : "")
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		(don't pass cells, i'll just read from the global)
		done
		fail
	*/
	writeCells : function(args) {
		$.ajax({
			type : "POST",
			url : "writecells",
			data : {
				cells : JSON.stringify(cells)
			}
		}).done(args.done)
		.fail(args.fail);
	},

	/*
	args:
		done
		fail
	*/
	save : function(args) {
		$.ajax({
			url : "save"
		}).done(args.done)
		.fail(args.fail);
	},

	quit : function() {
		$.ajax({
			url : "quit"
		});
	}
};

server = new RemoteServer();
