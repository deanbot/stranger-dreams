package net.strangerdreams.engine.script.data
{
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.data.IOrderedObject;
	import net.strangerdreams.engine.data.IScreened;
	
	public class ScriptScreen implements IBaseText, IOrderedObject
	{
		private var _text:String;
		private var _order:uint;
		private var _screens:Dictionary;
		private var _numScreens:uint;
		public function ScriptScreen(order:uint,text:String=null,screens:Dictionary=null)
		{
			_order=order;
			_text=text;
			_screens=screens;
			if(_screens!=null)
				for(var k:String in _screens)
					_numScreens++;
		}

		public function get hasText():Boolean
		{
			return (_text!='')?true:false;
		}
		
		public function get text():String
		{
			return _text;
		}

		public function get order():uint
		{
			return _order;
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
	}
}