var mjid = 0;
var cells = [];
var ctrls = [];
var worksheetDiv;
var lastAddNewCellButton;

//put all menu buttons here.  or TODO just use jquery?
var menuButtons = [];

//use this for disable/enable'ing all controls while waiting for ajax responses
// to prevent the user from issuing multiple commands at once and causing the server/client to go out of sync
function setAllControlsEnabled(enabled) {
	$.each(menuButtons, function(i, button) {
		button.prop('disabled', !enabled);
	});
	$.each(ctrls, function(i, ctrl) {
		ctrl.setEnabled(enabled);
	});
	if (lastAddNewCellButton) {
		lastAddNewCellButton.prop('disabled', !enabled);
	}
}

function findCtrlForUID(uid) {
	for (var i = 0; i < cells.length; ++i) {
		if (cells[i].uid == uid) {
			return ctrls[i];
		}
	}
}

function CellControl(
	cell, 
	nextSibling
) {
	var ctrl = this;
	ctrl.cell = cell;
	
	ctrl.inputTextArea = $('<textarea>', {
		//class : 'inputTextArea',
		text : ctrl.cell.input
	});

/* can't do this immediatley or the javascript locks up
ctrl.inputTextArea.linedtextarea();
*/
/* looks alright ... adds an extra \n to all text areas ... numbers are an extra column wider than they need to be ...
... seems numbers overflow when i hide divs 
... and when i resize textarea rows, there's no way to resize numbers, unless i go through and redo them
... hmm, making my own number system might be better
setTimeout(function() {	
	ctrl.inputTextArea.linedtextarea();
}, 0);
*/
	ctrl.inputTextArea.addClass('inputTextArea');
	ctrl.inputTextArea.attr('autocapitalize', 'off');		
	ctrl.inputTextArea.attr('autocomplete', 'off');		
	ctrl.inputTextArea.attr('autocorrect', 'off');		
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
				//I forget what website I got this from, but it's not working in Firefox
				document.execCommand("insertText", false, '\t');
				//...so instead...
       			//https://stackoverflow.com/questions/6140632/how-to-handle-tab-in-textarea
				// ... but this doesn't work with the undo command ...
				/*
				var pos = this.selectionStart;
				var value = $(this).val();
				$(this).val(value.substring(0, pos) + "\t" + value.substring(pos));
				this.selectionStart = this.selectionEnd = pos + 1;
				*/
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
			if (e.shiftKey) {
				e.preventDefault();
				
				setAllControlsEnabled(false);
				ctrl.run({
					done : function() {
						//...annddd... select the next cell
console.log("after run response");
console.log("for cell", ctrl.cell);
						for (var j = 0; j < cells.length; ++j) {
							if (cells[j].uid == ctrl.cell.uid) {
								//have to enable before calling jquery.focus()
								setAllControlsEnabled(true);
								
								if (j < cells.length-1) {
console.log("focusing on inputTextArea after number ", j); 
									ctrls[j+1].setHidden({hidden:false});
									ctrls[j+1].inputTextArea.focus();
								} else {
									// if it's the last cell then ... create a new cell and highlight it?
									lastAddNewCellButton.click();
								}
								return;
							}
						}

						setAllControlsEnabled(true);
						//TODO error: couldn't find cell that we just ran
					},
					fail : function() {
						setAllControlsEnabled(true);
						fail();
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

	var rhsCtrlDiv = $('<span>', {
		class : 'rhsCtrlDiv'
	});


	var addAndRhsDiv = $('<div>', {
		class : 'addAndRhsDiv'
	});
	ctrl.div.append(addAndRhsDiv);

	// 'add new cell before'
	ctrl.addNewCellButton = createAddNewCellButton(ctrl.cell, addAndRhsDiv);
	//ctrl.div.append($('<hr>'));
	
	//ctrl.div.append(rhsCtrlDiv);
	addAndRhsDiv.prepend(rhsCtrlDiv);



	ctrl.toggleHiddenButton = $('<button>', {
		text : 'v',
		click : function() {
			ctrl.toggleHiddenButton.prop('disabled', true);
			ctrl.setHidden({
				hidden : !ctrl.cell.hidden,
				done : function(){
					ctrl.toggleHiddenButton.prop('disabled', false);
					// don't bother enable/disable all controls, only this one? or only the expand/collapse ones?
				},
				fail : function() {
					ctrl.toggleHiddenButton.prop('disabled', false);
					fail();
				}
			});
		}
	});
	rhsCtrlDiv.append(ctrl.toggleHiddenButton);

	ctrl.runUntilButton = $('<button>', {
		text : '...▶',
		click : function() {
			var endIndex;
			for (var i = 0; i < ctrls.length; ++i) {
				if (ctrls[i] == ctrl) {
					endIndex = i;
					break;
				}
			}
			if (!endIndex) throw "can't find this ctrl in the ctrls"

			setAllControlsEnabled(false);
			writeAllCells({
				done : function() {
					var iterate;
					iterate = function(i) {
						if (i > endIndex
							|| ctrls[i].cell.outputtype == 'stop'
						) {
							setAllControlsEnabled(true);
							//done
						} else {
							ctrls[i].run({
								done : function() {
									iterate(++i);
								},
								fail : function() {
									iterate(++i);
								}
							});
						}
					};
					iterate(0);
				},
				fail : function() {
					setAllControlsEnabled(true);
					//TODO fail
					fail();
				}
			});
		}
	});
	rhsCtrlDiv.append(ctrl.runUntilButton);

	ctrl.runButton = $('<button>', {
		text : '▶',
		click : function() {
			setAllControlsEnabled(false);
			ctrl.run({
				fail : function() {
					setAllControlsEnabled(true);
					fail();
				},
				done : function() {
					setAllControlsEnabled(true);
				}
			});
		}
	});
	rhsCtrlDiv.append(ctrl.runButton);

	ctrl.runAfterButton = $('<button>', {
		text : '▶...',
		click : function() {
			var startIndex;
			for (var i = 0; i < ctrls.length; ++i) {
				if (ctrls[i] == ctrl) {
					startIndex = i;
					break;
				}
			}
			if (!startIndex) throw "can't find this ctrl in the ctrls"

			setAllControlsEnabled(false);
			writeAllCells({
				done : function() {
					var iterate;
					iterate = function(i) {
						if (i >= cells.length
							|| ctrls[i].cell.outputtype == 'stop'
						) {
							setAllControlsEnabled(true);
							//done
						} else {
							ctrls[i].run({
								done : function() {
									iterate(++i);
								},
								fail : function() {
									iterate(++i);
								}
							});
						}
					};
					iterate(startIndex);
				},
				fail : function() {
					setAllControlsEnabled(true);
					//TODO fail
					fail();
				}
			});
		}
	});
	rhsCtrlDiv.append(ctrl.runAfterButton);



	ctrl.setOutputTypeSelect = $('<select>', {
		html : $.map(['text', 'html', 'latex', 'stop'], function(s,i) {
			return '<option>'+s+'</option>'
		}).join(''),
		change : function(e) {
			ctrl.setOutputTypeSelect.prop('disabled', true);
			var val = this.value;

console.log("setting output type to ", val);
			server.setOutputType({
				uid : ctrl.cell.uid,
				outputtype : this.value,
				done : function(celldata) {
					//only update this cell
					// no need to disable controls too? just this control?
					ctrl.setOutputTypeSelect.prop('disabled', false);
					
					ctrl.refreshJustThisCell(celldata);
console.log("...successfully set output type to ", ctrl.cell.outputtype);
				},
				fail : function() {
					ctrl.setOutputTypeSelect.prop('disabled', false);
					fail();
				}
			});
		}
	});
	ctrl.setOutputTypeSelect.val(ctrl.cell.outputtype);
	rhsCtrlDiv.append(ctrl.setOutputTypeSelect);

	ctrl.removeCellButton = $('<button>', {
		text : '-',
		click : function() {
			setAllControlsEnabled(false);
			
			server.remove({
				uid : ctrl.cell.uid,
				done : function() {
					/* update all? * /
					getAllCellsFromServerAndRebuildHtml();
					/**/
					/* update only client changes... */
					for (var j = 0; j < cells.length; ++j) {
						if (cells[j].uid == ctrl.cell.uid) {
							ctrls[j].div.remove();
							cells.splice(j, 1);
							ctrls.splice(j, 1);
							// after removing ...
							if (j < cells.length) {
								ctrls[j].inputTextArea.focus();
							}
							
							setAllControlsEnabled(true);
							return;
						}
					}
					//TODO error here, couldn't find the cell
					setAllControlsEnabled(true);
					/**/
				},
				fail : function() {
					setAllControlsEnabled(true);
					fail();
				}
			});
		}
	});
	rhsCtrlDiv.append(ctrl.removeCellButton);

	var ioDiv = $('<div>', {
		class : 'ioDiv',
	});
	ctrl.div.append(ioDiv);

	ioDiv.append(ctrl.inputTextArea);

	var outputID = 'mj'+(++mjid);
	ctrl.outputDiv = $('<div>', {
		id : outputID,
		class : 'outputDiv'
	});
	ioDiv.append(ctrl.outputDiv);
	ctrl.refreshOutput();
	
	ctrl.div.insertBefore(nextSibling);
}
CellControl.prototype = {
	setEnabled : function(enabled) {
		var ctrl = this;
		$.each([
			ctrl.addNewCellButton,
			ctrl.toggleHiddenButton,
			ctrl.runUntilButton,
			ctrl.runButton,
			ctrl.runAfterButton,
			ctrl.setOutputTypeSelect,
			ctrl.removeCellButton,
			ctrl.inputTextArea
		], function(i, button) {
			button.prop('disabled', !enabled);
		});
	},

	//refresh the contents of the ctrl.outputDiv based on the cell.output
	refreshOutput : function() {
		var ctrl = this;

		var outputtype = ctrl.cell.outputtype;
		if (outputtype != 'stop' && ctrl.cell.haserror) outputtype = 'text';
console.log("refreshing output type for", outputtype);
		
		var outputstr = ctrl.cell.output;
		if (outputtype == 'html') {
			ctrl.outputDiv.html(outputstr);
			MathJax.Hub.Queue(["Typeset", MathJax.Hub, ctrl.outputDiv.attr('id')]);

		//should there even be a 'latex' type? or just 'html' and mathjax?
		} else if (outputtype == 'latex') {
			ctrl.outputDiv.html(outputstr);
			MathJax.Hub.Queue(["Typeset", MathJax.Hub, ctrl.outputDiv.attr('id')]);
		} else if (outputtype == 'stop') {
			outputstr = '<hr><hr><hr>';
			ctrl.outputDiv.html(outputstr);
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
	},

	//replace the cell in the cells array with the new celldata JSON
	//and refresh the output
	refreshJustThisCell : function(celldata) {
		var ctrl = this;

		var newcell = $.parseJSON(celldata);
		cell = newcell;
		ctrl.cell = newcell;

		for (var i = 0; i < cells.length; ++i) {
			if (cells[i].uid == ctrl.cell.uid) {
				cells[i] = newcell;
			}
		}
		ctrl.refreshOutput();
	},

	//run the cell: send cell.input to the server, get back cell.output, and build the outputDiv
	run : function(args) {
		args = args || {};
		var ctrl = this;
		
		ctrl.div.css("border", "3px solid red");

		server.run({
			uid : ctrl.cell.uid,
			cellinput : ctrl.inputTextArea.val(),
			done : function(celldata) {
				ctrl.div.css("border", "");
				/* update all? * /
				getAllCellsFromServerAndRebuildHtml({
					done : args.done
				});
				/**/
				/* update only this one? */
				ctrl.refreshJustThisCell(celldata);
				//TODO wait for 'refreshJustThisCell' to finish?  finish MathJax rendering callback?
				if (args.done) args.done();
				/**/
			},
			fail : function() {
				ctrl.div.css("border", "");
				fail();
			}
		});
	},

	/*
	args:
		hidden
		done
		fail

	TODO wait for callback?
	*/
	setHidden : function(args) {
		var ctrl = this;
		ctrl.cell.hidden = args.hidden;
		if (ctrl.cell.hidden) {
			ctrl.inputTextArea.hide();
		} else {
			ctrl.inputTextArea.show();
		}
		
		//let the caller setup done or fail if they want
		server.setHidden({
			uid : ctrl.cell.uid,
			hidden : ctrl.cell.hidden,
			done : args.done,
			fail : args.fail
		});
	}
};

function createAddNewCellButton(cellToInsertBefore, parentNode) {
	var addNewCellButton = $('<div>', {
		class : 'addNewCellButton',
		click : function() {
			// write all cell inputTextArea's -> cell inputs -> back to the server
			writeAllCells({
				// then insert the new cell
				done : function() {
					server.newCell({
						uid : cellToInsertBefore ? cellToInsertBefore.uid : undefined,
						done : function(newcelljson) {
							var newcell = $.parseJSON(newcelljson);
							
							/* update everything? * /
							getAllCellsFromServerAndRebuildHtml({
								done : function() {
									// TODO focus on the new cell
									findCtrlForUID(newcell.uid).inputTextArea.focus();
								}
							});
							/**/
							/* update just the new cell */
							// and rebuild the control for it too
							var newctrl;
							if (cellToInsertBefore) {
								
								//var posToInsertBefore = cells.indexOf(cellToInsertBefore);
								//TODO search with comparator? it has to exist somewhere...
								var posToInsertBefore = -1;
								for (var j = 0; j < cells.length; ++j) {
									if (cells[j].uid == cellToInsertBefore.uid) {
										posToInsertBefore = j;
										break;
									}
								}
								
								if (posToInsertBefore < 0 || posToInsertBefore >= cells.length) {
									console.log("cellToInsertBefore", cellToInsertBefore);
									throw "failed to find cellToInsertBefore";
								}
								var ctrlToInsertBefore = ctrls[posToInsertBefore];
								newctrl = new CellControl(newcell, ctrlToInsertBefore.div);
								cells.splice(posToInsertBefore, 0, newcell);
								ctrls.splice(posToInsertBefore, 0, newctrl);
							} else {
								newctrl = new CellControl(newcell, lastAddNewCellButton);
								cells.push(newcell);
								ctrls.push(newctrl);
							}
							newctrl.inputTextArea.focus();
							/**/
						},
						fail : fail
					});
				}
			});
		}
	});
	parentNode.append(addNewCellButton);

	return addNewCellButton;
}

function rebuildHtmlFromCells(args) {
	//args.cellsjson should exist
console.log("rebuildHtmlFromCells got", arguments);
	cells = $.parseJSON(args.cellsjson);
	ctrls = [];

	worksheetDiv.html('');

console.log("cells", cells);
console.log("cells.length "+cells.length);
	
	lastAddNewCellButton = createAddNewCellButton(null, worksheetDiv);
	
	$.each(cells, function(_, cell) {
		ctrls.push(new CellControl(cell, lastAddNewCellButton));
	});

	if (ctrls.length) {
		ctrls[0].inputTextArea.focus();
	}

	if (args.done) args.done();
}

//args include 'done' or 'fail'
//now this is only run by init(), but can be run from other buttons for debugging / lazy programming
function getAllCellsFromServerAndRebuildHtml(args) {
	args = args || {};
	server.getCells({
		done : function(cellsjson) {
			rebuildHtmlFromCells($.extend({
				cellsjson : cellsjson
			}, args));
		},
		fail : function() {
			(args.fail || fail).apply(null, arguments);	//you only do this if the first function is not a global/window variable, otherwise it errors.  stupid javascript.
		}
	});
}

function fail(e) {
	console.log(arguments);
	console.log(e.stack);
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
	server.writeCells({
		done : args.done,
		fail : args.fail || fail
	});
}

/*
args:
	root
	worksheets
	done
*/
function init(args) {
	var root = args ? args.root : document.body;

	var menubar = $('<div>', {
		class : 'menubar'
	});
	$(root).append(menubar);


	menubar.append($('<span>', {
		text : worksheetFilename
	}));
	
	menubar.append($('<br>'));

	//arguments[0] is the name, arguments[1-n] are the ctors of the buttons
	var addMenu = function() {
		var dropdown = $('<div>', {
			class : 'dropdown'
		});
		menubar.append(dropdown);

		var menuButton = $('<button>', {
			text : arguments[0],
		});
		dropdown.append(menuButton);
		menuButtons.push(menuButton);

		var contents = $('<div>', {
			class : 'dropdown-content'
		});
		dropdown.append(contents);

		for (var i = 1; i < arguments.length; ++i) {
			var subButton = $('<a>', $.extend({href:'#'}, arguments[i]));
			contents.append(subButton);
			menuButtons.push(subButton);
		}
	};

	addMenu(
		'File',
		{
			text : 'New',
			click : function() {
				setAllControlsEnabled(false);
				server.newWorksheet({
					done : function() {
						$.each(ctrls, function(i,ctrl) {
							ctrl.div.remove();
						});
						cells = [];
						ctrls = [];
						setAllControlsEnabled(true);
						lastAddNewCellButton.click();
					},
					fail : function() {
						setAllControlsEnabled(true);
						fail();
						lastAddNewCellButton.click();
					}
				});
			}
		},
		{
			text : 'Save',
			click : function() {
console.log("save click, writing cells...");			
				var scrollTop = $(window).scrollTop();
				setAllControlsEnabled(false);
				$(window).scrollTop(scrollTop);
				writeAllCells({
					done : function() {
console.log("..done writing cells, giving save cmd...");
						server.save({
							done : function() {
console.log("...done giving save cmd.");
								setAllControlsEnabled(true);
								//something is making my scroll position jump around, and maybe it's this?
								$(window).scrollTop(scrollTop);
							},
							fail : function() {
console.log("...failed giving save cmd.");
								//TODO on fail, popup warning and re-enable controls			
								fail();
							}
						});
					},
					fail : function() {
console.log("...failed writing cells.");
						//TODO on fail, popup warning and re-enable controls
						fail();
					}
				});
			}
		},
		{
			text : 'Quit',
			click : function() {
				server.quit();
				//don't wait for ajax response ... there won't be one
				setAllControlsEnabled(false);
				$(root).prepend($('<div>', {
					css : {
						font : 'color:red'
					},
					text : "disconnected"
				}));
				//TODO for some reason when we connect the next time, we get a quit message and the server immediately dies.  only one extra quit message. 
				// I guess this is an ajax problem if it is sending the request, the server is receiving it and handling it, and then the next server is still getting another request.
			}
		}
	);

	addMenu(
		'Run',
		{
			text : 'Run All',
			click : function() {
				//TODO all controls except 'break execution' for emergency restarts
				setAllControlsEnabled(false);
// no need to write all cells, correct?
// because we're calling 'run' on each
// and 'run' itself will write each cell 
// but ... then again ... what's the harm?
				writeAllCells({
					done : function() {
						var iterate;
						iterate = function(i) {
							if (i >= ctrls.length
								|| ctrls[i].cell.outputtype == 'stop'
							) {
								//done
								setAllControlsEnabled(true);
							} else {
								ctrls[i].run({
									done : function() {
										iterate(++i);
									},
									fail : function() {
										iterate(++i);
									}
								});
							}
						};
						iterate(0);
					},
					fail : function() {
						setAllControlsEnabled(true);
						//TODO fail
						fail();
					}
				});
			}
		},
		{
			text : 'Reset Env',
			click : function() {
				setAllControlsEnabled(false);
				server.resetEnv({
					done : function() {
						setAllControlsEnabled(true);
					},
					fail : function() {
						setAllControlsEnabled(true);
						fail();
					}
				});
			}
		}
	);

	if (args.worksheets) {
		var loadWorksheetButtons = ['Worksheets'];
		$.each(args.worksheets, function(i,filename) {
			loadWorksheetButtons.push({
				text : filename,
				click : function() {
					setAllControlsEnabled(false);
					server.getWorksheet({
						filename : 'tests/'+filename+'.symmath',
						done : function(cellsjson) {
console.log("getWorksheet results", cellsjson);
							rebuildHtmlFromCells({
								cellsjson : cellsjson,
								done : function() {
									setAllControlsEnabled(true);
								},
								fail : function() {
									setAllControlsEnabled(true);
									fail();
								}
							});
						},
						fail : function() {
							setAllControlsEnabled(true);
							fail();
						}
					});
				}
			});
		});
		addMenu.apply(null, loadWorksheetButtons);
	}

	addMenu(
		'View',
		{
			text : 'Expand All',
			click : function() {
				setAllControlsEnabled(false);
				var i = 0;
				var n = ctrls.length;
				$.each(ctrls, function(i,ctrl) {
					ctrl.setHidden({
						hidden : false,
						done : function() {
							++i;
							if (i == n) {
								setAllControlsEnabled(true);
							}
						},
						fail : function() {
							setAllControlsEnabled(true);
							fail();
						}
					});
				});
			}
		},
		{
			text : 'Collapse All',
			click : function() {
				setAllControlsEnabled(false);
				var i = 0;
				var n = ctrls.length;
				$.each(ctrls, function(i,ctrl) {
					ctrl.setHidden({
						hidden : true,
						done : function() {
							++i;
							if (i == n) {
								setAllControlsEnabled(true);
							}
						},
						fail : function() {
							setAllControlsEnabled(true);
							fail();
						}
					});
				});
			}
		},
		{
			text : 'Clear All Output',
			click : function() {
				setAllControlsEnabled(false);

				for (var i = 0; i < cells.length; ++i) {
					cells[i].output = '';
					ctrls[i].refreshOutput();
				}
				
				// TODO writeAllCells re-reads them and rebuilds
				// don't need to do that here
				writeAllCells({
					done : function() {
						setAllControlsEnabled(true);
					}
				});
			}
		}
	);

	var helpDiv = $('<div>', {
		class : 'helpDiv'
	});
	$(root).append(helpDiv);

	
	$.ajax({
		url : symmathDir+'/README.reference.md',
		dataType : 'text',
		cache : false,
	}).fail(function() {
		console.log("failed to get readme", arguments);
	}).done(function(text) {
		console.log("got reference", arguments);
		var converter = new showdown.Converter();
		var help = converter.makeHtml(text);
		helpDiv.append($('<button>', {
			text : 'x',
			class : 'closeHelpButton',
			click : function() {
				helpDiv.hide();
			}
		}));
		helpDiv.append(help);
	});


	addMenu(
		'Help',
		{
			text : 'Help',
			click : function() {
				helpDiv.show();
			}
		}
	);

	$(root).append(menubar);

	worksheetDiv = $('<div>', {
		class : 'worksheetDiv'
	});
	$(root).append(worksheetDiv);
	$(root).append($('<br>'));

	setAllControlsEnabled(false);
	getAllCellsFromServerAndRebuildHtml({
		done : function() {
			setAllControlsEnabled(true);
			
			if (ctrls.length == 0) {
				//no cells in our file?  at least load the first cell
				lastAddNewCellButton.click();
			}
		
			if (args && args.done) args.done();
		}
	});
}
