package net.strangerdreams.engine.scene.data
{
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.DialogOption;

	public class DialogTreeOption
	{
		private var _shortKey:String;
		private var _longKey:String;
		private var _nextKey:String;
		private var _flagRequirement:String;
		private var _antiFlagRequirement:String;
		private var _order:uint;
		
		public function DialogTreeOption()
		{
			
		}
		
		public function get order():uint
		{
			return _order;
		}

		public function setData(data:XML):void
		{
			var shortKey:String = String(data.@shortKey);
			var longKey:String = String(data.@longKey);
			if(shortKey==""||shortKey==null)
				throw new Error("DialogTreeOption has no short key");
			if(longKey==""||longKey==null)
				throw new Error("DialogTreeOption has no long key");
			var scriptKey:String = String(data.@scriptKey);
			var nextKey:String = String(data.@nextKey);
			var flagRequirement:String=String(data.@flagRequirement);
			var antiFlagRequirement:String=String(data.@antiFlagRequirement);
			
			_shortKey=shortKey;
			_longKey=longKey;
			_nextKey=nextKey;
			_flagRequirement=flagRequirement;
			_antiFlagRequirement=antiFlagRequirement;
			_order = uint(String(data.@order));
		}

		public function get antiFlagRequirement():String
		{
			return _antiFlagRequirement;
		}

		public function get flagRequirement():String
		{
			return _flagRequirement;
		}

		public function get shortKey():String
		{
			return _shortKey;
		}
		
		public function get longKey():String
		{
			return _longKey;
		}
		
		public function get nextKey():String
		{
			return _nextKey;
		}

	}
}