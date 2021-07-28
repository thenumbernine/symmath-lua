var mjid = 0;
var cells = [];
var ctrls = [];
var worksheetDiv;
var lastAddNewCellButton;

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

	var createAddNewCellButton = function(pos, parentNode) {
		var addNewCellButton = $('<div>', {
			class : 'addNewCellButton',
			click : function() {
				// write all cell inputTextArea's -> cell inputs -> back to the server
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
									findCtrlForUID(uid).inputTextArea.focus();
								}
							});
						})
						.fail(fail);
					}
				});
			}
		});
		parentNode.append(addNewCellButton);
		return addNewCellButton;
	};
	var addCell = function(cell, cellIndex) {

		//TODO make 'addCell' a ctor, and make 'ctrl' into 'this' , and for callbacks make it 'thiz' too
		var ctrl = {};
		ctrl.cell = cell;
		
		ctrl.refreshOutput = function() {
			var outputtype = ctrl.cell.outputtype;
			if (ctrl.cell.haserror) outputtype = 'text';
				
			var outputstr = ctrl.cell.output;
			if (outputtype == 'html') {
				ctrl.outputDiv.html(outputstr);
				MathJax.Hub.Queue(["Typeset", MathJax.Hub, ctrl.outputDiv.attr('id')]);

			//should there even be a 'latex' type? or just 'html' and mathjax?
			} else if (outputtype == 'latex') {
				ctrl.outputDiv.html(outputstr);
				MathJax.Hub.Queue(["Typeset", MathJax.Hub, ctrl.outputDiv.attr('id')]);
			
			} else {
				ctrl.outputDiv.html('');
				if (outputtype != 'text') {
					outputstr = 'UNKNOWN OUTPUT TYPE: '+outputtype+'\n';
				}
				ctrl.outputDiv.append($('<pre>', {text : outputstr}));
			}
		
			if (outputstr.length == 0) {
				ctrl.outputDiv.hide();
			} else {
				ctrl.outputDiv.show();
			}
		};

		var refreshJustThisCell = function(celldata) {
			var newcell = $.parseJSON(celldata);
			cell = newcell;
			ctrl.cell = newcell;

			for (var i = 0; i < cells.length; ++i) {
				if (cells[i].uid == ctrl.cell.uid) {
					cells[i] = newcell;
				}
			}
			ctrl.refreshOutput();
		};

		ctrl.inputTextArea = $('<textarea>', {
			//class : 'inputTextArea',
			text : ctrl.cell.input
		});
		ctrl.inputTextArea.addClass('inputTextArea');
		
		ctrl.run = function(args) {
			args = args || {};
			var cellinput = ctrl.inputTextArea.val();
			$.ajax({
				type : "POST",
				url : "run",
				data : {
					uid : ctrl.cell.uid,
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

		ctrl.inputTextArea.attr('spellcheck', 'false');
		var updateTextAreaLines = function() {
			var numlines = ctrl.inputTextArea.val().split('\n').length;
			ctrl.inputTextArea.attr('rows', numlines);	// + 1);
		};
		if (ctrl.cell.hidden) ctrl.inputTextArea.hide();
		updateTextAreaLines();
		ctrl.inputTextArea.keydown(function(e) {
			if (e.keyCode == 9) {
				e.preventDefault();
				if (this.selectionStart == this.selectionEnd) {
					document.execCommand("insertText", false, '\t');
				} else {
					var selStart = this.selectionStart;
					var selEnd = this.selectionEnd;
					var text = $(this).val();
					while (selStart > 0 && text[selStart-1] != '\n') {
						selStart--;
					}
					while (selEnd > 0 && text[selEnd-1]!='\n' && selEnd < text.length) {
						selEnd++;
					}

					var lines = text.substr(selStart, selEnd - selStart).split('\n');

					for (var i=0; i<lines.length; i++) {
						if (i==lines.length-1 && lines[i].length==0) {
							continue;
						}

						if (e.shiftKey)
						{
							if (lines[i].startsWith('\t'))
								lines[i] = lines[i].substr(1);
							else if (lines[i].startsWith("    "))
								lines[i] = lines[i].substr(4);
						} else {
							lines[i] = "\t" + lines[i];
						}
					}
					lines = lines.join('\n');

					this.selectionStart = selStart;
					this.selectionEnd = selEnd;
					document.execCommand("insertText", false, lines);
					this.selectionStart = selStart;
					this.selectionEnd = selStart + lines.length;
				}
			} else if (e.keyCode == 13) {
				if (e.ctrlKey) {
					e.preventDefault();
					ctrl.run({
						done : function() {
							//...annddd... select the next cell
console.log("after run response");
console.log("for cell", ctrl.cell);
							for (var j = 0; j < cells.length; ++j) {
								if (cells[j].uid == ctrl.cell.uid) {
									if (j < cells.length-1) {
console.log("focusing on next inputTextArea...");
										ctrls[j+1].setHidden(false);
										ctrls[j+1].inputTextArea.focus();
									} else {
										// if it's the last cell then ... create a new cell and highlight it?
										lastAddNewCellButton.click();
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
		ctrl.inputTextArea.keyup(function(e) {
			updateTextAreaLines();
		});

		// this contains the add-new-button, the rhs-ctrls, the input, and the output
		ctrl.div = $('<div>', {
			class : 'ctrlDiv'
		});
		worksheetDiv.append(ctrl.div);

		// 'add new cell before'
		ctrl.addNewCellButton = createAddNewCellButton(cellIndex+1, ctrl.div);

		//ctrl.div.append($('<hr>'));
		ctrl.setHidden = function(hidden) {
			ctrl.cell.hidden = hidden;
			if (ctrl.cell.hidden) {
				ctrl.inputTextArea.hide();
			} else {
				ctrl.inputTextArea.show();
			}
			$.ajax({
				url : "sethidden?uid="+ctrl.cell.uid+"&hidden="+ctrl.cell.hidden
			});
		};
		

		var rhsCtrlDiv = $('<span>', {
			class : 'rhsCtrlDiv'
		});
		ctrl.div.append(rhsCtrlDiv);

		rhsCtrlDiv.append($('<button>', {
			text : 'v',
			click : function() {
				ctrl.setHidden(!ctrl.cell.hidden);
			}
		}));

		rhsCtrlDiv.append($('<button>', {
			text : 'run',
			click : function() {
				ctrl.run.apply(arguments);
			}
		}));
		
		var setoutputtype = $('<select>', {
			html : $.map(['text', 'html', 'latex'], function(s,i) {
				return '<option>'+s+'</option>'
			}).join(''),
			change : function(e) {
				var val = this.value;
				$.ajax({
					url : "setoutputtype?uid="+ctrl.cell.uid+"&outputtype="+val
				}).done(function(celldata) {
					//only update this cell
					refreshJustThisCell(celldata);
				})
				.fail(fail);
			}
		});
		setoutputtype.val(ctrl.cell.outputtype);
		rhsCtrlDiv.append(setoutputtype);
	
		rhsCtrlDiv.append($('<button>', {
			text : '-',
			click : function() {
				$.ajax({
					url : "remove?uid="+ctrl.cell.uid
				}).done(function() {
					//update all?
					getAllCellsFromServerAndRebuildHtml();

					/* update only client changes... * /
					for (var j = 0; j < cells.length; ++j) {
						if (cells[j].uid == ctrl.cell.uid) {
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

		ctrl.div.append($('<br>'));


		var ioDiv = $('<div>', {
			class : 'ioDiv',
		});
		ctrl.div.append(ioDiv);

		ioDiv.append(ctrl.inputTextArea);
		ioDiv.append($('<br>'));


		var outputID = 'mj'+(++mjid);
		ctrl.outputDiv = $('<div>', {
			id : outputID,
			class : 'outputDiv'
		});
		ioDiv.append(ctrl.outputDiv);
		ctrl.refreshOutput();

		ctrls.push(ctrl);
	}
console.log("cells", cells);
console.log("cells.length "+cells.length);
	$.each(cells, function(cellIndex, cell) {
		addCell(cell, cellIndex);
	});
	lastAddNewCellButton = createAddNewCellButton(cells.length+1, worksheetDiv);

	if (ctrls.length) {
		ctrls[0].inputTextArea.focus();
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
		cell.input = ctrl.inputTextArea.val();
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
					var iterate;
					iterate = function(i) {
						if (i >= ctrls.length) return;
						ctrls[i].run({
							done : function() {
								iterate(++i);
							}
						});
					};
					iterate(0);
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
		text : 'clear all output',
		click : function() {
			for (var i = 0; i < cells.length; ++i) {
				cells[i].output = '';
				ctrls[i].refreshOutput();
			}
			
			// TODO writeAllCells re-reads them and rebuilds
			// don't need to do that here
			writeAllCells();
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

	worksheetDiv = $('<div>', {
		class : 'worksheetDiv'
	});
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
