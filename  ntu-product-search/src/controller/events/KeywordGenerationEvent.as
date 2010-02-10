package controller.events
{
	import flash.events.Event;

	public class KeywordGenerationEvent extends Event
	{
		public var xmlResult:XML;
		public static const KEYWORDGENERATION:String = "keywordgeneration";
		public function KeywordGenerationEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		
		override public function clone():Event{
			return new KeywordGenerationEvent(type, xmlResult);
		}
		
	}
}