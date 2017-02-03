package com.viacom.brbpl.ccdata
{
	public class CCData
	{
		public var captionText:String = "";
		public var backgroundColor:String;
		public var textColor:String;
		public var underline:Boolean;
		public var transparent:Boolean;
		public var isCommand:Boolean;
		public var row:Number;
		public var column:Number;
		public var italic:Boolean;
		public function CCData(text:String, textstyle:String = 'white', bgcolor:String = 'black', underlineText:Boolean = false, italics:Boolean = false, transparentBG:Boolean = false, curRow:Number = 11, curCol:Number = 0)
		{
			captionText = text;
			backgroundColor = bgcolor;
			textColor = textstyle;
			underline = underlineText;
			italic = italics;
			transparent = transparentBG;
			row = curRow;
			column = curCol;
		}
		
		public function exportJSON():String
		{
			var jsonText:String = JSON.stringify(this);	
			return jsonText;
		}
	}
}