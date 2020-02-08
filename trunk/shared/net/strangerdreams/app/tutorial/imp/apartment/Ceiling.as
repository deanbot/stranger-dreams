package net.strangerdreams.app.tutorial.imp.apartment
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class Ceiling extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentCeilingFrame;
		public function Ceiling()
		{
			super();
		}
		
		private var doCaption:NativeSignal;
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
			this.sm.addState( CaptionClick.KEY, new CaptionClick() );
			
			doCaption=new NativeSignal(this.asset, "doCaption", Event);
			doCaption.addOnce( onDoCaption);
		}
		
		private function onDoCaption(e:Event):void
		{
			//trace("hey");
			doCaption = null;
			FlagManager.addFlag("doCaption");
			SESignalBroadcaster.updateState.dispatch();
		}
	}
}
import com.greensock.TweenLite;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TweenPlugin;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.BlurFilter;

import net.strangerdreams.engine.SESignalBroadcaster;

class Default extends State
{
	public static const KEY:String = "Default";
	private var ref:MovieClip;
	private var frameBlur:BlurFilter;
	private var lidBlur:BlurFilter;
	private var eyeLidTop:Shape;
	private var eyeLidBottom:Shape;
	
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		lidBlur = new BlurFilter();
		lidBlur.blurX = 2;
		lidBlur.blurY = 2;
		ref.addChild(eyeLidTop = new Shape());
		ref.addChild(eyeLidBottom = new Shape());
		eyeLidTop.graphics.beginFill( 0x000000, 1);
		eyeLidTop.graphics.drawRect(0, 0, ref.width, (ref.height*.5));
		eyeLidTop.graphics.endFill();
		eyeLidBottom.graphics.beginFill( 0x000000, 1);
		eyeLidBottom.graphics.drawRect(0, (ref.height*.5), ref.width, (ref.height*.5));
		eyeLidBottom.graphics.endFill();
		eyeLidTop.filters=[lidBlur];
		eyeLidBottom.filters=[lidBlur];
		eyeLidTop.cacheAsBitmap=true;
		eyeLidBottom.cacheAsBitmap=true;
		frameBlur = new BlurFilter();
		frameBlur.quality = 2;
		frameBlur.blurX = 20;
		frameBlur.blurY = 20;
		ref.filters = [frameBlur];
		
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		TweenLite.to(eyeLidTop, 1.5,{ y:"-266", delay:1.5,onComplete:onEyeLidsTweened});
		TweenLite.to(eyeLidBottom, 1.5,{ y:"+266", delay:1.5 });
	}
	
	private function onEyeLidsTweened():void
	{
		ref.removeChild(eyeLidTop);
		ref.removeChild(eyeLidBottom);
		TweenPlugin.activate([BlurFilterPlugin]);
		TweenLite.to(ref, 2.5, {blurFilter:{blurX:0, blurY:0},onComplete:onBlurTweened});
	}
	
	private function onBlurTweened():void
	{
		ref.dispatchEvent(new Event("doCaption"));
	}
	
	override public function doOutro():void
	{
		ref.filters=null;
		frameBlur=lidBlur=null;
		eyeLidTop = eyeLidBottom = null;
		ref = null;
		this.signalOutroComplete();
	}
}

class CaptionClick extends State
{
	public static const KEY:String = "CaptionClick";
	public function CaptionClick()
	{
		
	}
	
	override public function doIntro():void
	{
		this.signalIntroComplete();
	}
	
	override public function action():void 
	{
		SESignalBroadcaster.captionComplete.addOnce(fadeOut);
	}
	
	private function fadeOut():void
	{
		SESignalBroadcaster.changeNode.dispatch(2);
	}
	
}