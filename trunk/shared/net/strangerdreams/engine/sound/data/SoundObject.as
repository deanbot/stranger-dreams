package net.strangerdreams.engine.sound.data
{
	import net.deanverleger.core.IDestroyable;
	import net.strangerdreams.engine.sound.SoundObjectType;

	public class SoundObject implements ISoundObject, IDestroyable
	{
		private var _key:String;
		private var _className:String;
		public function SoundObject(key:String,className:String)
		{
			_key = key;
			_className = className;
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function get className():String
		{
			return _className;
		}
		
		public function destroy():void
		{
			_key = _className = null;
		}
	}
}