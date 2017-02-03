var _ = require('underscore');
var $ = require('npm-zepto');

module.exports = function(div) {
	_div = div;
	return {
		initialize: function() {
				this.TOTAL_NUMBER_OF_CC_ROWS = 15;
				_.bindAll(this, 'setCcCommand', 'setCcData', 'injectCea608Cue', 'applyCommandStyle');
				this.ccBuffer = this.initializeCcBuffer(this.TOTAL_NUMBER_OF_CC_ROWS);
				this.isbuffering = false;

				//Style changes on preamble and mid row - need to save for buffers
				this.curPreambleRow = -1;
				this.curPreamCommand = {};
				this.curMidRowCommand = {};
				this.tabOffset = {};
				this.rollup = 2;
				this.cssStyles = {};

				//Create 608 display
				this.cea608CustomTracksSelector = '.sixOeight-tracks';
				this.$Cea608CustomContainer = $(_div);
				this.$Cea608CustomContainer
					.addClass('sixOeight-default')
					.append('<div class="sixOeight-tracks"></div>');

				for (var i = 1; i <= this.TOTAL_NUMBER_OF_CC_ROWS; i++) {
					var rowDiv = this.renderRowDiv(i);

					rowDiv.append('<span></span>');
					this.$Cea608CustomContainer
						.find(this.cea608CustomTracksSelector)
						.append(rowDiv);
				}

				//List of commands from flash 608 decoder
				this.COMMANDS = {
					PREAMBLE: 'preamble', //style and positioning preamble
					MID_ROW: 'midrow',
					START_BUFFER: 'resume caption loading', //(start buffered caption text)
					BACKSPACE: 'backspace', //(overwrite last char)
					DELETE_ROW: 'delete to end of row', //(clear line)
					ROLL_UP_2: 'roll up 2', //(scroll size)
					ROLL_UP_3: 'roll up 3', //(scroll size)
					ROLL_UP_4: 'roll up 4', //(scroll size)
					RESUME_DIRECT: 'resume direct captioning', //(start caption text)
					TEXT_RESTART: 'text restart', //(start non-caption text)
					RESUME_DISPLAY: 'resume text display', //(resume non-caption text)
					ERASE_DISPLAY: 'erase displayed memory', //(clear screen)erase displayed memory
					CARRIAGE_RETURN: 'carriage return', //(scroll lines up)
					CLEAR_BUFFER: 'erase non displayed memory', //(clear buffer)
					DISPLAY_BUFFER: 'end of caption', //(display buffer)
					TAB_OFFSET_1: 'tab offset 1', //(add spacing)
					TAB_OFFSET_2: 'tab offset 2', //(add spacing)
					TAB_OFFSET_3: 'tab offset 3' //(add spacing)
				};
		},
		
		renderRowDiv: function(index) {
			return $('<div>')
				.addClass('ccrow row_' + index)
				.css('top', ('6' * index) + '%');
		},

		initializeCcBuffer: function(numRows) {
			var arr = [];

			arr.length = numRows;
			for (var i = 0; i < numRows; i++) {
				arr[i] = '';
			}
			return arr;
		},

		clearCcBuffer: function(buffer) {
			buffer.map(function() {
				return '';
			});
		},

		injectCea608Cue: function(data) {
			if (data.isCommand) {
				this.setCcCommand(data);
			} else {
				this.setCcData(data);
			}
		},

		setCcData: function(ccdata) {
			if (this.isbuffering) {
				if (this.ccBuffer[ccdata.row - 1] === undefined) {
					this.ccBuffer[ccdata.row - 1] = '';
				}
				this.ccBuffer[this.curPreambleRow - 1] += ccdata.captionText;
			} else {
				var ccRowDisplay =
					this.$Cea608CustomContainer
					.find(this.cea608CustomTracksSelector)
					.find('.row_' + ccdata.row)
					.find('span');

				if (this.curMidRowCommand[ccdata.row] !== undefined) {
					this.applyCommandStyle(ccRowDisplay, this.curMidRowCommand[ccdata.row]);
					this.curMidRowCommand[ccdata.row] = undefined;
				}
				if (this.curPreamCommand[ccdata.row] !== undefined) {
					this.applyCommandStyle(ccRowDisplay, this.curPreamCommand[ccdata.row]);
					this.curPreamCommand[ccdata.row] = undefined;
				}
				ccRowDisplay.append(ccdata.captionText);
			}
		},

		setCcCommand: function(ccComand) {
			switch (ccComand.captionText) {
				case this.COMMANDS.START_BUFFER:
					this.isbuffering = true;
					break;
				case this.COMMANDS.DISPLAY_BUFFER:

					//send command to display buffer
					for (var j = 0; j < this.TOTAL_NUMBER_OF_CC_ROWS; j++) {
						var curRow = this.$Cea608CustomContainer
							.find(this.cea608CustomTracksSelector)
							.find('.row_' + (j + 1))
							.find('span');

						curRow.empty();
						if (this.ccBuffer[j] !== '') {
							var displayString = this.ccBuffer[j];

							//We need to adjust this padding value to
							if (this.curPreamCommand[j + 1] !== undefined) {
								this.applyCommandStyle(curRow, this.curPreamCommand[j + 1]);
								this.curPreamCommand[j + 1] = undefined;
							}
							if (this.curMidRowCommand[j + 1] !== undefined) {
								this.applyCommandStyle(curRow, this.curMidRowCommand[j + 1]);
								this.curMidRowCommand[j + 1] = undefined;
							}
							curRow.append(displayString);
							this.ccBuffer[j] = '';
						}
					}
					break;
				case this.COMMANDS.CLEAR_BUFFER:
					this.ccBuffer = this.clearCcBuffer(this.ccBuffer); //eslint-disable-line camelcase
					break;
				case this.COMMANDS.ERASE_DISPLAY:

					//send command to clear all from screen
					this.$Cea608CustomContainer
						.find('.ccrow span')
						.empty();
					break;
				case this.COMMANDS.BACKSPACE:
					var commandRow = this.ccBuffer[ccComand.row - 1];

					if (this.isbuffering && this.ccBuffer.length > 0 &&
						commandRow !== undefined) {
						this.ccBuffer[ccComand.row - 1] = commandRow.slice(0, -1);
					} else {
						var contRow = this.$Cea608CustomContainer.find(this.cea608CustomTracksSelector + ' .row_' + ccComand.row + ' span');

						if (contRow.text() !== undefined) {
							var newtext = contRow.text().slice(0, -1);

							contRow.text(newtext);
						}
					}
					break;
				case this.COMMANDS.DELETE_ROW:

					//Need to adjust this so ony one row is deleted
					this.$Cea608CustomContainer
						.find('.row_' + this.cccomand.row + ' span')
						.empty();
					break;
				case this.COMMANDS.ROLL_UP_2:
					this.rollup = 2;
					break;
				case this.COMMANDS.ROLL_UP_3:
					this.rollup = 3;
					break;
				case this.COMMANDS.ROLL_UP_4:
					this.rollup = 4;
					break;
				case this.COMMANDS.RESUME_DIRECT:
					this.isbuffering = false;
					break;
				case this.COMMANDS.TEXT_RESTART:
					this.log.info('TEXT_RESTART:', this.ccBuffer);
					break;
				case this.COMMANDS.RESUME_DISPLAY:
					this.log.info('RESUME_DISPLAY:', this.ccBuffer);
					break;
				case this.COMMANDS.CARRIAGE_RETURN:

					//move displayed rows up one, clearing the top row
					if (this.isbuffering) {
						this.$Cea608CustomContainer
							.find('.ccrow span')
							.empty();
					} else {
						for (var i = 1; i <= this.TOTAL_NUMBER_OF_CC_ROWS; i++) {
							var toRow = this.$Cea608CustomContainer
								.find(this.cea608CustomTracksSelector)
								.find('.row_' + i)
								.find('span');
							toRow.empty();
							if (toRow !== this.TOTAL_NUMBER_OF_CC_ROWS) {
								var rowCount = i + 1;
								var textToScroll = this.$Cea608CustomContainer
									.find(this.cea608CustomTracksSelector)
									.find('.row_' + rowCount)
									.find('span');
								this.copyRowStyle(
									this.$Cea608CustomContainer
									.find(this.cea608CustomTracksSelector)
									.find('.row_' + i),
									this.$Cea608CustomContainer
									.find(this.cea608CustomTracksSelector)
									.find('.row_' + rowCount));
								if (Math.abs(i - ccComand.row) < this.rollup) {
									toRow.append(textToScroll.text());
								}
							}
						}
					}
					break;
				case this.COMMANDS.TAB_OFFSET_1:
					this.tabOffset[ccComand.row] = 1;
					break;
				case this.COMMANDS.TAB_OFFSET_2:
					this.tabOffset[ccComand.row] = 2;
					break;
				case this.COMMANDS.TAB_OFFSET_3:
					this.tabOffset[ccComand.row] = 3;
					break;
				case this.COMMANDS.PREAMBLE:
					this.curPreambleRow = ccComand.row;
					this.curPreamCommand[ccComand.row] = ccComand;
					break;
				case this.COMMANDS.MID_ROW:
					this.curMidRowCommand[ccComand.row] = ccComand;
					break;
			}
		},

		applyCommandStyle: function(rowToDo, command) {
			var paddingVal;
			var tabToAdd = 0;
			var textColor;
			var backgroundColor;

			textColor = this.cssStyles.color || command.textColor;
			backgroundColor = this.cssStyles.backgroundColor || command.backgroundColor;
			rowToDo.css('color', textColor);
			rowToDo.css('background-color', backgroundColor);
			if (!_.isEmpty(this.cssStyles)) {
				rowToDo.css('font-family', this.cssStyles.fontFamily);
				rowToDo.css('font-size', this.cssStyles.fontSize);
			}

			// non-customizable styles
			rowToDo.css('font-style', (command.italic) ? 'italic' : 'normal');
			rowToDo.css('text-decoration', command.underline ? 'underline' : 'none');
			if (this.tabOffset[command.row] !== undefined) {

				//add any tab offset from commands to this row
				tabToAdd = this.tabOffset[command.row];
				this.tabOffset[command.row] = undefined;
			}
			paddingVal = (command.column + tabToAdd) * 1;
			this.$Cea608CustomContainer
				.find(this.cea608CustomTracksSelector)
				.find('.row_' + command.row)
				.css('padding-left', paddingVal + 'em');
		},

		copyRowStyle: function(toRow, fromRow) {
			var toSpan = toRow.find('span');
			var fromSpan = fromRow.find('span');

			toRow.css('padding-left', fromRow.css('padding-left'));
			toSpan.css('color', fromSpan.css('color'));
			toSpan.css('font-style', fromSpan.css('font-style'));
			toSpan.css('background-color', fromSpan.css('background-color'));
			toSpan.css('text-decoration', fromSpan.css('text-decoration'));
		}
	}
}