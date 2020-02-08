package net.deanverleger.graphics.shapes
{
	import com.greensock.TweenLite;
	
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.deanverleger.utils.LoggingUtils;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class SolidFadingBG extends Shape implements IFader
	{
		private var _bgAction:Signal;
		private var _maxAlpha:Number;
		private var _transitionTime:Number;
		private var _timer:Timer;
		private var _timerComplete:NativeSignal;
		private static const TIMER_TIME:Number = 300;
		
		public function SolidFadingBG( width:Number, height:Number, maxAlpha:Number = 1, color:uint = 0x000000, transitionTime:Number = .3 )
		{
			super();
			_maxAlpha = maxAlpha;
			_transitionTime = transitionTime;
			this.graphics.beginFill( color, maxAlpha);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			this.alpha = 0;
			_bgAction = new Signal();
			_timer = new Timer(TIMER_TIME);
			_timerComplete=new NativeSignal(_timer,TimerEvent.TIMER,TimerEvent);
		}
		
		public function show():void 
		{
			this.makeVisible();
			if(alpha == _maxAlpha)
			{
				_timerComplete.addOnce( function(e:TimerEvent):void { _timer.stop(); _timer.reset(); _bgAction.dispatch(); } );
				_timer.start();
			} else
				TweenLite.to(this, _transitionTime, { alpha:_maxAlpha, onComplete:this._bgAction.dispatch });
		}
		
		public function showCustom(duration:Number = -1):void 
		{
			this.makeVisible();
			if(alpha == _maxAlpha)
			{
				_timerComplete.addOnce( function(e:TimerEvent):void { _timer.stop(); _timer.reset(); _bgAction.dispatch(); } );
				_timer.start();
			} else
				TweenLite.to(this, ( (duration < 0) ? _transitionTime : duration), { alpha:_maxAlpha, onComplete:this._bgAction.dispatch });
		}
		
		private function makeVisible():void
		{
			this.visible = true;
		}
		
		public function hide():void 
		{
			if(alpha == 0)
			{
				_timerComplete.addOnce( function(e:TimerEvent):void { _timer.stop(); _timer.reset(); this.hideFinished(); } );
				_timer.start();
			} else
				TweenLite.to(this, _transitionTime, { alpha:0, onComplete:this.hideFinished });
		}
		
		public function hideCustom(duration:Number = -1):void 
		{
			if(alpha == 0)
			{
				_timerComplete.addOnce( function(e:TimerEvent):void { _timer.stop(); _timer.reset(); this.hideFinished(); } );
				_timer.start();
			} else
				TweenLite.to(this, ( (duration < 0) ? _transitionTime : duration), { alpha:0, onComplete:this.hideFinished });
		}
		
		private function hideFinished():void
		{
			this.visible = false;
			if(_bgAction !=null)
				this._bgAction.dispatch();
		}
		
		public function get bgAction():Signal { return _bgAction; }
		
		public function destroy():void
		{
			_timerComplete.removeAll();
			_timerComplete = null;
			_timer = null;
			_bgAction.removeAll();
			_bgAction = null;
		}
	}
}