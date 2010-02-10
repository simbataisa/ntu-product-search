package controller.events
{
	import flash.events.Event;

	public class AutoSuggestionEvent extends Event
	{
		public var xmlResult:XML;
		public static const AUTOSUGGESTION:String = "autosuggestion";
		public function AutoSuggestionEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		
		override public function clone():Event{
			return new AutoSuggestionEvent(type, xmlResult);
		}
		
	}
}