package com.viacom.brbpl.decoder
{
	import com.viacom.brbpl.ccdata.CCData;
	import com.viacom.brbpl.constants.CharacterMapping;
	import com.viacom.brbpl.events.CCDataEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class Decoder608 extends EventDispatcher
	{
		private var ccDisplayString:String = ""; //this should be some sort of CC_Object that we parse into
		private var lastCommand:Array = [0,0];
		private var currentCommand:uint = 0;
		private var currentBGStyle:String = "black";
		private var currentBGTrans:uint = 0;
		private var currentTextStyle:String = "white";
		
		private var underline:Boolean = false;
		private var italic:Boolean = false;
		private var _currentCCData:CCData;
		//608 CC is commonly laid out in a  32x15 character grid indents identify column location
		private var currentRow:Number = 11;
		private var currentColumn:Number = 0;
		private var styleArray:Array = ["white", "green", "blue", "cyan", "red", 
			"yellow", "magenta", "italics", 0, 
			4, 8, 12, 16, 20, 24, 28];
		
		public function Decoder608() 
		{
		}
		
		public function processCCData(data:ByteArray):void
		{						
			var byte:uint;
			while(data.bytesAvailable)
			{	
				//Need to check the logic here, I think we might want to parse this byte only once
				//in the cases where there are more characters in a single payload there would
				//not be another count/valid byte, in which case the check for 255 would have to be
				//on the cc_data_ bytes and not this one. This might be where we were losing
				//data on the higher akamai renditions
				byte = data.readUnsignedByte();					
				if((byte & 255) == 255){
					//end of packet
					return;
				}
				
				var ccValid:Boolean = !((byte & 4) == 0);	
				var total:uint = 31 & byte;
				
				if(ccValid)
				{
					if(data.bytesAvailable)
						var cc_data_1:uint = data.readUnsignedByte();
					if(data.bytesAvailable)
						var cc_data_2:uint = data.readUnsignedByte();		
					
					if(checkCommandByte(cc_data_1, cc_data_2))
					{
						//CC was a command
						if(ccDisplayString != "")
						{						
							ccDisplayString = "";
						}
						if(!duplicateCommand)
							dispatchEvent(new CCDataEvent(CCDataEvent.CC_COMMAND,_currentCCData.exportJSON()));
						else
							duplicateCommand = false;
					}
					else{
						var displayByte_1:uint = cc_data_1&127;
						var displayByte_2:uint = cc_data_2&127;
						var ccdatatext:String = '';
						//check for special characters     118
						//P|0|0|1|C|0|0|1| |P|0|1|1|  CHAR |
						if(!(displayByte_1 == 0 && displayByte_2 == 0)){ //In some encodign we are seeing mega 0's both have to be 
							if(((displayByte_1 & 17) == 17 && (displayByte_1 & 102) == 0 )
								&& ((displayByte_2 & 48) == 48 && (displayByte_2 & 64) == 0 ))
							{
								//Special Chartacter
								ccDisplayString += CharacterMapping.getSpecialCharacter((displayByte_2 & 63));						
								ccdatatext += CharacterMapping.getSpecialCharacter((displayByte_2 & 63));						
							}
							// |P|0|0|1|C|0|1|S| |P|0|1|CHARACTER|
							else if(((displayByte_1 & 18) == 18 && (displayByte_1 & 101) == 0 )
								&& ((displayByte_2 & 32) == 32 && (displayByte_2 & 64) == 0 ))
							{
								//Extended spanish french special character 
								dispatchBackspaceCommand();
								ccDisplayString += CharacterMapping.getExtendedSpecialCharacter((displayByte_2 & 63), CharacterMapping.SPANISH_FRENCH);						
								ccdatatext += CharacterMapping.getExtendedSpecialCharacter((displayByte_2 & 63), CharacterMapping.SPANISH_FRENCH);	
							}
							else if(((displayByte_1 & 19) == 19 && (displayByte_1 & 100) == 0 )
								&& ((displayByte_2 & 32) == 32 && (displayByte_2 & 64) == 0 ))
							{
								//Extended German Dutch special character
								dispatchBackspaceCommand();
								ccDisplayString += CharacterMapping.getExtendedSpecialCharacter((displayByte_2 & 63), CharacterMapping.GERMAN_DUTCH);						
								ccdatatext += CharacterMapping.getExtendedSpecialCharacter((displayByte_2 & 63), CharacterMapping.GERMAN_DUTCH);	
							}
							else
							{	
								if(displayByte_1 != 127){
									ccdatatext += CharacterMapping.getCharacter(displayByte_1);
									ccDisplayString += String.fromCharCode(displayByte_1);
								}
								if(displayByte_2 != 127){
									ccDisplayString += String.fromCharCode(displayByte_2);
									ccdatatext += CharacterMapping.getCharacter(displayByte_2);
								}
							}							
							_currentCCData = new CCData(ccdatatext, currentTextStyle, currentBGStyle, 
								underline, italic, currentBGTrans, currentRow, currentColumn);								
							dispatchEvent(new CCDataEvent( CCDataEvent.CC_DATA, _currentCCData.exportJSON()));							
						}
					}
				}
			}
		}
		
		private function dispatchBackspaceCommand():void
		{
			var backspaceCommand:CCData = new CCData('backspace',  currentTextStyle, currentBGStyle, underline, italic, currentBGTrans, currentRow, currentColumn);
			backspaceCommand.isCommand = true;
			dispatchEvent(new CCDataEvent(CCDataEvent.CC_COMMAND,backspaceCommand.exportJSON()));
		}
		
		private var duplicateCommand:Boolean = false;
		private function checkCommandByte(byte1:uint, byte2:uint):Boolean
		{
			//It is common practice to send commands twice, and as such we shall discard any
			//duplicate commands
			if(lastCommand[0] == byte1 && lastCommand[1] == byte2)
			{
				duplicateCommand = true;
				return true;
			}
			var isCommand:Boolean = false;
			//check if bit 12 are on (00010000) for byte one,
			//and that 12 and 13 are off (& 01100000 == 0)
			//Check for pre-amble command
			if(((byte1 & 16) == 16) && ((byte1 & 96) == 0) && ((byte2 & 64) == 64))
			{
				var rowPos:uint = (byte1 & 7);
				var rowToggle:Boolean = !((byte2 & 32) == 0);
				var channel:Boolean = !((byte1 & 8)== 0);
				currentRow = getCommandRow(rowPos,rowToggle);
				
				italic = false;
				if(((byte2 & 30)>>> 1) > 7)
					currentColumn = Number(getStyleAttributes((byte2 & 30) >>> 1));
				else if(((byte2 & 30)>>> 1) == 7)
					italic = true;
				else
					currentTextStyle = String(getStyleAttributes((byte2 & 30)>>> 1));
				
				underline = !((byte2 & 1) == 0);
				lastCommand[0] = byte1;
				lastCommand[1] = byte2;
				_currentCCData = new CCData("preamble", currentTextStyle, currentBGStyle, underline, italic, currentBGTrans, currentRow, currentColumn);
				_currentCCData.isCommand = true;
				isCommand = true;
			}
				//check for midrow command
				//Bits 14, 13, 10, 9, 6 and 4 are always 0, bits 12, 8 and 5 are always 1. 
				// 01100110 0101000 == 0 && 00010001 0010000 != 0
				//channel bit
			else if(((byte1 & 17) == 17) && ((byte1 & 102) == 0) && ((byte2 & 32) == 32) && ((byte2 & 80) == 0))
			{
			//	trace("Command - \tMidroll ", byte1.toString(2), byte2.toString(2));
				lastCommand[0] = byte1;
				lastCommand[1] = byte2;
				currentBGStyle = getBGColor(byte1,byte2);
				isCommand = true;
				_currentCCData = new CCData("midrow", currentTextStyle, currentBGStyle, underline,italic, currentBGTrans, currentRow, currentColumn);
				_currentCCData.isCommand = true;				
			}
				//check for other control codes 
				//Bits 14, 13, 9, 6 and 4 are always 0, bits 12, 10 and 5 are always 1.
			else if(((byte1 & 20) == 20) && ((byte1 & 98) == 0) && ((byte2 & 32) == 32) && ((byte2 & 80) == 0))
			{
				//trace("Command - \tOther ", byte1.toString(2), byte2.toString(2));
				lastCommand[0] = byte1;
				lastCommand[1] = byte2;
				_currentCCData = new CCData(getOtherCommand(byte2 & 15), currentTextStyle, currentBGStyle, underline, italic, currentBGTrans, currentRow, currentColumn);
				_currentCCData.isCommand = true;
				isCommand = true;
			}
			//check for tab offset commands
			else if(((byte1 & 23) == 23) && ((byte1 & 96) == 0) && ((byte2 & 32) == 32) && ((byte2 & 80) == 0))
			{
				lastCommand[0] = byte1;
				lastCommand[1] = byte2;
				_currentCCData = new CCData(getTabOffSet(byte2 & 7), currentTextStyle, currentBGStyle, underline, italic,currentBGTrans, currentRow, currentColumn);
				_currentCCData.isCommand = true;
				isCommand = true;
			}
			return isCommand;
		}
		
		private function getCommandRow(rowPosition:uint, rowToggle:Boolean):uint
		{
			//TODO set CONSTANTS
			//(Default Row 11 = 0,top rows 1-4 = 1-2,bottom rows 12-13 = 3)
			//row 11 (0000), 1 (0010), 2 (0011), 3, 4, 12, 13, 14, 15, 5, 6, 7, 8, 9, or 10 (1111).
			var row:uint = 11;
			switch(rowPosition)
			{
				case 0:
					row = 11;
					break;
				case 1:
					row = (rowToggle)?2:1;
					break;
				case 2:
					row = (rowToggle)?4:3;
					break;
				case 3:
					row = (rowToggle)?13:12;
					break;
				case 4:
					row = (rowToggle)?15:14;
					break;
				case 5:
					row = (rowToggle)?6:5;
					break;
				case 6:
					row = (rowToggle)?8:7;
					break;
				case 7:
					row = (rowToggle)?10:9;
					break;
			}
			//trace("\tRow: ", row);
			return row;
		}
		
		private function getStyleAttributes(style:uint):*
		{
			//white (0000), green, blue, cyan, red, yellow, magenta, italics, indent 0, indent 4, 
			//indent 8, indent 12, indent 16, indent 20, indent 24, indent 28 (1111).
			return styleArray[style] ;
		}
		
		private function getBGColor(byte1:uint, byte2:uint):String
		{
			var bgColor:String = currentBGStyle;
			var bgColors:Array = ["white","green", "cyan", "red", "yellow", "magenta", "black"];
			// Black text P|0|0|1|C|1|1|1| |P|0|1|0|1|1|1|U|
			// No BG byte 1 & 7 == 7  byte2 & 10101101 
			// bg color |P|0|0|1|C|0|0|0| |P|0|1|0|COLOR|T| 
			// midrow style |P|0|0|1|C|0|0|1| |P|0|1|0|STYLE|U
			//{white=0,green,blue,cyan,red,yellow,magenta,black}
			if((byte1 & 7) == 7 && byte2 == 173)
			{
				bgColor = "noBG";
			}
			else if((byte1 & 7) == 7  && (byte2 & 12) == 12)
			{
				bgColor = "blackText";
			}
			else if((byte1 & 1) == 1)
			{
				//midrow style
				//trace("Midrow style change Style: ",(byte2 & 14).toString(2) );
				if(((byte2 & 30)>>> 1) > 7)
					currentColumn = Number(getStyleAttributes((byte2 & 30) >>> 1));
				else if(((byte2 & 30)>>> 1) == 7)
					italic = true;
				else
					currentTextStyle = String(getStyleAttributes((byte2 & 30)>>> 1));
				
				underline = !((byte2 & 1) == 0);
			}
			else
			{
				bgColor = bgColors[(byte2 & 14)];
			}
			return bgColor;
		}
		
		
		private function getOtherCommand(com:uint):String
		{
			//resume caption loading (0000), backspace (0001), delete to end of row (0100), roll-up captions 2-rows, roll-up captions 3 rows, roll-up captions 4-rows, flash on (0.25 seconds once per second), resume direct captioning, text restart, resume text display, erase displayed memory, carriage return, erase nondisplayed memory, end of caption (1111)
			var commands:Array = ["resume caption loading", "backspace", '','',"delete to end of row", "roll-up captions 2-rows",
				"roll-up captions 3 rows", "roll-up captions 4-rows", "flash on (0.25 seconds once per second)", "resume direct captioning", 
				"text restart", "resume text display", "erase displayed memory", "carriage return", "erase nondisplayed memory",
				"end of caption"];
			var command:String = commands[com];
			return command;
		}
		
		private function getTabOffSet(com:uint):String
		{
			var offset:Array = ["tab offset 1","tab offset 2","tab offset 3"];
			if(com - 1 < 0 || com -1 > 2)
				com = 0;
			return offset[com - 1]; 
		}
		
		private function logDataPacket(data:ByteArray):void
		{
			while(data.bytesAvailable)
			{
				var tempByte:uint = data.readUnsignedByte();
				var byteString:String = tempByte.toString(2);
				var displayByte:uint = tempByte&127;
				//trace(displayByte.toString(2), "\t:", String.fromCharCode(displayByte));
			}			
		}
	}
}