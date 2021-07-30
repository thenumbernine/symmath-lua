// local / emulated lua in javascript ?

function EmulatedServer() {
}
EmulatedServer.prototype = {
	/*
	args:
		done
		fail
	*/
	getCells : function(args) {
	},

	/*
	args:
		uid
		outputtype
		done
		fail
	*/
	setOutputType : function(args) {
	},

	/*
	args:
		uid
		done
		fail
	*/
	remove : function(args) {
	},

	/*
	args:
		uid,
		cellinput,
		done
		fail
	*/
	run : function(args) {
	},

	/*
	args:
		uid
		hidden
	*/
	setHidden : function(args) {
	},

	/*
	args:
		uid (optional) cell to insert before
		done,
		fail
	*/
	newCell : function(args) {
	},

	/*
	args:
		(don't pass cells, i'll just read from the global)
		done
		fail
	*/
	writeCells : function(args) {
	},

	/*
	args:
		done
		fail
	*/
	save : function(args) {
	},

	quit : function() {
	}
};

server = new EmulatedServer();
