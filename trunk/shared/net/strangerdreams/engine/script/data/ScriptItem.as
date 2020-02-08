package net.strangerdreams.engine.script.data
{
	public class ScriptItem implements IScriptItem
	{
		private var _key:String;
		private var _title:String;
		private var _description:String;
		
		public function ScriptItem(key:String,title:String,description:String)
		{
			_key=key;
			_title=title;
			_description=description;
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
	}
}