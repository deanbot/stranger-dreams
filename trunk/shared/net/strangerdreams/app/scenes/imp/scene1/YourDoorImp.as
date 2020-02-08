package net.strangerdreams.app.scenes.imp.scene1
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class YourDoorImp extends LocationNode implements INodeImplementor
	{
		private var frame:SparkAndOatsDoors;
		private var removeFromStage:NativeSignal;
		private var busy:Boolean;
		
		public function YourDoorImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			sm.addState(Locked.KEY, new Locked(), (Locked.KEY==defaultState)?true:false);
			sm.addState(Unlocked.KEY, new Unlocked(), (Unlocked.KEY==defaultState)?true:false);
			
			removeFromStage=new NativeSignal(this.asset, Event.REMOVED_FROM_STAGE, Event );
			removeFromStage.addOnce(cleanUp);
			SESignalBroadcaster.compassDirectionClicked.add(compassArrowPressed);
			busy = false;
		}
		
		private function cleanUp(e:Event):void
		{
			removeFromStage.removeAll();
			removeFromStage = null;
			SESignalBroadcaster.compassDirectionClicked.remove(compassArrowPressed);
			busy = false
		}
		
		private function compassArrowPressed(dir:String):void
		{
			if(busy)
				return;
			if(!FlagManager.getHasFlag("unlocked"))
			{
				if(dir == "N")
				{
					busy = true;
					SESignalBroadcaster.captionComplete.addOnce(resetCaption)
					SESignalBroadcaster.singleCaption.dispatch("wheresRoomKey");
				}
				
			} else
			{
				SESignalBroadcaster.changeNode.dispatch(6);
			}
		}
		
		private function resetCaption():void
		{
			busy =false;
		}
	}
}

import com.meekgeek.statemachines.finite.states.State;

import flash.events.MouseEvent;

import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.sound.SoundObjectType;
import net.strangerdreams.engine.sound.SoundUtils;

import org.osflash.signals.natives.NativeSignal;

class Locked extends State
{
	public static const KEY:String = "Locked";
	private var ref:SparkAndOatsDoors;
	private var handleClick:NativeSignal;
	private var a:Boolean;
	private var playing:Boolean;
	
	public function Locked()
	{
		
	}
	override public function doIntro():void
	{
		ref = this.context as SparkAndOatsDoors;
		SESignalBroadcaster.itemUsed.addOnce( onKeyUsed );
		handleClick = new NativeSignal( ref["handle"],MouseEvent.CLICK,MouseEvent);
		handleClick.add(onLockedClicked);
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		handleClick.remove(onLockedClicked);
		handleClick = null;
		this.signalOutroComplete();
	}
	
	private function onKeyUsed( object:String ):void
	{
		if(object == "handle")
		{
			SoundUtils.playSingleSoundObject("hotelRoomDoorUnlocked",SoundObjectType.AMBIENT,1);
			ref = null;
		}
	}
	
	private function onLockedClicked(e:MouseEvent):void
	{
		if(playing)
			return;
		playing = true;
		SoundUtils.playSingleSoundObject((a==true)?"hotelRoomDoorJiggleA":"hotelRoomDoorJiggleB",SoundObjectType.AMBIENT,1,stopWorking);
		a = !a;
	}
	
	private function stopWorking():void
	{
		playing = false;
	}
}

class Unlocked extends State
{
	public static const KEY:String = "Unlocked";
	public function Unlocked()
	{
		
	}
}