package net.strangerdreams.engine.item.data
{
	
	public class Item implements IItem
	{
		private var _key:String;
		private var _title:String;
		private var _description:String;
		private var _assetClass:String;
		private var _type:String;
		
		public function Item(key:String,title:String,description:String,assetClass:String,type:String)
		{
			_key=key;
			_title=title;
			_description=description;
			_assetClass=assetClass;
			_type=type;
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function get assetClass():String
		{
			return _assetClass;
		}
		
		public function get type():String
		{
			return _type;
		}
	}
}