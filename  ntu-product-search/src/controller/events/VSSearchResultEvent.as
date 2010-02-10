package controller.events
{
	import flash.events.Event;

	public class VSSearchResultEvent extends Event
	{
		public var xmlResult:XML;
		public static const VSSEARCHRESULT:String = "vssearchresult";
		public function VSSearchResultEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		
		override public function clone():Event{
			return new VSSearchResultEvent(type, xmlResult);
		}
		
	}
}