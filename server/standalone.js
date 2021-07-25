var mjid = 0;
var cells = [];
var ctrls = [];
var worksheetDiv;

function findCtrlForUID(uid) {
	for (var i = 0; i < cells.length; ++i) {
		if (cells[i].uid == uid) {
			return ctrls[i];
		}
	}
}

function rebuildHtmlFromCells(args) {
	//args.cellsjson should exist
console.log("getcells got", arguments);
	cells = $.parseJSON(args.cellsjson);
	ctrls = [];

	worksheetDiv.html('');
	
	var addNewCellButton = function(pos, parentNode) {
		parentNode.append($('<button>', {
			// make rhsCtrlDiv top margin match this's top+bototm margin
			css : {
				margin : '10 0 10 0'
			},
			text : '+',
			click : function() {
				// write all cell textarea's -> cell inputs -> back to the server
				writeAllCells({
					// then insert the new cell
					done : function() {
						$.ajax({
							url : "newcell?pos="+pos
						}).done(function(newcelljson) {
							var newcell = $.parseJSON(newcelljson);
							var uid = newcell.uid;
							//update everything?
							getAllCellsFromServerAndRebuildHtml({
								done : function() {
									// TODO focus on the new cell
									findCtrlForUID(uid).textarea.focus();
								}
							});
						})
						.fail(fail);
					}
				});
			}
		}));
	};
	var addCell = function(cell, cellIndex) {
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

		var run = function(args) {
			args = args || {};
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
				//getAllCellsFromServerAndRebuildHtml();
				
				//update only this one?
				refreshJustThisCell(celldata);
			
				if (args.done) args.done();
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
			textarea.attr('rows', numlines);	// + 1);
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
					run({
						done : function() {
							//...annddd... select the next cell
console.log("after run response");
console.log("for cell", cell);
							for (var j = 0; j < cells.length; ++j) {
								if (cells[j].uid == cell.uid) {
									if (j < cells.length-1) {
console.log("focusing on next textarea...");
										ctrls[j+1].setHidden(false);
										ctrls[j+1].textarea.focus();
									} else {
										// if it's the last cell then ... create a new cell and highlight it?
									}
									break;
								}
							}
						}
					});
					return;
				}
			}
		});
		textarea.keyup(function(e) {
			updateTextAreaLines();
		});

		var ctrlDiv = $('<div>');
		worksheetDiv.append(ctrlDiv);

		addNewCellButton(cellIndex+1, ctrlDiv);

		//ctrlDiv.append($('<hr>'));
		var setHidden = function(hidden) {
			cell.hidden = hidden;
			if (cell.hidden) {
				textarea.hide();
			} else {
				textarea.show();
			}
			$.ajax({
				url : "sethidden?uid="+cell.uid+"&hidden="+cell.hidden
			});
		};
		

		var rhsCtrlDiv = $('<span>', {
			css : {
				// top margin matches top+bottom margin of '+' button
				margin : '20 0 0 0',
				display : 'inline',
				float : 'right'
			}
		});
		ctrlDiv.append(rhsCtrlDiv);

		rhsCtrlDiv.append($('<button>', {
			text : 'v',
			click : function() {
				setHidden(!cell.hidden);
			}
		}));

		rhsCtrlDiv.append($('<button>', {
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
					//only update this cell
					refreshJustThisCell(celldata);
				})
				.fail(fail);
			}
		});
		setoutputtype.val(cell.outputtype);
		rhsCtrlDiv.append(setoutputtype);
	
		rhsCtrlDiv.append($('<button>', {
			text : '-',
			click : function() {
				$.ajax({
					url : "remove?uid="+cell.uid
				}).done(function() {
					//update all?
					getAllCellsFromServerAndRebuildHtml();

					/* update only client changes... * /
					for (var j = 0; j < cells.length; ++j) {
						if (cells[j].uid == cell.uid) {
							ctrls[j].div.remove();
							cells.splice(j, 1);
							ctrls.splice(j, 1);
							break;
						}
					}
					/**/
					// BUT TODO this will make all the 'index' parameters associated with the '+' addNewCells to go out of order
				})
				.fail(fail);
			}
		}));

		ctrlDiv.append($('<br>'));


		ctrlDiv.append(textarea);
		ctrlDiv.append($('<br>'));


		var outputID = 'mj'+(++mjid);
		output = $('<div>', {
			id : outputID
		});
		output.addClass('symmath-output');
		ctrlDiv.append(output);
		refreshOutput();
	
		ctrls.push({
			cell : cell,
			div : ctrlDiv,
			textarea : textarea,
			setHidden : setHidden
		});
	}
console.log("cells", cells);
console.log("cells.length "+cells.length);
	$.each(cells, function(cellIndex,cell) {
		addCell(cell, cellIndex);
	});
	addNewCellButton(cells.length+1, worksheetDiv);

	if (ctrls.length) {
		ctrls[0].textarea.focus();
	}

	if (args.done) args.done();
}

//args include 'done' or 'fail'
function getAllCellsFromServerAndRebuildHtml(args) {
	args = args || {};
	$.ajax({
		url : "getcells"
	})
	.fail(function() {
		(args.fail || fail)();	//you only do this if the first function is not a global/window variable, otherwise it errors.  stupid javascript.
	})
	.done(function(cellsjson) {
		rebuildHtmlFromCells($.extend({
			cellsjson : cellsjson
		}, args));
	});
}

function fail() {
	console.log(arguments);
	throw 'failed';
}

function setCellInputsToTextareaValues() {
	if (ctrls.length != cells.length) throw "got a mismatch in size between ctrls and cells";
	$.each(ctrls, function(i,ctrl) {
		var cell = ctrl.cell;
		cell.input = ctrl.textarea.val();
	});
}

//write all cells back to the server.  call 'done' or 'fail' upon done or fail.
function writeAllCells(args) {
	args = args || {};

	//first copy textareas -> cell.input's
	setCellInputsToTextareaValues();

	//next write to the server
	$.ajax({
		type : "POST",
		url : "writecells",
		data : {
			cells : JSON.stringify(cells)
		}
	}).done(function() {
		if (args.done) args.done();
	}).fail(function() {
		if (args.fail) {
			args.fail()
		} else {
			fail();
		}
	});
}

function init() {
	$(document.body).append($('<button>', {
		text : 'save',
		click : function() {
console.log("save click, writing cells...");			
			//TODO here - disable controls until save is finished
			writeAllCells({
				done : function() {
console.log("..done writing cells, giving save cmd...");
					$.ajax({
						url : "save"
					}).done(function() {
console.log("...done giving save cmd.");
						//TODO on done, re-enable page controls
					}).fail(function() {
console.log("...failed giving save cmd.");
						//TODO on fail, popup warning and re-enable controls			
						fail();
					});
				},
				fail : function() {
console.log("...failed writing cells.");
					//TODO on fail, popup warning and re-enable controls
					fail();
				}
			});
		}
	}));
	
	$(document.body).append($('<button>', {
		text : 'run all',
		click : function() {
			writeAllCells({
				done : function() {
					
					//TODO replace this with a client-side for-loop
					// so if we encounter a *serious* error then at least we'll have the clientside output up to that point
					// also , requires less serverside functions 
					$.ajax({
						url : "runall"
					})
					.done(function(cellsjson) {
						rebuildHtmlFromCells({
							cellsjson : cellsjson,
							done : function() {
								//TODO here re-enable controls
							},
							// There isn't a fail right now.  this isn't a remote request after all.
							fail : function() {
								//TODO fail
							}
						});
					})
					.fail(function() {
						//TODO fail
						fail();
					});
				},
				fail : function() {
					//TODO fail
					fail();
				}
			});
		}
	}));

	$(document.body).append($('<button>', {
		text : 'expand all',
		click : function() {
			$.each(ctrls, function(i,ctrl) {
				ctrl.setHidden(false);
			});
		}
	}));

	$(document.body).append($('<button>', {
		text : 'collapse all',
		click : function() {
			$.each(ctrls, function(i,ctrl) {
				ctrl.setHidden(true);
			});
		}
	}));
	
	$(document.body).append($('<button>', {
		text : 'quit',
		click : function() {
			$.ajax({
				url : "quit"
			});
			
			//don't wait for ajax response ... there won't be one
			// TODO just grey out all buttons
			$(document.body).html("goodbye");
		}
	}));

	$(document.body).append($('<br>'));
	$(document.body).append($('<br>'));

	worksheetDiv = $('<div>', {});
	worksheetDiv.addClass('worksheet');
	$(document.body).append(worksheetDiv);
	$(document.body).append($('<br>'));

	getAllCellsFromServerAndRebuildHtml();
}

$(document).ready(function() {
	tryToFindMathJax({
		done : init,
		fail : fail
	});
});
