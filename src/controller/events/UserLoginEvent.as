package controller.events
{
	import flash.events.Event;

	public class UserLoginEvent extends Event
	{
		public var message:XML;
		public static const LOGINFAIL = "login fail";
		public static const LOGINSUCCESS = "login success";
		
		public function UserLoginEvent(type:String, mess:XML){
			super(type);
			message = XML(mess);	
		}
		
		override public function clone():Event{
			return new UserLoginEvent(type, message);
		}
	}
}