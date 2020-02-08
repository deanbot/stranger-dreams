package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	import com.meekgeek.statemachines.finite.manager.StateManager;
	import com.meekgeek.statemachines.finite.states.State;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.SETutorialBroadcaster;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.scene.data.CompassArrowDirection;
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	import org.osflash.signals.natives.sets.NativeSignalSet;

	public class HUD extends Sprite
	{
	// constants:
		public static const LOCATION:String = "HUD";
		public static const JOURNAL_ICON:String = "journal";
		public static const INVENTORY_ICON:String = "inventory";
		public static const SOUND_BRIEFCASE_SHOW:String = "briefcaseShow";
		public static const SOUND_BRIEFCASE_HIDE:String = "briefcaseHide";
		
	// private properties:
		private var goal_update_window:Sprite;
		private var menu_icon_window:Sprite;
		private var menu_icon_journal:ReversibleMovieClipWrapper;
		private var menu_icon_inventory:ReversibleMovieClipWrapper;
		private var _quick_slots_briefcase:Sprite;
		private var compass:Sprite;
		private var compass_needle:Sprite;
		private var compass_arrow_north:MovieClip;
		private var compass_arrow_east:MovieClip;
		private var compass_arrow_south:MovieClip;
		private var compass_arrow_west:MovieClip;
		private var _compass_back:Sprite;
		private var compass_back_button:ReversibleMovieClipWrapper;
		private var quickSlotTopOver:NativeSignal;
		private var quickSlotTopOut:NativeSignal;
		private var quickSlotTopClick:NativeSignal;
		private var quickSlotBottomOver:NativeSignal;
		private var quickSlotBottomOut:NativeSignal;
		private var quickSlotBottomClick:NativeSignal
		private var _briefcaseAction:Signal;
		private var _clickItemOver:Signal;
		private var _clickItemOut:Signal;
		private var _clickItemClick:Signal;
		private var _menuIconClick:Signal;
		private var _quickslotHandleClick:Signal;
		private var _compassArrowClick:Signal;
		private var _compassNeedleStill:Signal;
		private var _compassBackButtonClick:Signal;
		private var _stateAction:Signal;
		private var _quickSlots:Dictionary;
		private var _itemIcons:Dictionary;
		private var _intent:String;
		private var quickSlotDefaultX:Number;
		private var quickSlotExtendedX:Number;
		private var _itemSets:Dictionary;
		private var _sm:StateManager;
		private var greyJournal:Sprite;
		private var greyInventory:Sprite;
		private var iconSets:Dictionary;
		private var briefcaseHandleSet:Dictionary;
		private var compassBackButtonSet:Dictionary;
		private var menu_icons:Dictionary;
		private var menu_icons_active:Dictionary;
		private var _briefcaseVisible:Boolean = false;
		private var briefcaseExtending:Boolean;
		private var compass_arrows:Dictionary;
		private var compassLabels:Dictionary;
		private var compassArrowSets:Dictionary;
		private var compassIsFront:Boolean = true;
		private var _sounds:Dictionary;
		private var _itemGrid:ReversibleMovieClipGrid; 
		private var _goalUpdater:HUD_goalUpdater;
		[Embed(source="../../libs/UI/sounds/UIsuitcaseDragReverse.mp3")]
		private var BriefcaseHide:Class;
		[Embed(source="../../libs/UI/sounds/UIsuitcaseDrag.mp3")]
		private var BriefcaseShow:Class;
		private var defaultDegrees:Number;
		
	// public properties:
		public var addedToInventory:Signal;
		
	// constructor:
		public function HUD(arrowDegrees:Number) 
		{
			super();
			defaultDegrees = arrowDegrees;
			init();
		}
		
	// public getter/setters:
		
		public function get itemGrid():ReversibleMovieClipGrid
		{
			return _itemGrid;
		}
		
		public function get compass_back():Sprite
		{
			return _compass_back;
		}
		
		public function get quick_slots_briefcase():Sprite
		{
			return _quick_slots_briefcase;
		}
		
		public function get quickSlots():Dictionary
		{
			return _quickSlots;
		}
		
		public function set quickSlots(val:Dictionary):void
		{
			_quickSlots = val;
		}
		
		public function get intent():String 
		{ 
			return _intent; 
		}
		
		public function get journalActive():Boolean 
		{ 
			return menu_icons_active[menu_icon_journal]; 
		}
		
		public function get inventoryActive():Boolean 
		{ 
			return menu_icons_active[menu_icon_inventory]; 
		}
		
		public function get briefcaseVisible():Boolean 
		{ 
			return _briefcaseVisible; 
		}
		
		public function get briefcaseAction():Signal { return _briefcaseAction; }
		
		public function get stateAction():Signal { return _stateAction; }
		
		public function get clickItemOver():Signal { return _clickItemOver; }
		
		public function get clickItemOut():Signal { return _clickItemOut; } 
		
		public function get clickItemClick():Signal { return _clickItemClick; }
		
		public function get menuIconClick():Signal { return _menuIconClick; }
		
		public function get quickslotHandleClick():Signal { return _quickslotHandleClick; }
		
		public function get compassArrowClick():Signal { return _compassArrowClick; }
		
		public function get compassNeedleStill():Signal { return _compassNeedleStill; }
		
		public function get compassBackButtonClick():Signal { return _compassBackButtonClick; }
		
	// public methods:
		public function load():void
		{
			goal_update_window = new HUD_goal_update_window() as Sprite;
			menu_icon_window = new HUD_menu_icon_window() as Sprite;
			menu_icon_journal = new ReversibleMovieClipWrapper( new HUD_menu_icon_journal() as MovieClip, "normal", "noir" );
			menu_icon_inventory = new ReversibleMovieClipWrapper( new HUD_menu_icon_inventory() as MovieClip, "normal", "noir" );
			_quick_slots_briefcase = new HUD_quick_slots_briefcase() as Sprite;
			_quick_slots_briefcase.addChild( _itemGrid=new ReversibleMovieClipGrid(2,1,77,76,13,false,true) );
			_itemGrid.x=34.6;
			_itemGrid.y=13;
			_itemGrid.removedFromHud.add(onItemRemovedFromHud);
			_itemGrid.itemUsed.add(onItemUsed);
			for(var i:int=0; i<itemGrid.numCells; i++)
			{
				var blank:ReversibleMovieClipWrapper = new ReversibleMovieClipWrapper( new MovieClip() );
				blank.name="empty";
				_itemGrid.addItem(blank);
			}
			compass = new HUD_compass() as Sprite;
			compass_needle = new HUD_compass_needle() as Sprite;
			this.compass_needle.rotation = defaultDegrees;
			compass_arrow_north = new HUD_compass_arrow() as MovieClip;
			compass_arrow_east = new HUD_compass_arrow() as MovieClip;
			compass_arrow_south = new HUD_compass_arrow() as MovieClip;
			compass_arrow_west = new HUD_compass_arrow() as MovieClip;
			_compass_back = new HUD_compass_back() as Sprite;
			compass_back_button = new ReversibleMovieClipWrapper( new HUD_compass_back_button() as MovieClip, "normal", "hover" );
			
			initIcon(menu_icon_journal, JOURNAL_ICON);
			initIcon(menu_icon_inventory, INVENTORY_ICON);
			initArrow(compass_arrow_north, CompassArrowDirection.ARROW_N);
			initArrow(compass_arrow_east, CompassArrowDirection.ARROW_E);
			initArrow(compass_arrow_south, CompassArrowDirection.ARROW_S);
			initArrow(compass_arrow_west, CompassArrowDirection.ARROW_W);
			
			goal_update_window.x = 601;
			goal_update_window.y = 0;
			menu_icon_window.x = 638;
			menu_icon_window.y = 83;
			menu_icon_journal.x = menu_icon_journal.y = 13;
			menu_icon_inventory.x = 67;
			menu_icon_inventory.y = 18;
			_quick_slots_briefcase.x = quickSlotDefaultX = 729; //starts out hidden
			quickSlotExtendedX = 638;
			_quick_slots_briefcase.y = 159;
			compass.x = _compass_back.x = 620;
			compass.y = _compass_back.y = 373;
			_compass_back.visible = false;
			_compass_back.alpha = 0;
			compass_back_button.x = 29;
			compass_back_button.y = 44;
			compass_needle.x = 65.5;
			compass_needle.y = 64;
			compass_arrow_north.x = compass_arrow_south.x = 65;
			compass_arrow_north.y = 3;
			compass_arrow_south.y = 125;
			compass_arrow_south.rotation = 180;
			compass_arrow_east.y = compass_arrow_west.y = 64;
			compass_arrow_east.x = 126;
			compass_arrow_east.rotation = 90;
			compass_arrow_west.x = 4;
			compass_arrow_west.rotation = -90;
			_goalUpdater=new HUD_goalUpdater();
			_goalUpdater.x=22;
			_goalUpdater.y=8;
			goal_update_window.addChild(_goalUpdater);
			addChild(goal_update_window);
			addChild(menu_icon_window);
			menu_icon_window.addChild(menu_icon_journal);
			menu_icon_window.addChild(menu_icon_inventory);
			if(SEConfig.isTutorial)
			{
				greyJournal=new GreyJournal() as Sprite;
				greyInventory=new GreyInventory() as Sprite;
				menu_icon_window.addChild(greyJournal);
				menu_icon_window.addChild(greyInventory);
				greyJournal.x=12.1;
				greyJournal.y=10.75;
				greyInventory.x=66.15;
				greyInventory.y=11;
				SETutorialBroadcaster.briefcasePickedUp.addOnce(onBriefcasePickedUp);
				SETutorialBroadcaster.journalPickedUp.addOnce(onJournalPickedUp);
			}
			
			addChild(compass);
			addChild(_compass_back);
			addChild(_quick_slots_briefcase);
			_compass_back.addChild(compass_back_button);
			compass.addChild(compass_needle);
			compass.addChild(compass_arrow_north);
			compass.addChild(compass_arrow_east);
			compass.addChild(compass_arrow_south);
			compass.addChild(compass_arrow_west);
			
			compass_back_button.stop();
			compass_back_button.mouseChildren = false;
			ClipUtils.stopClips(compass_arrow_north, compass_arrow_east, compass_arrow_south, compass_arrow_west);
			
			menu_icon_journal.stopFrame.add(checkMouseOverIcon);
			menu_icon_inventory.stopFrame.add(checkMouseOverIcon);
			
			iconSets = ClipUtils.buttonRollSets( onMenuIconOver, onMenuIconOut, menu_icon_journal, menu_icon_inventory );
			ClipUtils.addNativeSignalCallback( onMenuIconClicked, InteractiveObjectSignalSet(iconSets[menu_icon_journal]).click, InteractiveObjectSignalSet(iconSets[menu_icon_inventory]).click );
			
			toggleCompass( true );
			
			_sounds = new Dictionary(true);
			_sounds[SOUND_BRIEFCASE_HIDE] = new BriefcaseHide() as Sound;
			_sounds[SOUND_BRIEFCASE_SHOW] = new BriefcaseShow() as Sound;
			
			_sm = new StateManager(this);
			_sm.addState( DefaultState.KEY, new DefaultState(), true );
			_sm.addState( JournalState.KEY, new JournalState() );
			_sm.addState( InventoryState.KEY, new InventoryState() );
			_sm.addState( InternalState.KEY, new InternalState() );
			_sm.addState( TemporarilyHiddenState.KEY, new TemporarilyHiddenState() );
			
			stateAction.add(onStateAction);
			
			SESignalBroadcaster.goalAdded.add(onGoalAdded);
			SESignalBroadcaster.goalUpdated.add(onGoalUpdated);
			SESignalBroadcaster.goalComplete.add(onGoalComplete);
		}
		
		public function unload():void
		{ 
			SESignalBroadcaster.goalAdded.remove(onGoalAdded);
			SESignalBroadcaster.goalUpdated.remove(onGoalUpdated);
			SESignalBroadcaster.goalComplete.remove(onGoalComplete);
			
			_sm = null;
			for ( var ke:Object in iconSets ) {
				InteractiveObjectSignalSet(iconSets[ke]).removeAll();
				iconSets[ke] = null;
				delete iconSets[ke];
			}
			iconSets = null;
			if ( compassBackButtonSet != null ) {
				for ( var k:Object in compassBackButtonSet ) {
					InteractiveObjectSignalSet(compassBackButtonSet[k]).removeAll();
					compassBackButtonSet[k] = null;
					delete compassBackButtonSet[k];
				}
				compassBackButtonSet = null;
			}
			compass_back_button.stopFrame.remove(checkMouseOverReversible);
			menu_icon_journal.stopFrame.remove(checkMouseOverIcon);
			menu_icon_inventory.stopFrame.remove(checkMouseOverIcon);
			removeBriefcaseControls();
			//clearArrowControls();
			
			compass.removeChild(compass_needle);
			compass.removeChild(compass_arrow_north);
			compass.removeChild(compass_arrow_east);
			compass.removeChild(compass_arrow_south);
			compass.removeChild(compass_arrow_west);
			_compass_back.removeChild(compass_back_button);
			removeChild(_compass_back);
			removeChild(compass);
			goal_update_window.removeChild(_goalUpdater);
			removeChild(goal_update_window);
			menu_icon_window.removeChild(menu_icon_journal);
			menu_icon_window.removeChild(menu_icon_inventory);
			removeChild(menu_icon_window);
			_quick_slots_briefcase.removeChild(_itemGrid);
			removeChild(_quick_slots_briefcase);
			
			destroyIcon(menu_icon_journal);
			destroyIcon(menu_icon_inventory);
			destroyArrow(compass_arrow_north);
			destroyArrow(compass_arrow_east);
			destroyArrow(compass_arrow_west);
			destroyArrow(compass_arrow_south);
			menu_icons = null;
			menu_icons_active = null;
			compass_arrows = null;
			compassLabels = null;
			
			compass_needle = null;
			compass_arrow_north = null;
			compass_arrow_east = null;
			compass_arrow_west = null;
			compass_arrow_south = null;
			compass_back_button = null;
			_compass_back = null;
			goal_update_window = null;
			_goalUpdater.destroy();
			_goalUpdater=null;
			menu_icon_journal = null;
			menu_icon_inventory = null;
			menu_icon_window = null;
			
			_quick_slots_briefcase = null;	
			
			_itemGrid.removedFromHud.remove(onItemRemovedFromHud);
			_itemGrid.itemUsed.remove(onItemUsed);
			_itemGrid = null;
			
			for ( var key:String in _sounds )
			{
				_sounds[key] = null;
				delete _sounds[key];
			}
			_sounds = null;
		}
		
		public function update():void
		{
			
		}
		
		public function addCompassArrowControls( arrows:Array ):void
		{
			if( compassArrowSets == null )
				compassArrowSets = new Dictionary(true);
			var currentSets:Dictionary = compassArrowSets;
			var inactiveDirections:Array = new Array( 'N','E','S','W');
			var arrowDirection:String;
			var arrowSet:InteractiveObjectSignalSet;
			var i:uint;
			var index:int;
			for( i = 0; i < arrows.length; i++) {
				arrowDirection = arrows[i];
				index = inactiveDirections.indexOf(arrowDirection);
				if( index != -1 )
					inactiveDirections.splice( index, 1);
				arrowSet = new InteractiveObjectSignalSet( MovieClip(compass_arrows[arrowDirection]) );
				arrowSet.mouseOver.add(onArrowOver);
				arrowSet.mouseOut.add(onArrowOut);
				arrowSet.click.add(onCompassArrowClicked);
				compassArrowSets[arrowDirection] = arrowSet;
				if( MovieClip(compass_arrows[arrows[i]]).currentFrameLabel != 'active' )
					MovieClip(compass_arrows[arrows[i]]).gotoAndStop( "active" );
			}

			for( i = 0; i<inactiveDirections.length; i++)
			{
				arrowDirection = String(inactiveDirections[i]);
				if( compassArrowSets[arrowDirection] != null)
				{
					arrowSet = InteractiveObjectSignalSet( compassArrowSets[arrowDirection] );
					if(arrowSet != null)
					{
						arrowSet.removeAll();
						arrowSet = null;
					}
					compassArrowSets[arrowDirection] = null;
					delete compassArrowSets[arrowDirection];
				}
				if( MovieClip(compass_arrows[arrowDirection]).currentFrameLabel != 'inactive' )
					MovieClip(compass_arrows[arrowDirection]).gotoAndStop( 'inactive');
			}
		}
		
		public function clearArrowControls():void
		{
			/*
			for ( var k:Object in compassArrowSets ) {
				//(HUD_compass_arrow(compass_arrows[k]) as MovieClip).gotoAndStop("inactive");
				HUD_compass_arrow(compass_arrows[k]).gotoAndStop( 'inactive');
				var arrowSet:Dictionary = compassArrowSets[k];
				for ( var key:Object in arrowSet ) {
					
					InteractiveObjectSignalSet(arrowSet[key]).removeAll();
					arrowSet[key] = null;
					delete arrowSet[key];
				}
				arrowSet = null;
				compassArrowSets[k] = null;
				delete compassArrowSets[k];
			}
			compassArrowSets = null;
			*/
			if( compassArrowSets == null )
				compassArrowSets = new Dictionary(true);
			var currentSets:Dictionary = compassArrowSets;
			var arrowDirection:String;
			var inactiveDirections:Array = new Array( 'N','E','S','W');
			var arrowSet:InteractiveObjectSignalSet;
			var i:uint;
			for( i = 0; i<inactiveDirections.length; i++)
			{
				arrowDirection = String(inactiveDirections[i]);
				if( compassArrowSets[arrowDirection] != null)
				{
					arrowSet = InteractiveObjectSignalSet( compassArrowSets[arrowDirection] );
					if(arrowSet != null)
					{
						arrowSet.removeAll();
						arrowSet = null;
					}
					compassArrowSets[arrowDirection] = null;
					delete compassArrowSets[arrowDirection];
				}
				if( MovieClip(compass_arrows[arrowDirection]).currentFrameLabel != 'inactive' )
					MovieClip(compass_arrows[arrowDirection]).gotoAndStop( 'inactive');
			}
		}
		
		public function addBriefcaseControls():void
		{
			briefcaseHandleSet = ClipUtils.buttonRollSets( onClickableOver, onClickableOut, Sprite(_quick_slots_briefcase["handle"]) );
			ClipUtils.addNativeSignalCallback( onBriefcaseHandleClicked, InteractiveObjectSignalSet(briefcaseHandleSet[ Sprite(_quick_slots_briefcase["handle"]) ]).click );
		}
		
		public function removeBriefcaseControls():void
		{
			for ( var key:Object in briefcaseHandleSet ) {
				InteractiveObjectSignalSet(briefcaseHandleSet[key]).removeAll();
				briefcaseHandleSet[key] = null;
				delete briefcaseHandleSet[key];
			}
			briefcaseHandleSet = null;
		}
		
		/**
		 * Flips the Compass, adding listeners
		 * 
		 */
		public function toggleCompass( showFront:Boolean = false ):void {
			if ( showFront || !compassIsFront) {
				ClipUtils.makeInvisible(_compass_back);
				ClipUtils.makeVisible(compass);
				compassIsFront = true;
				for ( var k:Object in compassBackButtonSet ) {
					InteractiveObjectSignalSet(compassBackButtonSet[k]).removeAll();
					compassBackButtonSet[k] = null;
					delete compassBackButtonSet[k];
				}
				compassBackButtonSet = null;
				compass_back_button.stopFrame.remove(checkMouseOverReversible);
				compass_back_button.gotoAndStop(compass_back_button.startLabel);
				// get correct arrows
				//addCompassArrowControls( CompassArrowDirection.ARROW_N, CompassArrowDirection.ARROW_E, CompassArrowDirection.Arrow_W );
				
			} else {
				ClipUtils.makeInvisible(compass);
				ClipUtils.makeVisible(_compass_back);
				compassIsFront = false;
				compassBackButtonSet = ClipUtils.buttonRollSets( onReversableOver, onReversableOut, compass_back_button );
				ClipUtils.addNativeSignalCallback( onCompassBackButtonClick, InteractiveObjectSignalSet(compassBackButtonSet[compass_back_button]).click );
				compass_back_button.stopFrame.add(checkMouseOverReversible);
				checkMouseOverReversible(compass_back_button);
			}
		}
		
		public function setCompassNeedleDegrees( degrees:Number ):void
		{
			var needleTweenDuration:Number = 3;
			//LoggingUtils.msgTrace("set compass degrees (current rotation: "+this.compass_needle.rotation+",rotationEquiv: "+getRotationEquivalent(degrees)+")",LOCATION);
			if(this.compass_needle.rotation!=getRotationEquivalent(degrees))
				TweenLite.to( this.compass_needle, needleTweenDuration, { rotation: degrees, ease:Elastic.easeOut } );
		}
		
		private function getRotationEquivalent(rotation:Number):Number
		{
			var equiv:Number = rotation;
			var keepGoing:Boolean=true;
			while(keepGoing)
			{
				if(equiv > 180)
					equiv=equiv-360;
				else if(equiv < -180)
					equiv=equiv+360;
				if(Math.abs(equiv)<=180)
					keepGoing=false;
			}
			return equiv;
		}
		
		public function hideBriefcase( time:Number = .5 ):void
		{
			if (!briefcaseExtending) {
				briefcaseExtending = true;
				TweenLite.to(_quick_slots_briefcase, time, {x:quickSlotDefaultX, onComplete:setBriefcaseRetracted });
			}
		}
		
		public function executeBriefCaseAction():void
		{
			if ( !this.briefcaseVisible )
				this.showBriefcase();
			else
				this.hideBriefcase()
		}
		
		public function showBriefcase():void
		{
			if (!briefcaseExtending) {
				briefcaseExtending = true;
				TweenLite.to(_quick_slots_briefcase, .5, {x:quickSlotExtendedX, onComplete:setBriefcaseExtended});
			}
		}
		
		public function checkRollOver(local:Boolean = false):void
		{
			var state:String = _sm.getState();
			var found:Boolean = false;
			
			if( state != TemporarilyHiddenState.KEY )
			{
				
				// can internal do menu icons?
				for ( var k:Object in menu_icons ) {
					if ( !found ) {
						
							if( ReversibleMovieClipWrapper(k).hitTestPoint(stage.mouseX,stage.mouseY) ) {
								this.clickItemOver.dispatch();
								found = true;
							}
						
					}
				}
				
				if( state != JournalState.KEY)
				{
					if ( !found )
						found = checkMouseOverItem();
				}
				
				if( state == DefaultState.KEY )
				{
					if ( !found ) {
						for ( var key:Object in compass_arrows ) {
							if ( MovieClip(compass_arrows[key]).currentFrameLabel == "active" ) {
								if ( MovieClip(compass_arrows[key]).hitTestPoint(mouseX,mouseY) ) {
									this.clickItemOver.dispatch();
									found = true;
								}
							}
						}
					}
					
					if ( !found ) {
						if ( Sprite(_quick_slots_briefcase["handle"]).hitTestPoint(mouseX,mouseY) ) {
							this.clickItemOver.dispatch();
							found = true;
						}
					}
				} else
				{
					if ( !found ) {
						if ( compass_back_button.hitTestPoint(mouseX,mouseY) ) {
							this.clickItemOver.dispatch();
							found = true;
						}
					}
				}
				
			}

			if ( !found )
				this.clickItemOut.dispatch();
		}
		
		/* Quickslots */
		public function initQuickSlotItem(icon:ReversibleMovieClipWrapper, key:String):void
		{
			if(_quickSlots[key]==null)
			{
				_quickSlots[key]=icon;
				_itemIcons[icon]=key;
				var set:InteractiveObjectSignalSet = new InteractiveObjectSignalSet(icon);
				set.mouseOver.add( quickslotItemOver );
				set.mouseOut.add( quickslotItemOut);
				_itemSets[key]=set;
			} else
			{
				trace("quickslot already seems to have this item");
			}
		}
		
		private function quickslotItemOver(e:MouseEvent):void
		{
			if(_itemGrid.permit)
				SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT)
		}
		
		private function quickslotItemOut(e:MouseEvent):void
		{
			if(_itemGrid.permit)
				SESignalBroadcaster.interactiveRollOut.dispatch();
		}
		
		public function checkMouseOverItem():Boolean
		{
			var icon:ReversibleMovieClipWrapper;
			var found:Boolean = false;
			for(var i:int = 0; i<this.itemGrid.numCells; i++)
			{
				icon = this.itemGrid.getItemAtPosition(i,0);
				if(icon.hitTestPoint(this.mouseX,this.mouseY))
				{
					found = true;
					if(this.itemGrid.mouseEnabled)
						SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
					else
						SESignalBroadcaster.interactiveRollOut.dispatch();
				}
			}
			return found;
		}
		/* END: QuickSlots */
		
		public function doJournalState():void { if ( _sm.getState() != JournalState.KEY ) doState(JournalState.KEY); }
		
		public function doInventoryState():void { if ( _sm.getState() != InventoryState.KEY ) doState(InventoryState.KEY); }
		
		public function doTempHiddenState():void { if ( _sm.getState() != TemporarilyHiddenState.KEY ) doState(TemporarilyHiddenState.KEY); }
		
		public function doInternalState():void { if ( _sm.getState() != InternalState.KEY ) doState(InternalState.KEY); }
		
		public function doDefaultState():void { if ( _sm.getState() != DefaultState.KEY ) doState(DefaultState.KEY); }

	// private methods:
		/**
		 * Preload HUD Sounds
		 * Create Signals
		 * Create Statemanager
		 */
		private function init():void
		{
			_clickItemOver = new Signal();
			_clickItemOut = new Signal();
			_clickItemClick = new Signal();
			_menuIconClick = new Signal(String);
			_quickslotHandleClick = new Signal();
			_compassArrowClick = new Signal();
			_compassNeedleStill = new Signal();
			_compassBackButtonClick = new Signal();
			_briefcaseAction = new Signal(Boolean);
			_stateAction = new Signal(String, Boolean);
			_quickSlots = new Dictionary(true);
			_itemIcons = new Dictionary(true);
			addedToInventory = new Signal( ReversibleMovieClipWrapper, String );
			_itemSets=new Dictionary(true);
		}	
	
		private function onArrowOver(e:MouseEvent):void 
		{ 
			var label:String = compassLabels[e.target];
			if( compassArrowSets[ label ] !=null )
				clickItemOver.dispatch(); 
		}
		
		private function onArrowOut(e:MouseEvent):void 
		{ 
			var label:String = compassLabels[e.target];
			if( compassArrowSets[ label ] !=null )
				clickItemOut.dispatch(); 
		}
		
		private function onClickableOver(e:MouseEvent):void 
		{ 
			clickItemOver.dispatch(); 
		}
		
		private function onClickableOut(e:MouseEvent):void 
		{ 
			clickItemOut.dispatch(); 
		}
		
		private function onCompassArrowClicked(e:MouseEvent):void { 
			var label:String = compassLabels[e.target];
			if( compassArrowSets[ label ] !=null  )
			{
				compassArrowClick.dispatch(label); 
				clickItemClick.dispatch();
			}
		}
		
		private function onCompassBackButtonClick(e:MouseEvent):void { 
			SESignalBroadcaster.interactiveRollOut.dispatch();
			compassBackButtonClick.dispatch(); 
			clickItemClick.dispatch();
		}
		
		private function onMenuIconClicked(e:MouseEvent):void 
		{ 
			menuIconClick.dispatch(menu_icons[e.target.parent]);
		}
		
		private function onBriefcaseHandleClicked(e:MouseEvent):void { 
			clickItemClick.dispatch();
			quickslotHandleClick.dispatch();
			if ( briefcaseVisible )
				SoundUtils.playUISound( _sounds[SOUND_BRIEFCASE_HIDE], function():void {}, "briefcase" );
			else
				SoundUtils.playUISound( _sounds[SOUND_BRIEFCASE_SHOW], function():void {}, "briefcase" );
			
		}
		
		private function onMenuIconOver(e:MouseEvent):void 
		{
			var target:ReversibleMovieClipWrapper = (e.target.parent as ReversibleMovieClipWrapper);
			if( !menu_icons_active[target] )
				if ( target.reversing )
					target.play();
				else if ( target.currentFrameLabel != "noir")
					target.play();
			
			clickItemOver.dispatch();
		}
		
		private function onMenuIconOut(e:MouseEvent):void 
		{
			var target:ReversibleMovieClipWrapper = ( e.target.parent as ReversibleMovieClipWrapper );
			if( !menu_icons_active[target] )
				if ( !target.reversing && target.currentFrameLabel != "normal" )
					target.reverse();
			
			clickItemOut.dispatch();
		}
		
		private function onReversableOver(e:MouseEvent):void
		{
			var target:ReversibleMovieClipWrapper = (e.target as ReversibleMovieClipWrapper);
			if ( target.reversing )
				target.play();
			else if ( target.currentFrameLabel != target.endLabel)
				target.play();
			
			clickItemOver.dispatch();
		}
		
		private function onReversableOut(e:MouseEvent):void
		{
			var target:ReversibleMovieClipWrapper = (e.target as ReversibleMovieClipWrapper);
			if ( !target.reversing && target.currentFrameLabel != target.startLabel )
				target.reverse();
			
			clickItemOut.dispatch();
		}
		
		private function checkMouseOverReversible(reversible:ReversibleMovieClipWrapper):void
		{
			if( ! reversible.hitTestPoint(mouseX,mouseY) )
				reversible.reverse();
		}
		
		private function initIcon(icon:ReversibleMovieClipWrapper, menu:String):void
		{
			if ( menu_icons == null )
				menu_icons = new Dictionary(true);
			if ( menu_icons_active == null )
				menu_icons_active = new Dictionary(true);
			menu_icons[icon] = menu;
			menu_icons_active[icon] = false;
			icon.stop();
		}
		
		private function destroyIcon(icon:ReversibleMovieClipWrapper):void
		{
			delete menu_icons[icon];
			delete menu_icons_active[icon];
		}

		private function initArrow(arrow:MovieClip, direction:String):void
		{
			if (compass_arrows == null)
				compass_arrows = new Dictionary(true);
			if ( compassLabels == null )
				compassLabels = new Dictionary(true);
			compass_arrows[direction] = arrow;
			compassLabels[arrow] = direction;
		}
		
		private function destroyArrow(arrow:MovieClip):void
		{
			delete compass_arrows[arrow];
		}

		private function doState(key:String):void {
			_intent = key;
			_sm.setState(key); 
		}
		
		private function onStateAction(stateKey:String, isIntro:Boolean):void
		{
			//trace ( "doing: " + stateKey + " state, intro: " + isIntro);
			if ( isIntro ) {
				_intent = null;
				switch (stateKey)
				{
					case DefaultState.KEY:
						this.itemGrid.permit=true;
						setJournalActive(false);
						setInventoryActive(false);
						break;
					case JournalState.KEY:
						this.itemGrid.permit=false;
						setJournalActive();
						setInventoryActive(false);
						break;
					case InventoryState.KEY:
						this.itemGrid.permit=false;
						setInventoryActive();
						setJournalActive(false);
						break;
					case InternalState.KEY:
						this.itemGrid.permit=false;
					case TemporarilyHiddenState.KEY:
						this.itemGrid.permit=false;
						break;
				}
			} else {
				switch (stateKey)
				{
					case DefaultState.KEY:	
						break;
					case JournalState.KEY:
						setJournalActive(false);
						break;
					case InventoryState.KEY:
						setInventoryActive(false);
						break;
					case InternalState.KEY:
						break;
					case TemporarilyHiddenState.KEY:
						break;				
				}
			}
		}
		
		private function setInventoryActive(isActive:Boolean = true):void { 
			menu_icons_active[menu_icon_inventory] = isActive; 
			if (isActive) {
				if (menu_icon_inventory.currentFrameLabel != "noir")
					menu_icon_inventory.gotoAndStop("noir");
			} else
				checkMouseOverIcon(menu_icon_inventory);
		}
		
		private function setJournalActive(isActive:Boolean = true):void { 
			menu_icons_active[menu_icon_journal] = isActive; 
			if (isActive) {
				if (menu_icon_journal.currentFrameLabel != "noir")
					menu_icon_journal.gotoAndStop("noir");
			} else
				checkMouseOverIcon(menu_icon_journal);
		}
		
		private function checkMouseOverIcon(icon:ReversibleMovieClipWrapper):void
		{
			if( !menu_icons_active[icon]) 
				if( ! icon.hitTestPoint(mouseX,mouseY) )
					icon.reverse();
		}
		
		private function setBriefcaseExtended():void { 
			briefcaseExtending = false; 
			_briefcaseVisible = true; 
			_briefcaseAction.dispatch(true); 
		}
		
		private function setBriefcaseRetracted():void { 
			briefcaseExtending = false; 
			_briefcaseVisible = false; 
			_briefcaseAction.dispatch(false);
		}
		
		/* QuickSlots */
		private function onItemRemovedFromHud(icon:ReversibleMovieClipWrapper, toInventory:Boolean):void
		{
			if(_quickSlots==null)
				return;
			if(_itemIcons==null)
				return;
			if(_itemSets==null)
				return;
			
			var key:String = _itemIcons[icon];
			
			InteractiveObjectSignalSet(_itemSets[key]).removeAll();
			_itemSets[key]=null;
			delete _itemSets[key];
			
			_itemIcons[icon]=null;
			delete _itemIcons[icon];
			delete _quickSlots[key];
			if(toInventory)
				addedToInventory.dispatch(icon,key);
		}
		
		private function onItemUsed(icon:ReversibleMovieClipWrapper, acceptsItemKey:String, nodeObjectKey:String):void
		{
			if(_quickSlots==null)
				return;
			if(_itemIcons==null)
				return;
			if(_itemSets==null)
				return;
			
			var key:String = _itemIcons[icon];
			if(key == acceptsItemKey)
				SESignalBroadcaster.itemUsed.dispatch(nodeObjectKey);
		}
		
		/* END: QuickSlots */

		/* Goal Updater */	
		private function onGoalAdded(title:String,type:String,notify:Boolean):void
		{
			_goalUpdater.addGoal(title,type);
		}
		
		private function onGoalUpdated(oldTitle:String,title:String,type:String,notify:Boolean):void
		{
			_goalUpdater.updateGoal(oldTitle,title);
		}
		
		private function onGoalComplete(title:String,notify:Boolean):void
		{
			_goalUpdater.removeGoal(title);
		}
		/* END: Goal Updater */
		
		/* Ben's Apartment Tutorial */
		private function onJournalPickedUp():void
		{
			menu_icon_window.removeChild(greyJournal);
		}
		
		private function onBriefcasePickedUp():void
		{
			menu_icon_window.removeChild(greyInventory);
		}
		/* END: Ben's Apartment Tutorial */
	}
}

import com.meekgeek.statemachines.finite.states.State;

import net.deanverleger.utils.LoggingUtils;
import net.strangerdreams.app.gui.HUD;

class DefaultState extends State {
	
	public static const KEY:String = "default";
	private var hudRef:HUD;
	
	public function DefaultState():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		//LoggingUtils.msgTrace("Default State Intro", HUD.LOCATION);
		hudRef = HUD(this.context);
		hudRef.stateAction.dispatch( KEY, true );
		if(	hudRef.briefcaseVisible ) {
			hudRef.hideBriefcase();
			hudRef.briefcaseAction.addOnce(onBriefcaseFinished);
		} else
			this.signalIntroComplete();
		hudRef.toggleCompass(true);
	}
	
	override public function action():void
	{
		hudRef.addBriefcaseControls();
	}
	
	override public function doOutro():void
	{
		//LoggingUtils.msgTrace("Default State Outro", HUD.LOCATION);
		hudRef.stateAction.dispatch( KEY, false );
		if ( hudRef.intent == InventoryState.KEY || hudRef.intent == JournalState.KEY || hudRef.intent == InternalState.KEY )
			hudRef.toggleCompass();
		hudRef = null;
		this.signalOutroComplete();
	}
	
	private function onBriefcaseFinished(isExtended:Boolean):void { this.signalIntroComplete(); }
}

class JournalState extends State {
	
	public static const KEY:String = "journal";
	private var hudRef:HUD;
	
	public function JournalState():void
	{
		super();
	}
	
	override public function doIntro():void
	{	
		//LoggingUtils.msgTrace("Journal State Intro", HUD.LOCATION);
		hudRef = HUD(this.context);
		hudRef.removeBriefcaseControls();
		hudRef.stateAction.dispatch( KEY, true );
		if ( !hudRef.briefcaseVisible ) {
			hudRef.showBriefcase();
			hudRef.briefcaseAction.addOnce(onBriefcaseFinished);
		} else
			this.signalIntroComplete();
	}
	
	override public function action():void
	{
		
	}
	
	override public function doOutro():void
	{
		//LoggingUtils.msgTrace("Journal State Intro", HUD.LOCATION);
		hudRef.stateAction.dispatch( KEY, false );
		if ( hudRef.intent == InventoryState.KEY || hudRef.intent == TemporarilyHiddenState.KEY )
		{
			hudRef = null;
			this.signalOutroComplete();
		}
		else {
			hudRef.hideBriefcase();
			hudRef.briefcaseAction.addOnce(onBriefcaseFinished);
		}
	}
	
	private function onBriefcaseFinished(isExtended:Boolean):void {
		if ( isExtended )
			this.signalIntroComplete(); 
		else 
			this.signalOutroComplete();
	}
}

class InternalState extends State {
	
	public static const KEY:String = "internal";
	private var hudRef:HUD;
	
	public function InternalState():void
	{
		super();
	}
	
	override public function doIntro():void
	{	
		//LoggingUtils.msgTrace("Internal State Intro", HUD.LOCATION);
		hudRef = HUD(this.context);
		hudRef.stateAction.dispatch( KEY, true );
		if(	hudRef.briefcaseVisible ) {
			hudRef.hideBriefcase();
			hudRef.briefcaseAction.addOnce(onBriefcaseFinished);
		} else
			this.signalIntroComplete();
	}
	
	override public function action():void
	{
		hudRef.addBriefcaseControls();
	}
	
	override public function doOutro():void
	{
		//LoggingUtils.msgTrace("Internal State Outro", HUD.LOCATION);
		hudRef.stateAction.dispatch( KEY, false );
		hudRef = null;
		this.signalOutroComplete();		
	}
	
	private function onBriefcaseFinished(isExtended:Boolean):void {
		//if ( isExtended )
			this.signalIntroComplete(); 
		//else 
			//this.signalOutroComplete();
	}
}

class InventoryState extends State {
	
	public static const KEY:String = "inventory";
	private var hudRef:HUD;
	
	public function InventoryState():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		//LoggingUtils.msgTrace("Inventory State Intro", HUD.LOCATION);
		hudRef = HUD(this.context);
		hudRef.removeBriefcaseControls();
		hudRef.stateAction.dispatch( KEY, true );
		if(	!hudRef.briefcaseVisible ) {
			hudRef.showBriefcase();
			hudRef.briefcaseAction.addOnce(onBriefcaseFinished);
		} else
			this.signalIntroComplete();
	}
	
	override public function action():void
	{
		
	}
	
	override public function doOutro():void
	{
		//LoggingUtils.msgTrace("Inventory State Outro", HUD.LOCATION);
		hudRef.stateAction.dispatch( KEY, false );
		if ( hudRef.intent == JournalState.KEY || hudRef.intent == TemporarilyHiddenState.KEY )
		{
			hudRef = null;
			this.signalOutroComplete();
		} else {
			hudRef.hideBriefcase();
			hudRef.briefcaseAction.addOnce(onBriefcaseFinished);
		}
	}
	
	private function onBriefcaseFinished(isExtended:Boolean):void {
		if ( isExtended )
			this.signalIntroComplete(); 
		else 
			this.signalOutroComplete();
	}
}

class TemporarilyHiddenState extends State {
	
	public static const KEY:String = "tempHidden";
	private var hudRef:HUD;
	
	public function TemporarilyHiddenState():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		//LoggingUtils.msgTrace("Temp. Hidden State Intro", HUD.LOCATION);
		hudRef = HUD(this.context);
		hudRef.stateAction.dispatch( KEY, true );
		hudRef.alpha = 0;
		hudRef.visible = false;
		this.signalIntroComplete(); 
	}
	
	override public function action():void
	{
		hudRef.removeBriefcaseControls();
	}
	
	override public function doOutro():void
	{
		//LoggingUtils.msgTrace("Temp. Hidden State Outro", HUD.LOCATION);
		hudRef.stateAction.dispatch( KEY, false );
		hudRef.alpha = 1;
		hudRef.visible = true;
		hudRef = null;
		this.signalOutroComplete();
	}
}