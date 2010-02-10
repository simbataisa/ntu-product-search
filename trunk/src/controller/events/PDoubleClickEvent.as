package controller.events
{
	import flash.events.Event;

	public class PDoubleClickEvent extends Event
	{
		public var pXML:XML;
		public static const PDOUBLECLICK:String = "pdoubleclick";
		public function PDoubleClickEvent(type:String,input:XML)
		{
			super(type);
			pXML = XML(input);
		}
		
		override public function clone():Event{
			return new PDoubleClickEvent(type, pXML);
		}
		
	}
}