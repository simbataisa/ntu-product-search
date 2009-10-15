// ActionScript file
import controller.RequestManager;
import controller.ResultLoader;
import controller.events.CategoryEvent;
import controller.events.CrawlResultEvent;
import controller.events.MerchantEvent;

import flash.events.TimerEvent;
import flash.net.URLVariables;
import flash.system.Security;
import flash.utils.Timer;

import mx.events.FlexEvent;
import mx.controls.Alert;

private var categories:XMLList;
private var merchants:XMLList;
private var loader:ResultLoader = new ResultLoader();
private var requester:RequestManager = new RequestManager();
private var timer:Timer;

private function init():void{
	start.addEventListener(FlexEvent.BUTTON_DOWN, startCrawlHandler);
	stop.addEventListener(FlexEvent.BUTTON_DOWN, stopCrawlHandler);
	clear.addEventListener(FlexEvent.BUTTON_DOWN, clearOutput);
	//Security.allowDomain();
	getCategories();
}
private function startCrawlHandler(e:FlexEvent):void{
	//start crawling here
	output.text = "Crawling ...\n " ;
	start.enabled = false;
	stop.enabled = true;
	clear.enabled = true;
	
	//var category:String = parseCategory(selectCat.selectedLabel.@id);
	
	var category:String = selectCat.selectedItem.@id;

	
	var params:URLVariables= new URLVariables("opt=start&category="+category+"&merchant=amazon&max=100");
	requester.send("http://msm.cais.ntu.edu.sg:8080/Search/RequestHandler", params);
	//send_data();
	loader.addEventListener(CrawlResultEvent.CRAWLRESULT, crawlResultHandler);
	timer = new Timer(10000);
	timer.addEventListener(TimerEvent.TIMER, TimerHandler);
	timer.start();
}

private function stopCrawlHandler(e:FlexEvent):void{
	stop.enabled = false;
	start.enabled = true;
	var params:URLVariables= new URLVariables("opt=stop");
	timer.stop();
	requester.send("http://msm.cais.ntu.edu.sg:8080/Search/RequestHandler", params);		
}

private function clearOutput(e:FlexEvent):void{
	output.text = "";
}
private function getCategories():void{
	 loader.addEventListener(CategoryEvent.CATEGORY, categoryHandler);	
     var params:URLVariables = new URLVariables("opt=check");
     loader.load("Controller/getCategories.php", params);
}

private function getMerchants():void{
	loader.addEventListener(MerchantEvent.MERCHANT, merchantHandler);
	loader.load("Controller/getMerchants.php");
}

private function merchantHandler(e:MerchantEvent):void{
	merchants = e.content.merchants.merchant;
	selectMerchant.dataProvider = merchants;
}
private function categoryHandler(e:CategoryEvent):void{
	//Alert.show(e.xmlCategories.toXMLString());
	categories = e.xmlCategories.categories.node;
	
	selectCat.dataProvider = categories;
	//Alert.show(selectCat.data.toString());
	getMerchants();
}

private function TimerHandler(e:TimerEvent):void{
	//Alert.show("send");
	var params:URLVariables= new URLVariables("opt=check");
	//requester.send("http://msm.cais.ntu.edu.sg:8080/Search/RequestHandler", params);
	loader.load("http://msm.cais.ntu.edu.sg:8080/Search/RequestHandler", params);
}

private function crawlResultHandler(e:CrawlResultEvent):void{
	//Alert.show(e.xmlResult.toXMLString());
	//Alert.show("here");
	//output.text +=e.xmlResult.title + "\n";
	var c:XMLList = e.xmlResult.categories.category;
	if(c!=null){
		for(var i:uint; i< c.length(); i++)
			output.text += "add category: " + c[i] + "\n";
	}
	var p:XMLList = e.xmlResult.products.product;
	if(p != null){
		for(var i:uint; i< p.length(); i++)
			output.text += p[i] + "\n";
	} 
}
private function loadSecurity():void{
	
	Security.loadPolicyFile("crossdomain.xml");
	Security.loadPolicyFile("http://msm.cais.ntu.edu.sg/~tamvu/download/crossdomain.xml");
	Security.loadPolicyFile("http://localhost/~tamvu/download/crossdomain.xml");
	Security.allowDomain("*");
	Security.allowDomain("localhost");
	Security.allowDomain("msm.cais.ntu.edu.sg");
	Security.allowDomain("127.0.0.1");	
}

private function parseCategory(cat:String):String{
	var pattern:RegExp = /\u0020/gi;
	cat = cat.replace(pattern, "%20");	
	
	pattern = /\u0026/gi;
	cat = cat.replace(pattern, "%26");
	pattern = /\u002C/gi;
	cat = cat.replace(pattern, "%2C");
	return cat;
}
