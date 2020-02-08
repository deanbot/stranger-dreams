package net.strangerdreams.engine.script.data
{
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.data.IScreened;
	
	public class DialogOption implements IBaseText, IScreened
	{
		private var _key:String;
		private var _text:String;
		private var _screens:Dictionary;
		private var _numScreens:uint;
		private var _alternateBetweenScreens:Boolean;
		private var _currentScreen:uint;
		public function DialogOption(key:String,text:String=null,screens:Dictionary=null,alternateBetweenScreens:Boolean=false)
		{
			_key=key;
			_text=text;
			_screens=screens;
			if(_screens!=null)
				for(var k:String in _screens)
					_numScreens++;
			_alternateBetweenScreens=alternateBetweenScreens;
			_currentScreen=1;
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function get hasText():Boolean
		{
			return (_text!='')?true:false;
		}
		
		public function get text():String
		{
			return _text;
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