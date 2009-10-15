// ActionScript file
import content.navigation.winProgress;

import controller.ResultLoader;
import controller.events.*;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.URLVariables;
import flash.xml.XMLNode;
import flash.xml.XMLNodeType;

import mx.controls.Alert;
import mx.events.ColorPickerEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.events.NumericStepperEvent;
import mx.managers.*;
private var loader:ResultLoader =  new ResultLoader();
private var baseURL:String = "http://msm.cais.ntu.edu.sg/~sngy0005/ProductSearch/";

private var categories:XMLList;
[Bindable]
private var products:XMLList;
[Bindable] 

public var upload:XML;

private var query:String = "";
private var pageLength:uint = 30;
private var totalResults:uint; 
private var totalONpage:uint; 
private var sort:String = "";
private var sortBy:String = "";
private var visual:Boolean=false;
private var CustomVisual:Boolean = false;
private var ranking:Boolean = false;
private	var p_id:String = "";  //contentBox.leftPanel.visualSearch.product.db_id;
private	var c_id:String =""; //contentBox.leftPanel.visualSearch.product.category;
private var pageNo:uint;
var r:String="";
var b:String="";
var g:String="";




private var fileref:FileReference = new FileReference;
private const _strUploadScript:String = "Controller/upload.php";
private var _winProgress:winProgress;

public function getCategories():void{
	//Alert.show("hello");
	loader.addEventListener(CategoryEvent.CATEGORY, categoryHandler);
	var params:URLVariables = new URLVariables("opt=get2level");
	loader.load("Controller/getCategories.php", params);
}

private function categoryHandler(e:CategoryEvent):void{
	
	categories = new XMLList();
	var allCate:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, "node");
	allCate.attributes.label = "All Categories";
	allCate.attributes.id="";
	var allCateNode:XML = XML(allCate);
	
	categories[0] = allCateNode;
	for(var i:uint; i< e.xmlCategories.categories.node.length(); i++){
		categories[i+1] = e.xmlCategories.categories.node[i];
	}
	headerBox.cateSelect.dataProvider=categories;
	if(e.xmlCategories.categories.node.length()<=10)
		headerBox.menu.dataProvider = e.xmlCategories.categories.node;
	else{
		
		var temp:XMLList = new XMLList();

		var more:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE,"node");
		more.attributes.label = "More";
		var aMenu:XML = XML(more);
		
		for(var i:uint=0; i<e.xmlCategories.categories.node.length(); i++){
			if(i<10){
				temp[i] = e.xmlCategories.categories.node[i];
			}
			else{
				aMenu.appendChild(e.xmlCategories.categories.node[i]);
			}
		}
	
		temp[10] = aMenu;
		headerBox.menu.dataProvider = temp;
	}

}

public function getDefault():void{
	
	//main.selectedIndex =1;
	loader.addEventListener(MessageEvent.MESSAGE, messageHandler);
	loader.addEventListener(SearchResultEvent.SEARCHRESULT, resultHandler);
	loader.load("Model/results.xml");
	
	//contentBox.mainDisplay.page.text= "1";
	
	//get data for display left 1

	//get data for display left 2;
}

private function messageHandler(e:MessageEvent):void{
	if(main.selectedIndex == 1){
		contentBox.mainDisplay.searchResults.results = null;
		contentBox.mainDisplay.searchResults.statusBar.text = e.mess;
	}
}
private function resultHandler(e:SearchResultEvent):void{
	
	//Alert.show(e.xmlResult.toXMLString());
	products = e.xmlResult.products.item;
	
	totalResults = uint(e.xmlResult.total);
	totalONpage= uint(e.xmlResult.total_found);
	
	
	//Alert.show(totalResults.toString()); 
	//Alert.show(e.xmlResult.total);
	//Alert.show(e.xmlResult.total_found);
	if(main.selectedIndex == 1){
		contentBox.mainDisplay.searchResults.results = null;
		contentBox.mainDisplay.searchResults.gridResult.dataProvider = null;
		contentBox.mainDisplay.searchResults.gridResult.invalidateDisplayList();
		//contentBox.mainDisplay.searchResults.gridResult.dataProvider = products;
		contentBox.mainDisplay.searchResults.results = products;
		contentBox.mainDisplay.Nopage.text = " of " + (Math.ceil(Number(totalResults)/pageLength)) + " Pages";
		//contentBox.leftPanel.textSearch.details = products[0];
		//Alert.show(products[0].id);
		var imgs:Array = new Array();
		imgs.push(products[0].primaryImage);
		for(var i:uint = 0; i< products[0].variantImage.length(); i++)
			imgs.push(products[0].variantImage[i]);
			
		//contentBox.leftPanel.textSearch.images = imgs;
		
		//contentBox.leftPanel.textSearch.currentImgId = 0;
		//contentBox.leftPanel.visualSearch.product = products[0 ];
		if(Math.ceil(Number(totalResults)/pageLength) <= 1)
		{
			contentBox.mainDisplay.nextPage.enabled = false;
			contentBox.mainDisplay.prevPage.enabled = false;
			
			
		}
		else
			contentBox.mainDisplay.nextPage.enabled = true;
		
		contentBox.mainDisplay.searchResults.statusBar.text = "Found: " + totalResults.toString() +  " matches in " + e.xmlResult.searchTime + " sec for query '"+query+"'";
	}
	else if(main.selectedIndex == 0){
		//welcomePage.photoList.dataProvider = products;
		welcomePage.topProducts = products;
		welcomePage.displayProduct = XML(products[0]);
	
	}

	
	if(categories == null)
		getCategories();
	
}






private function iniApp():void{
	

	getDefault();
	//contentBox.addEventListener(FlexEvent.CREATION_COMPLETE, mainChangeHandler);
	welcomePage.photoList.dataProvider = products;
	headerBox.menu.addEventListener(MenuEvent.ITEM_CLICK, categorySelected);
	main.addEventListener(IndexChangedEvent.CHANGE, switchViewHandler);
	headerBox.searchBut.addEventListener(FlexEvent.BUTTON_DOWN, searchHandler);
	headerBox.query.addEventListener(FlexEvent.ENTER, keyPressHandler);
	contentBox.addEventListener(FlexEvent.CREATION_COMPLETE, mainChangeHandler);
	
	//Alert.show("WIdth = " + contentBox.screen.width + "Height = " +contentBox.screen.height);
	
}



private function categorySelected(e:MenuEvent):void{
	if(main.selectedIndex == 0)
		main.selectedIndex = 1;
		//Alert.show("category=" + e.item.@id +"name" + e.item.@label);
	//	query=e.item.@label;
	var params:URLVariables = new URLVariables("category=" + e.item.@id + "&query=" +e.item.@name ); 		
	loader.load("Controller/getResult.php", params);
}
private function mainChangeHandler(e:FlexEvent):void{	
		// contentBox.leftPanel.addEventListener(IndexChangedEvent.CHANGE,PanelChange);
		//contentBox.leftPanel.visualSearch --> add listner inside selected child change
		contentBox.mainDisplay.searchResults.gridResult.addEventListener(MouseEvent.CLICK,itemClickHandler);
	    e.currentTarget.leftPanel.addEventListener(IndexChangedEvent.CHANGE,PanelChange);	
	    e.currentTarget.leftPanel.textSearch.addEventListener(IndexChangedEvent.CHANGE,indexChangeHandler)
		e.currentTarget.leftPanel.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
	    e.currentTarget.leftPanel.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
	
		
		
		//contentBox.leftPanel.visualSearch.addEventListener(FlexEvent.CREATION_COMPLETE,VSHandler);
		//contentBox.leftPanel.textSearch.addEventListener(IndexChangedEvent.CHANGE,indexChangeHandler);
		//contentBox.leftPanel.textSearch.pColor.addEventListener(ColorPickerEvent.CHANGE,colorSet);
		contentBox.mainDisplay.searchResults.shopWindow.addEventListener(IndexChangedEvent.CHANGE,viewChangeHandler);
		
		contentBox.mainDisplay.nextPage.addEventListener(FlexEvent.BUTTON_DOWN, pageHandler);
		contentBox.mainDisplay.prevPage.addEventListener(FlexEvent.BUTTON_DOWN,pageHandler);
		contentBox.mainDisplay.pageHits.addEventListener(NumericStepperEvent.CHANGE, pageLengthChange);	
		contentBox.mainDisplay.sortBut.addEventListener(MenuEvent.ITEM_CLICK, sortHandler);
		

		
}
private function initP(e:FlexEvent):void{
	Alert.show("Initilize");
	
	 e.currentTarget.addEventListener(IndexChangedEvent.CHANGE,PanelChange);	
}

private function PanelChange(e:IndexChangedEvent){
	//Alert.show("select = " + e.currentTarget.selectedIndex);
	
	if(e.currentTarget.selectedIndex == 0)
	{
		
		e.currentTarget.textSearch.addEventListener(IndexChangedEvent.CHANGE,indexChangeHandler);}
	
	else if (e.currentTarget.selectedIndex == 1){

		e.currentTarget.visualSearch.addEventListener(FlexEvent.CREATION_COMPLETE,VSHandler);
	
	}

	else if (e.currentTarget.selectedIndex == 2){
		//Alert.show("2 press");
		e.currentTarget.UploadSearch.addEventListener(FlexEvent.CREATION_COMPLETE,init_upload);}	
	
}

private function sortHandler(e:MenuEvent):void{
	var pageNo: uint = uint(contentBox.mainDisplay.page.text)-1;
	if(e.label == "price ascending" && visual==false){
		var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&sort=asc" +"&by=price");	
		loader.load("Controller/getResult.php", params);
		sort = "asc";
		sortBy = "price";
	}
	else if(e.label == "rating descending" && visual==false){
		
		var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&sort=des" +"&by=rate");	
		loader.load("Controller/getResult.php", params);
		sort = "des";
		sortBy = "rate";		
	}
	else if(e.label == "price descending" && visual==false){
		var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&sort=des" +"&by=price");	
		loader.load("Controller/getResult.php", params);
		sort = "des";
		sortBy = "price";
	}
	else if(e.label == "rating ascending" && visual==false){
		var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&sort=asc" +"&by=rate");	
		loader.load("Controller/getResult.php", params);
		sort = "asc";
		sortBy = "rate";
	}
	
}
private function switchViewHandler(e:IndexChangedEvent):void{
		if(e.newIndex == 1)
			welcomePage.timer.stop();
		else if(e.newIndex == 0)
			welcomePage.timer.start();
	
}

private function refineSearchHandler(e:FlexEvent):void{
	
	if(contentBox.leftPanel.textSearch.pName.text!="")
 		query = contentBox.leftPanel.textSearch.pName.text;
 	else
 		query = "";
 	var category:String = contentBox.leftPanel.textSearch.pCategory.selectedItem.@id;
 	var brand:String = contentBox.leftPanel.textSearch.brand.text;
 	var priceUpLim:String = contentBox.leftPanel.textSearch.upperLimit.text;
 	var priceLowLim:String = contentBox.leftPanel.textSearch.lowerLimit.text;
 	var rateUpLim:String = contentBox.leftPanel.textSearch.upRateLim.text;
 	var rateLowLim:String = contentBox.leftPanel.textSearch.lowRateLim.text;
 	var store:String = contentBox.leftPanel.textSearch.store.text;
 	var params:URLVariables = new URLVariables("query="+query+"&category="+category+"&brand="+brand+"&upP="+priceUpLim+"&lowP="+priceLowLim+"&upR="+rateUpLim+"&lowR="+rateLowLim+"&merchant="+store);
 	loader.load("Controller/getResult.php", params);

}

private function viewChangeHandler(e:IndexChangedEvent):void{

	if(e.newIndex == 0){
		//if(!contentBox.mainDisplay.searchResults.listResult.hasEventListener(MouseEvent.CLICK))
		Alert.show("Index Change to 0 : Gridview");
	
		contentBox.mainDisplay.searchResults.gridResult.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
	//	contentBox.mainDisplay.searchResults.listResult.addEventListener(MouseEvent.CLICK, itemClickHandler);
		//	contentBox.mainDisplay.searchResults.gridResult.invalidateDisplayList();
	}
	else if(e.newIndex == 1){
		//if(!contentBox.mainDisplay.searchResults.gridResult.hasEventListener(MouseEvent.CLICK))
		Alert.show("Index Change to 1 : Listview");
			contentBox.mainDisplay.searchResults.listResult.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
		//		contentBox.mainDisplay.searchResults.gridResult.addEventListener(MouseEvent.CLICK, itemClickHandler);		
			//contentBox.mainDisplay.searchResults.listResult.invalidateDisplayList();	
	}
	/*
	else if(e.newIndex == 2){
		//if(!contentBox.mainDisplay.searchResults.colResult.hasEventListener(MouseEvent.CLICK))
			contentBox.mainDisplay.searchResults.colResult.addEventListener(MouseEvent.CLICK, itemClickHandler);
	}
	*/
}
private function indexChangeHandler(e:IndexChangedEvent):void{

	if(e.newIndex == 1){
		e.currentTarget.pCategories = categories;
		e.currentTarget.refineForm.addEventListener(FlexEvent.CREATION_COMPLETE, addRefineHandler);
		
	}		
}

private function addRefineHandler(e:FlexEvent):void{
	contentBox.leftPanel.textSearch.rSearch.addEventListener(FlexEvent.BUTTON_DOWN, refineSearchHandler);
}
private function itemClickHandler(e:Event):void{
		
	var index:Object ;

	//index = 0;
	index = e.currentTarget.selectedIndices;
	
	
	
	if(index == "")
	index = 0;
	
	//Alert.show("index clicked = "+ index);
	
	
		contentBox.leftPanel.textSearch.details = products[index];
		contentBox.leftPanel.visualSearch.product = products[index];
		
		var imgs:Array = new Array();
		imgs.push(products[index].primaryImage);
		//Alert.show(products[index].variantImage.length().toString());
		for(var i:uint = 0; i< products[index].variantImage.length(); i++)
			imgs.push(products[index].variantImage[i]);
	
		//Alert.show(contentBox.leftPanel.textSearch.images.toString());
		contentBox.leftPanel.textSearch.images = imgs;
		contentBox.leftPanel.textSearch.currentImgId = 0;		
	//}
	
	//else 
		//contentBox.leftPanel.visualSearch.product = products[index];

} 



private function searchHandler(e:FlexEvent):void{

	
 	if(headerBox.query.text != ""){	
 		query = headerBox.query.text;
 		if(main.selectedIndex == 0)
 			main.selectedIndex = 1;		
 		visual = false;	
 		CustomVisual = false;
 		ranking = false;
 		//contentBox.mainDisplay.sortBut.enabled = true;
		var params:URLVariables = new URLVariables("query="+ query+"&page=0&pageLength=" + pageLength.toString());
		loader.load("Controller/getResult.php",params);
		contentBox.mainDisplay.page.text= "1";
		contentBox.mainDisplay.searchResults.results = null;
 	}
 	/*var id:String = contentBox.leftPanel.visualSearch.product.db_id;
		var c_id:String = contentBox.leftPanel.visualSearch.product.category;
		Alert.show("Id=".id +"c_id=".c_id );
 	var	id = "1";
	var c_id="8";
		main.selectedIndex = 1;	
	var params:URLVariables = new URLVariables("id="+id +"category="+c_id);
	loader.load("Controller/ConnectSocket.php", params);
	contentBox.mainDisplay.page.text= "1";
	contentBox.mainDisplay.searchResults.results = null;*/
	if(visual == false && CustomVisual==false && ranking==false)
	contentBox.mainDisplay.sortBut.enabled = true;
}

private function keyPressHandler(e:FlexEvent):void{
	
		if(headerBox.query.text != ""){
			//Alert.show("enter");
			query = headerBox.query.text;
			if(main.selectedIndex == 0)
				main.selectedIndex = 1;		
			visual = false;	
			CustomVisual = false;
			ranking = false;
			//contentBox.mainDisplay.sortBut.enabled = true;	
			//Alert.show(query);
			var params:URLVariables = new URLVariables("query=" +headerBox.query.text+"&page=0&pageLength="+pageLength.toString());
			loader.load("Controller/getResult.php", params);
			contentBox.mainDisplay.page.text="1";
		}
			
}

private function pageHandler(e:FlexEvent){
		//pageNo starts from 0 - totalPages -1
		//contentBox.mainDisplay.searchResults.results = null;
		//contentBox.mainDisplay.searchResults.gridResult.dataProvider = null;
		pageNo= uint(contentBox.mainDisplay.page.text)-1;
		//Alert.show("Button Press:" + e.currentTarget.id);
		
		if(e.currentTarget.id=="nextPage"){
		
			
			if(pageNo < (Math.ceil(Number(totalResults)/pageLength) -1) && visual == false && CustomVisual==false && ranking==false){
				pageNo++;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString() +"&sort="+sort +"&by="+sortBy);
				//Alert.show("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				loader.load("Controller/getResult.php", params);
			}
			else if(pageNo < (Math.ceil(Number(totalResults)/pageLength) -1) && visual == true && ranking==false)
			{
				pageNo++;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
					loader.load("Controller/ConnectSocket.php", params);
				//Alert.show("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				
				
			}
				else if(pageNo < (Math.ceil(Number(totalResults)/pageLength) -1) && CustomVisual == true&& ranking==false)
			{
				pageNo++;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("feature="+upload.item[0].feature + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
					loader.load("Controller/ConnectSocket.php", params);
				//Alert.show("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				
				
			}
			else if(pageNo < (Math.ceil(Number(totalResults)/pageLength) -1) && visual == true && ranking==true)
			{
				pageNo++;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&color=-1" +"&red="+ r+"&green="+g+"&blue="+ b);
					loader.load("Controller/ConnectSocket.php", params);
				//Alert.show("visual=true rank=true" + p_id +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				
				
			}
				else if(pageNo < (Math.ceil(Number(totalResults)/pageLength) -1) && CustomVisual == true && ranking==true)
			{
				pageNo++;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("feature="+upload.item[0].feature + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&color=-1" +"&red="+ r+"&green="+g+"&blue="+ b);
					loader.load("Controller/ConnectSocket.php", params);
				//Alert.show("Customvisual=true rank=true" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				
				
			}
			
			
			
		}
		else if(e.currentTarget.id=="prevPage"){
			if(pageNo > 0 && visual == false && CustomVisual==false && ranking==false){
				pageNo--;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
			//Alert.show("Df");
				var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&sort="+sort +"&by="+sortBy);
				//Alert.show("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				loader.load("Controller/getResult.php", params);
			}
			
			else if (pageNo > 0 && visual == true&& ranking==false){
				
				pageNo--;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				//Alert.show("id="+p_id +"&category="+c_id + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				loader.load("Controller/ConnectSocket.php", params);
				
			}
				else if (pageNo > 0 && CustomVisual == true && ranking==false){
				
				pageNo--;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				var params:URLVariables = new URLVariables("feature="+upload.item[0].feature + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				loader.load("Controller/ConnectSocket.php", params);
			
			}
			else if(pageNo > 0 && visual == true && ranking==true)
			{
				pageNo--;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&color=-1" +"&red="+ r+"&green="+g+"&blue="+ b);
					loader.load("Controller/ConnectSocket.php", params);
				//Alert.show("visual=true rank=true" + p_id +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				
				
			}
				else if(pageNo > 0&& CustomVisual == true && ranking==true)
			{
				pageNo--;
				contentBox.mainDisplay.page.text = (pageNo+1).toString();
				//Alert.show(contentBox.mainDisplay.page.text);
				var params:URLVariables = new URLVariables("feature="+upload.item[0].feature + "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString()+"&color=-1" +"&red="+ r+"&green="+g+"&blue="+ b);
					loader.load("Controller/ConnectSocket.php", params);
				//Alert.show("Customvisual=true rank=true" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
				
				
			}
			
			
		}		
		if(pageNo <= 0)
			contentBox.mainDisplay.prevPage.enabled=false;
		else
			contentBox.mainDisplay.prevPage.enabled=true;
		
		if(pageNo >= Math.ceil(Number(totalResults)/pageLength) -1){
	
			contentBox.mainDisplay.nextPage.enabled=false;
		}
		else{ 
			contentBox.mainDisplay.nextPage.enabled=true;		
		}
}

private function pageLengthChange(e:NumericStepperEvent):void{
	pageLength = uint(e.value);

}

//============VISUAL SEARCH================================

private function VSHandler(e:FlexEvent):void{
	//Alert.show("Complete Initialize");
	e.currentTarget.searchVisual.addEventListener(FlexEvent.BUTTON_DOWN, VisualSearchHandler);
	e.currentTarget.ColorPick.addEventListener(ColorPickerEvent.CHANGE,colorSet);
	//contentBox.leftPanel.visualSearch.ColorPick.addEventListener(ColorPickerEvent.CHANGE,colorSet);
	//contentBox.leftPanel.visualSearch.searchVisual.addEventListener(FlexEvent.BUTTON_DOWN, VisualSearchHandler);

}

//======COlOR SET

private function colorSet(e:ColorPickerEvent):void{
	ranking = true;
	var drawColor:uint = e.color;
	var hexColor:String=drawColor.toString(16);
	
	e.currentTarget.selectedColor=0;
	
	if (hexColor.length == 1)hexColor="000000";
	else if (hexColor.length == 4) hexColor="00"+hexColor;
	else if (hexColor.length == 2) hexColor="0000"+hexColor;
	
	r=parseInt(hexColor.substr(0,2),16).toString();
	g=parseInt(hexColor.substr(2,2),16).toString();
	b=parseInt(hexColor.substr(4,2),16).toString();
	
	//Alert.show("hello " + r +" "+ g+" "+b);
	//p_id = contentBox.leftPanel.visualSearch.product.db_id;

	if(visual==true){
	var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id +"&color=-1" +"&red="+ r+"&green="+g+"&blue="+ b+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
	loader.load("Controller/ConnectSocket.php", params);}
	else if(CustomVisual==true)
	{
	var params:URLVariables = new URLVariables("feature="+upload.item[0].feature+"&color=-97"+"&red="+ r+"&green="+g+"&blue="+ b+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
	loader.load("Controller/ConnectSocket.php", params);
	}
	else
	{
		Alert.show("This function is only avaliable after a visual search is executed");
	//var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString() +"&sort="+sort +"&by="+sortBy);
	//loader.load("Controller/getResult.php", params);
		
	}
	
}

/*
//==========Ranking======
private function rankingRHandler(e:MouseEvent):void{
	var temp:String ="";
	var num:int =0;
	var k:int = 0;
	if(totalONpage > pageLength)
	num = pageLength;
	else 
	num = totalONpage;
	//Alert.show("pageLength = " + num +"db = " + products[0].db_id);
	
	
	for(var i:uint = 0; i< num; i++)
	{	
		if(i>0)
		temp +=",";
		temp += products[i].db_id;
		k++;
	}
	Alert.show ("kk" +k);
	var params:URLVariables = new URLVariables("feature=1" +"&color=-99" +"&id="+temp );
	loader.load("Controller/ConnectSocket.php", params);
	
}
//==========Ranking======
private function rankingGHandler(e:MouseEvent):void{
	var temp:String ="";
	var num:int =0;
	var k:int = 0;
	if(totalONpage > pageLength)
	num = pageLength;
	else 
	num = totalONpage;
		//Alert.show("pageLength = " + num +"db = " + products[0].db_id);
	
	for(var i:uint = 0; i< num; i++)
	{	
		if(i>0)
		temp +=",";
		temp += products[i].db_id;
		k++;
	}
	Alert.show ("kk"+k);
	var params:URLVariables = new URLVariables("feature=1" +"&color=-98" +"&id="+temp );
	loader.load("Controller/ConnectSocket.php", params);
	
}
//==========Ranking======
private function rankingBHandler(e:MouseEvent):void{
	var temp:String ="";
	var num:int =0;
	p_id = contentBox.leftPanel.visualSearch.product.db_id;
	if(totalONpage > pageLength)
	num = pageLength;
	else 
	num = totalONpage;
	var k:int = 0;
	/*Alert.show("pageLength = " + num +"db = " + products[0].db_id);
	for(var i:uint = 0; i< num; i++)
	{	
		if(i>0)
		temp +=",";
		temp += products[i].db_id;
		k++;
	}
	Alert.show("kk=" +k);
	if(visual==true){
	var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id +"&color=-97");
	loader.load("Controller/ConnectSocket.php", params);}
	else if(CustomVisual==true)
	{
	var params:URLVariables = new URLVariables("feature="+upload.item[0].feature+"&color=-97");
	loader.load("Controller/ConnectSocket.php", params);
	}
	else
	{
	var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString() +"&sort="+sort +"&by="+sortBy);
	loader.load("Controller/getResult.php", params);
		
	}
	
	//var params:URLVariables = new URLVariables("feature=1" +"&color=-97" +"&id="+temp );
	//loader.load("Controller/ConnectSocket.php", params);
	
}
           
           
		*/
			
			
private function init_upload(e:FlexEvent):void
			{		
				e.currentTarget.UploadButton.addEventListener(FlexEvent.BUTTON_DOWN,browseAndUpload);		
			//	Alert.show("Complete Initialize");
			}
			
private function browseAndUpload(e:FlexEvent):void 
			
			{	
				
				fileref.addEventListener(Event.SELECT,fileRef_select);
				fileref.addEventListener(ProgressEvent.PROGRESS,fileRef_progress);
				fileref.addEventListener(Event.COMPLETE,fileRef_complete);
				fileref.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,serverResponse);
				var imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
                fileref.browse(new Array(imageTypes));
               
            }
private function fileRef_select(evt:Event):void {
 	  
 	if(fileref.size < 10485760)
 	{
 	
    try {
       // contentBox.leftPanel.UploadSearch.message.text = "size (bytes): " + contentBox.leftPanel.UploadSearch.numberFormatter.format(fileref.size);
          _winProgress = new winProgress();
      
       
     	 _winProgress =  winProgress(PopUpManager.createPopUp(this, winProgress, false));
        // PopUpManager.addPopUp(_winProgress,this,true);
        _winProgress.btnCancel.removeEventListener("click", onUploadCanceled);
        _winProgress.btnCancel.addEventListener("click", onUploadCanceled);
        _winProgress.title = "Uploading file to Server";
       // _winProgress.txtFile.text = fileref.name;
        _winProgress.progBar.label = "0%";
        _winProgress.move((contentBox.screen.width/2-_winProgress.width/2),(contentBox.screen.height/2-_winProgress.height/2));
        
        //PopUpManager.;
       
        
       
        var sendVars:URLVariables = new URLVariables();
        sendVars.action = "upload";
        
        var request:URLRequest = new URLRequest();
       // request.data = sendVars;
        request.url = _strUploadScript;
        request.method = URLRequestMethod.POST;
      
       	fileref.upload(request,"Filedata",false);
 
        
    } 
    catch (err:Error) 
    	{
    	    Alert.show( "ERROR: zero-byte file");
  		}
	 }
	 
	 
	 else 
	{
	Alert.show("Uploaded file must be less then 10 Mb ");
	}
	 
}
   

private function onUploadCanceled(event:Event):void {
    PopUpManager.removePopUp(_winProgress);
    _winProgress == null;
    fileref.cancel();
    
    
}
private function fileRef_progress(Event:ProgressEvent):void {
	 var numPerc:Number = Math.round((Number(Event.bytesLoaded) / Number(Event.bytesTotal)) * 100);

	
    _winProgress.progBar.setProgress(numPerc, 100);
    _winProgress.txtFile.text = fileref.name;
    _winProgress.progBar.label = numPerc + "%";
    _winProgress.progBar.validateNow();
    if (numPerc > 90) {
        _winProgress.btnCancel.enabled = false;
    } else {
        _winProgress.btnCancel.enabled = true;
    }

}
private function serverResponse(event:DataEvent):void {
   	upload = XML( event.data );
   	contentBox.leftPanel.UploadSearch.U_image.source = upload.item[0].url;

	CustomVisualSearch();
	
  	}


private function fileRef_complete(evt:Event):void {
	PopUpManager.removePopUp(_winProgress);
	Alert.show("File(s) have been uploaded.", "Upload successful");
    //contentBox.leftPanel.UploadSearch.message.text += " (complete)";
//   contentBox.leftPanel.UploadSearch.U_image.source = upload.item[0].url;
   // contentBox.leftPanel.UploadSearch.U_url = upload.item[0].url;
    //contentBox.leftPanel.UploadSearch.loadImage(upload.item[0].url);

}

public function test(e:FlexEvent):void {
        var request:URLRequest = new URLRequest(_strUploadScript);
        navigateToURL(request,"_blank");
     }

/////////upload
public function CustomVisualSearch():void{
	CustomVisual = true;
	visual = false;
	contentBox.mainDisplay.sortBut.enabled = false;
	query = "Visual Search";
	var params:URLVariables = new URLVariables("feature="+upload.item[0].feature+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
	loader.load("Controller/ConnectSocket.php", params);
	
}			
/////////////		
private function VisualSearchHandler(e:FlexEvent):void{
	
	p_id = contentBox.leftPanel.visualSearch.product.db_id;
	c_id = contentBox.leftPanel.visualSearch.product.category;
	query = "Visual Search";
	
	//Alert.show("Slider Value :" + contentBox.leftPanel.visualSearch.S_color.value);
//	Alert.show("id="+p_id +"category="+c_id);
	visual = true;
	CustomVisual=false;
	contentBox.mainDisplay.sortBut.enabled = false;
	//Alert.show("Search button prress");
	var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString() );
	loader.load("Controller/ConnectSocket.php", params);
	
	
	
	//contentBox.mainDisplay.page.text= "1";
	//contentBox.mainDisplay.searchResults.results = null;
}


//==================DRAG & DROP============================

private function dragEnterHandler(e:DragEvent):void{
	
	if(e.dragSource.hasFormat("product data")){
		DragManager.acceptDragDrop(contentBox.leftPanel);
		
	}
}

private function dragDropHandler(e:DragEvent):void{
	var data:Object = e.dragSource.dataForFormat("product data");
	if(contentBox.leftPanel.selectedIndex == 0 ){
		contentBox.leftPanel.textSearch.details = data;
		contentBox.leftPanel.visualSearch.product = data ;

	//	Alert.show("data in V=" +data.primaryImage)
		contentBox.leftPanel.validateNow();
		var imgs:Array = new Array();
		imgs.push(data.primaryImage);
		//Alert.show(products[index].variantImage.length().toString());
		for(var i:uint = 0; i< data.variantImage.length(); i++)
			imgs.push(data.variantImage[i]);
	
		//Alert.show(contentBox.leftPanel.textSearch.images.toString());
		contentBox.leftPanel.textSearch.images = imgs;
		contentBox.leftPanel.textSearch.currentImgId = 0;
	}
	else{
		contentBox.leftPanel.visualSearch.product = data
	}
	//Alert.show("id="+data.db_id +"category="+data.category);
		query = "Visual Search";
		visual = true;
		CustomVisual=false;
		contentBox.mainDisplay.sortBut.enabled = false;
		p_id = data.db_id;
		c_id = data.category;
	var params:URLVariables = new URLVariables("id="+p_id+"&category="+c_id+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
	//Alert.show(params.toString());
	loader.load("Controller/ConnectSocket.php", params);	
}
