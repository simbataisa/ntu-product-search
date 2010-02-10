package controller.events
{
	import flash.events.Event;

	public class USSearchResultEvent extends Event
	{
		public var xmlResult:XML;
		public static const USSEARCHRESULT:String = "ussearchresult";
		public function USSearchResultEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		
		override public function clone():Event{
			return new USSearchResultEvent(type, xmlResult);
		}
		
	}
}