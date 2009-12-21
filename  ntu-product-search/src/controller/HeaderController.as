// ActionScript file

//Import section

import controller.ResultLoader;
import controller.events.*;

import flash.events.Event;
import flash.net.URLVariables;
import flash.xml.XMLNode;
import flash.xml.XMLNodeType;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.events.*;
import mx.managers.*;

//Variable declaration section
private var loader:ResultLoader =  new ResultLoader();

private var baseURL:String = "http://msm.cais.ntu.edu.sg/~sngy0005/ProductSearch/";
public static var prefixDirectory:String = "C:/ProductSearch/images/";
private var notExisted:Boolean = false;
[Bindable] 
private var _categories:XMLList;
[Bindable]
private var _products:XMLListCollection = new XMLListCollection();
private var _productsPerPage:ArrayCollection = new ArrayCollection();
private var _productsPerPopupPage:ArrayCollection = new ArrayCollection();
private var _totalResults:uint; 
private var _totalPages:uint;
private var _previousPageStop:uint;
private var _previousPageStart:uint;
private var _previousPopupPageStop:uint;
private var _previousPopupPageStart:uint;
private var _currentPage:uint;
private var myXMLList:XMLList;
private var myXMLListIndex:uint;
private var _welcomePageProducts:XMLList;
private var _query:String = "";
private var _pageLength:uint = 30;

private var totalONpage:uint; 
private var _sortDirection:String = "";
private var _sortBy:String = "";
private var _pageNo:uint;

/**
 * Request server for a list of available categories.
 **/ 
public function getCategories():void{
	_categoryLoader = new ResultLoader();
	_categoryLoader.addEventListener(CategoryEvent.CATEGORY, categoryHandler);
	_categoryLoader.addEventListener(IOLoadEvent.ERROR, loadErrorHandler);
	
	var params:URLVariables = new URLVariables();
	params.opt = "get";									
	_categoryLoader.load("http://localhost:8084/AWSJavaCrawler/categoriesRequest.htm",params);	
}
/**
 * This event is raised if the return result contain title = "product categories"
 **/ 
private function categoryHandler(e:CategoryEvent):void{		
	/*--------------------------------------------------------------*/	
	//Using XMLList to populate data, but it not currently used.
	var categoriesNode:XMLList = e.xmlCategories.categories.children();
	_categories = new XMLList();
	_categories[0] = "All Categories";
	for(var i:uint; i< categoriesNode.length(); i++){
		_categories[i+1] = categoriesNode[i];
	}	
	/*--------------------------------------------------------------*/	
	//Converting XML to Object and add into Array Collection to make use of object properties
	var categoriesObject:Object = e.xmlCategories.categories.category;		
	var arrayCollection:ArrayCollection = new ArrayCollection();
	for(var menuIndex:uint = 0; menuIndex < categoriesObject.length(); menuIndex++){
		arrayCollection.addItem(categoriesObject[menuIndex]);
	}
	/*--------------------------------------------------------------*/	
	if(categoriesNode.length()<=10)
		//headerBox.menu.dataProvider = categoriesNode;
		headerBox.menu.dataProvider = arrayCollection;
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
	/*--------------------------------------------------------------*/		
	var allCateItem:XML =
		<categories>	
			<category value="0" label="All Categories"></category>
		</categories>
	
	//var firstObj:Object = allCateItem.category;
	//arrayCollection.addItem(firstObj);	
	var arrayCollection1:ArrayCollection = new ArrayCollection();
	arrayCollection1.addItem(allCateItem.category);
	for(var cateSelectIndex:uint = 0; cateSelectIndex < categoriesObject.length(); cateSelectIndex++){
		arrayCollection1.addItem(categoriesObject[cateSelectIndex]);
	}
	//headerBox.cateSelect.dataProvider=_categories;
	//Poputate data for cateSelect			
	headerBox.cateSelect.dataProvider=arrayCollection1;
}

private function loadErrorHandler(event:IOLoadEvent):void{
	if(event.isError){
		Alert.show("Unable to connect to server");
	}
}

private function messageHandler(e:MessageEvent):void{
	if(mainView.selectedIndex == 2){
		//contentBox.mainDisplay.searchResults.results = null;
		//contentBox.mainDisplay.searchResults.statusBar.text = e.mess;
	}
}





private function categorySelected(e:MenuEvent):void{
	if(mainView.selectedIndex == 0 || mainView.selectedIndex==1)
		mainView.selectedIndex = 2;
		//Alert.show("category=" + e.item.@id +"name" + e.item.@label);
	//	query=e.item.@label;
	var params:URLVariables = new URLVariables("category=" + e.item.@id + "&query=" +e.item.@name ); 		
	loader.load("Controller/getResult.php", params);
}

private function initP(e:FlexEvent):void{
	Alert.show("Initilize");
	
	 e.currentTarget.addEventListener(IndexChangedEvent.CHANGE,PanelChange);	
}

private function PanelChange(e:IndexChangedEvent):void{
	//Alert.show("select = " + e.currentTarget.selectedIndex);
	
	if(e.currentTarget.selectedIndex == 0)
	{		
		//e.currentTarget.textSearch.addEventListener(IndexChangedEvent.CHANGE,indexChangeHandler);
	}else if (e.currentTarget.selectedIndex == 1){
		e.currentTarget.visualSearch.addEventListener(FlexEvent.CREATION_COMPLETE,VSHandler);
	}

	else if (e.currentTarget.selectedIndex == 2){
		//Alert.show("2 press");
		e.currentTarget.UploadSearch.addEventListener(FlexEvent.CREATION_COMPLETE,init_upload);}		
}


/*

private function refineSearchHandler(e:FlexEvent):void{
	
	if(contentBox.leftPanel.textSearch.pName.text!="")
 		_query = contentBox.leftPanel.textSearch.pName.text;
 	else
 		_query = "";
 	var category:String = contentBox.leftPanel.textSearch.pCategory.selectedItem.@id;
 	var brand:String = contentBox.leftPanel.textSearch.brand.text;
 	var priceUpLim:String = contentBox.leftPanel.textSearch.upperLimit.text;
 	var priceLowLim:String = contentBox.leftPanel.textSearch.lowerLimit.text;
 	var rateUpLim:String = contentBox.leftPanel.textSearch.upRateLim.text;
 	var rateLowLim:String = contentBox.leftPanel.textSearch.lowRateLim.text;
 	var store:String = contentBox.leftPanel.textSearch.store.text;
 	var params:URLVariables = new URLVariables("query="+_query+"&category="+category
 		+"&brand="+brand+"&upP="+priceUpLim+"&lowP="+priceLowLim+"&upR="+rateUpLim
 		+"&lowR="+rateLowLim+"&merchant="+store);
 	loader.load("Controller/getResult.php", params);

}*/

/*
private function indexChangeHandler(e:IndexChangedEvent):void{
	if(e.newIndex == 1){
		e.currentTarget.pCategories = _categories;
		e.currentTarget.refineForm.addEventListener(FlexEvent.CREATION_COMPLETE, addRefineHandler);
		
	}		
}*/
/*
private function addRefineHandler(e:FlexEvent):void{
	contentBox.leftPanel.textSearch.rSearch.addEventListener(FlexEvent.BUTTON_DOWN, refineSearchHandler);
}*/

/**
 * This event is raised whenever user hit Search button on the search box
 **/
private function searchHandler(e:FlexEvent):void{	
 	if(headerBox.query.text != ""){	
 		var selectedCategory:String = headerBox.cateSelect.selectedLabel; 	 		
 		_query = headerBox.query.text;
 		if(mainView.selectedIndex == 0 || mainView.selectedIndex==1)
 			mainView.selectedIndex = 2;		
 		visual = false;	
 		CustomVisual = false;
 		ranking = false;
 		//contentBox.mainDisplay.sortBut.enabled = true;
		//var params:URLVariables = new URLVariables("query="+ query +"&page=0&pageLength=" + _pageLength.toString());
		//loader.load("Controller/getResult.php",params);
		//http://localhost:8084/AWSJavaCrawler/productSearch.htm?opt=byKeyword&search_index=All
		//&key_word=zip&reqType=getFirsPage&pageLength=10
		var params:URLVariables = new URLVariables("opt=byKeyword&search_index="+headerBox.cateSelect.selectedLabel
			+"&key_word="+headerBox.query.text
			+"&firstPageReq=y&pageLength="+contentBox.mainDisplay.pageHits.selectedLabel);
			//Number(contentBox.mainDisplay.pageHits.selectedLabel)*2
		loader.load("http://localhost:8084/AWSJavaCrawler/productSearch.htm",params);										
 	}else{
 		Alert.show("Please enter your search keyword"); 		
 	}
 	
	if(visual == false && CustomVisual==false && ranking==false)
	contentBox.mainDisplay.sortBut.enabled = true;
}

private function searchResultHandler(e:SearchResultEvent):void{	
	
	_totalResults = uint(e.xmlResult.total);
	//If no result found, do not procedd
	if(_totalResults!=0){		
		myXMLList = new XMLList(e.xmlResult.products.item);		
		if(mainView.selectedIndex == 2 && e.xmlResult.firstPage == "Y"){
			//contentBox.mainDisplay.searchResults.shopWindow.selectedIndex = 0;
			contentBox.mainDisplay.searchResults.setResults(null);			
			_products = new XMLListCollection(myXMLList);
			//_products = new XMLListCollection();
			//Put all xml result into array collection for caching			
			//for(var i:uint = 0; i < myXMLList.length(); i++){
				//trace("Primary Image " + i.toString()+ " " + prefixDirectory+myXMLList[i].primaryImage);
				//if(myXMLList[i].primaryImage.length()>0){
			//		_products.addItem(myXMLList[i]);
				//}				
			//}
			//Setting display products based on page hits
			_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);
			_previousPageStop = 0;  //reset	
			_previousPageStart = 0; //reset	
			_previousPageStop += _pageLength;
			
			_currentPage = 1;		
			_totalPages = (Math.ceil(_totalResults/_pageLength));
			//_totalResults = _products.length;
			//Alert.show(_products.toString());
			//Alert.show(_products.length.toString());
			_productsPerPage = new ArrayCollection();
			if(_products.length <= _pageLength){
				for(var j:uint; j < _products.length; j++){
					_productsPerPage.addItem(_products.getItemAt(j));
				}
			
			}else{
				for(var j:uint; j < _pageLength; j++){
					_productsPerPage.addItem(_products.getItemAt(j));
				}
			}
			if(_pageLength==20){
				contentBox.mainDisplay.searchResults.gridResult.rowHeight = 250;
				contentBox.mainDisplay.searchResults.gridResult.columnWidth = 250;
				contentBox.mainDisplay.searchResults.itemImageSizeGridResult = 150;
				contentBox.mainDisplay.searchResults.itemImageSizeListResult = 150;
			}else{
				contentBox.mainDisplay.searchResults.gridResult.rowHeight = 150;
				contentBox.mainDisplay.searchResults.gridResult.columnWidth = 150;
				contentBox.mainDisplay.searchResults.itemImageSizeGridResult = 80;
				contentBox.mainDisplay.searchResults.itemImageSizeListResult = 100;
			}
			//Assign data to searchResults' components
			contentBox.mainDisplay.searchResults.setResults(_productsPerPage);
			contentBox.mainDisplay.searchResults.setResultPopupPage(_productsPerPage);
			contentBox.mainDisplay.page.text= _currentPage.toString();
			//This part is to passing neccessary data to productZoom
			//So that ProductZoom can navigate pages by itself
			contentBox.mainDisplay.searchResults.setProductsList(_products);
			contentBox.mainDisplay.searchResults.totalResults = _totalResults; 
			contentBox.mainDisplay.searchResults.totalPages = _totalPages;        
			contentBox.mainDisplay.searchResults.currentPage = _currentPage;	
			contentBox.mainDisplay.searchResults.pageLength = _pageLength;
			contentBox.mainDisplay.searchResults.previousPageStop =  _previousPageStop;
			contentBox.mainDisplay.searchResults.previousPageStart = _previousPageStart;
				
			/*-------------------------------------------------------------------------------*/
			//Use first result as data for text search box
			var imgs:ArrayCollection = new ArrayCollection();
			imgs.addItemAt(prefixDirectory+_productsPerPage.getItemAt(0).primaryImage,0);	
			for(var k:uint = 0; k < _productsPerPage.getItemAt(0).variantImage.length(); k++)
				imgs.addItem(prefixDirectory+_productsPerPage.getItemAt(0).variantImage[k]);
			//	imgs[i+1] = (arrayCollection[0].variantImage[i]);
			
			//contentBox.leftPanel.textSearch.details = _productsPerPage.getItemAt(0);	
			//contentBox.leftPanel.textSearch.images = imgs;
			contentBox.leftPanel.details = _productsPerPage.getItemAt(0);	
			contentBox.leftPanel.images = imgs;
			/*-------------------------------------------------------------------------------*/
						
			if(_totalPages <= 1){
				contentBox.mainDisplay.nextPage.enabled = false;
				contentBox.mainDisplay.prevPage.enabled = false;							
			}
			else
				contentBox.mainDisplay.nextPage.enabled = true;	
			/*-------------------------------------------------------------------------------*/
			contentBox.mainDisplay.Nopage.text = " of " + _totalPages + " Pages";	
			contentBox.mainDisplay.searchResults.statusBar.text = "Found: " 
					+ _totalResults.toString() +  " matches in " 
					+ e.xmlResult.searchTime + " sec for query '"+_query+"'";					
													
		}else{
			for(var i:uint = 0; i < myXMLList.length(); i++){
				//trace("Primary Image " + i.toString()+ " " + prefixDirectory+myXMLList[i].primaryImage);				
				_products.addItem(myXMLList[i]);			
			}
		}
		
		/*-------------------------------------------------------------------------------*/
		//Retrieving the remained search results
		if(e.xmlResult.finished == "N"){
			getAllResultLeft(_query,_products.length,_totalResults);
		}	
	}else{
		Alert.show("Sorry! No item has been found. Please try another query!");
	}
	
	if(_categories == null)
		getCategories();	
}

private function getAllResultLeft(query:String, startIndex:uint, stopIndex:uint):void{
	var params:URLVariables = new URLVariables("opt=byKeyword&search_index="+headerBox.cateSelect.selectedLabel
		+"&key_word="+headerBox.query.text
		+"&firstPageReq=n&startIndex="+startIndex+"&stopIndex="+stopIndex);
	loader.load("http://localhost:8084/AWSJavaCrawler/productSearch.htm",params);
}

private function io_ErrorHandler(e:Event):void{
	notExisted = true;
}


			
			

			
	



