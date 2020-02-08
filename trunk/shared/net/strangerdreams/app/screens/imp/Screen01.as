package net.strangerdreams.app.screens.imp
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class Screen01 extends LocationNode implements INodeImplementor
	{
		private var frame:Chapter1Screen;
		public function Screen01()
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
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TweenPlugin;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BlurFilter;
import flash.utils.Timer;

import net.deanverleger.utils.ClipUtils;
import net.deanverleger.utils.LoggingUtils;
import net.strangerdreams.app.gui.Block;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private static const EXIT_TIMER_TIME:Number = 10000;
	
	private var ref:Chapter1Screen;
	private var wordBlur:BlurFilter;
	private var wordBlur2:BlurFilter;
	private var wordBlur3:BlurFilter;
	private var screenClicked:NativeSignal;
	private var exitTimer:Timer;
	private var exitTimerComplete:NativeSignal;
	private var exit:Boolean;
	private var skippedExitTimer:Boolean;
	private var title:Boolean;
	private var titlePre:Boolean;
	private var quote:Boolean;
	private var quotePre:Boolean;
	private var block:Block;
	private var sprite:Sprite;
	
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		ref=this.context as Chapter1Screen;
		//ref.mouseChildren = false;
		
		ref.title.tf.text = Caption(StoryScriptManager.getCaptionInstance("title")).text;
		ref.quote1.quote.text = Caption(StoryScriptManager.getCaptionInstance("q1text")).text;
		ref.quote1.author.text = Caption(StoryScriptManager.getCaptionInstance("q1auth")).text;
		ref.quote2.quote.text = Caption(StoryScriptManager.getCaptionInstance("q2text")).text;
		ref.quote2.author.text = Caption(StoryScriptManager.getCaptionInstance("q2auth")).text;
		
		wordBlur = new BlurFilter();
		wordBlur.blurX = 2;
		wordBlur.blurY = 2;
		wordBlur2 = new BlurFilter();
		wordBlur2.blurX = 2;
		wordBlur2.blurY = 2;
		wordBlur3 = new BlurFilter();
		wordBlur3.blurX = 2;
		wordBlur3.blurY = 2;
		ref.title.filters = [wordBlur];
		ref.quote1.filters = [wordBlur2];
		ref.quote2.filters = [wordBlur3];
		
		ref.title.cacheAsBitmap = ref.quote1.cacheAsBitmap = ref.quote2.cacheAsBitmap = true;
		
		ClipUtils.makeInvisible(ref.quote1,ref.quote2);
		ClipUtils.hide(ref.title);
		
		sprite = new Sprite();
		sprite.addChild(block = new Block());
		ref.addChild(sprite);
		block.visible = true;
		
		exitTimer = new Timer(EXIT_TIMER_TIME);
		exitTimerComplete = new NativeSignal(exitTimer, TimerEvent.TIMER, TimerEvent);
		
		screenClicked = new NativeSignal(sprite, MouseEvent.CLICK, MouseEvent);
		
		TweenPlugin.activate([BlurFilterPlugin]);
		
		titlePre = true;
		TweenLite.to(ref.title, 3, { alpha: 1, delay: 1, blurFilter:{blurX:0, blurY:0}, onStart:onTitleTweenStart, onComplete:onTitleTweenComplete });
		screenClicked.addOnce(onSceenClicked);
		
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		exitTimerComplete.remove(onExitTimerComplete);
		exitTimerComplete = null;
		exitTimer = null;
		sprite.removeChild(block);
		ref.removeChild(sprite);
		block = null;
		sprite = null;
		TweenLite.to(ref,1.5,{ alpha: 0, onComplete: function(): void { ref = null; signalOutroComplete(); } });
	}
	
	private function onTitleTweenStart():void
	{
		titlePre = false;
		title = true;
		screenClicked.addOnce(onSceenClicked);
	}
	
	private function onTitleTweenComplete():void
	{
		title = false;
		quotePre = true;
		ClipUtils.hide(ref.quote1, ref.quote2);
		TweenLite.to(ref.quote1, 4, { alpha: .8, delay: .5, blurFilter:{blurX:0, blurY:0} });
		TweenLite.to(ref.quote2, 4.2, { alpha: .8, delay: .5, blurFilter:{blurX:0, blurY:0}, onStart:onQuoteTweenStart, onComplete:onQuoteTweenComplete });
		screenClicked.addOnce(onSceenClicked);
	}
	private function onQuoteTweenStart():void
	{
		quotePre = false;
		quote = true;
		screenClicked.addOnce(onSceenClicked);
	}
	private function onQuoteTweenComplete():void
	{
		ref.title.filters = [];
		ref.quote1.filters = [];
		ref.quote2.filters = [];
		wordBlur = wordBlur2 = wordBlur3 = null;
		exitTimerComplete.addOnce(onExitTimerComplete);
		quote = false;
		exit = true;
		//ref.cacheAsBitmap = true;
		screenClicked.addOnce(onSceenClicked);
		exitTimer.start();
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
		if(titlePre){
			TweenLite.killDelayedCallsTo(title);
			TweenLite.to(ref.title, 3, { alpha: 1, blurFilter:{blurX:0, blurY:0}, onStart:onTitleTweenStart, onComplete:onTitleTweenComplete });
		} else if (title)
		{
			TweenLite.killTweensOf(ref.title,true);
		} else if (quotePre)
		{
			TweenLite.killDelayedCallsTo(ref.quote1);
			TweenLite.killDelayedCallsTo(ref.quote2);
			TweenLite.to(ref.quote1, 2, { alpha: 1, blurFilter:{blurX:0, blurY:0} });
			TweenLite.to(ref.quote2, 2.2, { alpha: 1, blurFilter:{blurX:0, blurY:0}, onStart:onQuoteTweenStart, onComplete:onQuoteTweenComplete });
		} else if (quote)
		{
			TweenLite.killTweensOf(ref.quote1,true);
			TweenLite.killTweensOf(ref.quote2,true);
		} else if (exit)
		{
			skippedExitTimer = true;
			SESignalBroadcaster.sceneEndReached.dispatch();
		}
	}
}