package com.jamesward
{
  import flash.display.BitmapData;
  import flash.events.ContextMenuEvent;
  import flash.events.Event;
  import flash.geom.Rectangle;
  import flash.net.FileReference;
  import flash.system.System;
  import flash.ui.ContextMenu;
  import flash.ui.ContextMenuItem;
  import flash.utils.ByteArray;
  
  import mx.controls.Image;
  import mx.controls.listClasses.IDropInListItemRenderer;
  import mx.controls.listClasses.IListItemRenderer;
  import mx.core.IDataRenderer;
  import mx.graphics.ImageSnapshot;
  import mx.utils.Base64Encoder;

  public class SaveableImage extends Image implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
  {
    public function SaveableImage()
    {
      super();

      addEventListener(Event.COMPLETE, setupContextMenu);
    }
    
    private function setupContextMenu(event:Event):void
    {
      this.removeEventListener(Event.COMPLETE, setupContextMenu);

      var myContextMenu:ContextMenu = new ContextMenu();
      myContextMenu.hideBuiltInItems();

      var item:ContextMenuItem = new ContextMenuItem("Save Image As...");
      myContextMenu.customItems.push(item);
      item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, saveImageAs);

      contextMenu = myContextMenu;
    }

    private function saveImageAs(event:ContextMenuEvent):void
    {
      var tba:ByteArray = new ByteArray();
      content.loaderInfo.bytes.readBytes(tba, 0, (content.loaderInfo.bytes.length - 17));
      tba.position = 49;
      
      var ba:ByteArray = new ByteArray();
      while (tba.bytesAvailable)
      {
        ba.writeByte(tba.readUnsignedByte());
      }
      trace(ba.bytesAvailable);
      var fr:FileReference = new FileReference();
      fr.save(ba, source.toString());
    }

  }
}