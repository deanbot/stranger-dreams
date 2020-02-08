package net.deanverleger.sound
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	public class BaseSoundObject
	{
		private var _soundChannel:SoundChannel;
		private var _soundTransform:SoundTransform;
		private var _playing:Boolean;
		private var _fading:Boolean;
		private var _sound:Sound;
		private var _soundComplete:Signal;
		private var _fadeComplete:Signal;
		private var _soundCompleted:NativeSignal;
		private var _loops:Number;

		public function BaseSoundObject(sound:Sound,startingVolume:Number,loops:Number = 0)
		{
			_sound = sound;
			_soundTransform = new SoundTransform(startingVolume);
			_fadeComplete = new Signal();
			_soundComplete = new Signal();
			_loops = loops;
			_playing = _fading = false;
		}
		
		public function get fadeComplete():Signal
		{
			return _fadeComplete;
		}

		public function get soundComplete():Signal
		{
			return _soundComplete;
		}

		public function get playing():Boolean
		{
			return _playing;
		}

		public function get soundTransform():SoundTransform
		{
			return _soundTransform;
		}

		public function get soundChannel():SoundChannel
		{
			return _soundChannel;
		}

		public function playSound():void
		{
			if(playing)
				return;
			if (_soundTransform == null)
				return;
			_soundChannel = _sound.play(0,_loops,_soundTransform);
			_soundCompleted = new NativeSignal(_soundChannel,Event.SOUND_COMPLETE,Event);
			_soundCompleted.addOnce( 
				function():void { 
					_playing = false;
					soundComplete.dispatch(); 
				} 
			);
			_playing = true;
		}
		
		public function stopSound():void
		{
			if(!playing)
				return;
			if (_soundTransform == null || _soundChannel == null)
				return;
			_soundChannel.stop();
			_playing = false;
			if(_fading) 
			{
				_fading = false;
				TweenLite.killTweensOf(_soundTransform);
			}
		}
		
		public function fadeTo(to:Number, duration:Number):void
		{
			if(!playing)
				return;
			if (_soundTransform == null || _soundChannel == null)
				return;
			if(volume == to)
				_fadeComplete.dispatch();
			else
			{
				_fading = true;
				TweenLite.killTweensOf(_soundTransform);
				TweenLite.to( _soundTransform, duration, {volume:to, onUpdate:updateChannel, onComplete:_fadeComplete.dispatch} );
			}
		}
		
		public function get volume():Number
		{
			return (_soundTransform != null) ? _soundTransform.volume : -9999;
		}
		
		public function set volume(val:Number):void
		{
			if (_soundTransform == null || _soundChannel == null)
				return;
			_soundTransform.volume = val;
			_soundChannel.soundTransform = _soundTransform;
		}
		
		public function destroy():void
		{
			if(_playing)
				if(_soundChannel !=null)
					_soundChannel.stop();
			_soundChannel = null;
			_soundTransform = null;
			_sound = null;
		}
		
		private function updateChannel():void
		{
			if (_soundTransform == null || _soundChannel == null)
				return;
			_soundChannel.soundTransform = _soundTransform;
		}
	}
}