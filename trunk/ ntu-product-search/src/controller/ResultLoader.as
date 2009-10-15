package controller
{
	import controller.events.*;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	[Bindable]
	public class ResultLoader
	{
		private var xmlContent:XML;
		private var xmlLoader:URLLoader;
		private var myalert:Alert;
		
		public function ResultLoader(){
			xmlLoader = new URLLoader();
			//xmlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, test);
			xmlLoader.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		public function load(xmlFile:String, vars:URLVariables=null):void{
			
			var request:URLRequest = new URLRequest(xmlFile);
			request.method = URLRequestMethod.POST;
		//	Alert.show(xmlFile);
			try{
				if(vars!= null)
					request.data = vars;
					//Alert.show(vars);
				xmlLoader.load(request);
			}
			catch(e:Error){
				Alert.show("can't load the document" + e.message);
			}
		}
		
		private function completeHandler(e:Event){
			
			if(e.target.data!=null){
				
				
				//myalert = Alert.show(e.target.data);
				
				
				
				xmlContent = new XML(e.target.data);
			
				if(xmlContent.title == "search results"){
				
					var resultEvt:SearchResultEvent = new SearchResultEvent(SearchResultEvent.SEARCHRESULT, xmlContent);
					dispatchEvent(resultEvt);
				}
				else if(xmlContent.title == "product categories"){
				
					var categoryEvt:CategoryEvent = new CategoryEvent(CategoryEvent.CATEGORY, xmlContent);
					dispatchEvent(categoryEvt);				
				}
				else if(xmlContent.title == "crawl results"){
					var crawlEvt:CrawlResultEvent = new CrawlResultEvent(CrawlResultEvent.CRAWLRESULT, xmlContent);
					dispatchEvent(crawlEvt);
				}
				else if(xmlContent.title == "message"){
					var messEvt:MessageEvent = new MessageEvent(MessageEvent.MESSAGE, xmlContent.messages.error.toString());
					dispatchEvent(messEvt);
				}
				else if(xmlContent.title =="merchant"){
					var merEvt:MerchantEvent = new MerchantEvent(MerchantEvent.MERCHANT, xmlContent);
					dispatchEvent(merEvt);
				}
			}
			//dispatch 2 events here - categories or search Result received.
		}
		/*
		private function test(e:HTTPStatusEvent){
			//var evt:HTTPStatusEvent = HTTPStatusEvent(e);
			Alert.show("attempting");
			Alert.show(e.status.toString());
	
		}
		*/
	}
}