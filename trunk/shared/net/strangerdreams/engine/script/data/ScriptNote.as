package net.strangerdreams.engine.script.data
{
	public class ScriptNote implements IScriptNote
	{
		private var _key:String;
		private var _title:String;
		
		public function ScriptNote(key:String, title:String)
		{
			_key=key;
			_title=title;
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function get title():String
		{
			return _title;
		}
	}
}