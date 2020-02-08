package net.strangerdreams.app.gui
{
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.deanverleger.graphics.shapes.SolidFadingBG;
	import net.deanverleger.gui.ShapeSprite;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.location.LocationNodeManager;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class ViewPort extends Sprite
	{
		// constants:
		public static const LOCATION:String = "ViewPort";
		// private properties:
		private var activeFrame:MovieClip;
		private var _ui:UI;
		private var blackMatte:SolidFadingBG;
		private var _blackMatteBgAction:Signal;
		private var _stateAction:Signal;
		private var _frameRemoved:Signal;
		private var _fadeAction:Signal;
		private var sm:StateManager;
		private var activeFrameRemoved:NativeSignal;
		private var _dev:Boolean;
		private var _destroyed:Boolean;
		private var _unloaded:Boolean;
		
		// public properties:
		// constructor:
		public function ViewPort(dev:Boolean=false)
		{
			_dev=dev;
			_destroyed = _unloaded = false;
			init();
			var mouseclick:NativeSignal;
			mouseclick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
			mouseclick.add( function (e:MouseEvent):void
			{
				trace(e.currentTarget);
			} );
		}
		
		// public getter/setters:
		public function get blackMatteBgAction():Signal
		{
			return _blackMatteBgAction;
		}
		
		public function get frameRemoved():Signal 
		{
			return _frameRemoved;
		}
		
		public function get stateAction():Signal
		{
			return _stateAction;
		}
		
		public function get fadeAction():Signal
		{
			return _fadeAction;
		}
		
		
		// public methods:
		/**
		 * Create display objects and states/state managager 
		 * 
		 */
		public function load():void
		{
			addChild( blackMatte = new SolidFadingBG( 760, 512, 1, 0x000000, SEConfig.transitionTime) );
			blackMatte.bgAction.add( this.blackMatteBgAction.dispatch );
			blackMatte.alpha = 1;
			
			_stateAction.add( onStateAction );
			
			sm = new StateManager( this );
			sm.addState( TransitionFadeToBlack.KEY, new TransitionFadeToBlack(), true );
			sm.addState( FrameInvisibleNoTransition.KEY, new FrameInvisibleNoTransition() );
			sm.addState( FrameVisible.KEY, new FrameVisible() );
			sm.addState( FrameVisibleNoTransition.KEY, new FrameInvisibleNoTransition() );
		}
		
		public function unload():void
		{
			if(_unloaded)
				return;
			sm.destroy();
			sm = null;
			_stateAction.removeAll();
			_stateAction = null;
			blackMatte.destroy();
			removeChild( blackMatte );
			if(shapeSprite !=null)
			{
				if(contains(shapeSprite))
				{
					removeChild(shapeSprite);
				}
				shapeSprite = null;
			}
			_unloaded = true;
		}
		
		public function destroy():void
		{
			if(_destroyed)
				return;
			unload();
			if(_blackMatteBgAction!=null)
				_blackMatteBgAction.removeAll();
			if(_frameRemoved!=null)
				_frameRemoved.removeAll();
			if(_fadeAction!=null)
				_fadeAction.removeAll();
			SESignalBroadcaster.blockToggle.remove(onBlockToggle);
			_blackMatteBgAction = _frameRemoved = _stateAction = _fadeAction = null;
			_destroyed = true;
		}
		
		/**
		 *  Call to add a MovieClip to the display list within the viewport
		 * 
		 * @param frame MovieClip - frame to add to viewport
		 * 
		 */
		public function setActiveFrame( frame:MovieClip ):void
		{
			//LoggingUtils.msgTrace("",LOCATION+".setActiveFrame()");
			if(_dev)
				frame.scaleX = frame.scaleY = 1.25;
			if ( frame != null ) {
				addChildAt( activeFrame = frame, 0 );
				removeMouseControls();
			}
		}
		
		/**
		 * Call to remove and null active frame 
		 * 
		 */
		public function unsetFrame():void
		{
			if ( activeFrame != null ) {
				//LoggingUtils.msgTrace("unsetting Frame",LOCATION);
				activeFrameRemoved = new NativeSignal ( activeFrame, Event.REMOVED_FROM_STAGE, Event );
				activeFrameRemoved.addOnce( onActiveFrameRemoved );
				removeChildAt( 0 );
			}
		}
		
		public function setUI( ui:UI ):void
		{
			if ( ui != null) {
				addChildAt( _ui = ui, 0 );
			}
		}
		
		public function unsetUI():void
		{
			if (_ui != null) {
				this.removeChild(_ui);
				this._ui = null;
			}
		}
		
		/** Transitions **/	
		
		public function fadeOut(duration:Number = 0):void 
		{
			fadeTime = duration;
			sm.setState( TransitionFadeToBlack.KEY );
		}
		
		public function skipFadeOut():void
		{
			sm.setState( FrameInvisibleNoTransition.KEY );
		}
		
		public function fadeIn():void 
		{
			sm.setState( FrameVisible.KEY );
		}
		
		public function skipFadeIn():void
		{
			sm.setState( FrameVisibleNoTransition.KEY );
		}
		
		// private methods:
		/**
		 * Initialize public signls 
		 */
		private function init():void
		{
			_blackMatteBgAction = new Signal();
			_frameRemoved = new Signal();
			_stateAction = new Signal( String );
			_fadeAction = new Signal( Boolean );
			SESignalBroadcaster.blockToggle.add(onBlockToggle);
		}
		
		private function onActiveFrameRemoved( e:Event ):void
		{
			activeFrameRemoved = null;
			activeFrame = null;
			_frameRemoved.dispatch();
		}
		
		private var fadeTime:Number = 0;
		private function onStateAction( key:String ):void
		{
			switch (key) 
			{
				case TransitionFadeToBlack.KEY:
					removeMouseControls();
					blackMatte.bgAction.addOnce( onFadeOut );
					if(fadeTime != 0)
						blackMatte.showCustom(fadeTime);
					else
						blackMatte.show();
					fadeTime = 0;
					break;
				case FrameVisible.KEY:
					blackMatte.bgAction.addOnce( onFadeIn );
					if(fadeTime != 0)
						blackMatte.hideCustom(fadeTime);
					else
						blackMatte.hide();
					fadeTime = 0;
					break;
				case FrameInvisibleNoTransition.KEY:
					onFadeOut();
					break;
				case FrameVisibleNoTransition.KEY:
					onFadeIn();
					break;
			}
		}
		
		private function onFadeOut():void
		{
			activeFrame.stop();
			_fadeAction.dispatch( false );
		}
		
		private function onFadeIn():void
		{
			addMouseControls();
			_fadeAction.dispatch( true );
		}
		
		private function addMouseControls():void
		{
			if (activeFrame != null)
				this.activeFrame.mouseChildren = this.activeFrame.mouseEnabled = true;
			if (_ui != null)
				this._ui.mouseChildren = this._ui.mouseEnabled = true;
		}
		
		private function removeMouseControls():void
		{
			if (activeFrame != null)
				activeFrame.mouseEnabled = activeFrame.mouseChildren = false;
			if (_ui != null)
				_ui.mouseEnabled = _ui.mouseChildren = false;
		}
		
		private var shapeSprite:ShapeSprite;
		private function onBlockToggle(on:Boolean):void
		{

		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import flash.events.TimerEvent;
import flash.utils.Timer;

import net.strangerdreams.app.gui.ViewPort;

import org.osflash.signals.natives.NativeSignal;


class TransitionFadeToBlack extends State {
	public static const KEY:String = "TransitionFadeToBlack";
	private var viewRef:ViewPort;
	private var transitionDelay:Number = 1000;
	private var timer:Timer;
	private var timerFinished:NativeSignal;
	
	public function TransitionFadeToBlack()
	{
		
	}
	
	override public function doIntro():void
	{
		viewRef = ViewPort(this.context);
		viewRef.blackMatteBgAction.addOnce( startTimer );
		viewRef.stateAction.dispatch( KEY );
	}
	
	private function startTimer():void
	{
		timer = new Timer( transitionDelay );
		timerFinished = new NativeSignal( timer, TimerEvent.TIMER, TimerEvent );
		timerFinished.addOnce( onTimerFinished );
		timer.start();
	}
	
	private function onTimerFinished( e:TimerEvent ):void
	{
		this.signalIntroComplete();
	}		
}

class FrameInvisibleNoTransition extends State {
	public static const KEY:String ="FrameInvisibleNoTransition";
	private var viewRef:ViewPort;
	
	public function FrameInvisibleNoTransition()
	{
		
	}
	
	override public function doIntro():void
	{
		viewRef = ViewPort(this.context);
		viewRef.stateAction.dispatch( KEY );
		this.signalIntroComplete();
	}
}

class FrameVisible extends State {
	public static const KEY:String = "FrameVisible";
	private var viewRef:ViewPort;
	
	public function FrameVisible()
	{
		
	}
	
	override public function doIntro():void
	{
		viewRef = ViewPort(this.context);
		viewRef.blackMatteBgAction.addOnce( this.signalIntroComplete );
		viewRef.stateAction.dispatch( KEY );
	}
}

class FrameVisibleNoTransition extends State {
	public static const KEY:String ="FrameVisibleNoTransition";
	private var viewRef:ViewPort;
	
	public function FrameVisibleNoTransition()
	{
		
	}
	
	override public function doIntro():void
	{
		viewRef = ViewPort(this.context);
		viewRef.stateAction.dispatch( KEY );
		this.signalIntroComplete();
	}
}