// ActionScript file
			import controller.ResultLoader;
			import controller.events.CategoryEvent;
			import controller.events.MessageEvent;
			
			import flash.net.URLVariables;
			
			import mx.containers.FormItem;
			import mx.controls.Alert;
			import mx.events.FlexEvent;
			
			[Bindable]
            public var selectedNode:XML;
            
            //public var curParentNode:XML;
            [Bindable]
            public var treeData:XMLList;
            /*
            [Embed(source="/images/qm2.jpg")]
            [Bindable]
            public var questionMark:Class;
            */
			public var loader:ResultLoader = new ResultLoader;
            // Event handler for the Tree control change event.
            public function treeChanged(event:Event):void {
            	//view.selectedIndex = 0;
            	//curParentNode = selectedNode;
                selectedNode=Tree(event.target).selectedItem as XML;
                //topLabel.text = " Selected Category : " + selectedNode.@label;
                
                //start exploring right here for convenience
             	var id:String = selectedNode.attribute("id").toString();
            	var params:URLVariables = new URLVariables("opt=check&id=" + id); 
            	loader.load("Controller/getCategories.php", params);               
            }
            private function changeIndexHandler(e:Event){
            	if(e.currentTarget.selectedIndex == 1)
            		newCate.addEventListener(FlexEvent.BUTTON_DOWN, newCateHandler);
            }
            
            private function init():void{
            	loader.addEventListener(CategoryEvent.CATEGORY, categoryHandler);
            	loader.addEventListener(MessageEvent.MESSAGE, messageHandler);
            	
            	exploreCate.addEventListener(FlexEvent.BUTTON_DOWN, exploreHandler);
            	addCate.addEventListener(FlexEvent.BUTTON_DOWN, addChildHandler);
            	//newCate.addEventListener(FlexEvent.BUTTON_DOWN, newCateHandler);
            	removeCate.addEventListener(FlexEvent.BUTTON_DOWN, removeCateHandler);
            	
            	var params:URLVariables = new URLVariables("opt=check");
            	loader.load("Controller/getCategories.php", params);
            }
            
            private function categoryHandler(e:CategoryEvent):void{
            	//Alert.show(e.xmlCategories.toXMLString());
            	if(treeData == null)
            		treeData = e.xmlCategories.categories.node;
            	else{
            		for(var i:uint = 0; i<e.xmlCategories.categories.node.length(); i++)
            			selectedNode.appendChild(e.xmlCategories.categories.node[i]); 
            		childCount.text = e.xmlCategories.categories.node.length().toString();
            		if(e.xmlCategories.categories.total_products!=null)
            			pCount.text = e.xmlCategories.categories.total_products.toString();
            	}
            }
            
            private function exploreHandler(e:FlexEvent):void{
            	//view.selectedIndex = 0;
            	if(selectedNode!=null){
            		var id:String = selectedNode.attribute("id").toString();
            		var params:URLVariables = new URLVariables("opt=check&id=" + id); 
            		loader.load("Controller/getCategories.php", params);
            	}
            	else
            		Alert.show("select a category first");
            }
            
            private function addChildHandler(e:FlexEvent):void{
            	//view.selectedIndex = 0;
            	if(selectedNode!=null){
            		var fItem:FormItem = new FormItem();
            		var newChildName:TextInput = new TextInput();
            		fItem.label = "New Child";
            		fItem.addChild(newChildName);
            		categoryDetails.addChildAt(fItem, 5);
            	}
            	else
            		Alert.show("select a category first");
            }
            
            private function newCateHandler(e:FlexEvent):void{
            	//topLabel.text = "create new category";
            	//view.selectedIndex = 1;
            	if(newCatName.text == "" || newCatName.text == null)
            		Alert.show("Please enter the category name");
            	else if(parentId.text=="" ||parentId.text == null)
            		Alert.show("Please enter the parent id");
            	else{
            		var params:URLVariables = new URLVariables("opt=add&name=" + newCatName.text +"&parent=" + parentId.text);
            		loader.load("Controller/getCategories.php", params);	
            	}
            	
            }
            
            private function removeCateHandler(e:FlexEvent):void{
            	//Alert.show(selectedNode.@id+"");
            	var params:URLVariables = new URLVariables("opt=remove&id=" + selectedNode.@id);
            	loader.load("Controller/getCategories.php", params);
            	var curParentNode:* = selectedNode.parent();
            	//Alert.show(selectedNode.childIndex().toString());
            	if(curParentNode != null)
            		delete curParentNode.node[selectedNode.childIndex()];
            	else
            		delete treeData.node[selectedNode.childIndex()];
            	
            }
            
            private function messageHandler(e:MessageEvent){
            	Alert.show(e.mess);
            }
                      /*
           	private function doubleClickHandler(e:Event){
           		Alert.show("here");
           		selectedNode=Tree(e.target).selectedItem as XML;
 				var id:String = selectedNode.attribute("id").toString();
            	var params:URLVariables = new URLVariables("id=" + id); 
            	loader.load("Controller/getCategories.php", params);          		
           	}
            */
            
           