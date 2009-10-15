package controller
{
	import controller.events.UserLoginEvent;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	[Bindable]
	public class UserManager
	{
		private var loader:URLLoader;
		public function UserManager()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loginHandler);
		}
		
		public function login(user:String, pass:String):void{
			var request:URLRequest = new URLRequest("Controller/login.php");
			request.method = URLRequestMethod.POST;
			var data:URLVariables = new URLVariables("user="+user+"&pass="+pass);
			request.data = data;
			//Alert.show("loging..");
			try{
				loader.load(request);
			}
			catch(e:Error){
				Alert.show("Can't login: " + e.message);
			}
		}
		
		public function logout():void{
			
		}
		
		private function loginHandler(e:Event){
			
			var message:XML = XML(e.target.data);
			//Alert.show(message.account.toXMLString());
			//Alert.show(message.account.error.toString());
			if(message.account.error.toString() == "" ){
				var loginSuccess:UserLoginEvent = new UserLoginEvent(UserLoginEvent.LOGINSUCCESS, message);
				dispatchEvent(loginSuccess);
				//Alert.show("Success");
			}
			else{
				var loginFail:UserLoginEvent = new UserLoginEvent(UserLoginEvent.LOGINFAIL, message);
				dispatchEvent(loginFail);
				//Alert.show("fail");
			} 
		}
	}
	
}