package controller.events
{
	import flash.events.Event;
	
	public class CrawlResultEvent extends Event
	{
		public static const CRAWLRESULT:String = "crawl result";
		//public static const NULLRESULT:String = "";
		public var xmlResult:XML;
		public function CrawlResultEvent(type:String, res:XML)
		{
			super(type);
			xmlResult = XML(res);
		}
		override public function clone():Event{
			return new CrawlResultEvent(type,xmlResult);
		}

	}
}