package net.strangerdreams.app.scenes.imp.scene3
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class LovesCounterImp extends LocationNode implements INodeImplementor
	{
		private var frame:LovesCounter;
		public function LovesCounterImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( JeanniePie.KEY, new JeanniePie(), (JeanniePie.KEY == defaultState)?true:false );
			this.sm.addState( AtleeIntro.KEY, new AtleeIntro(), (AtleeIntro.KEY == defaultState)?true:false );
			this.sm.addState( AtleeNotReady.KEY, new AtleeNotReady(), (AtleeNotReady.KEY == defaultState)?true:false );
			this.sm.addState( FadeAtlee.KEY, new FadeAtlee(), (FadeAtlee.KEY == defaultState)?true:false );
			this.sm.addState( Counter.KEY, new Counter(), (Counter.KEY == defaultState)?true:false );
			this.sm.addState( EndScene.KEY, new EndScene(), (EndScene.KEY == defaultState)?true:false );
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.TimerEvent;
import flash.utils.Timer;

import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.flag.FlagManager;
import net.strangerdreams.engine.location.LocationNodeManager;
import net.strangerdreams.engine.sound.SoundUtils;

import org.osflash.signals.natives.NativeSignal;

class JeanniePie extends State
{
	public static const KEY:String = "JeanniePie";
	public function JeanniePie()
	{
	
	}

}
class AtleeIntro extends State
{
	public static const KEY:String = "AtleeIntro";
	private var timer:Timer;
	private var onTimer:NativeSignal;
	
	public function AtleeIntro()
	{
	
	}
	override public function doIntro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(true);
		timer = new Timer(1400);
		onTimer = new NativeSignal(timer,TimerEvent.TIMER,TimerEvent);
		onTimer.addOnce(next);
		timer.start();
		SESignalBroadcaster.itemUsed.addOnce( onItemUsed );
	}
	
	private function next(e:TimerEvent):void
	{
		onTimer = null;
		timer = null;
		SESignalBroadcaster.blockToggle.dispatch(false);
		this.signalIntroComplete();
	}
	
	private function onItemUsed( itemKey:String ):void
	{
		timer = new Timer(200);
		onTimer = new NativeSignal(timer,TimerEvent.TIMER, TimerEvent);
		onTimer.addOnce(update);
		timer.start();
	}
	private function update(e:TimerEvent):void
	{
		onTimer = null;
		timer = null;
		FlagManager.addFlag("gaveAtleePhoto");
		LocationNodeManager.getLocationNode(StoryEngine.currentNode).updateState();
	}
}
class AtleeNotReady extends State
{
	public static const KEY:String = "AtleeNotReady";
	public function AtleeNotReady()
	{
	
	}
}
class FadeAtlee extends State
{
	public static const KEY:String = "FadeAtlee";
	public function FadeAtlee()
	{
	
	}
	
	override public function doIntro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(true);
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(false);
		this.signalOutroComplete();
	}
}
class Counter extends State
{
	public static const KEY:String = "Counter";
	private var timer:Timer;
	private var onTimer:NativeSignal;
	
	public function Counter()
	{
	
	}
	
	override public function doIntro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(true);
		timer = new Timer(1000);
		onTimer = new NativeSignal(timer,TimerEvent.TIMER,TimerEvent);
		onTimer.addOnce(next);
		timer.start();
		
	}
	
	override public function doOutro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(false);
		this.signalOutroComplete();
	}
	
	private function next(e:TimerEvent):void
	{
		onTimer = null;
		timer = null;
		this.signalIntroComplete();
	}
}
class EndScene extends State
{
	public static const KEY:String = "EndScene";
	private var ref:MovieClip;
	public function EndScene()
	{
	
	}
	
	override public function doIntro():void
	{
		ref = this.context as MovieClip;
		TweenLite.to(ref,5,{alpha: 0,onComplete: signalIntroComplete });
		SoundUtils.fadeAmbientChannels(0, 5, true);
		SoundUtils.fadeMusicChannels(0, 5, true);
	}
	
	override public function action():void
	{
		ref = null;
		SESignalBroadcaster.sceneEndReached.dispatch();
	}
}