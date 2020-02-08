package net.strangerdreams.app.scenes.imp.scene1
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class SparkAndOatsLobbyImp extends LocationNode implements INodeImplementor
	{
		private var frame:SparkAndOatsLobby;
		private var removeFromStage:NativeSignal;
		private var busy:Boolean;
		
		public function SparkAndOatsLobbyImp()
		{
			super();
			
		}
		
		public function loadStates(defaultState:String):void
		{
			sm.addState(ArtIntro.KEY, new ArtIntro(), (ArtIntro.KEY==defaultState)?true:false);
			sm.addState(Items.KEY, new Items());
			sm.addState(ArtDialogContinued.KEY, new ArtDialogContinued());
			sm.addState(DialogFinished.KEY, new DialogFinished(), (DialogFinished.KEY==defaultState)?true:false);
			
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
			
			if(dir == "E")
			{
				busy = true;
				SESignalBroadcaster.captionComplete.addOnce(resetCaption)
				SESignalBroadcaster.singleCaption.dispatch("noLeave");
			}
		}
		
		private function resetCaption():void
		{
			busy =false;
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import net.strangerdreams.engine.SEConfig;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.flag.FlagManager;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.scene.data.HoverType;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;
import net.strangerdreams.engine.sound.SoundObjectType;
import net.strangerdreams.engine.sound.SoundUtils;

import org.osflash.signals.natives.NativeSignal;
import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class ArtIntro extends State
{
	public static const KEY:String = "ArtIntro";
	public function ArtIntro()
	{
		
	}
}
class Items extends State
{
	public static const KEY:String = "Items";
	private var ref:SparkAndOatsLobby;
	private var keySet:InteractiveObjectSignalSet;
	private var mapSet:InteractiveObjectSignalSet;
	private var shortDelay:Timer;
	private var onShortDelay:NativeSignal;
	
	public function Items()
	{
		//comment="give flag haveKey when pick up key"	
	}
	override public function doIntro():void
	{
		ref = this.context as SparkAndOatsLobby;
		keySet = new InteractiveObjectSignalSet(ref.key);
		mapSet = new InteractiveObjectSignalSet(ref.map);
		this.signalIntroComplete();
	}
	override public function action():void
	{
	
		keySet.mouseOver.add(over);
		keySet.mouseOut.add(out);
		keySet.click.addOnce(addKey);
		//check over key
		if(ref.key.hitTestPoint(ref.mouseX,ref.mouseY))
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.GRAB);
	}
	override public function doOutro():void
	{
		keySet.removeAll();
		mapSet.removeAll();
		keySet = mapSet = null;
		ref=null;
		onShortDelay = null;
		shortDelay = null;
		this.signalOutroComplete();
	}
	private function over(e:MouseEvent):void
	{
		SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.GRAB);
	}
	
	private function out(e:MouseEvent):void
	{
		SESignalBroadcaster.interactiveRollOut.dispatch();
	}
	
	private function addKey(e:MouseEvent):void
	{
		SoundUtils.playSingleSoundObject("pickUpRoomKey",SoundObjectType.AMBIENT,1);
		keySet.removeAll();
		ItemManager.addItemInventory("roomKey",true);
		FlagManager.addFlag("haveKey");
		TweenLite.to(ref.keyGraphic, 2, { alpha: 0 });
		ref.key.visible = false;
		mapSet.mouseOver.add(over);
		mapSet.mouseOut.add(out);
		mapSet.click.addOnce(addMap);
		//check over map
		if(ref.map.hitTestPoint(ref.stage.mouseX,ref.stage.mouseY))
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.GRAB);
		else
			SESignalBroadcaster.interactiveRollOut.dispatch();
	}
	private function addMap(e:MouseEvent):void
	{
		SoundUtils.playSingleSoundObject("pickUpMap",SoundObjectType.AMBIENT,1);
		SESignalBroadcaster.interactiveRollOut.dispatch();
		mapSet.removeAll();
		SESignalBroadcaster.singleNotification.dispatch(Caption(StoryScriptManager.getCaptionInstance("mapAdded")).text);
		TweenLite.to(ref.mapGraphic, 2, { alpha: 0, onComplete:onMapFaded });
		SEConfig.hasMap = true;
	}

	private function onMapFaded():void
	{
		shortDelay = new Timer(800);
		onShortDelay = new NativeSignal(shortDelay,TimerEvent.TIMER,TimerEvent);
		onShortDelay.addOnce( function(e:TimerEvent):void
		{
			SESignalBroadcaster.updateState.dispatch();
		} );
		shortDelay.start();
		
		// if this doesn't work listen for event in main imp and do update state there
	}
}

class ArtDialogContinued extends State
{
	public static const KEY:String = "ArtDialogContinued";
	public function ArtDialogContinued()
	{
		
	}
}
class DialogFinished extends State
{
	public static const KEY:String = "DialogFinished";
	public function DialogFinished()
	{
		
	}
}