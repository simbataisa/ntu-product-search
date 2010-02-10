// ActionScript file
import mx.effects.*;
import mx.effects.effectClasses.*;
import mx.events.*;
import mx.core.*;
import mx.events.FlexEvent;
public var resizeInst:ResizeInstance;
import mx.managers.DragManager;
import mx.managers.PopUpManager;
import mx.events.CloseEvent;

[Embed(source="/images/star.png")]

public var star:Class;
[Embed(source="/images/greyStar.png")]

public var greyStar:Class;
[Embed(source="/images/halfGrey.png")]

public var halfStar:Class;

[Embed(source="/images/camera.png")]
public var defaultImage:Class;

public var results:XMLList;

private function startDragHandler(e:MouseEvent):void{
	var dragInitiator:Image = Image(e.currentTarget);
	var dragSource:DragSource = new DragSource();
	dragSource.addData(data, "product data");
	var imageProxy:Image = new Image;
	imageProxy.source = dragInitiator.source;
	imageProxy.width = dragInitiator.width;
	imageProxy.height = dragInitiator.height;
	DragManager.doDrag(dragInitiator, dragSource, e, imageProxy);
}


private function toShoppingSite():void{
	var request:URLRequest = new URLRequest(data.url);
	navigateToURL(request,"_blank");
}
		
private function parseRating(rateData:String):void{
	var rate:Number; 
	if(rateData == "" ||rateData == null)
		rate = 0;
	else
	rate = Number(rateData);
	rateBox.removeAllChildren();	
	//---------------------------------
	for(var i:uint = 1; i<=5; i++){
		var img:Image = new Image();
		img.width = 10;
		img.height = 10;
		img.alpha = 0.7;
		if(Number(i) <= rate){
			img.source = star;
		}
		else if((Number(i)-0.25)>rate && (Number(i-1)+0.25) < rate){
			img.source = halfStar;					
		}

		else if(Number(i) > rate){
			img.source = greyStar;
		}
		
		rateBox.addChild(img);
			}
}

private function set_Visible(event:MouseEvent):void{
		control.visible=true;
	}
private function unset_Visible(event:MouseEvent):void{
		control.visible=false;
	}
	
public function doZoom(event:MouseEvent):void { 
    if (zoomAll.isPlaying) { 
       zoomAll.reverse(); 
    } 
    else { 
 
        zoomAll.play([event.currentTarget], event.type == MouseEvent.MOUSE_OUT ? true : false); 
    } 
} 
				