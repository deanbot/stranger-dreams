package net.strangerdreams.app.scenes.imp.scene4
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class YourRoomImp extends LocationNode implements INodeImplementor
	{
		private var frame:SparkAndOatsRoom;
		private var removeFromStage:NativeSignal;
		private var busy:Boolean;
		
		public function YourRoomImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Ringing.KEY, new Ringing(), (Ringing.KEY==defaultState)?true:false );
			this.sm.addState( Phone.KEY, new Phone(), (Phone.KEY==defaultState)?true:false );
			
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
			
			if(dir == "S")
			{
				busy = true;
				SESignalBroadcaster.captionComplete.addOnce(resetCaption)
				SESignalBroadcaster.singleCaption.dispatch("answerPhone");
			}
		}
		
		private function resetCaption():void
		{
			busy = false;
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import net.strangerdreams.app.SEBetaBroadcaster;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.flag.FlagManager;

import org.osflash.signals.natives.NativeSignal;

class Ringing extends State
{
	public static const KEY:String = "Ringing";
	private var ref:SparkAndOatsRoom;
	private var phoneClicked:NativeSignal;
	public function Ringing()
	{
		
	}
	
	override public function doIntro():void
	{
		ref = this.context as SparkAndOatsRoom;
		phoneClicked = new NativeSignal(Sprite(ref.phone),MouseEvent.CLICK,MouseEvent);
		phoneClicked.addOnce(onPhoneClicked);
		this.signalIntroComplete();
	}
	
	private function onPhoneClicked(e:MouseEvent):void
	{
		SESignalBroadcaster.interactiveRollOut.dispatch();
		phoneClicked = null;
		ref = null;
		FlagManager.addFlag("answerPhone");
		SESignalBroadcaster.updateState.dispatch();
	}
}

class Phone extends State
{
	public static const KEY:String = "Phone";
	private var timer:Timer;
	private var onTimer:NativeSignal;
	public function Phone()
	{
		
	}
	
	override public function doIntro():void
	{
		timer = new Timer(2000);
		onTimer = new NativeSignal(timer,TimerEvent.TIMER,TimerEvent);
		onTimer.addOnce(onTimerFinished);
		timer.start();
		SESignalBroadcaster.blockToggle.dispatch(true);
	}
	
	private function onTimerFinished(e:TimerEvent):void
	{
		onTimer = null;
		timer = null;
		SEBetaBroadcaster.betaEndReached.dispatch();
		this.signalIntroComplete();
	}
}