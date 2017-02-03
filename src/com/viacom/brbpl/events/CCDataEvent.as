package com.viacom.brbpl.events
{
	import flash.events.Event;
	
	public class CCDataEvent extends Event
	{
		public static var CC_DATA:String = "cc_data";
		public static var CC_COMMAND:String = "cc_command";
		public var data:*;
		public function CCDataEvent(type:String, _data:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			data = _data;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new CCDataEvent(data, type, bubbles, cancelable);
		}
	}
}