package net.strangerdreams.engine.script.data
{
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.data.IScreened;
	import net.strangerdreams.engine.data.IVersioned;
	
	public class Dialog implements IBaseText, IVersioned, IScreened
	{
		private var _key:String;
		private var _text:String;
		private var _screens:Dictionary;
		private var _numScreens:uint;
		private var _alternateBetweenScreens:Boolean;
		private var _versions:Dictionary;
		private var _numVersions:uint;
		private var _currentScreen:uint;
		
		public function Dialog(key:String,text:String=null,screens:Dictionary=null,alternateBetweenScreens:Boolean=false,versions:Dictionary=null)
		{
			_key=key;
			_text=text;
			_screens=screens;
			if(_screens!=null)
				for(var k:String in _screens)
					_numScreens++;
			_alternateBetweenScreens=alternateBetweenScreens;
			_versions=versions;
			if(_versions!=null)
				for(var s:String in _versions)
					_numVersions++;
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
		
		public function get hasVersions():Boolean
		{
			return (_versions!=null)?true:false;
		}
		
		public function get versions():Dictionary
		{
			return _versions;
		}
		
		public function get numVersions():uint
		{
			return _numVersions;
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