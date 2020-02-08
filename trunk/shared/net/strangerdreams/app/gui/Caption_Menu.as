package net.strangerdreams.app.gui
{
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import net.deanverleger.utils.TweenUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Caption;
	import net.strangerdreams.engine.script.data.ScriptScreen;
	import net.strangerdreams.engine.script.data.ScriptVersion;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osmf.utils.Version;
	
	public class Caption_Menu extends Sprite implements IUIMenu
	{
		private var _working:Boolean;
		private var _freshOpen:Boolean;
		private var _container:Sprite;
		private var _sm:StateManager;
		private var _open:Signal;
		private var _exit:Signal;
		private var _stateLoaded:Signal;
		private var _transitionAction:Signal;
		private var _captionFinished:Signal;
		private var _currentCaption:Caption;
		private var _order:uint;
		private var _vOrder:uint;
		private var _sOrder:uint;
		private var _currentVersionPriority:uint;
		
		public function Caption_Menu()
		{
			super();
			init();
		}

		public function get captionFinished():Signal
		{
			return _captionFinished;
		}

		public function get open():Signal
		{
			return _open;
		}
		
		public function get exit():Signal
		{
			return _exit;
		}
		
		public function get stateLoaded():Signal
		{
			return _stateLoaded;
		}
		
		public function get working():Boolean
		{
			return _working;
		}
		
		public function get transitionAction():Signal
		{
			return _transitionAction;
		}
		
		public function get container():Sprite { 
			return _container; 
		}
		
		public function openMenu( startState:String = "ignore this" ):void
		{
			addChild( _container = new Sprite() );
			
			_container.alpha = 0;
			
			_working = true;
			_freshOpen = true;
			_order=_vOrder=_sOrder=_currentVersionPriority=1;
			
			_stateLoaded.add( onStateLoaded );
			_sm = new StateManager( this );
			_sm.addState( DefaultState.KEY, new DefaultState(), true);
			_sm.addState( OutState.KEY, new OutState());
		}
		
		public function exitMenu():void
		{
			if(_sm == null)
				return;
			_sm.setState( OutState.KEY );
			SESignalBroadcaster.interactiveRollOut.dispatch();
		}
		
		public function setCaption(captionKey:String):void
		{
			if(!StoryScriptManager.isValidCaption(captionKey))
				throw new Error("Caption Menu [setCaption("+captionKey+")] not a valid caption");
			_currentCaption=StoryScriptManager.getCaptionInstance(captionKey);
		}
		
		public function update():void
		{
			
		}
		
		public function bitmapTweenContainerOut():void
		{
			TweenUtils.bitmapAlphaTween( this._container, this, 1, 0, SEConfig.transitionTime, _transitionAction.dispatch );
		}
		
		public function getCurrentText():String
		{
			var caption:String;
			var screen:ScriptScreen;
			if(_currentCaption.hasText)
			{
				caption=_currentCaption.text;
			} else if(_currentCaption.hasScreens)
			{
				if(_currentCaption.alternateBetweenScreens)
				{
					screen = ScriptScreen(_currentCaption.screens[_currentCaption.currentScreen]);
					if(screen.hasScreens)	
						caption = ScriptScreen(screen.screens[_sOrder]).text;
					else
						caption = screen.text;
				} else
				{
					screen = ScriptScreen(_currentCaption.screens[_order]);
					if(screen.hasScreens)
						caption = ScriptScreen(screen.screens[_sOrder]).text;
					else
						caption= screen.text;
				}
			} else if(_currentCaption.hasVersions)
			{
				var version:ScriptVersion;
				var flagRequirementNotMet:Boolean=false;
				var priority:uint;
				while(priority<_currentCaption.numVersions&&caption==null)
				{
					flagRequirementNotMet=false;
					version=ScriptVersion(_currentCaption.versions[++priority]);
					if(version.hasFlagRequirement)
						if(!FlagManager.getHasFlag(version.flagRequirement))
							flagRequirementNotMet=true;
					
					if(!flagRequirementNotMet)
					{
						if(version.hasText)
						{
							caption=version.text;
						} 
						else if(version.hasScreens)
						{
							if(version.alternateBetweenScreens)
							{
								screen = ScriptScreen(version.screens[version.currentScreen]);
								
								if(screen.hasScreens)
									caption=ScriptScreen(screen.screens[_sOrder]).text;
								else
									caption=screen.text;
							} else 
							{
								screen = ScriptScreen(version.screens[_vOrder]);
								if(screen.hasScreens)
									caption = ScriptScreen(screen.screens[_sOrder]).text;
								else
									caption=screen.text;
							}
						} else
							throw new Error("Caption Menu (getCurrentText): couldn't find text (middle).");
					}
				}
				
				if(caption==null)
					throw new Error("Caption Menu (getCurrentText): couldn't find text (end).");
				else
					_currentVersionPriority=priority;
			} else
				throw new Error("Caption Menu (getCurrentText): couldn't find text (beginning).");
			
			return caption;
		}
		
		public function hasNextText():Boolean
		{
			var hasNext:Boolean = false;
			var screen:ScriptScreen;
			if(_currentCaption.hasText)
			{
				//false
			}else if(_currentCaption.hasScreens)
			{
				if(_currentCaption.alternateBetweenScreens)
				{
					screen = ScriptScreen(_currentCaption.screens[_currentCaption.currentScreen]);
					if(screen.hasScreens)
						if(_sOrder<screen.numScreens)
							hasNext=true;
				}
				else 
				{
					screen = ScriptScreen(_currentCaption.screens[_order]);
					if(screen.hasScreens)
					{
						if(_sOrder<screen.numScreens)
							hasNext=true;
						else if(_order<_currentCaption.numScreens)
							hasNext=true;
					} else if(_order<_currentCaption.numScreens)
						hasNext=true;
				}					
			} else if(_currentCaption.hasVersions)
			{
				var version:ScriptVersion=ScriptVersion(_currentCaption.versions[_currentVersionPriority]);
				if(version.hasText)
				{
					hasNext=false;
				} else if(version.hasScreens)
				{
					if(version.alternateBetweenScreens)
					{
						screen = ScriptScreen(version.screens[version.currentScreen]);
						if(screen.hasScreens)
							if(_sOrder<screen.numScreens)
								hasNext=true;
					} else 
					{
						screen = ScriptScreen(version.screens[_vOrder]);
						if(screen.hasScreens)
						{
							if(_sOrder<screen.numScreens)
								hasNext=true;
							else if(_vOrder<version.numScreens)
								hasNext=true
						} else if(_vOrder<version.numScreens)
							hasNext=true;	
					}
				} else
					throw new Error("Caption Menu (hasNextText): couldn't find if has next text (end).");
			} else
				throw new Error("Caption Menu (hasNextText): couldn't find if has next text (beginning).");
			return hasNext;
		}
		
		public function nextText():void
		{
			var screen:ScriptScreen;
			if(_currentCaption.hasScreens)
			{
				if(_currentCaption.alternateBetweenScreens)
				{
					screen = ScriptScreen(_currentCaption.screens[_currentCaption.currentScreen]);
					if(screen.hasScreens)
						_sOrder++;
				}
				else
				{
					screen = ScriptScreen(_currentCaption.screens[_order]);
					if(screen.hasScreens)
						if(_sOrder<screen.numScreens)
							_sOrder++;
						else
							_order++;
					else 
						_order++;
				}
			}
			else if(_currentCaption.hasVersions)
			{
				var version:ScriptVersion=ScriptVersion(_currentCaption.versions[_currentVersionPriority]);
				if(version.alternateBetweenScreens)
				{
					screen = ScriptScreen(version.screens[version.currentScreen]);
					if(screen.hasScreens)
						_sOrder++;
				} else
				{
					screen = ScriptScreen(version.screens[_vOrder]);
					if(screen.hasScreens)
						if(_sOrder<screen.numScreens)
							_sOrder++;
						else
							_vOrder++;
					else 
						_vOrder++;
				}
			}
		}
		
		public function alternate():void
		{
			var version:ScriptVersion;
			if(_currentCaption.hasScreens) 
			{
				if(_currentCaption.alternateBetweenScreens) 
					_currentCaption.nextScreen();
			} else if(_currentCaption.hasVersions)
			{
				if(_currentCaption.hasVersions)
				{
					version = ScriptVersion(_currentCaption.versions[_currentVersionPriority]);
					if(version.alternateBetweenScreens)
						version.nextScreen();
				}
			}
		}
		
		private function init():void
		{
			_open = new Signal();
			_exit = new Signal();
			_stateLoaded = new Signal( String );
			_transitionAction = new Signal();
			_captionFinished = new Signal();
		}
		
		private function onStateLoaded( stateKey:String ):void
		{
			if(stateKey!=OutState.KEY)
			{
				if (_freshOpen)
					_transitionAction.addOnce(onFreshOpen);
				
				this._transitionAction.addOnce( function():void { _working = false; } );
				TweenUtils.bitmapAlphaTween( this._container, this, 0, 1, SEConfig.transitionTime, function():void { _transitionAction.dispatch();} );	
			}else
			{
				this.unload();
				this.exit.dispatch();
			}
		}
		
		private function unload():void
		{
			stateLoaded.remove( onStateLoaded );
			
			_sm.destroy();
			_sm = null;
			
			DisplayObjectUtil.removeAllChildren( _container, false, true );
			removeChild( _container );
		}
		
		private function onFreshOpen():void
		{
			//trace( "Caption Menu says, \"There I've opened.\"" );
			open.dispatch();
			_freshOpen = false;
		}
	}
}
import com.greensock.TweenLite;
import com.greensock.easing.Quad;
import com.greensock.easing.Sine;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Sprite;
import flash.events.MouseEvent;

import net.strangerdreams.app.gui.Caption_Menu;
import net.strangerdreams.app.gui.MouseIconHandler;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.scene.data.HoverType;

import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class DefaultState extends State {
	
	public static const KEY:String = "defaultState";
	private var captionRef:Caption_Menu;
	private var container:Sprite;
	private var captionWindow:Sprite;
	private var nextArrowSet:InteractiveObjectSignalSet;
	private var mouseOverArrow:Boolean;
	private var tweeningArrowUp:Boolean;
	private var arrowStopped:Boolean;
	
	public function DefaultState()
	{
		super();
		
	}
	
	override public function doIntro():void
	{
		captionRef = Caption_Menu(this.context);
		container = captionRef.container;
		
		container.addChild(captionWindow=new UI_Caption_Menu());
		
		//update text
		UI_Caption_Menu(captionWindow).text.text = captionRef.getCurrentText();
		UI_Caption_Menu(captionWindow).text.selectable = false;
		
		// add controls
		nextArrowSet = new InteractiveObjectSignalSet(UI_Caption_Menu(captionWindow).arrowHit);
		nextArrowSet.click.add(onNextClicked);
		nextArrowSet.mouseOver.add( onArrowOver );
		nextArrowSet.mouseOut.add( onArrowOut );
		
		//queue fade in
		captionRef.transitionAction.addOnce(this.signalIntroComplete);
		captionRef.stateLoaded.dispatch( KEY );
	}
	
	override public function action():void
	{
		//startuh bouncin'
		bounceUp();
	}
	
	override public function doOutro():void
	{
		// remove controls
		nextArrowSet.removeAll();
		nextArrowSet = null;
		
		captionRef.transitionAction.addOnce( unload );
		captionRef.bitmapTweenContainerOut();
	}
	
	private function bounceUp():void
	{
		if(!mouseOverArrow) {
			tweeningArrowUp = true;
			arrowStopped=false;
			TweenLite.to( UI_Caption_Menu(captionWindow).arrow, .4, {y:"-10", onComplete:bounceDown, ease:Quad.easeOut} );
		}
	}
	
	private function bounceDown():void
	{
		tweeningArrowUp=false;
		TweenLite.to( UI_Caption_Menu(captionWindow).arrow, .4, {y:"+10", onComplete:onBounceDown, ease:Sine.easeIn} );
	}
	
	private function onBounceDown():void
	{
		if(mouseOverArrow)
			arrowStopped=true;
		bounceUp();
	}
	
	private function onArrowOver(e:MouseEvent):void 
	{
		mouseOverArrow=true;
		//stopuhbouncin.
		MouseIconHandler.onInteractiveRollOver();//.dispatch(HoverType.INTERACT); 
	}
	
	private function onArrowOut(e:MouseEvent):void 
	{ 
		mouseOverArrow=false;
		//uhresuma bouncin'
		if(arrowStopped)
			bounceUp();
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
	}
	
	private function onNextClicked(e:MouseEvent):void
	{
		if(captionRef.hasNextText())
		{
			captionRef.nextText();
			UI_Caption_Menu(captionWindow).text.text = captionRef.getCurrentText();
		} else
		{
			captionRef.alternate();
			captionRef.captionFinished.dispatch();
		}
	}

	private function unload():void
	{
		container.removeChild(captionWindow);
		container=null;
		captionRef=null;
		this.signalOutroComplete();
	}
}


class OutState extends State {
	
	public static const KEY:String = "out state";
	private var captionRef:Caption_Menu;
	
	public function OutState() {
		super();
	}
	
	override public function doIntro():void
	{
		this.signalIntroComplete();
		captionRef = Caption_Menu(this.context);
		captionRef.stateLoaded.dispatch( KEY );	
	}
}