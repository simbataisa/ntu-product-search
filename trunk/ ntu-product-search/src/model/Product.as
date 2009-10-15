package model
{
	
	public class Product
	{
		public var name:String;
		public var price:String;
		public var description:String;
		public var url:String;
		public var primaryImage:String;
		
		public function Product(n:String, p:String, d:String, u:String, pr:String){
			name = n;
			price = p;
			url = u;
			primaryImage = pr;
		}
	}
}