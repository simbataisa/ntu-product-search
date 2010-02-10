package controller.events
{
	import flash.events.Event;

	public class MessageEvent extends Event
	{
		public static const MESSAGE:String = "message";
		public var mess:String;
		public function MessageEvent(type:String, messa:String)
		{
			super(type);
			this.mess = messa;
		}
		override public function clone():Event{
			return new MessageEvent(type, mess);
		}
		
	}
}