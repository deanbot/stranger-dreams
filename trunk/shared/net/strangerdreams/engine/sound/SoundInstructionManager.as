package net.strangerdreams.engine.sound
{
	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.scene.data.NodeState;
	import net.strangerdreams.engine.sound.data.SoundInstruction;
	import net.strangerdreams.engine.sound.data.SoundInstructionObject;
	import net.strangerdreams.engine.sound.data.SoundObject;

	public class SoundInstructionManager
	{
		public static const LOCATION:String = "Sound Instruction Manager";
	// private properties:
		private static var _soundInstructions:Dictionary = new Dictionary(true);
		private static var _musicSoundObjects:Dictionary = new Dictionary(true);
		private static var _ambientSoundObjects:Dictionary = new Dictionary(true);
	
	// public methods:
		public static function generate(soundInstructionsData:XML,soundObjectsData:XML):void
		{
			if(soundInstructionsData == null || soundObjectsData == null)
				return;
			for each(var instructionData:XML in soundInstructionsData.soundInstruction)
			{
				var k:String = String(instructionData.@key);
				if(k==null)
					throw new Error("Sound Instruction Manager: Sound Instruction has no key.");
				_soundInstructions[k] = getSoundInstruction(instructionData);
			}
			var enumerationPackage:String = String(soundObjectsData.@enumerationPackage);
			var enumerationClassName:String = String(soundObjectsData.@enumerationClassName);
			if(enumerationClassName==null)
				throw new Error("Sound Instruction Manager: Sound Objects have no Enumeration Class Name.");
			for each(var mObjectData:XML in soundObjectsData.music.soundObject)
			{
				var key:String = String(mObjectData.@key);
				if(key==null)
					throw new Error("Sound Instruction Manager: Sound Object has no key.");
				var className:String = String(mObjectData.@className);
				if(className==null)
					throw new Error("Sound Instruction Manager: Sound Object has class name.");
				_musicSoundObjects[key] = getSoundObject(mObjectData,enumerationClassName,enumerationPackage);
			}
			for each(var objectData:XML in soundObjectsData.ambient.soundObject)
			{
				var aKey:String = String(objectData.@key);
				if(aKey==null)
					throw new Error("Sound Instruction Manager: Sound Object has no key.");
				var aClassName:String = String(objectData.@className);
				if(aClassName==null)
					throw new Error("Sound Instruction Manager: Sound Object has class name.");
				_ambientSoundObjects[aKey] = getSoundObject(objectData,enumerationClassName,enumerationPackage);
			}
		}

		public static function getSoundInstance(soundObjectKey:String,type:String):Sound
		{
			var s:Sound;
			if(type==SoundObjectType.MUSIC)
			{
				if(_musicSoundObjects[soundObjectKey])
					s = AssetUtils.getAssetInstance(SoundObject(_musicSoundObjects[soundObjectKey]).className) as Sound;
			} else if(type==SoundObjectType.AMBIENT)
			{
				if(_ambientSoundObjects[soundObjectKey])
					s = AssetUtils.getAssetInstance(SoundObject(_ambientSoundObjects[soundObjectKey]).className) as Sound;
			}
			return s;
		}
		
		public static function getSoundInstructionObject(soundInstructionKey:String, soundObjectKey:String, type:String):SoundInstructionObject
		{
			var s:SoundInstructionObject;
			if(_soundInstructions[soundInstructionKey])
			{
				if(type==SoundObjectType.MUSIC)
					s = SoundInstruction(_soundInstructions[soundInstructionKey]).musicInstructionObjects[soundObjectKey] as SoundInstructionObject;
				else if(type==SoundObjectType.AMBIENT)
					s = SoundInstruction(_soundInstructions[soundInstructionKey]).ambientInstructionObjects[soundObjectKey] as SoundInstructionObject;
			}
			return s;
		}
		
		public static function activateSoundInstruction(soundInstructionKey:String):void
		{
			var i:Object;
			var instructionObjectSets:Dictionary;
			var instructionObject:SoundInstructionObject;
			var currentInstructionObjects:Dictionary;
			LoggingUtils.msgTrace(soundInstructionKey,LOCATION + ".activateSoundInstruction()");
			if(SoundUtils.playingMusic)
			{
				//playing similar music. only play new music
				currentInstructionObjects = SoundUtils.getPlayingKeys(SoundObjectType.MUSIC);
				instructionObjectSets=SoundInstruction(_soundInstructions[soundInstructionKey]).musicInstructionObjects;
				for(i in instructionObjectSets)
				{
					if(currentInstructionObjects[i] == null)
					{
						instructionObject = SoundInstructionObject(instructionObjectSets[i]);
						if(instructionObject.playAtStart)
							SoundUtils.playSoundObject(SoundObjectType.MUSIC,instructionObject.soundObjectKey,soundInstructionKey,instructionObject.volume,instructionObject.loop,instructionObject.nextSoundObjectKey);
					}
				}
			} else
			{
				instructionObjectSets=SoundInstruction(_soundInstructions[soundInstructionKey]).musicInstructionObjects;
				for(i in instructionObjectSets)
				{
					instructionObject = SoundInstructionObject(instructionObjectSets[i]);
					if(instructionObject.playAtStart)
						SoundUtils.playSoundObject(SoundObjectType.MUSIC,instructionObject.soundObjectKey,soundInstructionKey,instructionObject.volume,instructionObject.loop,instructionObject.nextSoundObjectKey);
				}
			}
			
			if(SoundUtils.playingAmbient)
			{
				//playing similar ambient. only play new ambient
				currentInstructionObjects = SoundUtils.getPlayingKeys(SoundObjectType.AMBIENT);
				instructionObjectSets=SoundInstruction(_soundInstructions[soundInstructionKey]).ambientInstructionObjects;
				for(i in instructionObjectSets)
				{
					if(currentInstructionObjects[i] == null)
					{
						instructionObject = SoundInstructionObject(instructionObjectSets[i]);
						if(instructionObject.playAtStart)
							SoundUtils.playSoundObject(SoundObjectType.AMBIENT,instructionObject.soundObjectKey,soundInstructionKey,instructionObject.volume,instructionObject.loop,instructionObject.nextSoundObjectKey);
					}
				}
			} else
			{
				instructionObjectSets=SoundInstruction(_soundInstructions[soundInstructionKey]).ambientInstructionObjects;
				for(i in instructionObjectSets)
				{
					instructionObject = SoundInstructionObject(instructionObjectSets[i]);
					if(instructionObject.playAtStart)	
						SoundUtils.playSoundObject(SoundObjectType.AMBIENT,instructionObject.soundObjectKey,soundInstructionKey,instructionObject.volume,instructionObject.loop,instructionObject.nextSoundObjectKey);
				}
			}
		}
		
		public static function manageSoundChannelRemoval(currentLocationNode:LocationNode, destinationLocationNode:LocationNode = null):void
		{		
			if(destinationLocationNode == null && currentLocationNode.destinationState == null)
			{
				LoggingUtils.msgTrace("Fade out all");
				if(SoundUtils.playingAmbient)
					SoundUtils.fadeAmbientChannels(0,.3,true);
				if(SoundUtils.playingMusic)
					SoundUtils.fadeMusicChannels(0,.3,true);
			} else {
				var play:Boolean = SoundUtils.playingMusic;
				var tempInstruction:SoundInstruction;
				if(SoundUtils.playingMusic || SoundUtils.playingAmbient)
				{
					var currentSoundInstructionObjects:Dictionary = new Dictionary(true);
					var destinationSoundInstructionObjects:Dictionary = new Dictionary(true);
					var destinationState:NodeState;
					if(!destinationLocationNode) 
					{ //switching states
						destinationState = currentLocationNode.destinationState
						if(destinationState) 
						{ //returned a state
							if (destinationState.key != currentLocationNode.currentStateKey) 
							{ //is a different state
								if (currentLocationNode.soundInstructionKey == null ||currentLocationNode.soundInstructionKey =="" )
								{ //current node has state level sound instructions
									if (currentLocationNode.currentState.soundInstructionKey != destinationState.soundInstructionKey)
									{ //is changing to a new sound Instruction Key
										if(SoundUtils.playingMusic)
										{
											currentSoundInstructionObjects = (_soundInstructions[currentLocationNode.currentState.soundInstructionKey] as SoundInstruction).musicInstructionObjects;
											destinationSoundInstructionObjects = (_soundInstructions[destinationState.soundInstructionKey] as SoundInstruction).musicInstructionObjects;
											removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.MUSIC,false);
										}
										if(SoundUtils.playingAmbient)
										{
											currentSoundInstructionObjects = (_soundInstructions[currentLocationNode.currentState.soundInstructionKey] as SoundInstruction).ambientInstructionObjects;
											destinationSoundInstructionObjects = (_soundInstructions[destinationState.soundInstructionKey] as SoundInstruction).ambientInstructionObjects;
											removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.AMBIENT,false);
										}
									}
								} 
							} 
						}
					} else
					{ //switching nodes
						if (destinationLocationNode.soundInstructionKey == "")
						{ // destination node has state level sound instructions
							destinationState = destinationLocationNode.destinationState
							if(destinationState)
							{ //returned a state
								if (currentLocationNode.soundInstructionKey == "")
								{ //current node has state level sound instructions
									if(currentLocationNode.currentState.soundInstructionKey != destinationState.soundInstructionKey)
									{ //changing to a new sound Instruction Key
										if(SoundUtils.playingMusic)
										{
											tempInstruction = (_soundInstructions[currentLocationNode.currentState.soundInstructionKey] as SoundInstruction);
											if(tempInstruction!=null)
												currentSoundInstructionObjects = tempInstruction.musicInstructionObjects;
											tempInstruction = (_soundInstructions[destinationState.soundInstructionKey] as SoundInstruction);
											if(tempInstruction!=null)
												destinationSoundInstructionObjects = tempInstruction.musicInstructionObjects;
											removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.MUSIC);
										}
										if(SoundUtils.playingAmbient)
										{
											tempInstruction = (_soundInstructions[currentLocationNode.currentState.soundInstructionKey] as SoundInstruction);
											if(tempInstruction!=null)
												currentSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
											tempInstruction = (_soundInstructions[destinationState.soundInstructionKey] as SoundInstruction);
											if(tempInstruction!=null)
												destinationSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
											removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.AMBIENT);
										}
									}
								} else 
								{ //current node has node level sound instructions
									if(currentLocationNode.soundInstructionKey != destinationState.soundInstructionKey)
									{ //changing to a new sound Instruction Key
										if(SoundUtils.playingMusic)
										{
											tempInstruction = (_soundInstructions[currentLocationNode.soundInstructionKey] as SoundInstruction);
											if(tempInstruction !=null)
												currentSoundInstructionObjects = tempInstruction.musicInstructionObjects;
											tempInstruction = (_soundInstructions[destinationState.soundInstructionKey] as SoundInstruction);
											if(tempInstruction !=null)
												destinationSoundInstructionObjects = tempInstruction.musicInstructionObjects;
											removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.MUSIC);
										}
										if(SoundUtils.playingAmbient)
										{
											tempInstruction = (_soundInstructions[currentLocationNode.soundInstructionKey] as SoundInstruction);
											if(tempInstruction !=null)
												currentSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
											tempInstruction = (_soundInstructions[destinationState.soundInstructionKey] as SoundInstruction);
											if(tempInstruction !=null)
												destinationSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
											removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.AMBIENT);
										}
									}
								}
							}
						} else
						{ // destination node has node level sound instructions
							if (currentLocationNode.soundInstructionKey == "")
							{ //current node has state level sound instructions
								if(currentLocationNode.currentState.soundInstructionKey != destinationLocationNode.soundInstructionKey)
								{ //changing to a new sound Instruction Key
									if(SoundUtils.playingMusic)
									{
										tempInstruction = (_soundInstructions[currentLocationNode.currentState.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											currentSoundInstructionObjects = tempInstruction.musicInstructionObjects;
										tempInstruction =(_soundInstructions[destinationLocationNode.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											destinationSoundInstructionObjects = tempInstruction.musicInstructionObjects;
										removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.MUSIC);
									}
									
									if(SoundUtils.playingAmbient)
									{
										tempInstruction =(_soundInstructions[currentLocationNode.currentState.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											currentSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
										tempInstruction = (_soundInstructions[destinationLocationNode.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											destinationSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
										removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.AMBIENT);
									}
								}
							} else 
							{ //current node has node level sound instructions
								if (currentLocationNode.soundInstructionKey != destinationLocationNode.soundInstructionKey)
								{  //changing to a new sound Instruction Key
									if(SoundUtils.playingMusic)
									{
										tempInstruction = (_soundInstructions[currentLocationNode.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											currentSoundInstructionObjects = tempInstruction.musicInstructionObjects;
										tempInstruction = (_soundInstructions[destinationLocationNode.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											destinationSoundInstructionObjects = tempInstruction.musicInstructionObjects;
										removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.MUSIC);
									}
									
									if(SoundUtils.playingAmbient)
									{
										tempInstruction = (_soundInstructions[currentLocationNode.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											currentSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
										tempInstruction = (_soundInstructions[destinationLocationNode.soundInstructionKey] as SoundInstruction);
										if(tempInstruction!=null)
											destinationSoundInstructionObjects = tempInstruction.ambientInstructionObjects;
										removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects,destinationSoundInstructionObjects,SoundObjectType.AMBIENT);
									}
								}
							}
						}
					}
				}
			}
		}
		
		public static function clear():void
		{
			DictionaryUtils.emptyDestroyable(_soundInstructions);
			DictionaryUtils.emptyDestroyable(_musicSoundObjects);
			DictionaryUtils.emptyDestroyable(_ambientSoundObjects);
		}
	
	// private methods:	
		private static function getSoundInstruction(instructionData:XML):SoundInstruction
		{
			var key:String = String(instructionData.@key);
			var musicObjects:XMLList = XMLList(instructionData.music);
			var ambientObjects:XMLList = XMLList(instructionData.ambient);
			return new SoundInstruction(key,musicObjects,ambientObjects);
		}
		
		private static function getSoundObject(objectData:XML,enumerationClassName:String,enumerationPackage:String=null):SoundObject
		{
			
			var key:String = String(objectData.@key);
			var className:String = String(objectData.@className);
			return new SoundObject(key,className);
		}
		
		private static function removeDissimilarAndUpdateSimilar(currentSoundInstructionObjects:Dictionary,destinationSoundInstructionObjects:Dictionary,type:String,fade:Boolean=true):void
		{	
			var similar:Array = new Array();
			var dissimilar:Array = new Array();
			var i:uint;
			
			for(var key:String in currentSoundInstructionObjects)
				if (destinationSoundInstructionObjects[key])
					similar.push(key);
				else
					dissimilar.push(key);
			
			/*
			if (similar.length == 0)
			{
				if(type==SoundObjectType.MUSIC)
					if(fade)
						SoundUtils.fadeMusicChannels(0,SEConfig.transitionTime*2,true);
					else
						SoundUtils.emptyMusicChannels();
				else if(type==SoundObjectType.AMBIENT)
					if(fade)
						SoundUtils.fadeAmbientChannels(0,SEConfig.transitionTime*2,true);
					else
						SoundUtils.emptyAmbientChannels();
			} else
			{ */
				for(i=0;i<dissimilar.length;i++)
				{
					if(type==SoundObjectType.MUSIC)
					{
						if(fade)
							SoundUtils.fadeMusicChannel(dissimilar[i],0,SEConfig.transitionTime*2,true);
						else 
							SoundUtils.removeMusicChannel(dissimilar[i]);
					} else if(type==SoundObjectType.AMBIENT)
					{
						if(fade)
							SoundUtils.fadeAmbientChannel(dissimilar[i],0,SEConfig.transitionTime*2,true);
						else 
							SoundUtils.removeAmbientChannel(dissimilar[i]);
					}	
				}
				for(i=0;i<similar.length;i++)
				{
					var to:Number = SoundInstructionObject(destinationSoundInstructionObjects[similar[i]]).volume;
					var different:Boolean = (SoundInstructionObject(currentSoundInstructionObjects[similar[i]]).volume != to) ? true : false;
					if(different)
					{
						if(type==SoundObjectType.MUSIC)
							if(fade)
								SoundUtils.fadeMusicChannel(similar[i],to,SEConfig.transitionTime*2);
							else 
								SoundUtils.changeSoundChannelVolume(similar[i],SoundObjectType.MUSIC,to);
						else if(type==SoundObjectType.AMBIENT)
							if(fade)
								SoundUtils.fadeAmbientChannel(similar[i],to,SEConfig.transitionTime*2);
							else 
								SoundUtils.changeSoundChannelVolume(similar[i],SoundObjectType.AMBIENT,to);
					}
				}
			/*} */
			similar = dissimilar = null;
			currentSoundInstructionObjects = destinationSoundInstructionObjects = null;
		}
	}
}