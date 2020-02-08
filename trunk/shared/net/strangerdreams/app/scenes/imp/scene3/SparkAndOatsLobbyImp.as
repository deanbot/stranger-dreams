package net.strangerdreams.app.scenes.imp.scene3
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.sound.SoundObjectType;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class SparkAndOatsLobbyImp extends LocationNode implements INodeImplementor
	{
		public static const EVENT_DODOORSOUND:String = "eventDoDoorSound";
		private var frame:SparkAndOatsLobby;
		private var doDoorSound:NativeSignal;
		private var removedFromStage:NativeSignal;
		public function SparkAndOatsLobbyImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			removedFromStage = new NativeSignal(this.asset,Event.REMOVED_FROM_STAGE,Event);
			removedFromStage.addOnce(cleanUp);
			doDoorSound = new NativeSignal(this.asset,EVENT_DODOORSOUND,Event);
			doDoorSound.addOnce(closeDoor);
			this.sm.addState( Default.KEY, new Default(), (Default.KEY == defaultState)?true:false );
		}
		
		private function closeDoor(e:Event):void
		{
			if(SEConfig.doorReset == true)
			{
				SoundUtils.playSingleSoundObject("hotelDoorClose",SoundObjectType.AMBIENT,1);
				SEConfig.doorReset = false;
			}
		}
		
		private function cleanUp(e:Event):void
		{
			doDoorSound.remove(closeDoor);
			removedFromStage = doDoorSound = null;
		}
	}
}

import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.Event;

import net.strangerdreams.app.scenes.imp.scene3.SparkAndOatsLobbyImp;

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		MovieClip(this.context).dispatchEvent(new Event(SparkAndOatsLobbyImp.EVENT_DODOORSOUND));
		this.signalIntroComplete();
	}
}