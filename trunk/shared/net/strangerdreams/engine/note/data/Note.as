package net.strangerdreams.engine.note.data
{
	public class Note implements INote
	{
		private var _key:String;
		private var _title:String;
		private var _assetClass:String;
		private var _implementationClass:String;
		private var _read:Boolean;
		
		public function Note(key:String,title:String,assetClass:String,implementClass:String,read:Boolean)
		{
			_key=key;
			_title=title;
			_assetClass=assetClass;
			_implementationClass=implementClass;
			_read = read;
		}

		public function get read():Boolean
		{
			return _read;
		}

		public function set read(value:Boolean):void
		{
			_read = value;
		}

		public function get key():String
		{
			return _key;
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function get assetClass():String
		{
			return _assetClass;
		}
		
		public function get implementationClass():String
		{
			return _implementationClass;
		}
	}
}