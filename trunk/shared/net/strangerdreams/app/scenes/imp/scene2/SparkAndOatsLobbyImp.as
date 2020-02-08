package net.strangerdreams.app.scenes.imp.scene2
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.flag.FlagManager;
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
			this.sm.addState( ArtAuto.KEY, new ArtAuto(), (ArtAuto.KEY == defaultState)?true:false );
			this.sm.addState( DoreenFull.KEY, new DoreenFull(), (DoreenFull.KEY == defaultState)?true:false );
			this.sm.addState( DoreenShort.KEY, new DoreenShort(), (DoreenShort.KEY == defaultState)?true:false );
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

import net.strangerdreams.app.scenes.imp.scene2.SparkAndOatsLobbyImp;

class ArtAuto extends State
{
	public static const KEY:String = "ArtAuto";
	public function ArtAuto()
	{
		
	}
	
	override public function doIntro():void
	{
		MovieClip(this.context).dispatchEvent(new Event(SparkAndOatsLobbyImp.EVENT_DODOORSOUND));
		this.signalIntroComplete();
	}
}

class DoreenFull extends State
{
	public static const KEY:String = "DoreenFull";
	public function DoreenFull()
	{
		
	}
	
	override public function doIntro():void
	{
		MovieClip(this.context).dispatchEvent(new Event(SparkAndOatsLobbyImp.EVENT_DODOORSOUND));
		this.signalIntroComplete();
	}
}

class DoreenShort extends State
{
	public static const KEY:String = "DoreenShort";
	public function DoreenShort()
	{
		
	}
	
	override public function doIntro():void
	{
		MovieClip(this.context).dispatchEvent(new Event(SparkAndOatsLobbyImp.EVENT_DODOORSOUND));
		this.signalIntroComplete();
	}
}