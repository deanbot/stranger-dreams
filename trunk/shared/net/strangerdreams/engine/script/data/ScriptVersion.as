package net.strangerdreams.engine.script.data
{
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.data.IFlagRequired;
	import net.strangerdreams.engine.data.IScreened;
	
	public class ScriptVersion implements IVersionObject, IBaseText, IFlagRequired, IScreened
	{
		private var _text:String;
		private var _priority:uint;
		private var _flagRequirement:String;
		private var _alternateBetweenScreens:Boolean;
		private var _screens:Dictionary;
		private var _numScreens:uint;
		private var _currentScreen:uint;
		
		public function ScriptVersion(priority:uint=0,text:String=null,flagRequirement:String=null,screens:Dictionary=null,alternateBetweenScreens:Boolean=false)
		{
			_text = text;
			_priority=priority;
			_flagRequirement=flagRequirement;
			_screens=screens;
			if(_screens!=null)
				for(var k:String in _screens)
					_numScreens++;
			_alternateBetweenScreens=alternateBetweenScreens;
			_currentScreen=1;
		}

		public function get hasText():Boolean
		{
			return (_text!='')?true:false;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function get priority():uint
		{
			return _priority;
		}
		
		public function get hasFlagRequirement():Boolean
		{
			return (_flagRequirement!='')?true:false;
		}
		
		public function get flagRequirement():String
		{
			return _flagRequirement;
		}
		
		public function get hasScreens():Boolean
		{
			return (_screens!=null)?true:false;
		}
		
		public function get screens():Dictionary
		{
			return _screens;
		}
		
		public function get numScreens():uint
		{
			return _numScreens;
		}
		
		public function get alternateBetweenScreens():Boolean
		{
			return _alternateBetweenScreens;
		}
		
		public function get currentScreen():uint
		{
			return _currentScreen;
		}
		
		public function nextScreen():void
		{
			if(++_currentScreen>_numScreens)
				_currentScreen=1;
		}
		
		public function resetScreen():void
		{
			_currentScreen=1;
		}
	}
}