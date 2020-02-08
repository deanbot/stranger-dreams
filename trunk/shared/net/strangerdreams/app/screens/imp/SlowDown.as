package net.strangerdreams.app.screens.imp
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class SlowDown extends LocationNode implements INodeImplementor
	{
		private var frame:SlowDownScreen;
		public function SlowDown()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState(Default.KEY, new Default(),true);
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Transform;
import flash.utils.Timer;

import net.deanverleger.gui.ShapeSprite;
import net.strangerdreams.engine.SESignalBroadcaster;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	public static const STW:Number = 760;
	public static const STH:Number = 512;
	private var enterFrame:NativeSignal;
	private var ref:SlowDownScreen;
	private var sourceMC:MovieClip;
	private var BlurRect:Object;
	private var bmpData:BitmapData;
	private var bmpBuffer:BitmapData;
	private var render:MovieClip;
	private var BlurLength:Number;
	private var BlurAlpha:Number;
	private var trans:Transform;
	private var color:ColorTransform;
	private var readTimer:Timer;
	private var onReadTimer:NativeSignal;
	private var clickTimer:Timer;
	private var onClickTimer:NativeSignal;
	private var fading:Boolean;
	private var shapeSprite:ShapeSprite;
	private var screenClicked:NativeSignal;
	
	override public function doIntro():void
	{
		ref = this.context as SlowDownScreen;
		ref.tf.x=STW/2-ref.tf.width/2;
		ref.tf.y=STH/2-ref.tf.height/2;
		init();
		ref.addChild( shapeSprite = new ShapeSprite(760,512) );
		screenClicked = new NativeSignal(shapeSprite,MouseEvent.CLICK,MouseEvent);
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		readTimer = new Timer(13000);
		clickTimer = new Timer(6000);
		onReadTimer = new NativeSignal(readTimer,TimerEvent.TIMER, TimerEvent);
		onReadTimer.addOnce(onReadTimerFinished);
		onClickTimer = new NativeSignal(clickTimer,TimerEvent.TIMER,TimerEvent);
		onClickTimer.addOnce(letClickLeave);
		clickTimer.start();
		readTimer.start();
	}
	
	override public function doOutro():void
	{
		trans = null;
		color = null;
		BlurRect = null;
		bmpData = bmpBuffer = null;
		enterFrame = onReadTimer = onClickTimer = screenClicked = null;
		readTimer = clickTimer = null;
		sourceMC = render = null;
		ref = null;
		this.signalOutroComplete();
	}
	
	private function onReadTimerFinished(e:TimerEvent):void
	{
		if(!fading)
		{
			fading = true;
			enterFrame.remove(onEnterFrame);
			screenClicked.remove(onClick);
			SESignalBroadcaster.sceneEndReached.dispatch();
		}
	}
	
	private function letClickLeave(e:TimerEvent):void
	{
		screenClicked.addOnce(onClick);
	}
	
	private function onClick(e:MouseEvent):void
	{
		if(!fading)
		{
			fading = true;
			enterFrame.remove(onEnterFrame);
			onReadTimer.remove(onReadTimerFinished);
			SESignalBroadcaster.sceneEndReached.dispatch();
		}
	}
	
	private function init():void
	{
		sourceMC = ref.tf;
		
		var mcx:Number = sourceMC.x;
		var mcy:Number = sourceMC.y;
		var mcw:Number = sourceMC.width;
		var mch:Number = sourceMC.height;

		BlurRect = {
			x:-mcw/2,
			y:-mch/2,
			w:mcw*2+mcw/2,
			h:mch*2+mch/2
		};
		
		BlurLength = 1.003;
		BlurAlpha = 0.89;
		
		bmpData = new flash.display.BitmapData(BlurRect.w, BlurRect.h,
			true, 0x00FFFFFF);
		bmpBuffer = new flash.display.BitmapData(BlurRect.w, BlurRect.h,
			true, 0x00FFFFFF);
		
		render =new MovieClip();
		ref.tf.addChild(render);
		
		render.x = BlurRect.x;
		render.y = BlurRect.y;
		trans = new flash.geom.Transform(render);
		color = new flash.geom.ColorTransform(
			-1, 1, 1, BlurAlpha, 0, 0, 0, 0);
		trans.colorTransform = color;
		
		enterFrame = new NativeSignal(ref,Event.ENTER_FRAME,Event);
		enterFrame.add(onEnterFrame);
	}
	
	private function onEnterFrame(event:Event):void
	{
		//バッファから描画用ビットマップに転送
		bmpData.copyPixels(bmpBuffer, new flash.geom.Rectangle(
			0, 0, BlurRect.w, BlurRect.h), new flash.geom.Point(0, 0));
		
		// バッファにキャプチャー
		var m:Matrix = new flash.geom.Matrix(
			1 , 0, 0, 1,-BlurRect.x, -BlurRect.y);
		bmpBuffer.fillRect(new flash.geom.Rectangle(
			0, 0, BlurRect.w, BlurRect.h), 0x00FFFFFF);
		bmpBuffer.draw(sourceMC, m);
		
		
		// 描画オフセット用行列
		m = new flash.geom.Matrix(1,0,0,1,0,0);
		m.translate(-ref.mouseX,-ref.mouseY);
		m.scale(BlurLength,BlurLength);
		m.translate(ref.mouseX,ref.mouseY);
		
		// 上に重ねて描画
		render.graphics.clear();
		render.graphics.beginBitmapFill(bmpData, m, true, true);
		render.graphics.moveTo(0, 0);
		render.graphics.lineTo(0, BlurRect.h);
		render.graphics.lineTo(BlurRect.w, BlurRect.h);
		render.graphics.lineTo(BlurRect.w, 0);
		render.graphics.endFill();
	}
}