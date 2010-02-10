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
	[Event(name="vssearchresult", type="controller.events.VSSearchResultEvent")]
	[Event(name="ussearchresult", type="controller.events.USSearchResultEvent")]
	[Event(name="cssearchresult", type="controller.events.CSearchResultEvent")]
	[Event(name="autosuggestion", type="controller.events.AutoSuggestionEvent")]
	[Event(name="keywordgeneration", type="controller.events.KeywordGenerationEvent")]
		
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
		
		public function load(xmlURL:String, vars:URLVariables=null){
			
			var request:URLRequest = new URLRequest(xmlURL);
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
			var i:uint=0;
			/*if(xmlContent.title != "search results"){
				Alert.show(xmlContent.title);
			}*/
			if(xmlContent!=null){				
				if(xmlContent.title == "search results"){
					var resultEvt:SearchResultEvent = new SearchResultEvent(SearchResultEvent.SEARCHRESULT, xmlContent);
					dispatchEvent(resultEvt);
				}else if(xmlContent.title == "vssearch results"){									
					var vsResultEvt:VSSearchResultEvent = new VSSearchResultEvent(VSSearchResultEvent.VSSEARCHRESULT, xmlContent);
					dispatchEvent(vsResultEvt);					
				}else if(xmlContent.title == "ussearch results"){									
					var usResultEvt:USSearchResultEvent = new USSearchResultEvent(USSearchResultEvent.USSEARCHRESULT, xmlContent);
					dispatchEvent(usResultEvt);
				}else if(xmlContent.title == "cssearch results"){												
					var csResultEvt:ColorSearchResultEvent = new ColorSearchResultEvent(ColorSearchResultEvent.CSEARCHRESULT, xmlContent);
					dispatchEvent(csResultEvt);
				}else if(xmlContent.title == "search suggestion"){					
					var autoSuggestionEvt:AutoSuggestionEvent = new AutoSuggestionEvent(AutoSuggestionEvent.AUTOSUGGESTION, xmlContent);
					dispatchEvent(autoSuggestionEvt);
				}else if(xmlContent.title == "keyword generation"){					
					var keywordGenerationEvt:KeywordGenerationEvent = new KeywordGenerationEvent(KeywordGenerationEvent.KEYWORDGENERATION, xmlContent);
					dispatchEvent(keywordGenerationEvt);
				}else if(xmlContent.title == "product categories"){					
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
			var resultEvt:IOLoadEvent = new IOLoadEvent(IOLoadEvent.ERROR, true);
			dispatchEvent(resultEvt);
		}	
	}
}