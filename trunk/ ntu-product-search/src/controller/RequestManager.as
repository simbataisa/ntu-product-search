package controller
{
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	[Bindable]
	public class RequestManager
	{
		private var loader:URLLoader;
		public function RequestManager(){

				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, completeHandler);

		}
		
		private function completeHandler(e:Event):void{
			var result:String = e.target.data;
			Alert.show(result);
		} 
		
		public function send(file:String, vars:URLVariables=null):void{
			var request:URLRequest = new URLRequest(file);
			request.method = URLRequestMethod.GET;
			try{
				if(vars!=null)
					request.data = vars;
				loader.load(request);
			}catch(e:Error){
				Alert.show(e.message);
			}	 
		}
	}
}