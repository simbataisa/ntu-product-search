package controller.events
{
	import flash.events.Event;

	public class URLUploadEvent extends Event
	{
		public var xmlResult:XML;
		public static const UPLOADRESULT:String = "uploadresult";
		
		public function URLUploadEvent(type:String,res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		
		override public function clone():Event{
			return new URLUploadEvent(type, xmlResult);
		}
		
	}
}