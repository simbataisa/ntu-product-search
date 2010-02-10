package controller.events
{
	import flash.events.Event;
	public class IOLoadEvent extends Event
	{
		public var isError:Boolean;
		public static const ERROR:String = "error";
		public function IOLoadEvent(type:String, res:Boolean){
			super(type);
			isError = res;
		}
		
		override public function clone():Event{
			return new IOLoadEvent(type, isError);
		}		
	}
}