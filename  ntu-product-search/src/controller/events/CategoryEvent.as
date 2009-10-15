package controller.events
{
	import flash.events.Event;

	public class CategoryEvent extends Event
	{
		public var xmlCategories:XML;
		public static const CATEGORY:String = "categories";
		public function CategoryEvent(type:String, res:XML){
			super(type);
			xmlCategories = XML(res);
		}
		
		override public function clone():Event{
			return new CategoryEvent(type, xmlCategories);
		}
	}
}