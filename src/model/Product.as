package model
{	
	[Bindable]
	public class Product
	{
		private var _name:String;
		private var _price:String;
		private var _description:String;
		private var _url:String;
		private var _primaryImage:String;
		
		public function Product(name:String, price:String, description:String, 
			   url:String, primaryImage:String){
			this._name=name;
			this._price=price;
			this._url=url;
			this._primaryImage=primaryImage;
		}
		
		public function get name():String{
			return this._name
		}
		public function set name(name:String):void{
			this._name = name;
		}
		
		public function get price():String{
			return this._price
		}
		public function set name(price:String):void{
			this._price = price;
		}
		
		public function get description():String{
			return this._description;
		}
		public function set description(description:String):void{
			this._description = description;
		}
		
		public function get url():String{
			return this._url
		}
		public function set url(url:String):void{
			this._url = url;
		}
		
		public function get primaryImage():String{
			return this._primaryImage
		}
		public function set primaryImage(primaryImage:String):void{
			this._primaryImage = primaryImage;
		}
	}
}