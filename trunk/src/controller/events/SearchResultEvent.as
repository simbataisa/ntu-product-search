package controller.events
{
	import flash.events.Event;
	
	public class SearchResultEvent extends Event
	{
		public var xmlResult:XML;
		public static const SEARCHRESULT:String = "searchresult";
		
		public function SearchResultEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		
		override public function clone():Event{
			return new SearchResultEvent(type, xmlResult);
		}
		
	}
}