package net.strangerdreams.engine.sound.data
{
	import net.deanverleger.core.IDestroyable;

	public class SoundInstructionObject implements ISoundInstructionObject, IDestroyable
	{
		private var _soundObjectKey:String;
		private var _loop:Boolean;
		private var _volume:Number;
		private var _nextSoundObjectKey:String;
		private var _playAtStart:Boolean;
		public function SoundInstructionObject(key:String,loopObject:Boolean,rawVolume:Number,playAtStart:Boolean=true,nextKey:String=null)
		{
			_soundObjectKey = key;
			_loop = loopObject;
			if(rawVolume<0)
				throw new Error("Instruction Object Volume cannot be negative");
			if(rawVolume>1)
				_volume = rawVolume*.01;
			else
				_volume = rawVolume;
			_playAtStart=playAtStart;
			_nextSoundObjectKey = nextKey;
		}
		
		public function get soundObjectKey():String
		{
			return _soundObjectKey;
		}
		
		public function get loop():Boolean
		{
			return _loop;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get nextSoundObjectKey():String
		{
			return _nextSoundObjectKey;
		}
		
		public function destroy():void
		{
			_soundObjectKey = _nextSoundObjectKey = null;
			_volume = 0;
			_loop = false;
		}
		
		public function get playAtStart():Boolean
		{
			return _playAtStart;
		}
	}
}