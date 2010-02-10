package controller.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class FavouriteEvent extends Event
	{		
		public var userFavourite:Object;
		public static const FAVOURITE:String = "favourite";
		public function FavouriteEvent(type:String, fav:Object){
			super(type);
			this.userFavourite = fav;
		}
		
		override public function clone():Event{
			return new FavouriteEvent(type, userFavourite);
		}
	}
}