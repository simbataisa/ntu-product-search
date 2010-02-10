// ActionScript file
import content.navigation.winProgress;

import controller.events.ColorSearchResultEvent;
import controller.events.PDoubleClickEvent;
import controller.events.USSearchResultEvent;

import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.MenuEvent;
import mx.events.SliderEvent;
import mx.managers.DragManager;
import mx.rpc.events.ResultEvent;

private	var p_id:String = "";  //contentBox.leftPanel.visualSearch.product.db_id;
private	var c_id:String =""; //contentBox.leftPanel.visualSearch.product.category;

private var r:String="";
private var b:String="";
private var g:String="";

private var session:uint=0;

private var fileref:FileReference = new FileReference;
private var _winProgress:winProgress;

/**
 * Handling WelcomePage timer 
 **/
private function switchViewHandler(e:IndexChangedEvent):void{
	if(e.newIndex != 0)
		welcomePage.timer.stop();		
	else 
		welcomePage.timer.start();		
}

private function mainImageDoubleClickHandler(e:PDoubleClickEvent):void{
	if(mainView.selectedIndex == 0 || mainView.selectedIndex==1){
		mainView.selectedIndex = 2;
		contentBox.leftPanel.tabNavi.selectedIndex = 1;
	}
	var data:Object = e.pXML;
	contentBox.mainDisplay.page.text = "1";	
	if(contentBox.leftPanel.tabNavi.selectedIndex == 0 ){
		contentBox.leftPanel.details = data;
		contentBox.leftPanel.visualSearch.product = data ;
		contentBox.leftPanel.validateNow();
		var imgs:ArrayCollection = new ArrayCollection();
		imgs.addItem(data.primaryImage);		
		for(var i:uint = 0; i< data.variantImage.length(); i++){
			imgs.addItem(data.variantImage[i]);
		}
		contentBox.leftPanel.images = imgs;
		contentBox.leftPanel.currentImgId = 0;
	}
	else{
		contentBox.leftPanel.visualSearch.product = data
	}
	//Alert.show("id="+data.product_id +"category="+data.category_id);
	_query = "Visual Search";
	_categorySearch = false;
	visual = true;
	customVisual=false;
	ranking =false;
	contentBox.mainDisplay.sortBut.enabled = false;
	
	/*var params:URLVariables = new URLVariables("action=vsDragDrop&product_id="+data.product_id
		+"&category="+data.category_id+"&pageLength=" + _pageLength.toString());*/
	var params:URLVariables = new URLVariables("option=vsDragDrop&product_id="+data.product_id
		+"&category="+data.category_id+"&pageLength=" + _pageLength.toString()
		+"&firstPageReq=Y&lastPage=N");
	loader.load("PSInterface/visualSearchController.php", params);	
	//loader.load("Controller/ConnectSocket.php", params);
	//loader.load("/AWSJavaCrawler/socketHandler.htm", params);
	//loader.load("http://localhost:8084/AWSJavaCrawler/socketHandler.htm", params);
 				
 			
}
/**
 * 
 **/
/*private function panelChangeHandler(e:IndexChangedEvent):void{
	if (e.currentTarget.selectedIndex == 1){
		contentBox.leftPanel.visualSearch.vsButton.addEventListener(FlexEvent.BUTTON_DOWN,vsButtonhHandler);	
	}else if (e.currentTarget.selectedIndex == 2){
		init_upload();
	}
}*/

//==============================FUNCTIONS WORK ON SEARCH RESULT========================================
/**
 * This function is to handle contentBox.mainDisplay.nextPage and prevPage buttons
 **/ 
private function pageHandler(e:FlexEvent){	
	if(e.currentTarget.id=="nextPage" && _currentPage!=_totalPages)	
	{	
		/*Alert.show("_previousPageStop "+_previousPageStop  +"\n"				
				+ "_previousPage " +_currentPage);*/
						
		_currentPage += 1;		
		_productsPerPage = new ArrayCollection();
		_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);	
		
		if(_products.length-_previousPageStop > _pageLength){			
			for(var i:uint = 0; i < _pageLength; i++){
				_productsPerPage.addItem(_products.getItemAt(_previousPageStop+i));
			}
			_previousPageStop += _pageLength;	
		}else{			
			for(var i:uint = _previousPageStop; i < _products.length; i++){
				_productsPerPage.addItem(_products.getItemAt(i));
			}
			_previousPageStop = _products.length;	
		}	
		/*--------------------------------------------------------------------------*/	
		/*Alert.show("_currentPageStop "+_previousPageStop  +"\n"			
				+ "_currentPage " +_currentPage);*/
						
	}else if(e.currentTarget.id=="prevPage" && _currentPage!=1)
	{
		/*Alert.show("_previousPageStop "+_previousPageStop  +"\n"				
				+ "_previousPage " +_currentPage);*/
			
		_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);	
		if(_productsPerPage.length == _pageLength){
			_previousPageStop = _previousPageStop - _pageLength;
		}else{
			_previousPageStop = _previousPageStop - _productsPerPage.length;
		}
		_productsPerPage = new ArrayCollection();	
		_currentPage -= 1;		
		
		for(var i:uint = _pageLength; i > 0; i--){
			_productsPerPage.addItem(_products.getItemAt(_previousPageStop-i));
		}
		/*for(var i:uint = _previousPageStart - _pageLength; i < _previousPageStart ; i++){
			_productsPerPage.addItem(_products.getItemAt(i));
		}
		_previousPageStop = _previousPageStart;
		if(_previousPageStart>0)_previousPageStart = _previousPageStart - _pageLength;
		/*--------------------------------------------------------------------------*/	
		/*Alert.show("_currentPageStop "+_previousPageStop  +"\n"				
				+ "_currentPage " +_currentPage);*/
		
	}else if(e.currentTarget.id=="page"){
		var pageJump:int = Number(e.currentTarget.text);
		if(_currentPage != pageJump && pageJump>0 && pageJump<=_totalPages){
			var diff:int = pageJump-_currentPage;
			if(diff>0){
				/*Alert.show("_previousPageStop "+_previousPageStop  +"\n"
				+ "_previousPage " +_currentPage);*/
				//Go forward
				for(var times:uint; times < diff-1; times++){
					_previousPageStop +=_pageLength; 
				}
				
				_productsPerPage = new ArrayCollection();
				_previousPageStart = _previousPageStop;
				if(_products.length-_previousPageStop >= _pageLength){			
					for(var i:uint = 0; i < _pageLength; i++){
						_productsPerPage.addItem(_products.getItemAt(_previousPageStop+i));
					}					
					_previousPageStop += _pageLength;	
				}else{			
					for(var i:uint = _previousPageStop; i < _products.length; i++){
						_productsPerPage.addItem(_products.getItemAt(i));
					}
					_previousPageStop = _products.length;	
					
				}
				_currentPage = pageJump;
				/*Alert.show("_currentPageStop "+_previousPageStop  +"\n"
				+ "_currentPage " +_currentPage);*/
			}else{
				/*Alert.show("_previousPageStop "+_previousPageStop  +"\n"
				+ "_previousPage " +_currentPage);*/
				_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);
				if(_currentPage == _totalPages && _productsPerPage.length != _pageLength){
					_previousPageStop -= _productsPerPage.length;
					for(var times1:int = diff+1; times1 < 0; times1++){
						_previousPageStop -=_pageLength; 
					}
				}else{
					for(var times1:int = diff; times1 < 0; times1++){
						_previousPageStop -=_pageLength; 
					}
				}
				
				_productsPerPage = new ArrayCollection();							
				_currentPage = pageJump;		
				//Go backward
				for(var jumpIndex:int = _pageLength; jumpIndex>0; jumpIndex--){
					_productsPerPage.addItem(_products.getItemAt(_previousPageStop - jumpIndex));
				}
				/*Alert.show("_currentPageStop "+_previousPageStop  +"\n"
				+ "_currentPage " +_currentPage);*/
			}
		}
	}	
		
	
	contentBox.mainDisplay.page.text = _currentPage.toString();
	contentBox.mainDisplay.searchResults.setResults(_productsPerPage);	
	contentBox.mainDisplay.searchResults.setResultPopupPage(_productsPerPage);
	//This part is to passing neccessary data to productZoom
	//So that ProductZoom can navigate pages by itself
	contentBox.mainDisplay.searchResults.setProductsList(_products);
	contentBox.mainDisplay.searchResults.totalResults = _totalResults; 
	contentBox.mainDisplay.searchResults.totalPages = _totalPages;        
	contentBox.mainDisplay.searchResults.currentPage = _currentPage;	
	contentBox.mainDisplay.searchResults.pageLength = _pageLength;
	contentBox.mainDisplay.searchResults.previousPageStop =  _previousPageStop;
	contentBox.mainDisplay.searchResults.previousPageStart = _previousPageStart;	
}

/**
 * 
 **/ 
private function pageLengthChange(e:ListEvent):void{
	_pageLength = uint(e.currentTarget.selectedLabel);		
	_productsPerPage = new ArrayCollection();
	_previousPageStop = 0; //reset
	_previousPageStop += _pageLength; //re-assign
	_previousPageStart = 0; //reset
	_currentPage = 1;		
	_totalPages = (Math.ceil(_products.length/_pageLength));
	_totalResults = _products.length;
	
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
	var totalPages:uint = (Math.ceil(_products.length/_pageLength));
	if(_pageLength==20){
		var defaultZoom:Number = (Number(contentBox.mainDisplay.SliderZoom.minimum) + 
								 Number(contentBox.mainDisplay.SliderZoom.maximum)) / 2;
		
		contentBox.mainDisplay.searchResults.gridResult.rowHeight = defaultZoom*5;
		contentBox.mainDisplay.searchResults.gridResult.columnWidth = defaultZoom*5;
		contentBox.mainDisplay.searchResults.itemImageSizeGridResult = defaultZoom*3;
		contentBox.mainDisplay.searchResults.itemImageSizeListResult = defaultZoom*3;
		contentBox.mainDisplay.SliderZoom.value = defaultZoom;
	}else{
		var defaultZoom:Number = Number(contentBox.mainDisplay.SliderZoom.minimum);
		contentBox.mainDisplay.searchResults.gridResult.rowHeight = defaultZoom*5;
		contentBox.mainDisplay.searchResults.gridResult.columnWidth = defaultZoom*5;
		contentBox.mainDisplay.searchResults.itemImageSizeGridResult = defaultZoom*3;
		contentBox.mainDisplay.searchResults.itemImageSizeListResult = defaultZoom*3;
		contentBox.mainDisplay.SliderZoom.value = defaultZoom;
	}
	/*--------------------------------------------------------------------------*/
	contentBox.mainDisplay.page.text= _currentPage.toString();
	contentBox.mainDisplay.Nopage.text = " of " + totalPages + " Pages";	
	contentBox.mainDisplay.searchResults.setResults(_productsPerPage);
	contentBox.mainDisplay.searchResults.setResultPopupPage(_productsPerPage);
	//This part is to passing neccessary data to productZoom
	//So that ProductZoom can navigate pages by itself
	contentBox.mainDisplay.searchResults.setProductsList(_products);
	contentBox.mainDisplay.searchResults.totalResults = _totalResults; 
	contentBox.mainDisplay.searchResults.totalPages = _totalPages;        
	contentBox.mainDisplay.searchResults.currentPage = _currentPage;	
	contentBox.mainDisplay.searchResults.pageLength = _pageLength;
	contentBox.mainDisplay.searchResults.previousPageStop =  _previousPageStop;
	contentBox.mainDisplay.searchResults.previousPageStart = _previousPageStart;
}

/**
 * This function is to handle the Zooming action 
 * when changing value of Slider component
 **/
private function sliderChangeHandler(e:SliderEvent):void{
	contentBox.mainDisplay.searchResults.gridResult.rowHeight=e.currentTarget.value* 5;
	contentBox.mainDisplay.searchResults.gridResult.columnWidth=e.currentTarget.value * 5;
	contentBox.mainDisplay.searchResults.listResult.rowHeight=e.currentTarget.value* 5;	
	contentBox.mainDisplay.searchResults.itemImageSizeGridResult=e.currentTarget.value* 3;
	contentBox.mainDisplay.searchResults.itemImageSizeListResult=e.currentTarget.value* 3;
}

/**
 * To change view between Gid and List view
 **/ 
private function searchResultViewHandler(event:MenuEvent):void{
	
	if(event.label == "Grid View"){
		contentBox.mainDisplay.searchResults.shopWindow.selectedIndex = 0;
	}else if(event.label == "List View"){		
		contentBox.mainDisplay.searchResults.shopWindow.selectedIndex = 1;
	}
}

private function feedBackHandler(e:MouseEvent):void{
    var selectedIndicesString:String = "";
	if(contentBox.mainDisplay.searchResults.shopWindow.selectedIndex == 0){
		selectedIndicesString =contentBox.mainDisplay.searchResults.gridResult.selectedIndices.toString();
	}else if(contentBox.mainDisplay.searchResults.shopWindow.selectedIndex == 1){		
		selectedIndicesString =contentBox.mainDisplay.searchResults.listResult.selectedIndices.toString();
	}
	if(selectedIndicesString.length > 0){
		var selectedIndices:Array = selectedIndicesString.split(",");
		var params:URLVariables = new URLVariables("option=refineSearchResult"
			+"&product_id="+_productsPerPage[selectedIndices[0]].product_id
			+"&category="+_productsPerPage[selectedIndices[0]].category_id+"&pageLength=" + _pageLength.toString()
			+"&firstPageReq=Y&lastPage=N");
		if(visual){			
			loader.load("PSInterface/visualSearchController.php", params);
		}else if(customVisual){
			params = new URLVariables("option=vsRefinement"
			+"&product_id="+_productsPerPage[selectedIndices[0]].product_id
			+"&category="+_productsPerPage[selectedIndices[0]].category_id+"&pageLength=" + _pageLength.toString()
			+"&firstPageReq=Y&lastPage=N");
			loader.load("PSInterface/visualSearchController.php", params);
		}else{
			loader.load("PSInterface/productSearch.php",params);
		}
		
		
		
		///Alert.show(params.toString());
	}
	
}

private function sortHandler(e:MenuEvent):void{
	var pageNo: uint = uint(contentBox.mainDisplay.page.text)-1;
	if(e.label == "price ascending" && visual==false){
		var params:URLVariables = new URLVariables("query=" + _query +"&page=" + pageNo.toString() 
			+"&pageLength="  + _pageLength.toString()
			+"&sort=asc" +"&by=price");	
		loader.load("Controller/getResult.php", params);
		_sortDirection = "asc";
		_sortBy = "price";
	}
	else if(e.label == "rating descending" && visual==false){
		
		var params:URLVariables = new URLVariables("query=" + _query +"&page=" + pageNo.toString() 
			+"&pageLength="  + _pageLength.toString()+"&sort=des" +"&by=rate");	
		loader.load("Controller/getResult.php", params);
		_sortDirection = "des";
		_sortBy = "rate";		
	}
	else if(e.label == "price descending" && visual==false){
		var params:URLVariables = new URLVariables("query=" + _query +"&page=" + pageNo.toString() 
			+"&pageLength="  + _pageLength.toString()+"&sort=des" +"&by=price");	
		loader.load("Controller/getResult.php", params);
		_sortDirection = "des";
		_sortBy = "price";
	}
	else if(e.label == "rating ascending" && visual==false){
		var params:URLVariables = new URLVariables("query=" + _query +"&page=" + pageNo.toString() 
			+"&pageLength="  + _pageLength.toString()+"&sort=asc" +"&by=rate");	
		loader.load("Controller/getResult.php", params);
		_sortDirection = "asc";
		_sortBy = "rate";
	}
	
}

/**
 * searchResult and leftPanel Components
 **/
private function itemClickHandler(e:Event):void{		
	var index:Object ;	

	index = e.currentTarget.selectedIndices;
	
	//contentBox.mainDisplay.searchResults.gridResult.se
	//Alert.show(index.toString());
	if(index == "")	index = 0;
		
	//contentBox.leftPanel.textSearch.details = _productsPerPage[index];	
	contentBox.leftPanel.details = _productsPerPage[index];
	contentBox.leftPanel.visualSearch.details = _productsPerPage[index];
	contentBox.leftPanel.visualSearch.product = _productsPerPage[index];	
	var imgs:ArrayCollection = new ArrayCollection();
	imgs.addItemAt(prefixDirectory+_productsPerPage[index].primaryImage, 0);

	for(var i:uint = 0; i< _products[index].variantImage.length(); i++)
		imgs.addItemAt(prefixDirectory+_productsPerPage[index].variantImage[i], i+1);

	contentBox.leftPanel.images = new ArrayCollection();
	contentBox.leftPanel.visualSearch.images = new ArrayCollection();
	contentBox.leftPanel.currentImgId = 0;
	contentBox.leftPanel.images = imgs;
	contentBox.leftPanel.visualSearch.currentImgId = 0;
	contentBox.leftPanel.visualSearch.images = imgs;
	
} 

/**
 * To handle the action that use want to add products to favourite list 
 * on the left panel by clicking on * icon in Grid/List view
 **/ 
private function addToFavouriteHandler(event:FavouriteEvent):void{	
	if(!checkDuplucateInCart(event.userFavourite.pAsin, contentBox.leftPanel.favourites)){
		contentBox.leftPanel.favourites.addItem(event.userFavourite);
	}else{
		Alert.show("Item already added");
	}				
}

//============================== VISUAL SEARCH ===============================================

private function vsButtonHandler(e:FlexEvent):void{	
	p_id = contentBox.leftPanel.visualSearch.product.product_id;
	c_id = contentBox.leftPanel.visualSearch.product.category_id;
	_categorySearch = false;
	visual = true;
	customVisual=false;
	contentBox.mainDisplay.sortBut.enabled = false;
	//Alert.show("VisualSearchHandler ------- Search button prress");
	var params:URLVariables = new URLVariables("option=vsButtonClick&product_id="+p_id
		+"&category="+c_id+"&pageLength=" + _pageLength.toString()
		+"&firstPageReq=Y&lastPage=N");
	loader.load("PSInterface/visualSearchController.php", params);	
}

private function vsSearchResultHandler(e:VSSearchResultEvent):void{	
	_totalResults = uint(e.xmlResult.total);
	//If no result found, do not procedd
	if(_totalResults!=0){		
		myXMLList = new XMLList(e.xmlResult.products.item);		
		if(mainView.selectedIndex == 2 && e.xmlResult.firstPage == "Y"){
			_pageNo = 1;
			//contentBox.mainDisplay.searchResults.shopWindow.selectedIndex = 0;
			contentBox.mainDisplay.searchResults.setResults(null);			
			_products = new XMLListCollection(myXMLList);
			
			//Setting display products based on page hits
			_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);
			_previousPageStop = 0;  //reset	
			_previousPageStart = 0; //reset	
			_previousPageStop += _pageLength;
			
			_currentPage = 1;		
			_totalPages = (Math.ceil(_totalResults/_pageLength));

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

			//contentBox.leftPanel.details = _productsPerPage.getItemAt(0);	
			//contentBox.leftPanel.images = imgs;
			contentBox.leftPanel.visualSearch.details = _productsPerPage.getItemAt(0);	
			contentBox.leftPanel.visualSearch.images = imgs;
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
		//Retrieving the remaining of search results		
		//Retrieving the remaining of vs search results				
		if(e.xmlResult.finished == "N"){					
			if(_pageNo == _totalPages-1){
				if(_totalResults-_products.length>=_pageLength){
					getAllVSResultLeft(_products.length,_products.length+_pageLength, "Y");
				}else{
					getAllVSResultLeft(_products.length,_totalResults, "Y");
				}
				
			}else{
				getAllVSResultLeft(_products.length,_products.length+_pageLength, "N");
			}
			_pageNo++;
		}	
	}else{
		Alert.show("Sorry! No item has been found. Please try another query!");
	}
	
	if(_categories == null)
		getCategories();	
}
private function getAllVSResultLeft(startIndex:uint, stopIndex:uint, lastPage:String):void{
	var params:URLVariables = new URLVariables("option=vsDragDrop&search_index="+headerBox.cateSelect.selectedLabel
		+"&firstPageReq=N&startIndex="+startIndex+"&stopIndex="+stopIndex+"&lastPage="+lastPage);
	//loader.load("/AWSJavaCrawler/productSearch.htm",params);
	loader.load("PSInterface/visualSearchController.php",params);		
	//loader.load("http://localhost:8084/AWSJavaCrawler/productSearch.htm",params);
}
//=============================== COlOR SET =================================================
private function colorSet(e:ColorPickerEvent):void{
	ranking = true;
	var drawColor:uint = e.color;
	var hexColor:String=drawColor.toString(16);
	
	//e.currentTarget.selectedColor=0;
	
	if (hexColor.length == 1)hexColor="000000";
	else if (hexColor.length == 4) hexColor="00"+hexColor;
	else if (hexColor.length == 2) hexColor="0000"+hexColor;
	
	r=parseInt(hexColor.substr(0,2),16).toString();
	g=parseInt(hexColor.substr(2,2),16).toString();
	b=parseInt(hexColor.substr(4,2),16).toString();
	
	//Alert.show("hello " + r +" "+ g+" "+b);
	//p_id = contentBox.leftPanel.visualSearch.product.db_id;
	contentBox.mainDisplay.page.text ="1";
	var params:URLVariables = new URLVariables("option=byColor"
			+"&red="+ r+"&green="+g+"&blue="+ b+"&pageLength=" + _pageLength.toString()
			+"&firstPageReq=Y&lastPage=N");
	if(visual==true){
		//var params:URLVariables = new URLVariables("id="+p_id +"&category="+c_id +"&color=-1" +"&red="+ r+"&green="+g+"&blue="+ b+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
		loader.load("PSInterface/visualSearchController.php", params);
	}else if(customVisual==true){
		//var params:URLVariables = new URLVariables("feature="+upload.item[0].feature+"&color=-97"+"&red="+ r+"&green="+g+"&blue="+ b+ "&page=" + pageNo.toString() +"&pageLength="  + pageLength.toString());
		loader.load("PSInterface/imageUploadSearchController.php", params);
	}else{
		//Alert.show("This function is only avaliable after a visual search is executed");
		
		loader.load("PSInterface/productSearch.php", params);		
	}	
}
private function csSearchResultHandler(e:ColorSearchResultEvent){
	_totalResults = uint(e.xmlResult.total);
	//If no result found, do not procedd
	if(_totalResults!=0){		
		myXMLList = new XMLList(e.xmlResult.products.item);		
		if(mainView.selectedIndex == 2 && e.xmlResult.firstPage == "Y"){
			_pageNo = 1;
			//contentBox.mainDisplay.searchResults.shopWindow.selectedIndex = 0;
			contentBox.mainDisplay.searchResults.setResults(null);			
			_products = new XMLListCollection(myXMLList);
			
			//Setting display products based on page hits
			_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);
			_previousPageStop = 0;  //reset	
			_previousPageStart = 0; //reset	
			_previousPageStop += _pageLength;
			
			_currentPage = 1;		
			_totalPages = (Math.ceil(_totalResults/_pageLength));

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
		//Retrieving the remaining of search results		
		//Retrieving the remaining of vs search results				
		if(e.xmlResult.finished == "N"){					
			if(_pageNo == _totalPages-1){
				if(_totalResults-_products.length>=_pageLength){
					getAllCSResultLeft(_products.length,_products.length+_pageLength, "Y");
				}else{
					getAllCSResultLeft(_products.length,_totalResults, "Y");
				}
				
			}else{
				getAllCSResultLeft(_products.length,_products.length+_pageLength, "N");
			}
			_pageNo++;
		}	
	}else{
		Alert.show("Sorry! No item has been found. Please try another query!");
	}
	
	if(_categories == null)
		getCategories();
}
private function getAllCSResultLeft(startIndex:uint, stopIndex:uint, lastPage:String):void{
	var params:URLVariables = new URLVariables("option=byColor&search_index="+headerBox.cateSelect.selectedLabel
		+"&firstPageReq=N&startIndex="+startIndex+"&stopIndex="+stopIndex+"&lastPage="+lastPage);
	if(visual){		
		loader.load("PSInterface/visualSearchController.php",params);
	}else if(customVisual){
		
	}else{		
		loader.load("PSInterface/productSearch.php",params);
	}
			
	//loader.load("http://localhost:8084/AWSJavaCrawler/productSearch.htm",params);
}
//============================== UPLOADING =================================================
/*private function init_upload():void
{		
	//e.currentTarget.UploadButton.addEventListener(FlexEvent.BUTTON_DOWN,browseAndUpload);	
	contentBox.leftPanel.UploadSearch.imageUploadButton.addEventListener(FlexEvent.BUTTON_DOWN,browseAndUpload);
	contentBox.leftPanel.UploadSearch.urlUploadButton.addEventListener(FlexEvent.BUTTON_DOWN,UrlUpload);
	contentBox.leftPanel.UploadSearch.urlMethod.addEventListener(ResultEvent.RESULT,handleXML);	
}*/
private function vsUrlImageUploadHandler(e:FlexEvent):void
{
	contentBox.leftPanel.visualSearch.urlMethod.send();
}
private function vsUrlImageUploadXMLHandler(event:ResultEvent):void
{
   var uploadXMLResult:XML = XML( event.result );
   //contentBox.leftPanel.UploadSearch.U_image.source = upload.item.url;
   contentBox.leftPanel.visualSearch.vsImageQuery.load(uploadXMLResult.item.url);
   contentBox.leftPanel.visualSearch.url.text="Pls Enter URL or Select an image";
   doUploadVisualSearch(uploadXMLResult.item.url);
}
/*private function UrlUpload(e:FlexEvent):void
{
	//var url:Object = contentBox.leftPanel.UploadSearch.url.text;	
	contentBox.leftPanel.UploadSearch.urlMethod.send();
}	*/		
 public function handleXML(event:ResultEvent):void
{
   var uploadXMLResult:XML = XML( event.result );
   //Alert.show(uploadXMLResult.toString());
   //contentBox.leftPanel.UploadSearch.U_image.source = upload.item.url;
   //contentBox.leftPanel.UploadSearch.U_image.load(uploadXMLResult.item.url);
   //contentBox.leftPanel.UploadSearch.url.text="Pls Enter URL or Select an image";
   contentBox.leftPanel.visualSearch.vsImageQuery.load(uploadXMLResult.item.ur);
   contentBox.leftPanel.visualSearch.url.text="Pls Enter URL or Select an image";
   doUploadVisualSearch(uploadXMLResult.item.url);
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

/**
 * Checking whether filesize is withiin the limit
 **/ 
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
	                      
	        var sendVars:URLVariables = new URLVariables();
	        sendVars.action = "upload";
	        
	        var request:URLRequest = new URLRequest();
	        request.data = sendVars;
	        request.url = "PSInterface/upload.php";;
	        request.method = URLRequestMethod.POST;	       	
	       	fileref.upload(request,"Filedata",false);
	 	        
	    }catch (err:Error){
	        Alert.show( "ERROR: zero-byte file");
	  	}
	 }else{
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
   	var uploadXMLResult:XML = XML( event.data );   	
   	//Alert.show(uploadXMLResult);
   	//contentBox.leftPanel.UploadSearch.U_image.source = uploadXMLResult.item[0].url;
   	contentBox.leftPanel.visualSearch.vsImageQuery.source = uploadXMLResult.item[0].url;
	doUploadVisualSearch(uploadXMLResult.item[0].url);	
}

private function fileRef_complete(evt:Event):void {
	PopUpManager.removePopUp(_winProgress);
	Alert.show("File(s) have been uploaded.", "Upload successful");  
}

private function doUploadVisualSearch(imageURL:String):void{
	//Alert.show(imageURL);	
	visual = false;
	customVisual=true;
	contentBox.mainDisplay.sortBut.enabled = false;
			
	contentBox.mainDisplay.sortBut.enabled = false;
	var params:URLVariables = new URLVariables("option=imageUploadSearch"
		+"&pageLength=" + _pageLength.toString() + "&search_index="+contentBox.leftPanel.visualSearch.upcateSelect.selectedLabel
		+"&firstPageReq=Y&lastPage=N");
		//Alert.show(params.toString());
	loader.load("PSInterface/imageUploadSearchController.php", params);
}		

private function usSearchResultHandler(e:USSearchResultEvent):void{
	_totalResults = uint(e.xmlResult.total);
	//If no result found, do not procedd
	if(_totalResults!=0){		
		myXMLList = new XMLList(e.xmlResult.products.item);		
		if(mainView.selectedIndex == 2 && e.xmlResult.firstPage == "Y"){
			_pageNo = 1;
			//contentBox.mainDisplay.searchResults.shopWindow.selectedIndex = 0;
			contentBox.mainDisplay.searchResults.setResults(null);			
			_products = new XMLListCollection(myXMLList);
			
			//Setting display products based on page hits
			_pageLength = Number(contentBox.mainDisplay.pageHits.selectedLabel);
			_previousPageStop = 0;  //reset	
			_previousPageStart = 0; //reset	
			_previousPageStop += _pageLength;
			
			_currentPage = 1;		
			_totalPages = (Math.ceil(_totalResults/_pageLength));

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

			//contentBox.leftPanel.details = _productsPerPage.getItemAt(0);	
			//contentBox.leftPanel.images = imgs;
			contentBox.leftPanel.visualSearch.details = _productsPerPage.getItemAt(0);	
			contentBox.leftPanel.visualSearch.images = imgs;
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
		//Retrieving the remaining of search results		
		//Retrieving the remaining of vs search results				
		if(e.xmlResult.finished == "N"){					
			if(_pageNo == _totalPages-1){
				if(_totalResults-_products.length>=_pageLength){
					getAllUSResultLeft(_products.length,_products.length+_pageLength, "Y");
				}else{
					getAllUSResultLeft(_products.length,_totalResults, "Y");
				}
				
			}else{
				getAllUSResultLeft(_products.length,_products.length+_pageLength, "N");
			}
			_pageNo++;
		}	
	}else{
		Alert.show("Sorry! No item has been found. Please try another query!");
	}
	
	if(_categories == null)
		getCategories();
}
private function getAllUSResultLeft(startIndex:uint, stopIndex:uint, lastPage:String):void{
	var params:URLVariables = new URLVariables("option=imageUploadSearch"
		+"&firstPageReq=N&startIndex="+startIndex+"&stopIndex="+stopIndex+"&lastPage="+lastPage);
	//loader.load("/AWSJavaCrawler/productSearch.htm",params);
	loader.load("PSInterface/imageUploadSearchController.php",params);		
	//loader.load("http://localhost:8084/AWSJavaCrawler/productSearch.htm",params);
}
//============================== DRAG & DROP =================================================


private function visualSearchDragEnterHandler(e:DragEvent):void{
	if(e.dragSource.hasFormat("product data")){
		DragManager.acceptDragDrop(contentBox.leftPanel.visualSearch);		
	}
}

private function visualSearchDragDropHandler(e:DragEvent):void{	
	var data:Object = e.dragSource.dataForFormat("product data");
	contentBox.mainDisplay.page.text = "1";	
	if(contentBox.leftPanel.tabNavi.selectedIndex == 0 ){
		contentBox.leftPanel.details = data;
		contentBox.leftPanel.visualSearch.product = data ;
		contentBox.leftPanel.visualSearch.vsImageQuery.source = "p_images/"+ data.primaryImage;
		contentBox.leftPanel.validateNow();
		var imgs:ArrayCollection = new ArrayCollection();
		imgs.addItem(data.primaryImage);		
		for(var i:uint = 0; i< data.variantImage.length(); i++){
			imgs.addItem(data.variantImage[i]);
		}
		contentBox.leftPanel.images = imgs;
		contentBox.leftPanel.currentImgId = 0;
	}
	else{
		contentBox.leftPanel.visualSearch.product = data
	}
	//Alert.show("id="+data.product_id +"category="+data.category_id);
	_query = "Visual Search";
	_categorySearch = false;
	visual = true;
	customVisual=false;
	ranking =false;
	contentBox.mainDisplay.sortBut.enabled = false;
	
	/*var params:URLVariables = new URLVariables("action=vsDragDrop&product_id="+data.product_id
		+"&category="+data.category_id+"&pageLength=" + _pageLength.toString());*/
	var params:URLVariables = new URLVariables("option=vsDragDrop&product_id="+data.product_id
		+"&category="+data.category_id+"&pageLength=" + _pageLength.toString()
		+"&firstPageReq=Y&lastPage=N");
	loader.load("PSInterface/visualSearchController.php", params);	
	//loader.load("Controller/ConnectSocket.php", params);
	//loader.load("/AWSJavaCrawler/socketHandler.htm", params);
	//loader.load("http://localhost:8084/AWSJavaCrawler/socketHandler.htm", params);
}
/**
 * To handle product dragged into favourite list
 */ 
private function cartDragEnterTextHandler(event:DragEvent):void{
	if(event.dragSource.hasFormat("product data")){
		DragManager.acceptDragDrop(contentBox.leftPanel.Cart);		
	}
}

private function cartDragDropTextHandler(event:DragEvent):void{
	var data:Object = event.dragSource.dataForFormat("product data");
	if(!checkDuplucateInCart(data.asin, contentBox.leftPanel.favourites)){
		contentBox.leftPanel.favourites.addItem({"pName":data.name,
		"pPrice":parsePrice(data.minRetail,data.maxRetail),"pAdd":data.url, "pAsin":data.asin});
	}else{
		Alert.show("Item already added");
	}
	
	//contentBox.leftPanel.details = data;
	//var imgs:ArrayCollection = new ArrayCollection();
	//imgs.addItem(data.primaryImage);	
	//for(var i:uint = 0; i< data.variantImage.length(); i++)
	//	imgs.addItem(data.variantImage[i]);
	//contentBox.leftPanel.images = imgs;
	//contentBox.leftPanel.currentImgId = 0;
}

private function parsePrice(p1:String, p2:String):String{
	var format:String = "";
	if(p1.indexOf("-1") > -1 || p1 == "" || p1 ==  null)
		format += "N/A";
	else
		format += "$"+p1;
		
	if(p2.indexOf("-1") > -1 || p2 == "" || p2 ==  null)
		format += "-N/A";
	else
		format += "-$"+p2;					
	return format;
}

private function checkDuplucateInCart(asin:String, list:ArrayCollection):Boolean{
	var duplicate:Boolean = false;
	for(var i:int = 0; i< list.length; i++){
		if(list.getItemAt(i).pAsin == asin){
			duplicate = true;
			break;
		}
	}
	return duplicate;			
}

/*
//==========Ranking======
private function rankingRHandler(e:MouseEvent):void{
	var temp:String ="";
	var num:int =0;
	var k:int = 0;
	if(totalONpage > _pageLength)
	num = _pageLength;
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
	if(totalONpage > _pageLength)
	num = _pageLength;
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
	if(totalONpage > _pageLength)
	num = _pageLength;
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
	var params:URLVariables = new URLVariables("query=" + query +"&page=" + pageNo.toString() +"&pageLength="  + _pageLength.toString() +"&sort="+sort +"&by="+sortBy);
	loader.load("Controller/getResult.php", params);
		
	}
	
	//var params:URLVariables = new URLVariables("feature=1" +"&color=-97" +"&id="+temp );
	//loader.load("Controller/ConnectSocket.php", params);
	
}*/