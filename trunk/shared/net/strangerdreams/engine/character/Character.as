package net.strangerdreams.engine.character
{
	public class Character implements IKeyAndAsset
	{
		private var _key:String;
		private var _asset:String;
		
		public function Character(k:String,a:String)
		{
			_key = k;
			_asset = a;
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function get asset():String
		{
			return _asset;
		}
	}
}