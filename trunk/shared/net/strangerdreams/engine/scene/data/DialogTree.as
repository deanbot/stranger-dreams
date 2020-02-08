package net.strangerdreams.engine.scene.data
{
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Dialog;

	public class DialogTree
	{
		private var _key:String;
		private var _scriptKey:String;
		private var _options:Dictionary;
		private var _end:Boolean;
		private var _givesFlag:String;
		private var _charKey:String;
		private var _numOptions:uint;
		
		public function DialogTree()
		{
			
		}
		
		public function setData(data:XML):void
		{
			var key:String = String(data.@key);
			if(key==null)
				throw new Error("Dialog Tree has no key");
			if(String(data.@scriptKey)==null||String(data.@scriptKey)=="")
				throw new Error("Dialog Tree has no scriptKey");
			var scriptKey:String = String(data.@scriptKey);
			var charKey:String = String(data.@character);
			var end:Boolean=(String(data.@end) =="true")?true:false;
			var givesFlag:String=String(data.@givesFlag);
			var options:Dictionary = new Dictionary(true);
			var option:DialogTreeOption;
			_numOptions = 0;
			for each (var optionData:XML in data.option)
			{
				option = new DialogTreeOption();
				option.setData(optionData);
				options[option.order]=option;
				_numOptions++;
			}
			_key=key;
			_scriptKey = scriptKey;
			_options=options;
			_charKey=charKey;
			_end=end;
			_givesFlag=givesFlag;
		}
		
		public function get key():String
		{
			return _key;
		}

		public function get flag():String
		{
			return _givesFlag;
		}

		public function get charKey():String
		{
			return _charKey;
		}

		public function get end():Boolean
		{
			return _end;
		}

		public function get options():Dictionary
		{
			return _options;
		}
		
		public function get hasOptions():Boolean
		{
			return (_numOptions>0)?true:false;
		}

		public function get scriptKey():String
		{
			return _scriptKey;
		}

	}
}