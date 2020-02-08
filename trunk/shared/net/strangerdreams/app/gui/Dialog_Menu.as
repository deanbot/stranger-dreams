package net.strangerdreams.app.gui
{
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.deanverleger.utils.TweenUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.character.CharacterManager;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.LocationNodeManager;
	import net.strangerdreams.engine.scene.data.DialogTree;
	import net.strangerdreams.engine.scene.data.DialogTreeOption;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Dialog;
	import net.strangerdreams.engine.script.data.DialogOption;
	import net.strangerdreams.engine.script.data.ScriptScreen;
	import net.strangerdreams.engine.script.data.ScriptVersion;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	
	public class Dialog_Menu extends Sprite implements IUIMenu
	{
	// constants:
		public static const LOCATION:String = "Dialog_Menu";
		private static const LOC_A:String = "A";
		private static const LOC_B:String = "B";
	
	// private properties:
		private var _working:Boolean;
		private var _freshOpen:Boolean;
		private var _container:Sprite;
		private var _sm:StateManager;
		private var _open:Signal;
		private var _exit:Signal;
		private var _stateLoaded:Signal;
		private var _transitionAction:Signal;
		private var _dialogFinished:Signal;
		private var _currentDialogTree:DialogTree;
		private var _dialog:Dialog;
		private var _order:uint;
		private var _vOrder:uint;
		private var _sOrder:uint;
		private var _currentVersionPriority:uint;
		
		// public properties:
	
	// constructor:
		public function Dialog_Menu()
		{
			super();
			init();
		}
		
	// public getter/setters:
		public function get hasOptions():Boolean
		{
			return _currentDialogTree.hasOptions;
		}
		
		public function get atEnd():Boolean
		{
			return _currentDialogTree.end;
		}
		
		public function get dialogCharacter():MovieClip
		{
			return MovieClip(CharacterManager.getCharAsset(String(_currentDialogTree.charKey)));
		}
		
		public function get dialogFinished():Signal
		{
			return _dialogFinished;
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
		
		public function get dialogText():String
		{
			var dialogScreenText:String;
			var screen:ScriptScreen;
			if(_currentDialogTree!=null)
			{
				_dialog = StoryScriptManager.getDialogInstance("n"+StoryEngine.currentNode+_currentDialogTree.scriptKey);
				if(_dialog.hasText)
				{
					dialogScreenText=_dialog.text;
				} else if(_dialog.hasScreens)
				{
					if(_dialog.alternateBetweenScreens)
						screen = ScriptScreen(_dialog.screens[_dialog.currentScreen]);
					else
						screen = ScriptScreen(_dialog.screens[_order]);
					
					if(screen.hasScreens)
						dialogScreenText = ScriptScreen(screen.screens[_sOrder]).text;
					else
						dialogScreenText = screen.text;
				} else if(_dialog.hasVersions)
				{
					var version:ScriptVersion;
					var flagRequirementNotMet:Boolean=false;
					var priority:uint;
					while(priority<_dialog.numVersions && dialogScreenText==null)
					{
						flagRequirementNotMet=false;
						version=ScriptVersion(_dialog.versions[++priority]);
						if(version.hasFlagRequirement)
							if(!FlagManager.getHasFlag(version.flagRequirement))
								flagRequirementNotMet=true;
						
						if(!flagRequirementNotMet)
						{
							if(version.hasText)
							{
								dialogScreenText=version.text;
							}
						   else if(version.hasScreens)
							{
								if(version.alternateBetweenScreens)
									screen = ScriptScreen(version.screens[version.currentScreen]);
								else
									screen = ScriptScreen(version.screens[_vOrder]);
								
								if(screen.hasScreens)
									dialogScreenText = ScriptScreen(screen.screens[_sOrder]).text;
								else
									dialogScreenText=screen.text;
							} else
								throw new Error("Dialog Menu (dialogText): couldn't find text (middle).");
						}
					}
				}
				
				if(dialogScreenText==null)
					throw new Error("Dialog Menu (dialogText): couldn't find text (end).");
				else
					_currentVersionPriority=priority;
			} else
				throw new Error("Dialog Menu (dialogText): couldn't find text (beginning).");
			
			return dialogScreenText;
		}
		
		public function get hasNextText():Boolean
		{
			var hasNext:Boolean = false;
			var screen:ScriptScreen;
			if(_dialog.hasText)
			{
				//false
			}else if(_dialog.hasScreens)
			{
				if(_dialog.alternateBetweenScreens)
				{
					screen = ScriptScreen(_dialog.screens[_dialog.currentScreen]);
					if(screen.hasScreens)
						if(_sOrder<screen.numScreens)
							hasNext=true;
				}
				else 
				{
					screen = ScriptScreen(_dialog.screens[_order]);
					if(screen.hasScreens)
					{
						if(_sOrder<screen.numScreens)
							hasNext=true;
						else if(_order<_dialog.numScreens)
							hasNext=true;
					} else if(_order<_dialog.numScreens)
						hasNext=true;
				}					
			} else if(_dialog.hasVersions)
			{
				var version:ScriptVersion=ScriptVersion(_dialog.versions[_currentVersionPriority]);
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
					throw new Error("Dialog Menu (hasNextText): couldn't find if has next text (end).");
			} else
				throw new Error("Dialog Menu (hasNextText): couldn't find if has next text (beginning).");
			return hasNext;
		}
		
		public function get orderedOptions():Array 
		{
			var ordered:Array = new Array();
			var keepGoing:Boolean = true;
			var i:uint = 1;
			var tempOption:DialogTreeOption;
			var pass:Boolean;
			
			if(_currentDialogTree.hasOptions)
			{
				var options:Dictionary = _currentDialogTree.options;
				while(keepGoing)
				{
					tempOption = null;
					pass = false;
					if(options[i]==null)
						keepGoing = false;
					else
						tempOption = options[i] as DialogTreeOption;
					
					if(tempOption!=null)
					{
						if(tempOption.flagRequirement=="")
						{
							if(tempOption.antiFlagRequirement=="")
								pass=true;
							else if(!FlagManager.getHasFlag(tempOption.antiFlagRequirement))
								pass=true;
						}
						else
						{
							if(FlagManager.getHasFlag(tempOption.flagRequirement))
							{
								if(tempOption.antiFlagRequirement=="")
									pass=true;
								else if(!FlagManager.getHasFlag(tempOption.antiFlagRequirement))
									pass=true;
							} 
						}
						
						if(pass)
							ordered.push(tempOption);
					}
					
					if(keepGoing)
						i++;
				}
			}

			return ordered;
		}
		
		// public methods:
		public function setNextDialog(nextKey:String):void
		{
			var tree:DialogTree = LocationNodeManager.getLocationNode(StoryEngine.currentNode).dialogTrees[nextKey];
			if(tree!=null)
			{
				if(tree.flag!=null)
				{
					if (!FlagManager.getHasFlag(tree.flag))
						FlagManager.addFlag(tree.flag);
				}
			}
			setDialogTree(tree);
		}
		
		public function nextText():void
		{
			var screen:ScriptScreen;
			if(_dialog.hasScreens)
			{
				if(_dialog.alternateBetweenScreens)
				{
					screen = ScriptScreen(_dialog.screens[_dialog.currentScreen]);
					if(screen.hasScreens)
						_sOrder++;
				}
				else
				{
					screen = ScriptScreen(_dialog.screens[_order]);
					if(screen.hasScreens)
						if(_sOrder<screen.numScreens)
							_sOrder++;
						else
							_order++;
						else 
							_order++;
				}
			}
			else if(_dialog.hasVersions)
			{
				var version:ScriptVersion=ScriptVersion(_dialog.versions[_currentVersionPriority]);
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
			if(_dialog.hasScreens) 
			{
				if(_dialog.alternateBetweenScreens) 
					_dialog.nextScreen();
			} else if(_dialog.hasVersions)
			{
				if(_dialog.hasVersions)
				{
					version = ScriptVersion(_dialog.versions[_currentVersionPriority]);
					if(version.alternateBetweenScreens)
						version.nextScreen();
				}
			}
		}
		
		public function openMenu(startState:String = "ignore this"):void
		{
			addChild( _container = new Sprite() );
			
			_container.alpha = 0;
			
			_working = true;
			_freshOpen = true;
						
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
		
		public function setDialogTree(dialogTree:DialogTree):void
		{
			_currentDialogTree = dialogTree;
			_order=_vOrder=_sOrder=_currentVersionPriority=1;
		}
		
		public function update():void
		{
			
		}
		
		public function bitmapTweenContainerOut(duration:Number = 0):void
		{
			if(duration == 0)
				duration=SEConfig.transitionTime;
			TweenUtils.bitmapAlphaTween( this._container, this, 1, 0, duration, _transitionAction.dispatch );
		}
		
	// private methods:
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
			_currentDialogTree = null;
			
			DisplayObjectUtil.removeAllChildren( _container, false, true );
			removeChild( _container );
			_container = null;
		}
		
		private function onFreshOpen():void
		{
			//trace( "Caption Menu says, \"There I've opened.\"" );
			open.dispatch();
			_freshOpen = false;
		}
		
		private function init():void
		{
			_open = new Signal();
			_exit = new Signal();
			_stateLoaded = new Signal( String );
			_transitionAction = new Signal();
			_dialogFinished = new Signal();
			
		}
		
	}
}
import com.greensock.TweenLite;
import com.greensock.easing.Quad;
import com.greensock.easing.Sine;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.Dictionary;

import net.deanverleger.utils.ClipUtils;
import net.deanverleger.utils.LoggingUtils;
import net.strangerdreams.app.gui.Dialog_Menu;
import net.strangerdreams.app.gui.MouseIconHandler;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.scene.data.DialogTreeOption;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.DialogOption;

import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class DefaultState extends State {
	
	public static const KEY:String = "defaultState";
	private static const LOC_A:String = "A";
	private static const LOC_B:String = "B";
	private var ref:Dialog_Menu;
	private var container:Sprite;
	
	private var dialogMenu:UI_DialogMenu;
	
	//dialog window objects
	private var dialogArrowGraphic:Sprite;
	private var dialogArrowHit:Sprite;
	private var dialogText:TextField;
	private var dialogCharacterHolder:Sprite;
	private var dialogCharacter:MovieClip;
	private var arrowSet:InteractiveObjectSignalSet;
	//options window objects
	private var longText:TextField;
	private var optionsWindow:Sprite;
	private var optionTextA:TextField;
	private var optionTextB:TextField;
	private var optionHitLocations:Dictionary;
	//create sprites to textWidth and height of option tfs
	private var optionHitA:Sprite;
	private var optionHitB:Sprite;
	private var optionASet:InteractiveObjectSignalSet;
	private var optionBSet:InteractiveObjectSignalSet;
	private var activeA:Boolean;
	private var activeB:Boolean;
	private var orderedOptions:Array;
	private var optionOrder:Dictionary;
	private var mouseOverArrow:Boolean;
	private var tweeningArrowUp:Boolean;
	private var arrowStopped:Boolean;
	private var haltArrow:Boolean;
	private var busy:Boolean;
	
	public function DefaultState()
	{
		super();
		optionOrder = new Dictionary(true);
		optionOrder[LOC_A] = 0;
		optionOrder[LOC_B] = 1;
	}
	
	override public function doIntro():void
	{
		ref = Dialog_Menu(this.context);
		container = ref.container;
		
		dialogMenu = new UI_DialogMenu();
		dialogArrowGraphic = dialogMenu.arrow;
		dialogArrowGraphic.cacheAsBitmap = true;
		dialogArrowHit = dialogMenu.arrowHit;
		dialogText = dialogMenu.dialogText;
		dialogCharacterHolder = dialogMenu.dialogCharactherHolder;
		dialogCharacter = ref.dialogCharacter;
		dialogCharacter.cacheAsBitmap = dialogCharacterHolder.cacheAsBitmap = true;
		dialogCharacterHolder.addChild(dialogCharacter);
		arrowSet = new InteractiveObjectSignalSet(dialogArrowHit);
		optionsWindow = dialogMenu.optionsWindow;
		optionsWindow.cacheAsBitmap = true;
		longText = dialogMenu.longText;
		optionTextA = dialogMenu.optionA;
		optionTextB = dialogMenu.optionB;
		ClipUtils.makeInvisible(dialogText, optionsWindow,longText,optionTextA,optionTextB);
		container.addChild(dialogMenu);
		
		//get_first_text
		dialogText.text = ref.dialogText;
		
		
		//queue fade in
		ref.transitionAction.addOnce(this.signalIntroComplete);
		ref.stateLoaded.dispatch( KEY );
	}
	
	override public function action():void
	{
		busy = true;
		dialogTextSet();
	}
	
	override public function doOutro():void
	{
		// remove controls
		arrowSet.removeAll();
		arrowSet = null;
		
		ref.transitionAction.addOnce( unload );
		ref.bitmapTweenContainerOut(.75);
	}
	
	private function addArrowControls():void
	{
		if(arrowSet==null)
			return;
		arrowSet.click.add( onNextClicked );
		arrowSet.mouseOver.add( onArrowOver );
		arrowSet.mouseOut.add( onArrowOut );
		busy = false;
	}
	
	private function removeArrowControls():void
	{
		if(arrowSet==null)
			return;
		arrowSet.click.remove( onNextClicked );
		arrowSet.mouseOver.remove( onArrowOver );
		arrowSet.mouseOut.remove( onArrowOut );
	}
	
	private function dialogTextSet():void
	{
		
		ClipUtils.hide(dialogText);
		dialogText.cacheAsBitmap = true;
		TweenLite.to(dialogText, .6, { alpha: 1, onComplete:dialogTextFadedIn });
	}
	
	private function dialogTextFadedIn():void
	{
		if(ref == null)
			return;
		if(ref.hasNextText || ref.atEnd)
			bounceUp();
		
		if(!ref.atEnd && !ref.hasNextText)
		{
			//if options
			if(ref.hasOptions)
			{
				orderedOptions = ref.orderedOptions;
				if(orderedOptions[locToOrder(LOC_A)] != null)
					activeA = true;
				if(orderedOptions[locToOrder(LOC_B)] != null)
					activeB = true;
				
				if(optionsWindow.alpha == 0)
				{
					ClipUtils.hide(optionsWindow);
					TweenLite.to(optionsWindow, .3, { alpha: 1, onComplete:optionsWindowFadedIn });
				} else
				{
					TweenLite.to(longText, .2, { alpha: 0, onComplete:oldTextFaded });
				}
				removeArrowControls();
			}	
		} else
		{
			addArrowControls();
			if(dialogArrowHit.hitTestPoint(container.mouseX, container.mouseY))
			{
				mouseOverArrow=true;
				MouseIconHandler.onInteractiveRollOver();
			}
		}
	}
	
	private function oldTextFaded():void
	{
		ClipUtils.makeInvisible(longText);
		optionsWindowFadedIn();
	}
	
	private function optionsWindowFadedIn():void
	{
		if(activeA)
		{
			optionTextA.text = getOptionShortText(LOC_A);
			optionTextA.cacheAsBitmap = true;
		}
		if(activeB)
		{
			optionTextB.text = getOptionShortText(LOC_B);
			optionTextB.cacheAsBitmap = true;
		}
		
		optionHitLocations = new Dictionary(true);
		if(activeA)
		{
			optionHitA = new OptionHit(optionTextA.textWidth,optionTextA.textHeight);
			initOptionHit(optionHitA,LOC_A);
			optionASet = new InteractiveObjectSignalSet(optionHitA);
			optionHitA.x = optionTextA.x;
			optionHitA.y = optionTextA.y;
			dialogMenu.addChild(optionHitA);
			if(activeB)
				TweenLite.to(optionTextA, .3, { alpha: 1 });
			else
				TweenLite.to(optionTextA, .3, { alpha: 1, onComplete:addOptionControls });
			ClipUtils.hide(optionTextA);
		}
		if(activeB)
		{
			optionHitB = new OptionHit(optionTextB.textWidth, optionTextB.textHeight);
			initOptionHit(optionHitB,LOC_B);
			optionBSet = new InteractiveObjectSignalSet(optionHitB);
			optionHitB.x = optionTextA.x;
			optionHitB.y = optionTextB.y;
			dialogMenu.addChild(optionHitB);
			TweenLite.to(optionTextB, .3, { alpha: 1, onComplete:addOptionControls });
			ClipUtils.hide(optionTextB);
		}
	}
	
	private function removeControls():void
	{
		if(activeA)
		{
			optionASet.mouseOver.remove(optionOver);	
			optionASet.mouseOut.remove(optionOut);
			optionASet.click.remove(optionClick);
			
		}
		if(activeB)
		{
			optionBSet.mouseOut.remove(optionOut);
			optionBSet.mouseOver.remove(optionOver);
			optionBSet.click.remove(optionClick);
			
		}
	}
	
	private function addOptionControls():void
	{
		if(activeA)
		{
			optionASet.mouseOver.add(optionOver);
			optionASet.mouseOut.add(optionOut);
			optionASet.click.addOnce(optionClick);
		}
		if(activeB)
		{
			optionBSet.mouseOver.add(optionOver);
			optionBSet.mouseOut.add(optionOut);
			optionBSet.click.addOnce(optionClick);
		}
		busy = false;
	}

	private function initOptionHit(optionHit:Sprite, location:String):void
	{
		optionHitLocations[optionHit]=location;
	}
	
	private function deInitOptionHit(optionHit:Sprite):void
	{
		delete optionHitLocations[optionHit];
	}
	
	private function locToOrder(loc:String):uint
	{
		return optionOrder[loc];
	}
	
	private function getOptionShortText(loc:String):String
	{
		var dialogTreeOption:DialogTreeOption = orderedOptions[locToOrder(loc)] as DialogTreeOption;
		return "> "+DialogOption(StoryScriptManager.getDialogOptionInstance("n"+StoryEngine.currentNode+dialogTreeOption.shortKey)).text;
	}
	
	private function getOptionLongText(loc:String):String
	{
		var dialogTreeOption:DialogTreeOption = orderedOptions[locToOrder(loc)] as DialogTreeOption;
		return DialogOption(StoryScriptManager.getDialogOptionInstance("n"+StoryEngine.currentNode+dialogTreeOption.longKey)).text;
	}
	
	private function getOptionNexTKey(loc:String):String
	{
		var dialogTreeOption:DialogTreeOption = orderedOptions[locToOrder(loc)] as DialogTreeOption;
		return dialogTreeOption.nextKey;
	}
	
	private function optionClick(e:MouseEvent):void
	{
		if(busy)
			return;
		busy = true;
		var loc:String = String(optionHitLocations[e.target]);
		longText.text = getOptionLongText( loc );
		longText.cacheAsBitmap = true;
		ref.setNextDialog( getOptionNexTKey(loc) );
		removeControls();
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
		TweenLite.to(dialogText, .5, { alpha: 0 });
		if(activeA)
		{
			if(activeB)
				TweenLite.to(optionTextA, .5, { alpha: 0 });
			else
				TweenLite.to(optionTextA, .5, { alpha: 0, onComplete:fadeInOptionLong });
		}
		if(activeB)
		{
			TweenLite.to(optionTextB, .5, { alpha: 0, onComplete:fadeInOptionLong });
		}
		
	}
	
	private function fadeInOptionLong():void
	{
		ClipUtils.makeInvisible(optionTextA,optionTextB,dialogText);
		optionTextA.cacheAsBitmap = optionTextB.cacheAsBitmap = false;
		dialogText.cacheAsBitmap = false;
		if(activeA)
		{
			deInitOptionHit(optionHitA);
			dialogMenu.addChild(optionHitA);
			optionASet = null;
			optionHitA = null;
		}
		if(activeB)
		{
			deInitOptionHit(optionHitB);
			dialogMenu.addChild(optionHitB);
			optionBSet = null;
			optionHitB = null;
		}
		activeA = activeB = false;
		ClipUtils.hide(longText);
		dialogText.text = ref.dialogText;
		dialogText.cacheAsBitmap = true;
		TweenLite.to(longText, .5, { alpha: 1, onComplete:dialogTextSet });
	}
	
	private function optionOver(e:MouseEvent):void
	{
		MouseIconHandler.onInteractiveRollOver();
	}
	
	private function optionOut(e:MouseEvent):void
	{
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
	}
	
	private function bounceUp():void
	{
		if(!mouseOverArrow) {
			tweeningArrowUp = true;
			arrowStopped=haltArrow=false;
			TweenLite.to( dialogArrowGraphic, .4, {y:"-10", onComplete:bounceDown, ease:Quad.easeOut} );
		}
	}
	
	private function bounceDown():void
	{
		tweeningArrowUp=false;
		TweenLite.to( dialogArrowGraphic, .4, {y:"+10", onComplete:onBounceDown, ease:Sine.easeIn} );
	}
	
	private function onBounceDown():void
	{
		if(mouseOverArrow)
			arrowStopped=true;
		if(!haltArrow)
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
		if(arrowStopped && !haltArrow)
			bounceUp();
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
	}
	
	private function onNextClicked(e:MouseEvent):void
	{
		if(busy)
			return;
		busy = true;
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
		removeArrowControls();
		if(ref.atEnd)
		{
			haltArrow = true;
			if (ref.hasNextText)
				TweenLite.to(dialogText,.7,{alpha:0, onComplete:setNextDialogText });
			else
			{
				ref.alternate();
				ref.dialogFinished.dispatch();
			}
		} else 
		{
			haltArrow = true;
			if (ref.hasNextText)
				TweenLite.to(dialogText,.7,{alpha:0, onComplete:setNextDialogText });
		}
	}
	
	private function setNextDialogText():void
	{
		dialogText.cacheAsBitmap = false;
		ref.nextText();
		dialogText.text = ref.dialogText; 
		dialogTextSet();
	}
	
	private function unload():void
	{
		container.removeChild(dialogMenu);
		container=null;
		ref=null;
		busy = false;
		this.signalOutroComplete();
	}
}

class OutState extends State {
	
	public static const KEY:String = "out state";
	private var ref:Dialog_Menu;
	
	public function OutState() {
		super();
	}
	
	override public function doIntro():void
	{
		this.signalIntroComplete();
		ref = Dialog_Menu(this.context);
		ref.stateLoaded.dispatch( KEY );	
		ref = null;
	}
}

class OptionHit extends Sprite {
	public function OptionHit(width:Number, height:Number) {
		this.graphics.beginFill( 0x000000, 0);
		this.graphics.drawRect(0, 0, width, height);
		this.graphics.endFill();
		this.alpha = 0;
	}
}