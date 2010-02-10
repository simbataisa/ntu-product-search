package controller.events
{
	import flash.events.Event;

	public class MerchantEvent extends Event
	{
		public static const MERCHANT = "merchant";
		public var content:XML;
		public function MerchantEvent(type:String, con:XML)
		{
			super(type);
			content = con;
		}
		
		override public function clone():Event{
			return new MerchantEvent(type, content);
		}
		
	}
}