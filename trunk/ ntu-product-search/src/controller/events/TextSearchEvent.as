package controller.events
{
	import flash.events.Event;
	
	public class TextSearchEvent extends Event
	{		
		public var userQuery:String;
		public static const TEXTCHANGE:String = "textChange";
		public function TextSearchEvent(type:String, userQuery:String){
			super(type);
			this.userQuery = userQuery;
		}
		
		override public function clone():Event{
			return new TextSearchEvent(type, userQuery);
		}
	}
}