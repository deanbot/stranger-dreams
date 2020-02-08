package net.strangerdreams.engine.sound
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.sound.BaseSoundObject;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.sound.data.SoundInstructionObject;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	import spark.components.mediaClasses.VolumeBar;

	public class SoundUtils
	{
		// constants:
		public static const LOCATION:String = "Soundutils";
		// private properties:
		private static var _uiSoundFinished:NativeSignal;
		private static var _uiSoundChannel:SoundChannel;
		private static var _uiSoundTransform:SoundTransform = new SoundTransform();	
		private static var _numAmbientSoundChannels:uint;
		private static var _numMusicSoundChannels:uint;
		private static var musicChannelsFadedCountdown:uint;
		private static var ambientChannelsFadedCountdown:uint;
		private static var _uiCallbacks:Dictionary = new Dictionary(true);
		private static var _musicSoundChannels:Dictionary = new Dictionary(true);
		private static var _ambientSoundChannels:Dictionary = new Dictionary(true);
		private static var _musicFinishedCallbacks:Dictionary = new Dictionary(true);
		private static var _ambientFinishedCallbacks:Dictionary = new Dictionary(true);
		private static var _musicSoundTransforms:Dictionary = new Dictionary(true);
		private static var _ambientSoundTransforms:Dictionary = new Dictionary(true);
		private static var _musicObjectVolumes:Dictionary = new Dictionary(true);
		private static var _ambientObjectVolumes:Dictionary = new Dictionary(true);
		private static var _fadeMusicTimers:Dictionary=new Dictionary(true);
		private static var _fadeAmbientTimers:Dictionary=new Dictionary(true);
		private static var _onFadeMusicTimer:Dictionary=new Dictionary(true);
		private static var _onFadeAmbientTimer:Dictionary=new Dictionary(true);
		private static var _currentUISound:String = "";
		
		// public properties:
		// constructor:
		// public getter/setters:
		public static function get playingMusic():Boolean
		{
			//LoggingUtils.msgTrace(String((_numMusicSoundChannels > 0) ? true : false),LOCATION+".get playingMusic()");
			return (_numMusicSoundChannels > 0) ? true : false;
		}
		
		public static function get playingAmbient():Boolean
		{
			//LoggingUtils.msgTrace(String((_numAmbientSoundChannels > 0) ? true : false),LOCATION+".get playingAmbient()");
			return (_numAmbientSoundChannels > 0) ? true : false;
		}
		
		// public methods:
		public static function getPlayingKeys(type:String):Dictionary
		{
			var keys:Dictionary = new Dictionary(true);
			var k:Object;
			if(type==SoundObjectType.MUSIC)
			{
				if(playingMusic)
				{
					for(k in _musicSoundChannels)
					{
						keys[k] = k;
					}
				}
			} else if (type==SoundObjectType.AMBIENT)
			{
				if(playingAmbient)
				{
					for(k in _ambientSoundChannels)
					{
						keys[k] = k;
					}
				}
			}
			return keys;
		}
		
		public static function playUISound( sound:Sound, callback:Function, _name:String, ignorePreviousCallback:Boolean = false, volumeMultiplier:Number = -1 ):void
		{
			// get ui sound volume
			_uiSoundTransform.volume = (SEConfig.muted) ? 0 : (volumeMultiplier != -1) ? uiSoundLevel*volumeMultiplier : uiSoundLevel;
			
			//LoggingUtils.msgTrace("Playing UI sound (vol:"+_uiSoundTransform.volume+")",LOCATION);
			//check for other sounds playing with the same name
			if ( _uiSoundChannel != null )
			{
				//stop channel
				_uiSoundChannel.stop();
				
				// reset sound signal
				_uiSoundFinished.removeAll();
				_uiSoundFinished = null;
				
				//reset channel
				_uiSoundChannel = null;
				
				//do callback if not set to ignore
				if ( !ignorePreviousCallback )
					if(_uiCallbacks[_currentUISound]!=null)
						_uiCallbacks[_currentUISound]();
				
				//reset callback at name
				if(_uiCallbacks[_name]!=null)
				{
					_uiCallbacks[_name] = null;
					delete _uiCallbacks[_name];
				}
			}
			
			//store handler in dictionary by name
			_uiCallbacks[_name] = function():void { callback(_name) };
			
			//create function to clean up and do callback
			var onFinished:Function = function ( e:Event ):void
			{
				// reset sound signal
				_uiSoundFinished.removeAll();
				_uiSoundFinished = null;
				
				//reset sound channel
				_uiSoundChannel = null;
				
				// do callback
				_uiCallbacks[_name]();
				
				//reset callback at name
				_uiCallbacks[_name] = null;
				delete _uiCallbacks[_name];
				
				_currentUISound=null;
			};
			
			_currentUISound=_name;
			
			//play sound
			_uiSoundChannel = sound.play( 0, 0, _uiSoundTransform );
			
			//create sound finished signal
			_uiSoundFinished = new NativeSignal( _uiSoundChannel, Event.SOUND_COMPLETE, Event );
			
			//add listener to sound finished signal
			_uiSoundFinished.addOnce( onFinished );
		}
		
		public static function playSoundObject(type:String,soundGroupKey:String,soundInstructionKey:String,volume:Number=1,loop:Boolean = true,nextKey:String=null):void
		{
			LoggingUtils.msgTrace("registering sound ("+type+") Channel ("+soundGroupKey+") at: "+volume,LOCATION);
			// separate by type
			if(type == SoundObjectType.MUSIC)
			{
				//ignore play command if group playing with the same name
				if (!_musicSoundChannels[soundGroupKey])
				{
					_numMusicSoundChannels++;
					registerPlaySoundGroup(_musicSoundChannels,_musicFinishedCallbacks,_musicSoundTransforms,_musicObjectVolumes,volume,type,soundGroupKey,soundInstructionKey,loop,nextKey);
				} else {
					LoggingUtils.msgTrace("Ignoring register command, sound already playing",LOCATION);
				}
			}
			else if (type == SoundObjectType.AMBIENT)
			{
				if (!_ambientSoundChannels[soundGroupKey])
				{
					_numAmbientSoundChannels++;
					registerPlaySoundGroup(_ambientSoundChannels,_ambientFinishedCallbacks,_ambientSoundTransforms,_ambientObjectVolumes,volume,type,soundGroupKey,soundInstructionKey,loop,nextKey);
				} else {
					LoggingUtils.msgTrace("Ignoring register command, sound already playing",LOCATION);
				}
			}
		}
		
		/**
		 * Note: Since function does not edit sound transforms directly (passes to another function),
		 * this function will pass volume levels as is (without factoring in sound offsets)
		 * @param to
		 * @param time
		 * @param removeAllOnComplete
		 * 
		 */
		public static function fadeMusicChannels(to:Number=0,time:Number=.3,removeAllOnComplete:Boolean=false):void
		{
			LoggingUtils.msgTrace("Fading all Music Channels (to:"+to+")",LOCATION);
			var tweenCallback:Function;
			if(removeAllOnComplete) {
				var removeThese:Dictionary = new Dictionary(true);
				for (var k:Object in _musicSoundChannels)
				{
					removeThese[k] = k;
				}
				musicChannelsFadedCountdown=_numMusicSoundChannels;
				tweenCallback = function():void { musicChannelsFadedCountdown--; if(musicChannelsFadedCountdown == 0) emptyMusicChannels(removeThese); };
			}
			for(var key:String in _musicSoundChannels)			
				fadeMusicChannel(key,to,time,false,tweenCallback);
		}

		/**
		 * Note: Since function does not edit sound transforms directly (passes to another function),
		 * this function will pass volume levels as is (without factoring in sound offsets)
		 * @param to
		 * @param time
		 * @param removeAllOnComplete
		 * 
		 */
		public static function fadeAmbientChannels(to:Number=0,time:Number=.3,removeAllOnComplete:Boolean=false):void
		{
			LoggingUtils.msgTrace("Fading all Ambient Channel ("+key+") to: "+to,LOCATION);
			var tweenCallback:Function;
			if(removeAllOnComplete) {
				var removeThese:Dictionary = new Dictionary(true);
				for (var k:Object in _ambientSoundChannels)
				{
					removeThese[k] = k;
				}
				ambientChannelsFadedCountdown=_numAmbientSoundChannels;
				tweenCallback = function():void { ambientChannelsFadedCountdown--; if(ambientChannelsFadedCountdown == 0) emptyAmbientChannels(removeThese); };
			}
			for(var key:String in _ambientSoundChannels)			
				fadeAmbientChannel(key,to,time,false,tweenCallback);
		}
		
		public static function fadeMusicChannel(key:String,to:Number=0,time:Number=.3,removeKeyOnComplete:Boolean=false,callback:Function=null):void
		{
			if(_musicSoundChannels[key]==null)
			{
				LoggingUtils.msgTrace("key (" + key + ") not found",LOCATION + ".fade music channel");
				if(callback!=null)
					callback();
				return;
			}
			var volume:Number = (SEConfig.muted) ? 0 : to*musicSoundLevel;
			LoggingUtils.msgTrace("Fading Music Channel ("+key+") to: "+to + "(actualVolume: " + volume  + ")",LOCATION);
			var updateChannel:Function = function():void{
				SoundChannel(_musicSoundChannels[key]).soundTransform = SoundTransform(_musicSoundTransforms[key]);
				_musicObjectVolumes[key]=SoundChannel(_musicSoundChannels[key]).soundTransform.volume/musicSoundLevel;
			}
			if(removeKeyOnComplete || callback!=null)
			{
				var onComplete:Function = function():void
				{
					if(removeKeyOnComplete)
						removeMusicChannel(key);
					else if(callback!=null)
						callback();
				}
			} 
			TweenLite.killTweensOf(SoundTransform(_musicSoundTransforms[key]));
			if( SoundChannel(_musicSoundChannels[key]).soundTransform.volume == volume)
			{
				if(removeKeyOnComplete || callback!=null)
				{
					_fadeMusicTimers[key]=new Timer(time);
					_onFadeMusicTimer[key]=new NativeSignal(Timer(_fadeMusicTimers[key]), TimerEvent.TIMER, TimerEvent);
					NativeSignal(_onFadeMusicTimer[key]).addOnce( function(e:TimerEvent):void { onComplete(); } );
					Timer(_fadeMusicTimers[key]).start();
				}	
			} else
			{
				if(removeKeyOnComplete || callback!=null)
					TweenLite.to( SoundTransform(_musicSoundTransforms[key]), time, {volume:volume, onUpdate:updateChannel, onComplete:onComplete} );
				else
					TweenLite.to( SoundTransform(_musicSoundTransforms[key]), time, {volume:volume, onUpdate:updateChannel});
			}
		}
		
		public static function fadeAmbientChannel(key:String,to:Number=0,time:Number=.3,removeKeyOnComplete:Boolean=false,callback:Function=null):void
		{
			if(_ambientSoundChannels[key]==null)
			{
				LoggingUtils.msgTrace("key (" + key + ") not found",LOCATION + ".fade ambient channel");
				if(callback!=null)
					callback();
				return;
			}
			var volume:Number = (SEConfig.muted) ? 0 : to*ambientSoundLevel;
			LoggingUtils.msgTrace("Fading Ambient Channel ("+key+") to: "+to + "(actualVolume: " + volume  + ")",LOCATION);
			var updateChannel:Function = function():void 
			{
				SoundChannel(_ambientSoundChannels[key]).soundTransform = SoundTransform(_ambientSoundTransforms[key]);
				_ambientObjectVolumes[key]=SoundChannel(_ambientSoundChannels[key]).soundTransform.volume/ambientSoundLevel;
			}
			if(removeKeyOnComplete || callback!=null)
			{
				var onComplete:Function = function():void
				{
					if(removeKeyOnComplete)
						removeAmbientChannel(key);
					else if(callback!=null)
						callback();
				}
			}
			TweenLite.killTweensOf(SoundTransform(_ambientSoundTransforms[key]));
			if( SoundChannel(_ambientSoundChannels[key]).soundTransform.volume == volume)
			{
				if(removeKeyOnComplete || callback!=null)
				{
					_fadeAmbientTimers[key]=new Timer(time);
					_onFadeAmbientTimer[key]=new NativeSignal(Timer(_fadeAmbientTimers[key]), TimerEvent.TIMER, TimerEvent);
					NativeSignal(_onFadeAmbientTimer[key]).addOnce( function(e:TimerEvent):void { onComplete(); } );
					Timer(_fadeAmbientTimers[key]).start();
				}	
			} else
			{
				if(removeKeyOnComplete || callback!=null)				
					TweenLite.to( SoundTransform(_ambientSoundTransforms[key]), time, {volume:to, onUpdate:updateChannel, onComplete:onComplete} );
				else
					TweenLite.to( SoundTransform(_ambientSoundTransforms[key]), time, {volume:to, onUpdate:updateChannel});
			}
		}

		public static function removeMusicChannel(key:String):void
		{
			if(_musicSoundChannels[key]==null)
				return;
			_numMusicSoundChannels--;
			clearSoundGroup(_musicSoundChannels,_musicFinishedCallbacks,_musicSoundTransforms,_musicObjectVolumes,key);
		}
		
		public static function removeAmbientChannel(key:String):void
		{
			if(_ambientSoundChannels[key]==null)
				return;
			_numAmbientSoundChannels--;
			clearSoundGroup(_ambientSoundChannels,_ambientFinishedCallbacks,_ambientSoundTransforms,_ambientObjectVolumes,key);
		}
		
		public static function emptyMusicChannels(removeThese:Dictionary=null):void
		{
			for(var key:String in _musicSoundChannels)
			{
				if(removeThese!=null)
				{
					if(removeThese[key]!=null) {
						clearSoundGroup(_musicSoundChannels,_musicFinishedCallbacks,_musicSoundTransforms,_musicObjectVolumes,key);
						_numMusicSoundChannels--;
					}
				}else {
					_numMusicSoundChannels=0;
					clearSoundGroup(_musicSoundChannels,_musicFinishedCallbacks,_musicSoundTransforms,_musicObjectVolumes,key);
				}
			}
		}
		
		public static function emptyAmbientChannels(removeThese:Dictionary=null):void
		{
			for(var key:String in _ambientSoundChannels)
			{
				if(removeThese!=null)
				{
					if(removeThese[key]!=null) {
						clearSoundGroup(_ambientSoundChannels,_ambientFinishedCallbacks,_ambientSoundTransforms,_ambientObjectVolumes,key);
						_numAmbientSoundChannels--;
					}
				} else {
					_numAmbientSoundChannels=0;
					clearSoundGroup(_ambientSoundChannels,_ambientFinishedCallbacks,_ambientSoundTransforms,_ambientObjectVolumes,key);
				}
			}
		}
		
		public static function updateSoundObjectsVolume():void
		{
			LoggingUtils.msgTrace("",LOCATION+".updateSoundObjectsVolume()");
			var i:Object;
			for( i in _musicObjectVolumes)
			{
				SoundTransform(_musicSoundTransforms[i]).volume = (SEConfig.muted) ? 0 : Number(_musicObjectVolumes[i])*musicSoundLevel;
				SoundChannel(_musicSoundChannels[i]).soundTransform = SoundTransform(_musicSoundTransforms[i]);	
			}
			
			for( i in _ambientObjectVolumes)
			{
				SoundTransform(_ambientSoundTransforms[i]).volume =  (SEConfig.muted) ? 0 : Number(_ambientObjectVolumes[i])*ambientSoundLevel;
				SoundChannel(_ambientSoundChannels[i]).soundTransform = SoundTransform(_ambientSoundTransforms[i]);
			}
		}
		
		public static function changeSoundChannelVolume(key:String,type:String,volume:Number):void
		{
			LoggingUtils.msgTrace("",LOCATION+".changeSoundChannelVolume()");
			if(type==SoundObjectType.MUSIC)
			{
				//update volume
				if(Number(_musicObjectVolumes[key])!=volume)
				{
					_musicObjectVolumes[key]=volume;
					SoundTransform(_musicSoundTransforms[key]).volume = (SEConfig.muted) ? 0 : volume*musicSoundLevel;
					SoundChannel(_musicSoundChannels[key]).soundTransform = SoundTransform(_musicSoundTransforms[key]);	
				}
			}else if(type==SoundObjectType.AMBIENT)
			{
				if(Number(_ambientObjectVolumes[key])!=volume)
				{
					_ambientObjectVolumes[key]=volume;
					SoundTransform(_ambientSoundTransforms[key]).volume = (SEConfig.muted) ? 0 : volume*ambientSoundLevel;
					SoundChannel(_ambientSoundChannels[key]).soundTransform = SoundTransform(_ambientSoundTransforms[key]);
				}
			}
		}
		
		private static const singleSounds:Dictionary = new Dictionary(true);
		private static const singleSoundIgnoreCallback:Dictionary = new Dictionary(true);
		
		public static function playSingleSound(key:String, sound:Sound, volume:Number = 1, callback:Function = null):void
		{
			if(singleSounds[key] != null)
			{ LoggingUtils.msgTrace("Already playing sound at key: " + key, LOCATION);	return; }
			var object:BaseSoundObject = new BaseSoundObject(sound, (SEConfig.muted) ? 0 : volume);
			singleSounds[key] = object;
			singleSoundIgnoreCallback[key] = false;
			LoggingUtils.msgTrace("Play single sound (" + key +") at: "+volume,LOCATION);
			if(callback !=null)
				object.soundComplete.addOnce( 
					function():void
					{
						if(!singleSoundIgnoreCallback[key])
							callback();
					}
				);
			object.soundComplete.addOnce( function():void { clearSingleSound(key); } );
			object.playSound();
		}
		
		public static function playSingleSoundObject(key:String, type:String, vol:Number = 1, callback:Function = null):void
		{
			playSingleSound(key, Sound(SoundInstructionManager.getSoundInstance(key,type)),vol,callback);
		}
		
		public static function stopSingleSound(key:String, ignoreCallback:Boolean = true):void
		{
			if(singleSounds[key] == null)
				return;
			LoggingUtils.msgTrace("Stop single sound (" + key +")",LOCATION);
			var object:BaseSoundObject = BaseSoundObject(singleSounds[key]);
			if(object.playing)
			{
				if(ignoreCallback)
					singleSoundIgnoreCallback[key] = true;
				object.stopSound();	
			}
		}
		
		public static function fadeSingleSound(key:String, to:Number, duration:Number, callback:Function = null):void
		{
			if(singleSounds[key] == null)
				return;
			var object:BaseSoundObject = BaseSoundObject(singleSounds[key]);
			singleSoundIgnoreCallback[key] = false;
			if(callback !=null)
				object.fadeComplete.addOnce( 
					function():void
					{
						if(!singleSoundIgnoreCallback[key])
							callback();
						clearSingleSound(key);
					}
				);

			object.fadeTo(to,duration);
		}
		
		private static function clearSingleSound(key:String):void
		{
			if(singleSounds[key] == null)
				return;
			var object:BaseSoundObject = BaseSoundObject(singleSounds[key]);
			object.destroy()
			singleSounds[key] = null;
			delete singleSounds[key];
			delete singleSoundIgnoreCallback[key];
		}

	// private methods:
		private static function registerPlaySoundGroup(channelsDictionary:Dictionary, callbacksDictionary:Dictionary, transforms:Dictionary, volumesDictionary:Dictionary, volume:Number, type:String, soundObjectKey:String, soundInstructionKey:String, loop:Boolean = true, nextKey:String = null):void
		{
			//LoggingUtils.msgTrace("Registering Play Sound Group",LOCATION);
			var channel:SoundChannel = new SoundChannel();
			
			var transform:SoundTransform;
			var soundInstance:Sound;
			volumesDictionary[soundObjectKey]=volume;
			if(type==SoundObjectType.MUSIC)
			{
				transform = new SoundTransform( (SEConfig.muted) ? 0 : volume*musicSoundLevel);
				LoggingUtils.msgTrace("Playing music sound ["+soundObjectKey+"] (vol:"+((SEConfig.muted) ? 0 : volume*musicSoundLevel)+")",LOCATION);
			}
			else if(type==SoundObjectType.AMBIENT)
			{
				transform = new SoundTransform( (SEConfig.muted) ? 0 : volume*ambientSoundLevel);
				LoggingUtils.msgTrace("Playing ambient sound ["+soundObjectKey+"] (vol:"+((SEConfig.muted) ? 0 : volume*ambientSoundLevel)+")",LOCATION);
			}
			var listener:Function = function(e:Event):void
			{
				LoggingUtils.msgTrace("Sound ["+soundObjectKey+"] Complete");
				clearSoundGroup(channelsDictionary,callbacksDictionary,transforms,volumesDictionary,soundObjectKey);
				if(type==SoundObjectType.MUSIC)
					_numMusicSoundChannels--;
				else if(type==SoundObjectType.AMBIENT)
					_numAmbientSoundChannels--;
				if(nextKey)
				{
					var soundInstructionObject:SoundInstructionObject = SoundInstructionManager.getSoundInstructionObject(soundInstructionKey,soundObjectKey,type);
					playSoundObject(type,nextKey,soundInstructionKey,soundInstructionObject.volume,soundInstructionObject.loop,soundInstructionObject.nextSoundObjectKey);
				}
			};
			
			soundInstance = SoundInstructionManager.getSoundInstance(soundObjectKey,type);
			if(soundInstance == null)
				return;
			channelsDictionary[soundObjectKey] = channel = soundInstance.play(0,(loop == true)?9999:0,transform);
			var soundFinished:NativeSignal = new NativeSignal(channel,Event.SOUND_COMPLETE,Event);
			soundFinished.addOnce(listener);
			callbacksDictionary[soundObjectKey] = soundFinished;
			transforms[soundObjectKey] = transform;
		}
		
		private static function clearSoundGroup(channels:Dictionary,callbacks:Dictionary,transforms:Dictionary,volumes:Dictionary,key:String):void
		{
			if(callbacks[key] != null)
				NativeSignal(callbacks[key]).removeAll();
			if(channels[key] != null)
				SoundChannel(channels[key]).stop();
			channels[key]=null;
			callbacks[key]=null;
			transforms[key]=null;
			volumes[key]=null;
			if(_onFadeMusicTimer[key]!=null)
			{
				NativeSignal(_onFadeMusicTimer[key]).removeAll();
				_onFadeMusicTimer[key]=null;
				delete _onFadeMusicTimer[key];
			}
			if(_fadeMusicTimers[key]!=null)
			{
				_fadeMusicTimers[key]=null;
				delete _fadeMusicTimers[key];
			}
			if(_onFadeAmbientTimer[key]!=null)
			{
				NativeSignal(_onFadeAmbientTimer[key]).removeAll();
				_onFadeAmbientTimer[key]=null;
				delete _onFadeAmbientTimer[key];
			}
			if(_fadeAmbientTimers[key]!=null)
			{
				_fadeAmbientTimers[key]=null;
				delete _fadeAmbientTimers[key];
			}
			delete channels[key];
			delete callbacks[key];
			delete transforms[key];
			delete volumes[key];
		}
		
		private static function get uiSoundLevel():Number
		{
			return ( SEConfig.globalVolume * SEConfig.uiVolumeOffset );
		}
		
		private static function get musicSoundLevel():Number
		{
			return ( SEConfig.globalVolume * SEConfig.musicVolumeOffset );
		}
		
		private static function get ambientSoundLevel():Number
		{
			return ( SEConfig.globalVolume * SEConfig.ambientVolumeOffset );
		}
	}
}