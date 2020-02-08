package net.strangerdreams.app.screens.imp
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class EndTutorial extends LocationNode implements INodeImplementor
	{
		private var frame:EndTutorialScreen;
		public function EndTutorial()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import net.strangerdreams.app.gui.Block;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private static const EXIT_TIMER_TIME:Number = 18000;
	private var ref:EndTutorialScreen;
	private var screenClicked:NativeSignal;
	private var block:Block;
	private var sprite:Sprite;
	private var skippedExitTimer:Boolean;
	private var exitTimer:Timer;
	private var exitTimerComplete:NativeSignal;
	
	override public function doIntro():void
	{
		ref = this.context as EndTutorialScreen;
		ref.tf.text = Caption(StoryScriptManager.getCaptionInstance("frameText")).text;
		ref.tf.alpha = ref.alpha = 0;
		sprite = new Sprite();
		sprite.addChild(block = new Block());
		ref.addChild(sprite);
		screenClicked = new NativeSignal(sprite, MouseEvent.CLICK, MouseEvent);
		TweenLite.to(ref,2, { alpha:1,onComplete:showTF});
		
	}
	
	private function showTF():void
	{
		TweenLite.to(ref.tf,3, { alpha: 1, delay:2, onComplete: signalIntroComplete() });
	}
	
	override public function action():void
	{
		block.visible = true;
		exitTimer = new Timer(EXIT_TIMER_TIME);
		exitTimerComplete = new NativeSignal(exitTimer, TimerEvent.TIMER, TimerEvent);
		exitTimerComplete.addOnce(onExitTimerComplete);
		exitTimer.start();
		screenClicked.addOnce(onSceenClicked);
	}
	
	private function onExitTimerComplete(e:TimerEvent):void
	{
		if(skippedExitTimer)
			return;
		onSceenClicked(new MouseEvent(MouseEvent.CLICK));
	}
	
	private function onSceenClicked(e:MouseEvent):void
	{
		screenClicked.remove(onSceenClicked);
		skippedExitTimer = true;
		TweenLite.to(ref,1.5,{ alpha: 0, onComplete: function(): void { 
			exitTimerComplete.remove(onExitTimerComplete);
			exitTimerComplete = null;
			exitTimer = null;
			sprite.removeChild(block);
			ref.removeChild(sprite);
			block = null;
			sprite = null;	 
			ref=null;
			SESignalBroadcaster.sceneEndReached.dispatch(); 
		} });
	}
}