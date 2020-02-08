package net.strangerdreams.engine.events.data
{
	public class StoryEvent
	{
		private var _key:String;
		private var _conditions:Array;
		private var _results:Array;
		private var _remove:Array;
		public function StoryEvent(key:String, con:Array, res:Array, rem:Array)
		{
			_key=key;
			_results=res;
			_conditions=con;
			_remove=rem;
		}
		public function get key():String { return _key; }
		public function get results():Array { return _results; }
		public function get conditions():Array { return _conditions; }
		public function get remove():Array { return _remove; }
	}
}