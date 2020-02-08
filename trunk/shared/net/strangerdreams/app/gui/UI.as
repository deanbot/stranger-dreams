package net.strangerdreams.app.gui
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.core.IDestroyable;
	import net.deanverleger.graphics.shapes.SolidFadingBG;
	import net.deanverleger.gui.ShapeSprite;
	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.SETutorialBroadcaster;
	import net.strangerdreams.app.keyboard.SEHotkeyListener;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.item.ItemManager;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.location.LocationNodeManager;
	import net.strangerdreams.engine.note.INoteImplementor;
	import net.strangerdreams.engine.note.NoteImplementor;
	import net.strangerdreams.engine.note.NoteManager;
	import net.strangerdreams.engine.note.data.Note;
	import net.strangerdreams.engine.scene.data.DialogTree;
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.scene.data.NodeObject;
	import net.strangerdreams.engine.scene.data.NodeObjectType;
	import net.strangerdreams.engine.scene.data.NodeState;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Caption;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class UI extends Sprite
	{
		// constants:
		public static const LOCATION:String = "UI";
		public static const MENU_INVENTORY:String = "inventory";
		public static const MENU_JOURNAL:String = "journal";
		public static const MENU_CAPTION:String = "caption";
		public static const MENU_DIALOG:String = "dialog";
		
		// private properties:
		private var _hud:HUD;
		private var _menuBG:SolidFadingBG;
		private var _inventoryMenu:Inventory_Menu;
		private var _journalMenu:Journal_Menu;
		private var _captionMenu:Caption_Menu;
		private var _dialogMenu:Dialog_Menu;
		private var _notificationDisplay:NotificationDisplay;
		private var menus:Dictionary;
		private var activeMenu:String = null;
		private var _working:Boolean = false;
		private var nextMenu:String = null;
		private var tempMenu:String = null;
		private var _nodeObjects:Dictionary;
		private var _nodeAsset:MovieClip;
		private var _compassArrowClicked:Signal;
		private var _forcedMove:Signal;
		private var captionDelay:Timer;
		private var dialogDelay:Timer;
		private var captionDelayed:NativeSignal;
		private var dialogDelayed:NativeSignal;
		private var _arrowDegrees:Number;
		private var _internalState:Boolean;
		private var _currentNodeObject:NodeObject;
		private var _currentDialogTree:DialogTree;
		private var _notificationSet:InteractiveObjectSignalSet;
		private var _subMenu:String;
		private var _frameOverlayHolder:Sprite;
		private var _menuOverlayHolder:Sprite;
		private var _currentOverlayHolder:Sprite;
		private var _unloaded:Boolean;
		private var _notesQueue:Array;
		private var _activeNote:NoteImplementor;
		private var _destroyed:Boolean;
		private var questionCaption:QuestionCaption;
		
		private var mouseclick:NativeSignal;
		
		// public properties:
		// constructor:
		public function UI()
		{
			init();
			_arrowDegrees = 0;
			_destroyed = false;
			mouseclick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
			mouseclick.add( function (e:MouseEvent):void
			{
				trace(e.currentTarget);
			} );
		}
		
		// public getter/setters:
		
		public function get notificationDisplay():NotificationDisplay
		{
			return _notificationDisplay;
		}
		
		public function get compassArrowClicked():Signal 
		{ 
			return _compassArrowClicked; 
		}
		
		public function get forcedMove():Signal 
		{ 
			return _forcedMove; 
		}
		
		public function set working(value:Boolean):void
		{
			_working = value;
			if(value == true)
				SEHotkeyListener.halt();
			else
				SEHotkeyListener.resume();
				
		}
		
		
		// public methods:
		/**
		 * Initalizes all items. Still need to call hud.load() to load the hud.
		 * 
		 */
		public function load():void
		{
			_unloaded = false;
			
			addChild( _frameOverlayHolder = new Sprite() );
			addChild( _menuBG = new SolidFadingBG( 760, 512, .85, 0x000000, SEConfig.transitionTime ) );
			_menuBG.visible = false;
			_hud = new HUD(_arrowDegrees);
			
			addChild( _hud );
			addChild( _journalMenu = new Journal_Menu(_hud,this) );
			addChild( _inventoryMenu = new Inventory_Menu(_hud) );
			addChild( _captionMenu = new Caption_Menu() );
			addChild( _dialogMenu = new Dialog_Menu() );
			addChild( _menuOverlayHolder = new Sprite() );
			addChild( _notificationDisplay=new NotificationDisplay );
			_notificationDisplay.activity.add(onNotificationActivity);
			_notificationSet = new InteractiveObjectSignalSet(_notificationDisplay);
			initMenu( _journalMenu, MENU_JOURNAL );
			initMenu( _inventoryMenu, MENU_INVENTORY );
			initMenu( _captionMenu, MENU_CAPTION );
			initMenu( _dialogMenu, MENU_DIALOG);
			_hud.load();
			
			MouseIconHandler.init();
			
			SESignalBroadcaster.interactiveClick.add( onNodeObjectClick );
			SESignalBroadcaster.captionTriggered.add( onCaptionTriggered ); 
			SESignalBroadcaster.singleCaption.add( onSingleCaption );
			SESignalBroadcaster.dialogTriggered.add( onDialogTriggered );
			SESignalBroadcaster.itemUsed.add( onItemUsed );
			SESignalBroadcaster.saveTriggered.add( onSaveTriggered );
			SESignalBroadcaster.questionTriggered.add( onQuestionTriggered );
			
			SESignalBroadcaster.hideHUD.add(onHideHUD);
			SESignalBroadcaster.showHUD.add(onShowHUD);
			SESignalBroadcaster.enterInternalState.add(onInternalEnter);
			SESignalBroadcaster.leaveInternalState.add(onInternalExit);
			SESignalBroadcaster.queueNoteOverlay.add(onNoteQueued);
			SESignalBroadcaster.doNoteOverlay.add(onDoNoteOverlay);
			SESignalBroadcaster.blockToggle.add(onBlockToggle);
			_internalState=false;
			
			//set hud controls
			_hud.clickItemOver.add( MouseIconHandler.onInteractiveRollOver );
			_hud.clickItemOut.add( MouseIconHandler.onItemRollOut );
			_hud.menuIconClick.add( onHUDMenuIconClick );
			_hud.quickslotHandleClick.add( onQuickSlotsHandleClick );
			_hud.compassBackButtonClick.add( onCompassBackButtonClicked );
			_inventoryMenu.clickItemOver.add( MouseIconHandler.onInteractiveRollOver );
			_inventoryMenu.clickItemOut.add( MouseIconHandler.onItemRollOut );
			_inventoryMenu.keyItemsActiveChange.add( onKeyItemsActiveChange );
			_journalMenu.clickItemOver.add( MouseIconHandler.onInteractiveRollOver );
			_journalMenu.clickItemOut.add( MouseIconHandler.onItemRollOut );
			_journalMenu.volumeChange.add( onVolumeChange );
			_journalMenu.muteChange.add( onMuteChange );
			_journalMenu.fullScreeenChange.add( onFullScreenChange );
			_journalMenu.quitTitleAction.addOnce( onQuitToTitle );
			_journalMenu.quitAction.addOnce( onQuitGame );
			_captionMenu.captionFinished.add( onCaptionFinished );
			_dialogMenu.dialogFinished.add( onDialogFinished );
			
			SEHotkeyListener.journalKeyPressed.add(onJournalKeyPressed);
			SEHotkeyListener.inventoryKeyPressed.add(onInventoryKeyPressed);
			SEHotkeyListener.goalKeyPressed.add(onGoalKeyPressed);
			SEHotkeyListener.optionsKeyPressed.add(onOptionsKeyPressed);
			SEHotkeyListener.keyItemsKeyPressed.add(onKeyItemsPressed);
			SEHotkeyListener.notesKeyPressed.add(onNotesKeyPressed);
			SEHotkeyListener.mapKeyPressed.add(onMapKeyPressed);
			SEHotkeyListener.backKeyPressed.add(onBackKeyPressed);
			
			_notesQueue = new Array();
			saidBit = false;
		}
		
		public function resetHud():void
		{
			_hud.hideBriefcase( 0 );
			//_hud.clearArrowControls();	
		}
		
		public function setUpArrowControls( arrowDirections:Array ):void
		{
			if(_hud != null)
			{
				if ( arrowDirections.length > 0 ) {
					_hud.compassArrowClick.add( onCompassArrowClicked );
					_hud.addCompassArrowControls( arrowDirections );
				} else 
					_hud.clearArrowControls();
			}
		}
		
		/**
		 * Do animation on HUD compass needle to new degree 
		 * 
		 */
		public function setCompassNeedleDegrees( degrees:Number ):void
		{
			//LoggingUtils.msgTrace("Set Compass Degrees: "+degrees,LOCATION);
			// degrees is the inverse of rotation
			if(_arrowDegrees==degrees)
				return;
			_arrowDegrees = degrees;
			if(_hud!=null)
				_hud.setCompassNeedleDegrees( degrees );
		}
		
		public function issueRollOut():void
		{
			MouseIconHandler.onItemRollOut();
		}
		
		public function checkRollOver():void
		{
			_hud.checkRollOver();
		}
		
		public function hideHUD():void
		{
			_hud.doTempHiddenState();
		}
		
		public function revealHUD():void
		{
			_hud.doDefaultState();
		}
		
		public function unload():void
		{
			if(!_unloaded)
			{
				_unloaded = true;
				SEHotkeyListener.journalKeyPressed.remove(onJournalKeyPressed);
				SEHotkeyListener.inventoryKeyPressed.remove(onInventoryKeyPressed);
				SEHotkeyListener.goalKeyPressed.remove(onGoalKeyPressed);
				SEHotkeyListener.optionsKeyPressed.remove(onOptionsKeyPressed);
				SEHotkeyListener.keyItemsKeyPressed.remove(onKeyItemsPressed);
				SEHotkeyListener.notesKeyPressed.remove(onNotesKeyPressed);
				SEHotkeyListener.mapKeyPressed.remove(onMapKeyPressed);
				SEHotkeyListener.backKeyPressed.remove(onBackKeyPressed);
				
				SESignalBroadcaster.hideHUD.remove(onHideHUD);
				SESignalBroadcaster.showHUD.remove(onShowHUD);
				SESignalBroadcaster.enterInternalState.remove(onInternalEnter);
				SESignalBroadcaster.leaveInternalState.remove(onInternalExit);
				SESignalBroadcaster.interactiveClick.remove( onNodeObjectClick );
				SESignalBroadcaster.captionTriggered.remove( onCaptionTriggered ); 
				SESignalBroadcaster.singleCaption.remove( onSingleCaption ); 
				SESignalBroadcaster.queueNoteOverlay.remove(onNoteQueued);
				SESignalBroadcaster.doNoteOverlay.remove(onDoNoteOverlay);
				SESignalBroadcaster.dialogTriggered.remove( onDialogTriggered );
				SESignalBroadcaster.itemUsed.remove( onItemUsed );
				SESignalBroadcaster.saveTriggered.remove( onSaveTriggered );
				
				//set hud controls
				_hud.clickItemOver.remove( MouseIconHandler.onInteractiveRollOver );
				_hud.clickItemOut.remove( MouseIconHandler.onItemRollOut );
				_hud.menuIconClick.remove( onHUDMenuIconClick );
				_hud.quickslotHandleClick.remove( onQuickSlotsHandleClick );
				_hud.compassBackButtonClick.remove( onCompassBackButtonClicked );
				_inventoryMenu.clickItemOver.remove( MouseIconHandler.onInteractiveRollOver );
				_inventoryMenu.clickItemOut.remove( MouseIconHandler.onItemRollOut );
				_inventoryMenu.keyItemsActiveChange.remove( onKeyItemsActiveChange );
				_journalMenu.clickItemOver.remove( MouseIconHandler.onInteractiveRollOver );
				_journalMenu.clickItemOut.remove( MouseIconHandler.onItemRollOut );
				_journalMenu.volumeChange.remove( onVolumeChange );
				_journalMenu.muteChange.remove( onMuteChange );
				_journalMenu.fullScreeenChange.remove( onFullScreenChange );
				_journalMenu.quitTitleAction.remove( onQuitToTitle );
				_journalMenu.quitAction.remove( onQuitGame );
				_captionMenu.captionFinished.remove( onCaptionFinished );
				_dialogMenu.dialogFinished.remove(onDialogFinished);
				_notificationDisplay.activity.remove(onNotificationActivity);
				
				DisplayObjectUtil.removeAllChildren(this);
				_frameOverlayHolder = _menuOverlayHolder = _currentOverlayHolder = null;
				_menuBG.destroy();
				_menuBG = null;
				_hud.unload();
				_hud = null;
				_journalMenu.exitMenu();
				_journalMenu = null;
				_inventoryMenu.exitMenu();
				_inventoryMenu = null;
				_captionMenu.exitMenu();
				_captionMenu = null;
				_dialogMenu.exitMenu();
				_dialogMenu = null;
				_notificationDisplay.destroy();
				_notificationDisplay = null;
				_notificationSet.removeAll();
				_notificationSet = null;
				
				DictionaryUtils.emptyDictionary(menus);
				DictionaryUtils.emptyDictionary(_nodeObjects);
				
				//MouseIconHandler.hideMouse();
				
				activeMenu = nextMenu = tempMenu = _subMenu = null;
				_working = _internalState = false;
				_nodeAsset = null;
				
				_nodeObjects = menus = null;
				
				_nodeObjects = null;
				if(captionDelayed !=null)
					captionDelayed.removeAll();
				captionDelay = null;
				captionDelayed = null;
				_arrowDegrees = 0;
				_currentNodeObject = null;
				_currentDialogTree = null;
			}
		}
		
		public function destroy():void
		{
			if(_destroyed)
				return;
			unload();
			_forcedMove.removeAll();
			_compassArrowClicked.removeAll();
			_forcedMove = _compassArrowClicked = null;
			_destroyed = true;
		}
		
		// private methods:
		private function init():void
		{
			_compassArrowClicked = new Signal( String );
			_forcedMove = new Signal( uint );
		}
		
		private function initMenu( menu:*, menuName:String ):void
		{
			if (menus == null)
				menus = new Dictionary(true);
			menus[menuName] = menu;
		}
		
		private function onJournalKeyPressed():void
		{
			_subMenu = null;
			onHUDMenuIconClick(MENU_JOURNAL);
		}
		
		private function onInventoryKeyPressed():void
		{
			_subMenu = null;
			onHUDMenuIconClick(MENU_INVENTORY);
		}
		
		private function onGoalKeyPressed():void
		{
			LoggingUtils.msgTrace("goal key (working: " +_working + ")",LOCATION);
			_subMenu = Journal_Menu.PAGE_GOALS;
			onHUDMenuIconClick(MENU_JOURNAL);
		}
		
		private function onOptionsKeyPressed():void
		{
			LoggingUtils.msgTrace("options key (working: " +_working + ")",LOCATION);
			_subMenu = Journal_Menu.PAGE_OPTIONS;
			onHUDMenuIconClick(MENU_JOURNAL);
		}
		
		private function onKeyItemsPressed():void
		{
			LoggingUtils.msgTrace("key items (working: " +_working + ")",LOCATION);
			_subMenu = Inventory_Menu.PAGE_KEY_ITEMS;
			onHUDMenuIconClick(MENU_INVENTORY);
		}
		
		private function onNotesKeyPressed():void
		{
			LoggingUtils.msgTrace("notes key (working: " +_working + ")",LOCATION);
			_subMenu = Journal_Menu.PAGE_NOTES;
			onHUDMenuIconClick(MENU_JOURNAL);
		}
		
		/**
		 * show don't have map caption if no map 
		 * 
		 */
		private function onMapKeyPressed():void
		{
			LoggingUtils.msgTrace("map key (working: " +_working + ")",LOCATION);
			if(!SEConfig.hasMap)
			{
				working=true;
				SESignalBroadcaster.captionComplete.addOnce(function():void { working=false });
				SESignalBroadcaster.singleCaption.dispatch("noMap");
			}
			_subMenu = Journal_Menu.PAGE_MAP;
			onHUDMenuIconClick(MENU_JOURNAL);
		}
		
		/**
		 * Either pull up options if not in menu screen or back if in menu screen 
		 */
		private function onBackKeyPressed():void
		{
			LoggingUtils.msgTrace("back key pressed (working: " + _working + ", activemenu: " + activeMenu + ", internalState: " + _internalState + ")",LOCATION);
			if(_internalState)
				if(activeMenu==null)
					SESignalBroadcaster.leaveInternalState.dispatch();
				else if (activeMenu!=MENU_CAPTION)
					unloadActiveMenu();
				else if(activeMenu==null)
					onOptionsKeyPressed();
				else if (activeMenu!=MENU_CAPTION)
					unloadActiveMenu();
		}
		
		private function onHUDMenuIconClick(menuIcon:String):void
		{
			// keep from working when holding something perhaps?
			if ( !_working ) {
				working = true;
				//trace( "UI says, \"Time to go to work.\"");
				if ( activeMenu == null ) 
				{
					activeMenu = menuIcon;
					SEHotkeyListener.haltMovement();
					_menuBG.bgAction.addOnce(loadActiveMenu);
					_menuBG.show();
				} else {
					if ( activeMenu != menuIcon )
					{
						nextMenu = menuIcon;
						unloadActiveMenu();
					} else {
						if ( _subMenu == null )
							unloadActiveMenu();
						else 
						{
							if ( activeMenu == MENU_JOURNAL )
							{
								if(_journalMenu.currentPage == _subMenu)
									unloadActiveMenu();
								else
								{
									_journalMenu.transitionAction.addOnce( takeBreak );
									_journalMenu.openMenuPage(_subMenu);
								}
							} 
							else if ( activeMenu == MENU_INVENTORY )
							{
								if(_inventoryMenu.currentPage == _subMenu)
									unloadActiveMenu();
								else
								{
									_inventoryMenu.transitionAction.addOnce( takeBreak );
									_inventoryMenu.openMenuPage(_subMenu);
								}
							}
						}
					}
				}
			}
		}
		
		private function loadActiveMenu():void
		{
			//trace("loadActiveMenu: " + activeMenu);
			/* hud */
			if ( activeMenu == MENU_JOURNAL )
				_hud.doJournalState();
			else if ( activeMenu == MENU_INVENTORY )
				_hud.doInventoryState();
			else if (activeMenu==MENU_CAPTION)
			{
				_notificationDisplay.pause();
				if(tempMenu!=MENU_JOURNAL && tempMenu!=MENU_INVENTORY)
					if(!_internalState)
						_hud.doDefaultState();
			} else if (activeMenu==MENU_DIALOG)
			{
				_notificationDisplay.pause();
				if(tempMenu!=MENU_JOURNAL && tempMenu!=MENU_INVENTORY)
					if(!_internalState)
						_hud.doDefaultState();
			}
			/* end hud */
			
			SEHotkeyListener.haltMovement();
			
			/* menu */
			IUIMenu(menus[activeMenu]).openMenu(_subMenu);
			_subMenu = null;
			IUIMenu(menus[activeMenu]).open.addOnce(takeBreak);
			/* menu */
		}
		
		private function unloadActiveMenu():void
		{
			//trace("unload: " + activeMenu);
			if(activeMenu==null)
				return;
			
			IUIMenu(menus[activeMenu]).exitMenu();
			
			if (nextMenu == null)
			{
				IUIMenu(menus[activeMenu]).exit.addOnce( function():void {
					if(StoryEngine.updateStateQueued)
					{
						LoggingUtils.msgTrace("updating state from queued update",LOCATION);
						SESignalBroadcaster.updateState.dispatch();
						StoryEngine.updateStateQueued = false;
					}
					SEHotkeyListener.resumeMovement();
					takeBreak();
				});
				activeMenu = _subMenu = null;
				_menuBG.hide();
				if( !_internalState )
					_hud.doDefaultState();
			} 
			else 
			{
				IUIMenu(menus[activeMenu]).exit.addOnce(loadActiveMenu);
				activeMenu = nextMenu;
				nextMenu = null;
			}
		}
		
		private function onCaptionFinished():void
		{
			if (!_working) 
			{
				working = true;
				unloadCaption();
			}
		}
		
		private function onDialogFinished():void
		{
			if (!_working) 
			{
				working = true;
				unloadDialog();
			}
		}
		
		private function unloadCaption():void
		{
			//trace("unloadCaption");
			IUIMenu(menus[activeMenu]).exit.addOnce( function():void { 
				_notificationDisplay.resume();
				SESignalBroadcaster.captionComplete.dispatch();
				SEHotkeyListener.resumeMovement();
				SEHotkeyListener.resumeUI();
				SESignalBroadcaster.blockToggle.dispatch(false);
				takeBreak();
				if(_currentNodeObject!=null)
				{
					if (_currentNodeObject.objectFlag!=null)
					{
						if(FlagManager.getHasFlagRequirements(_currentNodeObject.flagRequirements))
							if (!FlagManager.getHasFlag(_currentNodeObject.objectFlag))
								FlagManager.addFlag(_currentNodeObject.objectFlag);
					}
					if (_currentNodeObject.calculateAfter)
						LocationNodeManager.getLocationNode(StoryEngine.currentNode).updateState();
					_currentNodeObject=null;
				}
				
			});
			
			IUIMenu(menus[activeMenu]).exitMenu();
			if (tempMenu!=null) 
			{
				activeMenu = tempMenu;
				tempMenu = null;
			} else
				activeMenu = null;
		}
		
		private function unloadDialog():void
		{
			//trace("unloadDialog");
			IUIMenu(menus[activeMenu]).exit.addOnce( function():void { 
				_notificationDisplay.resume();
				SESignalBroadcaster.dialogComplete.dispatch();
				SEHotkeyListener.resumeMovement();
				SEHotkeyListener.resumeUI();
				takeBreak();
				if(_currentNodeObject!=null)
				{
					if (_currentNodeObject.objectFlag!=null)
					{
						if (!FlagManager.getHasFlag(_currentNodeObject.objectFlag))
							FlagManager.addFlag(_currentNodeObject.objectFlag);
					}
					if (_currentNodeObject.calculateAfter)
						LocationNodeManager.getLocationNode(StoryEngine.currentNode).updateState();
					_currentNodeObject=null;
				}
				if(_currentDialogTree!=null)
				{
					if(_currentDialogTree.flag!=null)
					{
						if (!FlagManager.getHasFlag(_currentDialogTree.flag))
							FlagManager.addFlag(_currentDialogTree.flag);
					}
					_currentDialogTree=null;
				}
			});
			
			IUIMenu(menus[activeMenu]).exitMenu();
			if (tempMenu!=null) 
			{
				activeMenu = tempMenu;
				tempMenu = null;
			} else
				activeMenu = null;
		}
		
		private function takeBreak():void 
		{ 
			working = false; 
			//trace( "UI says, 'break time!'"); 
		}
		
		private function onMenuWorkingChange(isWorking:Boolean = false):void
		{
			working = isWorking;
		}
		
		private function onHideHUD(fade:Boolean):void
		{
			_hud.visible=false;
		}
		
		private function onShowHUD(fade:Boolean):void
		{
			_hud.visible=true;
		}
		
		/**
		 * Show/Hide briefcase if not in menu screen or replace items
		 */
		private function onQuickSlotsHandleClick():void
		{
			//keep from doing when holding something perhaps
			if (activeMenu == null)
				_hud.executeBriefCaseAction();
		}
		
		private function onCompassArrowClicked( arrowDirection:String ):void
		{
			compassArrowClicked.dispatch( arrowDirection );
		}
		
		/**
		 * Show/Hide menu or replace items 
		 * 
		 */
		private function onCompassBackButtonClicked():void
		{
			//keep from doing when holding something perhaps
			if ( !_working && !_internalState )
			{
				//if (activeMenu==null)
				//{ LoggingUtils.msgTrace("Not internal, but no active menu.",LOCATION + ".onCompassBackButtonClicked()"); return; }
				//LoggingUtils.msgTrace("Not internal, unloading menu.", LOCATION + ".onCompassBackButtonClicked()");
				working = true;
				unloadActiveMenu();
				
			} else if ( _internalState) {
				//LoggingUtils.msgTrace("Internal State, leaving internal.", LOCATION + ".onCompassBackButtonClicked()");
				if (!_working)
					SESignalBroadcaster.leaveInternalState.dispatch();
				//else
				//LoggingUtils.msgTrace("Wrking and can't go back from internal state.", LOCATION + ".onCompassBackButtonClicked()");
			} 
		}
		
		private function onMenuTransitionFinished(briefCaseAction:String):void
		{
			//
		}
		
		private static function onNodeObjectRollOver( hoverType:String ):void
		{
			if (hoverType == HoverType.INSPECT)
				MouseIconHandler.onInspectableRollOver();
			else if (hoverType == HoverType.INTERACT)
				MouseIconHandler.onGrabableRollOver();
			else if (hoverType == HoverType.GRAB)
				MouseIconHandler.onGrabableRollOver();
			else if (hoverType == HoverType.SPEAK)
				MouseIconHandler.onSpeakableRollOver();
		}
		
		private function onNotificationActivity(active:Boolean):void
		{
			if(active)
			{
				
				var locationNode:LocationNode = LocationNodeManager.getLocationNode(StoryEngine.currentNode);
				_nodeAsset=locationNode.asset;
				var theState:NodeState = locationNode.currentState;
				//LoggingUtils.msgTrace("notificationActivity: " + theState.key);
				if(theState.numNodeObjects>0)
					_nodeObjects=theState.nodeObjects;
				else 
					_nodeObjects = null;
				
				//check if over any node object
				//if so issue onNodeObjectRollOver
				
				_notificationSet.click.add(onNotificationClick);
				_notificationSet.mouseMove.add(onNotificationOver);
				//_notificationSet.mouseOut.add(onNoticationOut);
			}
			else
			{
				_nodeObjects=null;
				_nodeAsset=null;
				_notificationSet.removeAll();
			}
		}
		
		private function checkOverNodeObject():String
		{
			if(_nodeObjects==null || _nodeAsset==null || _activeNote!=null )
				return null;
			var nodeObject:String;
			for ( var k:String in _nodeObjects )
			{
				var nObject:NodeObject = _nodeObjects[k];
				if (nObject.hoverType != HoverType.NONE) {
					var dispObject:DisplayObjectContainer = _nodeAsset[k] as DisplayObjectContainer;
					if(dispObject.hitTestPoint(mouseX,mouseY))
						nodeObject=k;
				}
			}
			return nodeObject;
		}
		
		private function onNotificationOver(e:MouseEvent):void
		{
			var nodeObject:String = checkOverNodeObject();
			if(nodeObject!=null)
			{
				var i:uint;
				var locationNode:LocationNode = LocationNodeManager.getLocationNode(StoryEngine.currentNode);
				var theState:NodeState = locationNode.currentState;
				// if object has flag and a hovertype of inspect, but the object type is interact then use interact hover
				var useObjectType:Boolean = false;
				var theObject:NodeObject = theState.nodeObjects[nodeObject] as NodeObject;
				if(theObject != null)
				{
					if ( theObject.hoverType != theObject.type )
						if ( theObject.flagRequirements.length>0 )
							for(i = 0; i<theObject.flagRequirements.length; i++)
								if ( FlagManager.getHasFlag(String(theObject.flagRequirements[i])) )
									useObjectType = true;
					
					if (useObjectType)
						onNodeObjectRollOver(NodeObject(_nodeObjects[nodeObject]).type);
					else
						onNodeObjectRollOver(NodeObject(_nodeObjects[nodeObject]).hoverType);
				}
			} else
				MouseIconHandler.onItemRollOut();
		}
		
		private function onNotificationClick(e:MouseEvent):void
		{
			var nodeObject:String = checkOverNodeObject();
			if(nodeObject==null)
				return;
			onNodeObjectClick(_nodeObjects[nodeObject] as NodeObject);
			MouseIconHandler.onItemRollOut();
		}
		
		private function onNodeObjectClick( nodeObject:NodeObject ):void
		{
			if(nodeObject == null)
				return;
			var flagRequirements:Array = nodeObject.flagRequirements;
			var i:uint;
			var useObjectType:Boolean;
			var flagReqsMet:Boolean = true;
			if (nodeObject.type == NodeObjectType.CAPTION) {
				_currentNodeObject = nodeObject;
				activeMenu=MENU_CAPTION;
				_captionMenu.setCaption("n"+StoryEngine.currentNode+nodeObject.name);
				loadActiveMenu();
			} else if (nodeObject.type == NodeObjectType.LINK) {
				this._forcedMove.dispatch( nodeObject.linkedNode );
			} else if (nodeObject.type == NodeObjectType.SAVE) {
				triggerSave();
			} else if (nodeObject.type == NodeObjectType.DIALOG) {
				_currentNodeObject = nodeObject;
				activeMenu = MENU_DIALOG;
				_currentDialogTree = Dictionary(LocationNode(LocationNodeManager.getLocationNode(StoryEngine.currentNode)).dialogTrees)[String(nodeObject.dialogKey)];
				_dialogMenu.setDialogTree(_currentDialogTree);
				loadActiveMenu();
			} else if (nodeObject.type == NodeObjectType.MINIGAME) {
				SESignalBroadcaster.miniGameEnter.dispatch( nodeObject.miniGameClass );
			} else if (nodeObject.type == NodeObjectType.GRAB) {
				if ( nodeObject.hoverType == HoverType.INSPECT )
				{
					if ( flagRequirements.length>0 )
						if(!FlagManager.getHasFlagRequirements(flagRequirements))
							flagReqsMet = false;
					
					if (!flagReqsMet) {
						_currentNodeObject = nodeObject;
						activeMenu=MENU_CAPTION;
						_captionMenu.setCaption("n"+StoryEngine.currentNode+nodeObject.name);
						loadActiveMenu();
					}
				}
			} else if (nodeObject.type==NodeObjectType.INTERACT)
			{
				// treat as caption if hovertype is inspect and nodeObject has a flagRequirement
				if ( nodeObject.hoverType == HoverType.INSPECT )
				{
					if ( flagRequirements.length>0 )
						if(!FlagManager.getHasFlagRequirements(flagRequirements))
							flagReqsMet = false;
					
					if (!flagReqsMet) {
						_currentNodeObject = nodeObject;
						activeMenu=MENU_CAPTION;
						_captionMenu.setCaption("n"+StoryEngine.currentNode+nodeObject.name);
						loadActiveMenu();
					}
				}
			} else if (nodeObject.type==NodeObjectType.PICK_UP)
			{
				if ( flagRequirements.length>0 )
					if(!FlagManager.getHasFlagRequirements(flagRequirements))
						flagReqsMet = false;
				
				if(flagReqsMet)
				{
					if (nodeObject.itemKey!=null)
					{
						if (!ItemManager.hasItem(nodeObject.itemKey))
							ItemManager.addItemInventory(nodeObject.itemKey,true);
					}
					if (nodeObject.objectFlag!=null)
					{
						if (!FlagManager.getHasFlag(nodeObject.objectFlag))
							FlagManager.addFlag(nodeObject.objectFlag);
					}
					if (nodeObject.calculateAfter)
						LocationNodeManager.getLocationNode(StoryEngine.currentNode).updateState();
					SESignalBroadcaster.interactiveRollOut.dispatch();
				} else
				{
					_currentNodeObject = nodeObject;
					activeMenu=MENU_CAPTION;
					_captionMenu.setCaption("n"+StoryEngine.currentNode+nodeObject.name);
					loadActiveMenu();
				}
			}
		}
		
		private function onItemUsed( itemKey:String ):void
		{
			var locationNode:LocationNode = LocationNodeManager.getLocationNode(StoryEngine.currentNode);
			_nodeAsset=locationNode.asset;
			var theState:NodeState = locationNode.currentState;
			if(theState.numNodeObjects>0)
				_nodeObjects=theState.nodeObjects;
			var nodeObject:NodeObject = NodeObject(_nodeObjects[itemKey]);
			
			if(nodeObject.objectFlag != "")
			{
				if(!FlagManager.getHasFlag(nodeObject.objectFlag))
					FlagManager.addFlag(nodeObject.objectFlag);
			}
			if(nodeObject.itemUsedNotificationKey != "")
			{
				SESignalBroadcaster.singleNotification.dispatch(Caption(StoryScriptManager.getCaptionInstance(nodeObject.itemUsedNotificationKey)).text);
			}
			if(nodeObject.calculateAfter)
			{
				LocationNodeManager.getLocationNode(StoryEngine.currentNode).updateState();
			}
		}
		
		private function onCaptionTriggered(nodeObject:NodeObject,delay:Boolean):void
		{
			doCaption(nodeObject,null,delay);
		}
		
		private function onSingleCaption(captionKey:String):void
		{
			doCaption(null,captionKey);
		}
		
		private function onDialogTriggered(dialogTree:DialogTree,nodeObject:NodeObject,delay:Boolean):void
		{
			doDialog(dialogTree,nodeObject,delay);
		}
		
		private function onSaveTriggered(saveText:String,yesText:String,noText:String):void
		{
			SESignalBroadcaster.questionOptionSelected.addOnce(saveOptionPressed);
			doQuestion(saveText,yesText,noText);
		}
		
		private function triggerSave():void
		{
			var tempCaption:Caption = Caption(StoryScriptManager.getCaptionInstance("saveGame"));
			var saveText:String = (tempCaption != null)? tempCaption.text : "Save Game?";
			tempCaption = Caption(StoryScriptManager.getCaptionInstance("yes"));
			var yesText:String = (tempCaption != null)? tempCaption.text : "Yes";
			tempCaption = Caption(StoryScriptManager.getCaptionInstance("no"));
			var noText:String = (tempCaption != null)? tempCaption.text : "No";
			SESignalBroadcaster.saveTriggered.dispatch(saveText, yesText, noText);
		}
		
		private function saveOptionPressed(selection:String):void
		{
			if(selection == QuestionOptionSelectionItem.OPTION_A)
			{
				saveGame();
			}
		}
		
		private function onQuestionTriggered(questionText:String, optionA:String, optionB:String):void
		{
			doQuestion(questionText,optionA,optionB);
		}
		
		/**
		 * Creates small question window. listen for optionSelected(String) (QuestionOptionSelectionItem.OPTION_A, B)
		 * @param questionText
		 * @param optionA
		 * @param optionB
		 * 
		 */
		private function doQuestion(questionText:String, optionA:String = "Yes", optionB:String = "No"):void
		{
			working = true;
			questionCaption = new QuestionCaption(questionText,optionA,optionB);
			questionCaption.yesPressed.addOnce(questionOptionAPressed);
			questionCaption.noPressed.addOnce(questionOptionBPressed);
			addChild(questionCaption);
		}
		
		private function questionOptionAPressed():void
		{
			if(questionCaption == null)
				return;
			questionCaption.noPressed.remove(questionOptionBPressed);
			SESignalBroadcaster.questionOptionSelected.dispatch(QuestionOptionSelectionItem.OPTION_A);
			hideQuestion();
		}
		
		private function questionOptionBPressed():void
		{
			if(questionCaption == null)
				return;
			questionCaption.yesPressed.remove(questionOptionAPressed);
			SESignalBroadcaster.questionOptionSelected.dispatch(QuestionOptionSelectionItem.OPTION_B);
			hideQuestion();
		}
		private function hideQuestion():void
		{
			if(questionCaption == null)
				return;
			questionCaption.unloadFinished.addOnce(removeQuestion);
			questionCaption.unload();
		}
		
		private function removeQuestion():void
		{
			if(questionCaption==null)
				return;
			questionCaption.destroy();
			if(contains(questionCaption))
				removeChild(questionCaption);
			questionCaption = null;
			working = false;
		}
		
		private function doDialog(dialogTree:DialogTree,nodeObject:NodeObject,delay:Boolean=false):void
		{
			if(dialogTree==null)
				return;
			
			SESignalBroadcaster.interactiveRollOut.dispatch();
			SESignalBroadcaster.blockToggle.dispatch(true);
			dialogDelay=new Timer(1600);
			dialogDelayed=new NativeSignal(dialogDelay, TimerEvent.TIMER, TimerEvent);
			_currentDialogTree=dialogTree;
			_currentNodeObject=nodeObject;
			
			SEHotkeyListener.haltMovement();
			SEHotkeyListener.haltUI();
			_notificationDisplay.pause();
			
			var dialog:Function = function():void {
				SESignalBroadcaster.blockToggle.dispatch(false);
				dialogDelayed=null;
				dialogDelay=null;
				activeMenu=MENU_DIALOG;
				_dialogMenu.setDialogTree(dialogTree);
				loadActiveMenu();
			};
			
			if(delay)
			{
				dialogDelayed.addOnce(function(e:TimerEvent):void { dialog(); });
				dialogDelay.start();
			} else
				dialog();
			
		}
		
		private function doCaption(nodeObject:NodeObject=null,captionKey:String=null,delay:Boolean=false):void
		{
			var key:String;
			if(nodeObject!=null)
			{
				captionDelay=new Timer(1200);
				captionDelayed=new NativeSignal(captionDelay, TimerEvent.TIMER, TimerEvent);
				_currentNodeObject=nodeObject;
				key="n"+StoryEngine.currentNode+_currentNodeObject.name;	
			} else if(captionKey!=null)
				key=captionKey;
			
			SEHotkeyListener.haltMovement();
			SEHotkeyListener.haltUI();
			_notificationDisplay.pause();
			
			var caption:Function = function():void {
				captionDelayed=null;
				captionDelay=null;
				if(captionKey!=null)
					tempMenu=activeMenu;
				activeMenu=MENU_CAPTION;
				_captionMenu.setCaption(key);
				loadActiveMenu();
			};
			
			if(nodeObject!=null)
			{
				if(delay)
				{
					SESignalBroadcaster.blockToggle.dispatch(true);
					captionDelayed.addOnce(function(e:TimerEvent):void { caption(); });
					captionDelay.start();
				} else
				{
					caption();
				}
			}
			else 
				caption();
		}
		
		private function onBlockToggle(on:Boolean):void
		{
			if(_hud==null)
				return;
			if(on)
			{
				working = true;
				_hud.mouseChildren = _hud.mouseEnabled = false;
			}
			else
			{
				_hud.mouseChildren = _hud.mouseEnabled = true;
				working = false;
			}
		}
		
		private function onInternalEnter():void
		{
			if( !_internalState )
				_internalState=true;
			else
				return;
			_hud.doInternalState();
			SEHotkeyListener.haltMovement();
		}
		
		private function onInternalExit():void
		{
			if( _internalState )
				_internalState=false;
			else
				return;
			_hud.doDefaultState();
			SEHotkeyListener.resumeMovement();
		}
		
		private function onNoteQueued(noteKey:String, useFrameOverlay:Boolean):void
		{
			//LoggingUtils.msgTrace("note: " + noteKey + " queued",LOCATION);
			_notesQueue.push(noteKey);
		}
		
		private function onDoNoteOverlay(noteKey:String, useFrameOverlay:Boolean):void
		{
			//LoggingUtils.msgTrace("activating note: " + noteKey + ", using overlay in [" + ((useFrameOverlay == true) ? "frame]" : "menu]"),LOCATION);
			_notesQueue.unshift(noteKey);
			if(useFrameOverlay)
				_currentOverlayHolder = _frameOverlayHolder;
			else
				_currentOverlayHolder = _menuOverlayHolder;
			_currentOverlayHolder.addChild( OverlayUtil.getOverlay() );
			OverlayUtil.bgAction.addOnce( loadQueuedNote );
			OverlayUtil.fadeIn();
		}
		
		private function loadQueuedNote():void
		{
			if(_notesQueue.length > 0)	
			{
				_activeNote = NoteManager.getNoteImplementor( String(_notesQueue.shift()) );
				//LoggingUtils.msgTrace("Loading note: " + _activeNote.noteDataObject.key, LOCATION);
				_activeNote.noteFinished.addOnce( onNoteFinished );
				_currentOverlayHolder.addChild( _activeNote );
			}
			else
				onNotesQueueEmpty();
		}
		
		private function onNoteFinished():void
		{
			//LoggingUtils.msgTrace("Note Finished: " + _activeNote.noteDataObject.title,LOCATION);
			_activeNote.noteFinished.remove( onNoteFinished );
			IDestroyable(_activeNote).destroy();
			_activeNote.destroyed.addOnce(onNoteDestroyed);
			_activeNote.destroyBase();
		}
		
		private function onNoteDestroyed():void
		{
			//LoggingUtils.msgTrace("Note Destroyed ",LOCATION);
			_currentOverlayHolder.removeChild(_activeNote);
			_activeNote = null;
			loadQueuedNote();
		}
		
		private function onNotesQueueEmpty():void
		{
			//LoggingUtils.msgTrace("Note queue empty",LOCATION);
			OverlayUtil.bgAction.addOnce( removeNoteOverlay );
			OverlayUtil.fadeOut();
		}
		
		private function removeNoteOverlay():void
		{
			_currentOverlayHolder.removeChildAt( 0 );
			_currentOverlayHolder = null;
			SESignalBroadcaster.noteOverlayFinished.dispatch();
			if(activeMenu==null)
			{	
				if(StoryEngine.updateStateQueued)
				{
					updateState();
					StoryEngine.updateStateQueued = false;
				}
			}
		}
		
		private function updateState():void
		{
			//LoggingUtils.msgTrace("update state initiated",LOCATION);
			SESignalBroadcaster.updateState.dispatch();
			_nodeObjects = null;
		}
		
		/**
		 * Update Global Volumef
		 */
		private function onVolumeChange(volume:Number):void
		{
			var vol:Number;
			if (volume > 1)
				vol = volume/100;
			else 
				vol = volume;
			SEConfig.globalVolume = vol;
			SoundUtils.updateSoundObjectsVolume();
		}
		
		private function onMuteChange(mute:Boolean):void
		{
			//LoggingUtils.msgTrace("Mute change ("+mute+").",LOCATION);
			SEConfig.muted = mute;
			SoundUtils.updateSoundObjectsVolume();
		}
		
		private function onKeyItemsActiveChange( nowActive:Boolean ):void
		{
			if ( nowActive ) {
				//hide screen for performance
				_hud.doTempHiddenState();
			} else {
				//show screen
				_hud.doInventoryState();
			}
		}
		
		/**
		 * Change to full screen ( black screen that shows trees when loading )
		 * @param isFullScreeen whether to launch fullscreen
		 */
		private function onFullScreenChange(isFullScreen:Boolean):void
		{
			SEConfig.fullScreen = isFullScreen;
			if (SEConfig.fullScreen)
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				stage.displayState = StageDisplayState.NORMAL;
		}
		
		/**
		 * Unload Game and go to menu
		 */
		private function onQuitToTitle():void
		{
			SESignalBroadcaster.interactiveRollOut;
			SESignalBroadcaster.quitToMain.dispatch();
		}
		
		/**
		 * Unload Game and close the application
		 */
		private function onQuitGame():void
		{
			SESignalBroadcaster.interactiveRollOut;
			SESignalBroadcaster.quitGame.dispatch();	
		}
		
		private function get isTutorial():Boolean
		{
			return SEConfig.isTutorial;
		}
		
		private var saidBit:Boolean;
		private function saveGame():void
		{
			trace( "[UI] save functionality not yet implemented" );
			SESignalBroadcaster.singleNotification.dispatch("Game Saved.");
			if(!saidBit)
			{
				saidBit = true;
				SESignalBroadcaster.singleNotification.dispatch("...");
				SESignalBroadcaster.singleNotification.dispatch("Saving the game doesn't work yet :P");
			}
		}
	}
}