package controller.events
{
	import flash.events.Event;

	public class RatingEvent extends Event
	{
		public var obj:Object;
		public static const RATING:String = "rating";
		public function RatingEvent(type:String,res:Object)
		{
			super(type);
			obj = res;
		}
		
		override public function clone():Event{
			return new RatingEvent(type, obj);
		}
		
	}
}