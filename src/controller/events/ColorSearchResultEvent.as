package controller.events
{
	import flash.events.Event;

	public class ColorSearchResultEvent extends Event
	{
		public var xmlResult:XML;
		public static const CSEARCHRESULT:String = "csearchresult";
		public function ColorSearchResultEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}		
		override public function clone():Event{
			return new ColorSearchResultEvent(type, xmlResult);
		}
		
	}
}