import {DOM, assertExists, removeFromParent, merge, show, hide} from '/js/util.js';

function fail(e) {
	console.log(arguments);
	console.log(e);
	throw 'failed';
}

// https://docs.mathjax.org/en/latest/web/typeset.html#typeset-async
// new MathJax is a bit more restrictive of how to handle concurrent rendering ...
function typeset(code) {
	MathJax.startup.promise = MathJax.startup.promise
		.then(() => MathJax.typesetPromise(code()))
		.catch((err) => console.log('Typeset failed: ' + err.message));
	return MathJax.startup.promise;
}

class ServerBase {
	constructor() {
		this.mjid = 0;
		this.cells = [];
		this.ctrls = [];
		//this.worksheetDiv;
		//this.lastAddNewCellButton;
		//this.server;

		//put all menu buttons here.  or TODO just use jquery?
		this.menuButtons = [];
	}

	//use this for disable/enable'ing all controls while waiting for ajax responses
	// to prevent the user from issuing multiple commands at once and causing the server/client to go out of sync
	setAllControlsEnabled(enabled) {
		this.menuButtons.forEach(button => {
			button.disabled = !enabled;
		});
		this.ctrls.forEach(ctrl => {
			ctrl.setEnabled(enabled);
		});
		if (this.lastAddNewCellButton) {
			this.lastAddNewCellButton.disabled = !enabled;
		}
	}
	
	findCtrlForUID(uid) {
		for (let i = 0; i < this.cells.length; ++i) {
			if (this.cells[i].uid == uid) {
				return this.ctrls[i];
			}
		}
	}
}

const serverBase = new ServerBase();

class CellControl {
	constructor(
		cell,
		nextSibling
	) {
		let ctrl = this;
		ctrl.cell = cell;
		ctrl.inputTextArea = DOM('textarea', {
			//class : 'inputTextArea',
			value : ctrl.cell.input,
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
		ctrl.inputTextArea.classList.add('inputTextArea');
		ctrl.inputTextArea.autocapitalize = 'off';
		ctrl.inputTextArea.autocomplete = 'off';
		ctrl.inputTextArea.autocorrect = 'off';
		ctrl.inputTextArea.spellcheck = false;
		let updateTextAreaLines = function() {
			let numlines = ctrl.inputTextArea.value.split('\n').length;
			ctrl.inputTextArea.rows = numlines;	// + 1);
		};
		if (ctrl.cell.hidden) hide(ctrl.inputTextArea);
		updateTextAreaLines();
		ctrl.inputTextArea.addEventListener('keydown', e => {
			const thiz = ctrl.inputTextArea;
			if (e.keyCode == 9) {
				e.preventDefault();
				if (thiz.selectionStart == thiz.selectionEnd) {
					//I forget what website I got this from, but it's not working in Firefox
					document.execCommand("insertText", false, '\t');
					//...so instead...
					//https://stackoverflow.com/questions/6140632/how-to-handle-tab-in-textarea
					// ... but this doesn't work with the undo command ...
					/*
					let pos = thiz.selectionStart;
					let value = thiz.value;
					thiz.value = value.substring(0, pos) + "\t" + value.substring(pos);
					thiz.selectionStart = thiz.selectionEnd = pos + 1;
					*/
				} else {
					let selStart = thiz.selectionStart;
					let selEnd = thiz.selectionEnd;
					let text = thiz.value;
					while (selStart > 0 && text[selStart-1] != '\n') {
						selStart--;
					}
					while (selEnd > 0 && text[selEnd-1]!='\n' && selEnd < text.length) {
						selEnd++;
					}

					let lines = text.substr(selStart, selEnd - selStart).split('\n');

					for (let i=0; i<lines.length; i++) {
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

					thiz.selectionStart = selStart;
					thiz.selectionEnd = selEnd;
					document.execCommand("insertText", false, lines);
					thiz.selectionStart = selStart;
					thiz.selectionEnd = selStart + lines.length;
				}
			} else if (e.keyCode == 13) {
				if (e.shiftKey) {
					e.preventDefault();

					serverBase.setAllControlsEnabled(false);
					ctrl.run({
						done : () => {
							//...annddd... select the next cell
	console.log("after run response");
	console.log("for cell", ctrl.cell);
							for (let j = 0; j < serverBase.cells.length; ++j) {
								if (serverBase.cells[j].uid == ctrl.cell.uid) {
									//have to enable before calling jquery.focus()
									serverBase.setAllControlsEnabled(true);

									if (j < serverBase.cells.length-1) {
	console.log("focusing on inputTextArea after number ", j);
										serverBase.ctrls[j+1].setHidden({hidden:false});
										serverBase.ctrls[j+1].inputTextArea.focus();
									} else {
										// if it's the last cell then ... create a new cell and highlight it?
										serverBase.lastAddNewCellButton.click();
									}
									return;
								}
							}

							serverBase.setAllControlsEnabled(true);
							//TODO error: couldn't find cell that we just ran
						},
						fail : e => {
							setAllControlsEnabled(true);
							fail(e);
						}
					});
					return;
				}
			}
		});
		ctrl.inputTextArea.addEventListener('keyup', e => {
			updateTextAreaLines();
		});

		// this contains the add-new-button, the rhs-ctrls, the input, and the output
		ctrl.div = DOM('div');
		ctrl.div.classList.add('ctrlDiv');

		let rhsCtrlDiv = DOM('span');
		rhsCtrlDiv.classList.add('rhsCtrlDiv');


		let addAndRhsDiv = DOM('div', {
			appendTo : ctrl.div,
		});
		addAndRhsDiv.classList.add('addAndRhsDiv');

		// 'add new cell before'
		ctrl.addNewCellButton = createAddNewCellButton(ctrl.cell, addAndRhsDiv);
		//ctrl.div.append(DOM('hr'));

		//ctrl.div.append(rhsCtrlDiv);
		addAndRhsDiv.prepend(rhsCtrlDiv);



		ctrl.toggleHiddenButton = DOM('button', {
			text : 'v',
			click : e => {
				ctrl.toggleHiddenButton.disabled = true;
				ctrl.setHidden({
					hidden : !ctrl.cell.hidden,
					done : () => {
						ctrl.toggleHiddenButton.disabled = false;
						// don't bother enable/disable all controls, only this one? or only the expand/collapse ones?
					},
					fail : () => {
						ctrl.toggleHiddenButton.disabled = false;
						fail();
					}
				});
			}
		});
		rhsCtrlDiv.appendChild(ctrl.toggleHiddenButton);

		ctrl.runUntilButton = DOM('button', {
			text : '...▶',
			click : e => {
				let endIndex;
				for (let i = 0; i < serverBase.ctrls.length; ++i) {
					if (serverBase.ctrls[i] == ctrl) {
						endIndex = i;
						break;
					}
				}
				if (!endIndex) throw "can't find this ctrl in the ctrls"

				serverBase.setAllControlsEnabled(false);
				writeAllCells({
					done : () => {
						const iterate = i => {
							if (i > endIndex
								|| serverBase.ctrls[i].cell.outputtype == 'stop'
							) {
								serverBase.setAllControlsEnabled(true);
								//done
							} else {
								serverBase.ctrls[i].run({
									done : () => { iterate(++i); },
									fail : () => { iterate(++i); }
								});
							}
						};
						iterate(0);
					},
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						//TODO fail
						fail();
					},
				});
			}
		});
		rhsCtrlDiv.append(ctrl.runUntilButton);

		ctrl.runButton = DOM('button', {
			text : '▶',
			click : e => {
				serverBase.setAllControlsEnabled(false);
				ctrl.run({
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						fail();
					},
					done : () => {
						serverBase.setAllControlsEnabled(true);
					}
				});
			}
		});
		rhsCtrlDiv.append(ctrl.runButton);

		ctrl.runAfterButton = DOM('button', {
			text : '▶...',
			click : e => {
				let startIndex;
				for (let i = 0; i < serverBase.ctrls.length; ++i) {
					if (serverBase.ctrls[i] == ctrl) {
						startIndex = i;
						break;
					}
				}
				if (!startIndex) throw "can't find this ctrl in the ctrls"

				serverBase.setAllControlsEnabled(false);
				writeAllCells({
					done : () => {
						const iterate = i => {
							if (i >= serverBase.cells.length
								|| serverBase.ctrls[i].cell.outputtype == 'stop'
							) {
								serverBase.setAllControlsEnabled(true);
								//done
							} else {
								serverBase.ctrls[i].run({
									done : () => { iterate(++i); },
									fail : () => { iterate(++i); },
								});
							}
						};
						iterate(startIndex);
					},
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						//TODO fail
						fail();
					}
				});
			}
		});
		rhsCtrlDiv.appendChild(ctrl.runAfterButton);



		ctrl.setOutputTypeSelect = DOM('select', {
			html : ['text', 'html', 'latex', 'stop']
				.map((s,i) => {
					return '<option>'+s+'</option>'
				}).join(''),
			change : e => {
				ctrl.setOutputTypeSelect.disabled = true;
				const val = ctrl.setOutputTypeSelect.value;

	console.log("setting output type to ", val);
				serverBase.server.setOutputType({
					uid : ctrl.cell.uid,
					outputtype : this.value,
					done : celldata => {
						//only update this cell
						// no need to disable controls too? just this control?
						ctrl.setOutputTypeSelect.disabled = false;

						ctrl.refreshJustThisCell(celldata);
	console.log("...successfully set output type to ", ctrl.cell.outputtype);
					},
					fail : () => {
						ctrl.setOutputTypeSelect.disabled = false;
						fail();
					},
				});
			},
		});
		ctrl.setOutputTypeSelect.value = ctrl.cell.outputtype;
		rhsCtrlDiv.append(ctrl.setOutputTypeSelect);

		ctrl.removeCellButton = DOM('button', {
			text : '-',
			click : e => {
				serverBase.setAllControlsEnabled(false);

				serverBase.server.remove({
					uid : ctrl.cell.uid,
					done : () => {
						/* update all? * /
						getAllCellsFromServerAndRebuildHtml();
						/**/
						/* update only client changes... */
						for (let j = 0; j < serverBase.cells.length; ++j) {
							if (serverBase.cells[j].uid == ctrl.cell.uid) {
								serverBase.ctrls[j].div.remove();
								serverBase.cells.splice(j, 1);
								serverBase.ctrls.splice(j, 1);
								// after removing ...
								if (j < serverBase.cells.length) {
									serverBase.ctrls[j].inputTextArea.focus();
								}

								serverBase.setAllControlsEnabled(true);
								return;
							}
						}
						//TODO error here, couldn't find the cell
						serverBase.setAllControlsEnabled(true);
						/**/
					},
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						fail();
					},
				});
			},
		});
		rhsCtrlDiv.appendChild(ctrl.removeCellButton);

		const ioDiv = DOM('div', {class:'ioDiv', appendTo:ctrl.div});

		ioDiv.append(ctrl.inputTextArea);

		const outputID = 'mj'+(++serverBase.mjid);
		ctrl.outputDiv = DOM('div', {
			id : outputID,
			class : 'outputDiv',
			appendTo : ioDiv,
		});
		ctrl.refreshOutput();

		nextSibling.parentNode.insertBefore(ctrl.div, nextSibling);
	}
	
	setEnabled(enabled) {
		let ctrl = this;
		[
			ctrl.addNewCellButton,
			ctrl.toggleHiddenButton,
			ctrl.runUntilButton,
			ctrl.runButton,
			ctrl.runAfterButton,
			ctrl.setOutputTypeSelect,
			ctrl.removeCellButton,
			ctrl.inputTextArea
		].forEach(button => {
			button.disabled = !enabled;
		});
	}

	//refresh the contents of the ctrl.outputDiv based on the cell.output
	refreshOutput() {
		let ctrl = this;

		let outputtype = ctrl.cell.outputtype;
		if (outputtype != 'stop' && ctrl.cell.haserror) outputtype = 'text';
//console.log("refreshing output type for", outputtype);

		let outputstr = ctrl.cell.output;
		if (outputtype == 'html') {
			ctrl.outputDiv.innerHTML = outputstr;
//console.log('outputting html', ctrl.outputDiv);
			typeset(() => [ctrl.outputDiv]);
		//should there even be a 'latex' type? or just 'html' and mathjax?
		} else if (outputtype == 'latex') {
			ctrl.outputDiv.innerHTML = outputstr;
//console.log('outputting latex', ctrl.outputDiv);
			typeset(() => [ctrl.outputDiv]);
		} else if (outputtype == 'stop') {
			outputstr = '<hr><hr><hr>';
			ctrl.outputDiv.innerHTML = outputstr;
		} else {
			ctrl.outputDiv.innerHTML = '';
			if (outputtype != 'text') {
				outputstr = 'UNKNOWN OUTPUT TYPE: '+outputtype+'\n';
			}
			ctrl.outputDiv.append(DOM('pre', {text : outputstr}));
		}

		if (outputstr.length == 0) {
			hide(ctrl.outputDiv);
		} else {
			show(ctrl.outputDiv);
		}
	}

	//replace the cell in the cells array with the new celldata JSON
	//and refresh the output
	refreshJustThisCell(celldata) {
		let ctrl = this;

		let newcell = JSON.parse(celldata);
		ctrl.cell = newcell;

		for (let i = 0; i < serverBase.cells.length; ++i) {
			if (serverBase.cells[i].uid == ctrl.cell.uid) {
				serverBase.cells[i] = newcell;
			}
		}
		ctrl.refreshOutput();
	}

	//run the cell: send cell.input to the server, get back cell.output, and build the outputDiv
	run(args) {
		args = args || {};
		let ctrl = this;

		ctrl.div.style.border = "3px solid red";

		serverBase.server.run({
			uid : ctrl.cell.uid,
			cellinput : ctrl.inputTextArea.value,
			done : function(celldata) {
				ctrl.div.style.border = "";
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
			fail : e => {
				ctrl.div.style.border = "";
				fail(e);
			}
		});
	}

	/*
	args:
		hidden
		done
		fail

	TODO wait for callback?
	*/
	setHidden(args) {
		let ctrl = this;
		ctrl.cell.hidden = args.hidden;
		if (ctrl.cell.hidden) {
			hide(ctrl.inputTextArea);
		} else {
			show(ctrl.inputTextArea);
		}

		//let the caller setup done or fail if they want
		serverBase.server.setHidden({
			uid : ctrl.cell.uid,
			hidden : ctrl.cell.hidden,
			done : args.done,
			fail : args.fail
		});
	}
}

function createAddNewCellButton(cellToInsertBefore, parentNode) {
	let addNewCellButton = DOM('div', {
		class : 'addNewCellButton',
		click : e => {
			// write all cell inputTextArea's -> cell inputs -> back to the server
			writeAllCells({
				// then insert the new cell
				done : () => {
					serverBase.server.newCell({
						uid : cellToInsertBefore ? cellToInsertBefore.uid : undefined,
						done : newcelljson => {
							let newcell = JSON.parse(newcelljson);

							/* update everything? * /
							getAllCellsFromServerAndRebuildHtml({
								done : () => {
									// TODO focus on the new cell
									findCtrlForUID(newcell.uid).inputTextArea.focus();
								},
							});
							/**/
							/* update just the new cell */
							// and rebuild the control for it too
							let newctrl;
							if (cellToInsertBefore) {

								//let posToInsertBefore = cells.indexOf(cellToInsertBefore);
								//TODO search with comparator? it has to exist somewhere...
								let posToInsertBefore = -1;
								for (let j = 0; j < serverBase.cells.length; ++j) {
									if (serverBase.cells[j].uid == cellToInsertBefore.uid) {
										posToInsertBefore = j;
										break;
									}
								}

								if (posToInsertBefore < 0 || posToInsertBefore >= serverBase.cells.length) {
									console.log("cellToInsertBefore", cellToInsertBefore);
									throw "failed to find cellToInsertBefore";
								}
								let ctrlToInsertBefore = serverBase.ctrls[posToInsertBefore];
								newctrl = new CellControl(newcell, ctrlToInsertBefore.div);
								serverBase.cells.splice(posToInsertBefore, 0, newcell);
								serverBase.ctrls.splice(posToInsertBefore, 0, newctrl);
							} else {
								newctrl = new CellControl(newcell, serverBase.lastAddNewCellButton);
								serverBase.cells.push(newcell);
								serverBase.ctrls.push(newctrl);
							}
							newctrl.inputTextArea.dispatchEvent(new Event('focus'));
							/**/
						},
						fail : fail,
					});
				},
			});
		},
	});
	parentNode.appendChild(addNewCellButton);

	return addNewCellButton;
}

function rebuildHtmlFromCells(args) {
	//args.cellsjson should exist
console.log("rebuildHtmlFromCells got", args);
	serverBase.cells = JSON.parse(args.cellsjson);
	serverBase.ctrls = [];

	serverBase.worksheetDiv.innerHTML = '';

console.log("cells", serverBase.cells);
console.log("cells.length "+serverBase.cells.length);

	serverBase.lastAddNewCellButton = createAddNewCellButton(null, serverBase.worksheetDiv);

	serverBase.cells.forEach(cell => {
		serverBase.ctrls.push(new CellControl(cell, serverBase.lastAddNewCellButton));
	});

	if (serverBase.ctrls.length) {
		serverBase.ctrls[0].inputTextArea.dispatchEvent(new Event('focus'));
	}

	if (args.done) args.done();
}

//args include 'done' or 'fail'
//now this is only run by init(), but can be run from other buttons for debugging / lazy programming
function getAllCellsFromServerAndRebuildHtml(args) {
	args = args || {};
	serverBase.server.getCells({
		done : cellsjson => {
			rebuildHtmlFromCells(merge({
				cellsjson : cellsjson
			}, args));
		},
		fail : (...args2) => {
			(args.fail || fail).apply(null, args2);	//you only do this if the first function is not a global/window variable, otherwise it errors.  stupid javascript.
		}
	});
}

function setCellInputsToTextareaValues() {
	if (serverBase.ctrls.length != serverBase.cells.length) throw "got a mismatch in size between ctrls and cells";
	serverBase.ctrls.forEach(ctrl => {
		const cell = ctrl.cell;
		cell.input = ctrl.inputTextArea.value;
	});
}

//write all cells back to the server.  call 'done' or 'fail' upon done or fail.
function writeAllCells(args) {
	args = args || {};

	//first copy textareas -> cell.input's
	setCellInputsToTextareaValues();

	//next write to the server
	serverBase.server.writeCells({
		done : args.done,
		fail : args.fail || fail,
	});
}

/*
args:
	server
	root
	worksheets
	done
*/
function init(args) {
	serverBase.server = assertExists(args, 'server');
	const root = args ? args.root : document.body;

	const menubar = DOM('div', {
		class : 'menubar',
		appendTo : root,
	});

	menubar.appendChild(DOM('span', {
		text : window.worksheetFilename,
	}));

	menubar.appendChild(DOM('br'));

	//args[0] is the name, args[1-n] are the ctors of the buttons
	const addMenu = (...args) => {
		const dropdown = DOM('div', {
			class : 'dropdown',
			appendTo : menubar,
		});

		const menuButton = DOM('button', {
			text : args[0],
			appendTo : dropdown,
		});
		serverBase.menuButtons.push(menuButton);

		const contents = DOM('div', {
			class : 'dropdown-content',
			appendTo : dropdown,
		});

		for (let i = 1; i < args.length; ++i) {
			const subButton = DOM('a', merge({href:'#'}, args[i]));
			contents.append(subButton);
			serverBase.menuButtons.push(subButton);
		}
	};

	addMenu(
		'File',
		{
			text : 'New',
			click : e => {
				serverBase.setAllControlsEnabled(false);
				serverBase.server.newWorksheet({
					done : () => {
						serverBase.ctrls.forEach(ctrl => {
							removeFromParent(ctrl.div);
						});
						serverBase.cells = [];
						serverBase.ctrls = [];
						serverBase.setAllControlsEnabled(true);
						serverBase.lastAddNewCellButton.dispatchEvent(new Event('click'));
					},
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						fail();
						serverBase.lastAddNewCellButton.dispatchEvent(new Event('click'));
					},
				});
			},
		},
		{
			text : 'Save',
			click : e => {
console.log("save click, writing cells...");
				const scrollTop = window.scrollTop;
				serverBase.setAllControlsEnabled(false);
				window.scrollTop = scrollTop;
				writeAllCells({
					done : () => {
console.log("..done writing cells, giving save cmd...");
						serverBase.server.save({
							done : () => {
console.log("...done giving save cmd.");
								serverBase.setAllControlsEnabled(true);
								//something is making my scroll position jump around, and maybe it's this?
								window.scrollTop = scrollTop;
							},
							fail : () => {
console.log("...failed giving save cmd.");
								//TODO on fail, popup warning and re-enable controls
								fail();
							},
						});
					},
					fail : () => {
console.log("...failed writing cells.");
						//TODO on fail, popup warning and re-enable controls
						fail();
					},
				});
			},
		},
		{
			text : 'Quit',
			click : e => {
				serverBase.server.quit();
				//don't wait for ajax response ... there won't be one
				serverBase.setAllControlsEnabled(false);
				root.prepend(DOM('div', {
					css : {
						font : 'color:red'
					},
					text : "disconnected",
				}));
				//TODO for some reason when we connect the next time, we get a quit message and the server immediately dies.  only one extra quit message.
				// I guess this is an ajax problem if it is sending the request, the server is receiving it and handling it, and then the next server is still getting another request.
			},
		},
	);

	addMenu(
		'Run',
		{
			text : 'Run All',
			click : e => {
				//TODO all controls except 'break execution' for emergency restarts
				serverBase.setAllControlsEnabled(false);
// no need to write all cells, correct?
// because we're calling 'run' on each
// and 'run' itself will write each cell
// but ... then again ... what's the harm?
				writeAllCells({
					done : () => {
						const iterate = i => {
							if (i >= serverBase.ctrls.length
								|| serverBase.ctrls[i].cell.outputtype == 'stop'
							) {
								//done
								serverBase.setAllControlsEnabled(true);
							} else {
								serverBase.ctrls[i].run({
									done : () => { iterate(++i); },
									fail : () => { iterate(++i); },
								});
							}
						};
						iterate(0);
					},
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						//TODO fail
						fail();
					},
				});
			},
		},
		{
			text : 'Reset Env',
			click : e => {
				serverBase.setAllControlsEnabled(false);
				serverBase.server.resetEnv({
					done : () => {
						serverBase.setAllControlsEnabled(true);
					},
					fail : () => {
						serverBase.setAllControlsEnabled(true);
						fail();
					},
				});
			},
		},
	);

	if (args.worksheets) {
		let loadWorksheetButtons = ['Worksheets'];
		args.worksheets.forEach((filename,i) => {
			loadWorksheetButtons.push({
				text : filename,
				click : e => {
					serverBase.setAllControlsEnabled(false);
					serverBase.server.getWorksheet({
						filename : 'tests/'+filename+'.symmath',
						done : cellsjson => {
console.log("getWorksheet results", cellsjson);
							rebuildHtmlFromCells({
								cellsjson : cellsjson,
								done : () => {
									serverBase.setAllControlsEnabled(true);
								},
								fail : () => {
									serverBase.setAllControlsEnabled(true);
									fail();
								},
							});
						},
						fail : () => {
							serverBase.setAllControlsEnabled(true);
							fail();
						},
					});
				},
			});
		});
		addMenu.apply(null, loadWorksheetButtons);
	}

	addMenu(
		'View',
		{
			text : 'Expand All',
			click : e => {
				serverBase.setAllControlsEnabled(false);
				let i = 0;
				let n = serverBase.ctrls.length;
				serverBase.ctrls.forEach((ctrl,i) => {
					ctrl.setHidden({
						hidden : false,
						done : () => {
							++i;
							if (i == n) {
								serverBase.setAllControlsEnabled(true);
							}
						},
						fail : () => {
							serverBase.setAllControlsEnabled(true);
							fail();
						},
					});
				});
			},
		},
		{
			text : 'Collapse All',
			click : e => {
				serverBase.setAllControlsEnabled(false);
				let i = 0;
				let n = serverBase.ctrls.length;
				serverBase.ctrls.forEach((ctrl,i) => {
					ctrl.setHidden({
						hidden : true,
						done : () => {
							++i;
							if (i == n) {
								serverBase.setAllControlsEnabled(true);
							}
						},
						fail : () => {
							serverBase.setAllControlsEnabled(true);
							fail();
						},
					});
				});
			},
		},
		{
			text : 'Clear All Output',
			click : e => {
				serverBase.setAllControlsEnabled(false);

				for (let i = 0; i < serverBase.cells.length; ++i) {
					serverBase.cells[i].output = '';
					serverBase.ctrls[i].refreshOutput();
				}

				// TODO writeAllCells re-reads them and rebuilds
				// don't need to do that here
				writeAllCells({
					done : () => {
						serverBase.setAllControlsEnabled(true);
					}
				});
			},
		},
	);

	let helpDiv = DOM('div', {
		class : 'helpDiv',
		appendTo : root,
	});


	const readmeURL = window.symmathDir+'/README.reference.md';
//console.log('getting readme', readmeURL); 
	fetch(readmeURL)
	.then(response => {
		if (!response.ok) return Promise.reject('not ok');
		response.text()
		.then(text => {
//console.log("got reference", text);
			let converter = new showdown.Converter();
			let help = converter.makeHtml(text);
			helpDiv.append(DOM('button', {
				text : 'x',
				class : 'closeHelpButton',
				click : e => { hide(helpDiv); },
			}));
			helpDiv.append(DOM('div', {innerHTML : help}));
		});
	}).catch(e => {
		console.log("failed to get readme", e);
	});

	addMenu(
		'Help',
		{
			text : 'Help',
			click : e => { show(helpDiv); },
		},
	);

	root.appendChild(menubar);

	serverBase.worksheetDiv = DOM('div', {
		class : 'worksheetDiv',
		appendTo : root,
	});
	root.appendChild(DOM('br'));

	serverBase.setAllControlsEnabled(false);
	getAllCellsFromServerAndRebuildHtml({
		done : () => {
			serverBase.setAllControlsEnabled(true);

			if (serverBase.ctrls.length == 0) {
				//no cells in our file?  at least load the first cell
				serverBase.lastAddNewCellButton.click();
			}

			if (args && args.done) args.done();
		}
	});
}

export {init, fail, serverBase};
