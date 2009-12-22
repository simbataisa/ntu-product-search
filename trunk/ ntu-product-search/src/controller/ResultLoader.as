package controller
{
	import controller.events.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	[Bindable]
	
	[Event(name="category", type="controller.events.CategoryEvent")]
	[Event(name="crawlresult", type="controller.events.CrawlResultEvent")]
	[Event(name="error", type="controller.events.IOLoadEvent")]
	[Event(name="merchant", type="controller.events.MerchantEvent")]
	[Event(name="message", type="controller.events.MessageEvent")]
	[Event(name="searchresult", type="controller.events.SearchResultEvent")]
		
	public class ResultLoader extends EventDispatcher
	{
		private var xmlContent:XML;
		private var xmlLoader:URLLoader;
		private var myalert:Alert;
		public function ResultLoader(){
			xmlLoader = new URLLoader();			
			xmlLoader.addEventListener(Event.COMPLETE, completeHandler);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, io_errorHandler);
		}
		
		public function load(xmlFile:String, vars:URLVariables=null){
			
			var request:URLRequest = new URLRequest(xmlFile);
			request.method = URLRequestMethod.POST;
			try{
				if(vars!= null){
					request.data = vars;	
					xmlLoader.load(request);									
				}else{
					Alert.show("Invalid Search Keyword","Error");
				}
												
			}
			catch(e:Error){
				Alert.show("can't load the document" + e.message);				
			}
		}		
		
		private function completeHandler(e:Event):void{		
			xmlContent = new XML(e.target.data);			
			if(xmlContent!=null){
								
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
		}	
		
		private function io_errorHandler(event:Event):void{
			Alert.show("Unable to connect to server");
		}	
	}
}