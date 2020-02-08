package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	import com.greensock.data.TweenLiteVars;
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.graphics.shapes.SolidFadingBG;
	import net.deanverleger.utils.LoggingUtils;
	import net.deanverleger.utils.TweenUtils;
	import net.strangerdreams.app.keyboard.SEHotkeyListener;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class Journal_Menu extends Sprite implements IUIMenu
	{
	// constants:
		public static const LOCATION:String = "Journal_Menu";
		public static const SOUND_JOURNAL_INTRO:String="journalIntro";
		public static const SOUND_JOURNAL_OUTRO:String="journalOutro"
		public static const SOUND_JOURNAL_PAGE:String = "journalPage";
		public static const PAGE_GOALS:String = "goals";
		public static const PAGE_NOTES:String = "notes";
		public static const PAGE_MAP:String = "map";
		public static const PAGE_OPTIONS:String = "options";
		private static const TRANSITION_TIME:Number = .3;
		//private static const BG_MOUSE_X_OFFSET:Number = 15;
		private static const TAB_RIGHT_X:Number = 73;
		private static const TITLE_INDEX:Number = 6;
		private static const TAB_MOVE_SPEED:Number = .5;
		private static const NORMAL_TAB_INDEX:Number = 1;
		
		// private properties:
		private var _sm:StateManager;
		private var _currentPage:String;
		private var behind_tabs:Bitmap;
		private var tab_goals:Sprite;
		private var tab_notes:Sprite;
		private var tab_map:Sprite;
		private var tab_options:Sprite;
		private var bg:Bitmap;
		private var tabHitRect:Sprite;
		private var polaroid:Bitmap;
		private var title_goals:Bitmap;
		private var title_notes:Bitmap;
		private var title_map:Bitmap;
		private var title_options:Bitmap;
		private var currentTabIndex:Number = 5;
		private var _container:Sprite;
		private var _freshOpen:Boolean;
		private var _sounds:Dictionary;
		private var tabLeftX:Dictionary;
		private var tabActiveX:Dictionary;
		private var tabs:Dictionary;
		private var tabNames:Dictionary;
		private var titles:Dictionary;
		private var containsTitle:Boolean;
		private var tabGoalsMouseSet:InteractiveObjectSignalSet;
		private var tabNotesMouseSet:InteractiveObjectSignalSet;
		private var tabMapMouseSet:InteractiveObjectSignalSet;
		private var tabOptionsMouseSet:InteractiveObjectSignalSet;
		private var mouseTabSets:Dictionary;
		private var _working:Boolean = false;
		private var stateFunctions:Dictionary;
		private var nextKey:String;
		private var _stateLoaded:Signal;
		private var _clickItemOver:Signal;
		private var _clickItemOut:Signal;
		private var _soundAction:Signal;
		private var _transitionAction:Signal;
		private var _workingChange:Signal;
		private var _quitTitleAction:Signal;
		private var _muteChange:Signal;
		private var _volumeChange:Signal;
		private var _fullScreeenChange:Signal;
		private var _quitAction:Signal;
		private var _open:Signal;
		private var _exit:Signal;
		private var _hud:HUD;
		private var _ui:UI;
		
		[Embed(source="../../libs/UI/sounds/UIjournalOpen.mp3")]
		private var JournalIntro:Class;
		[Embed(source="../../libs/UI/sounds/UIjournalClose.mp3")]
		private var JournalOutro:Class;
		[Embed(source="../../libs/UI/sounds/UIjournalTabTurn.mp3")]
		private var JournalPage:Class
		
		// public properties:
		// constructor:
		public function Journal_Menu(hud:HUD,ui:UI)
		{
			_hud=hud;
			_ui=ui;
			super();
			init();
		}
		
		// public getter/setters:

		public function get ui():UI
		{
			return _ui;
		}

		public function set working(value:Boolean):void
		{
			//LoggingUtils.msgTrace("working: "+value, LOCATION);
			_working = value;
			if(value == true)
				SEHotkeyListener.halt();
			else
				SEHotkeyListener.resume();
		}
		
		public function get sounds():Dictionary
		{
			return _sounds;
		}
		
		public function get container():Sprite { 
			return _container; 
		}
		
		public function get hud():HUD
		{
			return _hud;
		}
		
		public function bitmapTweenContainerOut():void 
		{
			//trace ( "Entering Hide. Alpha: " + container.alpha );
			TweenUtils.bitmapAlphaTween( _container, this, 1, 0, TRANSITION_TIME, transitionAction.dispatch );
		}
		
		public function playSound( sound:Sound, name:String ):void
		{
			//trace( "Journal Menu says, \"playing sound [" + sound + "].\"" );
			SoundUtils.playUISound( sound, onSoundFinished, name);
		}

		public function get freshOpen():Boolean { return _freshOpen; }

		public function get stateLoaded():Signal { return _stateLoaded; }
		
		public function get clickItemOver():Signal { return _clickItemOver; }
		
		public function get clickItemOut():Signal { return _clickItemOut; } 
		
		public function get soundAction():Signal { return _soundAction; }
		
		public function get transitionAction():Signal { return _transitionAction; }
		
		public function get workingChange():Signal { return _workingChange; }
		
		public function get quitTitleAction():Signal { return _quitTitleAction; }
		
		public function get muteChange():Signal { return _muteChange; }
		
		public function get volumeChange():Signal { return _volumeChange; }
		
		public function get fullScreeenChange():Signal { return _fullScreeenChange; }
		
		public function get quitAction():Signal { return _quitAction; }
		
		public function get open():Signal { return _open; }
		
		public function get exit():Signal { return _exit; }
		
		public function get working():Boolean
		{
			return _working;
		}
		
		public function get currentPage():String
		{
			return _currentPage;
		}
		
		// public methods:
		/**
		 * create and add display objects, set up private event listeners, create states and init statemanager 
		 */
		public function openMenu(startPage:String = GoalsState.KEY):void
		{
			if(startPage == null)
				startPage = GoalsState.KEY; 
			//trace( "Journal Menu says, \"opening menu [" + startPage + "].\"");
			_currentPage = startPage;
			_freshOpen = true;
			working = true;
			containsTitle = false;
			
			_sounds = new Dictionary(true);
			_sounds[SOUND_JOURNAL_INTRO]=new JournalIntro() as Sound;
			_sounds[SOUND_JOURNAL_OUTRO]=new JournalOutro() as Sound;
			_sounds[SOUND_JOURNAL_PAGE]=new JournalPage() as Sound;
			
			addChild( _container = new Sprite() );
			_container.addChild( behind_tabs = new Bitmap( new Jou_behind_tabs(11, 214) ) );
			_container.addChild( bg = new Bitmap( new Jou_bg(1,1) ) );
			_container.addChild( polaroid = new Bitmap( new Jou_polaroid(1,1) ) );
			_container.addChild( tabHitRect = new Jou_tab_hit_rect() as Sprite );
			
			tab_goals = new Jou_tab_goals() as Sprite;
			tab_map = new Jou_tab_map() as Sprite;
			tab_notes = new Jou_tab_notes() as Sprite;
			tab_options = new Jou_tab_options() as Sprite;
			title_goals = new Bitmap( new Jou_title_goals(1,1) );
			title_notes = new Bitmap ( new Jou_title_notes(1,1) );
			title_map = new Bitmap ( new Jou_title_map(1,1) );
			title_options = new Bitmap ( new Jou_title_options(1,1) );
			
			behind_tabs.x = 102;
			behind_tabs.y = 161;
			bg.x = 91;
			bg.y = 43;
			polaroid.x = 22;
			polaroid.y = 15;
			tabHitRect.x = 113;
			tabHitRect.y = 174;
			tabHitRect.alpha = 0;
			tab_goals.y = 190;
			tab_map.y = 242;
			tab_notes.y = 292;
			tab_options.y = 341;
			title_goals.x = title_notes.x = title_map.x = title_options.x = 172;
			title_goals.y = title_notes.y = title_map.y = title_options.y = 60.55;
			
			this._container.alpha = 0;
			
			tabs = new Dictionary(true);
			tabNames = new Dictionary(true);
			tabLeftX = new Dictionary(true);
			tabActiveX = new Dictionary(true);
			titles = new Dictionary(true);
			stateFunctions = new Dictionary(true);
			mouseTabSets = new Dictionary(true);
			
			initTab(tab_goals, 45, 55, PAGE_GOALS);
			initTab(tab_map, 49, 55, PAGE_MAP);
			initTab(tab_notes, 42, 50, PAGE_NOTES);
			initTab(tab_options, 25, 40, PAGE_OPTIONS);
			//updateTabOrder();
			//setTabLocation();
			initTitle(title_goals, PAGE_GOALS);
			initTitle(title_map, PAGE_MAP);
			initTitle(title_notes, PAGE_NOTES);
			initTitle(title_options, PAGE_OPTIONS);
			//updateTitle();
			
			_sm = new StateManager(this);
			_sm.addState( GoalsState.KEY, new GoalsState(), (startPage == GoalsState.KEY) ? true : false );
			_sm.addState( MapState.KEY, new MapState(), (startPage == MapState.KEY) ? true : false );
			_sm.addState( NotesState.KEY, new NotesState(), (startPage == NotesState.KEY) ? true : false );
			_sm.addState( OptionsState.KEY, new OptionsState(), (startPage == OptionsState.KEY) ? true : false );
			_sm.addState( OutState.KEY, new OutState() );
			stateLoaded.add( onStateLoaded );
			
			initStateFunction( GoalsState.KEY, PAGE_GOALS );
			initStateFunction( MapState.KEY, PAGE_MAP );
			initStateFunction( NotesState.KEY, PAGE_NOTES );
			initStateFunction( OptionsState.KEY, PAGE_OPTIONS );
			
		}
		
		public function openMenuPage(pageName:String):void
		{
			if ( !working ) {
				if ( pageName != tabs[_currentPage] ) {
					working = true;
					stateFunctions[ pageName ]();
				}
			}
		}
		
		public function exitMenu():void
		{
			//trace( "Journal Menu says, \"exiting menu.\"");
			if(_sm == null)
				return;
			_sm.setState( OutState.KEY );
		}
		
		public function update():void
		{
			
		}
		
		// private methods:
		private function init():void {
			_clickItemOver = new Signal();
			_clickItemOut = new Signal();
			_stateLoaded = new Signal( String );
			_soundAction = new Signal();
			_transitionAction = new Signal();
			_workingChange = new Signal( Boolean );
			_quitTitleAction = new Signal();
			_muteChange = new Signal( Boolean );
			_volumeChange = new Signal( Number );
			_fullScreeenChange = new Signal( Boolean );
			_quitAction = new Signal();
			_open = new Signal();
			_exit = new Signal();
		}

		private function unload():void
		{
			stateLoaded.remove(onStateLoaded);
			
			containsTitle = false;

			_sm.destroy();
			_sm = null;
				
			DisplayObjectUtil.removeAllChildren( _container, false, true );
			removeChild( _container );
				
			deInitTitle(PAGE_GOALS);
			deInitTitle(PAGE_MAP);
			deInitTitle(PAGE_NOTES);
			deInitTitle(PAGE_OPTIONS);
			behind_tabs = polaroid = bg = title_goals = title_map = title_notes = title_options = null;
			deInitTab(tab_goals, PAGE_GOALS);
			deInitTab(tab_map, PAGE_MAP);
			deInitTab(tab_notes, PAGE_NOTES);
			deInitTab(tab_options, PAGE_OPTIONS);
			tab_goals = tab_notes = tab_map = tab_options = _container = null;
			tabGoalsMouseSet = tabMapMouseSet = tabNotesMouseSet = tabOptionsMouseSet = null;
			deInitStateFunction(PAGE_GOALS);
			deInitStateFunction(PAGE_MAP);
			deInitStateFunction(PAGE_NOTES);
			deInitStateFunction(PAGE_OPTIONS);
			mouseTabSets = tabs = tabNames = tabLeftX = tabActiveX = titles = stateFunctions = null;
			_hud=null;
			
			//trace( "Journal Menu says, \"Finished cleaning up!\"");
		}
		
		/* Begin Tabs and Titles */
		private function initTab(tab:Sprite, leftX:Number, rightX:Number, pageName:String):void
		{
			tabs[pageName] = tab;
			tabNames[tab] = pageName;
			tabLeftX[tab] = leftX;
			tabActiveX[tab] = rightX;
		}
		
		private function deInitTab(tab:Sprite, pageName:String):void
		{
			delete tabs[pageName];
			delete tabNames[tab];
			delete tabLeftX[tab];
			delete tabActiveX[tab];
		}
		
		private function get currentTab():Sprite
		{
			return tabs[_currentPage] as Sprite;
		}
		
		private function updateTabOrder():void
		{
			for( var tab:String in tabs ) {
				if ( tab != _currentPage )
					_container.addChildAt( tabs[tab], NORMAL_TAB_INDEX );
			}
			_container.addChildAt( currentTab, currentTabIndex );
		}
		
		private function setTabLocation():void
		{
			//trace ( "Setting Tab Locations. Current tab: " +  currentTab );
			for( var tab:String in tabs ) {
				if ( tab != _currentPage ) {
					TweenLite.killTweensOf( tabs[tab] );
					tabs[tab].x = TAB_RIGHT_X;
					//trace(tab);
				} else {
					TweenLite.killTweensOf( tabs[tab] );
					tabs[tab].x = tabActiveX[tabs[tab]];
					//trace(tabActiveX[tabs[tab]]);
				}
			}
		}
		
		private function initTitle(title:Bitmap, pageName:String):void
		{
			titles[pageName] = title;
		}
		
		private function deInitTitle(pageName:String):void
		{
			delete titles[pageName];
		}
		
		private function updateTitle():void
		{
			if ( containsTitle )
				this._container.removeChildAt( TITLE_INDEX );
			_container.addChildAt( titles[_currentPage], TITLE_INDEX );
			containsTitle = true;
		}
		
		private function updateJournalPage():void
		{
			//_currentPage = nextKey;
			//nextKey = null;
			updateTabOrder();
			setTabLocation();
			updateTitle();
			working = false;
		}
		/* End Tabs and Titles */
		
		/* Begin tab button functionality */
		private function addTabControls():void
		{
			// lets just assume if one is null they all are
			if ( mouseTabSets[PAGE_GOALS] == null ) {
				mouseTabSets[PAGE_GOALS] = tabGoalsMouseSet = new InteractiveObjectSignalSet( tabs[PAGE_GOALS] );
				mouseTabSets[PAGE_MAP] = tabMapMouseSet = new InteractiveObjectSignalSet( tabs[PAGE_MAP] );
				mouseTabSets[PAGE_NOTES] = tabNotesMouseSet = new InteractiveObjectSignalSet( tabs[PAGE_NOTES] );
				mouseTabSets[PAGE_OPTIONS] = tabOptionsMouseSet = new InteractiveObjectSignalSet( tabs[PAGE_OPTIONS] );
			}
			for ( var set:String in mouseTabSets ) {
				InteractiveObjectSignalSet( mouseTabSets[set] ).mouseOver.add(extendInactiveTab);
				InteractiveObjectSignalSet( mouseTabSets[set] ).mouseOut.add(retractInactiveTab);
				InteractiveObjectSignalSet( mouseTabSets[set] ).click.add(onInactiveTabClick);
			}
			_working = false;
		}
		
		private function removeTabControls():void
		{
			// lets just assume if one is null they all are
			if ( mouseTabSets[PAGE_GOALS] == null ) {
				for ( var set:String in mouseTabSets ) {
					InteractiveObjectSignalSet( mouseTabSets[set] ).removeAll();
					delete mouseTabSets[set];
				}
			}
		}
		
		/* back*/
		private function extendInactiveTab(e:MouseEvent):void
		{
			if ( e.target != tabs[_currentPage] ) {
				TweenLite.to( e.target, TAB_MOVE_SPEED, new TweenLiteVars().prop("x", tabLeftX[e.target]) );
				clickItemOver.dispatch();
			}
		}
		
		private function retractInactiveTab(e:MouseEvent):void
		{
			if ( e.target != tabs[_currentPage] ) {
				//trace ( "inactive tab, " + e.target + ", retract" );
				TweenLite.killTweensOf( e.target );
				TweenLite.to( e.target, TAB_MOVE_SPEED, new TweenLiteVars().prop("x", TAB_RIGHT_X) );
				clickItemOut.dispatch();
			}
		}
		
		private function onInactiveTabClick(e:MouseEvent):void
		{
			if ( !working ) {
				if ( e.target != tabs[_currentPage] ) {
					working = true; // silly mulitple click bug
					//trace ( "inactive tab, " + e.target + ", click" );
					TweenLite.killTweensOf( e.target );
					stateFunctions[ tabNames[e.target] ]();
				}
			}
		}
		/* End tab button functionality */
		
		private function onSoundFinished( name:String ):void
		{
			//soundFinished = null;
			soundAction.dispatch();
		}
		
		/* Start State Actions */
		private function initStateFunction( key:String, identifier:String ):void {
			stateFunctions[identifier] = function():void { 
				if(key==MapState.KEY)
					if(!SEConfig.hasMap)
					{
						SESignalBroadcaster.captionComplete.addOnce(function():void { _working=false });
						SESignalBroadcaster.singleCaption.dispatch("noMap");
					} else 
						_sm.setState(key); 
				else
					_sm.setState(key); 
			};
		}
		
		private function deInitStateFunction(pageName:String):void
		{
			delete stateFunctions[pageName];
		}

		
		private function onStateLoaded( stateKey:String ):void
		{
			//trace ( "Journal Menu says, \"State [ " + stateKey + "] is ready.\"" );
			
			if (stateKey != OutState.KEY) 
			{
				if (_freshOpen)
					transitionAction.addOnce(onFreshOpen);
				
				_currentPage = stateKey;
				updateJournalPage();
				
				//trace ( "Journal Menu says, \"Revealing the menu [" + _sm.getState() + "] now.\"" );
				this.transitionAction.addOnce( addTabControls );	
				TweenUtils.bitmapAlphaTween( _container, this, 0, 1, TRANSITION_TIME, transitionAction.dispatch );
			} else 
			{
				soundAction.addOnce( this.unload );
				soundAction.addOnce( exit.dispatch );
				playSound( sounds[SOUND_JOURNAL_OUTRO] as Sound, SOUND_JOURNAL_OUTRO );	
			}
		}
		
		private function onFreshOpen():void
		{
			//trace( "Journal Menu says, \"There I've opened.\"" );
			open.dispatch();
			_freshOpen = false;
		}
	}
}

import com.meekgeek.statemachines.finite.states.State;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.text.TextFormat;
import flash.utils.Dictionary;

import net.deanverleger.gui.InteractiveSurfaceScroller;
import net.deanverleger.gui.ShapeSprite;
import net.deanverleger.utils.AssetUtils;
import net.deanverleger.utils.ClipUtils;
import net.deanverleger.utils.DictionaryUtils;
import net.strangerdreams.app.gui.GoalIconClassName;
import net.strangerdreams.app.gui.Journal_Menu;
import net.strangerdreams.app.gui.MouseIconHandler;
import net.strangerdreams.engine.SEConfig;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.goal.GoalManager;
import net.strangerdreams.engine.goal.GoalType;
import net.strangerdreams.engine.goal.data.Goal;
import net.strangerdreams.engine.location.LocationNode;
import net.strangerdreams.engine.note.NoteManager;
import net.strangerdreams.engine.note.data.Note;

import org.casalib.util.DisplayObjectUtil;
import org.osflash.signals.natives.NativeSignal;
import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class GoalsState extends State {
	
	public static const KEY:String = "goals";
	private static const GOAL_BEGIN_Y:Number = 180;
	private static const GOAL_BETWEEN_Y_OFFSET:Number = 15;
	private var jouRef:Journal_Menu;
	private var stateContainer:Sprite;
	private var goalTextFull:GoalTextFull;
	private var goals:Array;
	private var goalDescriptions:Dictionary;
	private var goalDisplays:Dictionary;
	private var goalDisplaysText:Dictionary;
	private var goalInteractionSets:Dictionary;
	private var goalTextFullAdded:NativeSignal;
	
	public function GoalsState():void
	{
		
	}
	
	override public function doIntro():void
	{
		jouRef = Journal_Menu(this.context);
		jouRef.workingChange.dispatch(true);
		
		jouRef.container.addChild( stateContainer = new Sprite() );	
		goalDescriptions=new Dictionary(true);
		goalDisplays=new Dictionary(true);
		goalDisplaysText=new Dictionary(true);
		goalInteractionSets=new Dictionary(true);
		
		goalTextFull=new GoalTextFull();
		goalTextFullAdded = new NativeSignal(goalTextFull, Event.ADDED_TO_STAGE, Event);
		goalTextFullAdded.addOnce( onGoalTextFullAdded );
		stateContainer.addChild( goalTextFull );
		goalTextFull.x = 370;
		goalTextFull.y = 77;
		goalTextFull.tf.text="";
	}

	override public function doOutro():void
	{
		/* remove controls */
		/* end remove Controls */
		
		jouRef.transitionAction.addOnce( unload );
		jouRef.bitmapTweenContainerOut();
	}
	
	private function onGoalTextFullAdded(e:Event):void
	{
		jouRef.soundAction.addOnce( onSoundPlayed );
		if (jouRef.freshOpen)
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_INTRO] as Sound, Journal_Menu.SOUND_JOURNAL_INTRO );
		else
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_PAGE] as Sound, Journal_Menu.SOUND_JOURNAL_PAGE );
	}
	
	private function unload():void
	{	
		DisplayObjectUtil.removeAllChildren( stateContainer, false, true );
		jouRef.container.removeChild( stateContainer );
		goals = null;
		stateContainer = null;
		goalTextFull = null;
		for(var i:String in goalInteractionSets)
		{
			InteractiveObjectSignalSet(goalInteractionSets[i]).removeAll();
		}
		DictionaryUtils.emptyDictionary(goalDisplays);
		DictionaryUtils.emptyDictionary(goalDisplaysText);
		DictionaryUtils.emptyDictionary(goalInteractionSets);
		goalDisplays=goalDisplaysText=goalInteractionSets=null;
		this.signalOutroComplete();
	}
	
	private function onSoundPlayed():void
	{
		//print out active goals in order
		goals=GoalManager.orderderedGoals;		
		var goal:Goal;
		var display:GoalDisplay;
		var set:InteractiveObjectSignalSet;
		var y:Number = GOAL_BEGIN_Y;
		for(var i:uint=0; i<goals.length; i++)
		{
			goal=Goal(goals[i]);
			stateContainer.addChild( display=new GoalDisplay(goal.title,goal.type) );
			set = new InteractiveObjectSignalSet(display.goalText);
			goalInteractionSets[goal.title] = set;
			goalDescriptions[goal.title]=goal.description;
			goalDisplaysText[display.goalText]=goal.title; // actually just use the goalDisplay's goalText
			goalDisplays[goal.title]=display;
			
			set.mouseOver.add(onGoalTitleOver);
			set.mouseOut.add(onGoalTitleOut);
			set.click.add(onGoalTitleClick);
			display.x = 145;
			display.y = y;
			y += display.height + GOAL_BETWEEN_Y_OFFSET;
		}
		
		jouRef.stateLoaded.dispatch( KEY );
		jouRef.transitionAction.addOnce( this.signalIntroComplete );
	}
	
	private function onGoalTitleOver(e:MouseEvent):void
	{
		var goalDisplay:GoalDisplay = Sprite(GoalText(e.currentTarget).parent).parent as GoalDisplay;
		if(!goalDisplay.active)
			goalDisplay.underline();
		MouseIconHandler.onInteractiveRollOver();
	}
	
	private function onGoalTitleOut(e:MouseEvent):void
	{
		var goalDisplay:GoalDisplay = Sprite(GoalText(e.currentTarget).parent).parent as GoalDisplay;
		MouseIconHandler.onItemRollOut();
		if(!goalDisplay.active)
			goalDisplay.underline(false);
	}
	
	private function onGoalTitleClick(e:MouseEvent):void
	{
		var goalDisplay:GoalDisplay = Sprite(GoalText(e.currentTarget).parent).parent as GoalDisplay;
		var title:String = String(goalDisplaysText[GoalText(e.currentTarget)]);
		var text:String = goalDescriptions[ title ];
		goalTextFull.tf.text = text;
		var gD:GoalDisplay;
		for (var k:String in goalDisplays)
		{
			gD=GoalDisplay(goalDisplays[k]);
			if(goalDisplay==gD)
			{
				gD.underline( true );
				gD.active = true;
			}
			else
			{
				if(gD.active)
				{
					gD.underline( false );
					gD.active = false;
				}
			}
		}
	}
}

class MapState extends State {
	
	public static const KEY:String = "map";
	private var jouRef:Journal_Menu;
	private var stateContainer:Sprite;
	//decoration
	private var mapDeco:Bitmap;
	private var smallMap:Bitmap;
	
	private var bigMapOverlay:Jou_map_magnified_screen;
	private var rectMask:Shape;
	private var mapScrubber:Sprite;
	private var miniMapScrollBounds:Sprite;
	//private var mapScreen:Sprite;
	private var surfaceScroller:InteractiveSurfaceScroller;
	
	private var smallArrow:Sprite;
	private var largeArrow:Sprite;
	private var miniMapObjects:MiniMapObjects;
	private var bigMap:MabelMapFull;
	
	override public function doIntro():void
	{
		jouRef = Journal_Menu(this.context);
		jouRef.workingChange.dispatch(true);
		
		jouRef.container.addChild( stateContainer = new Sprite() );
		stateContainer.addChild( mapDeco = new Bitmap( new Jou_map_deco(1,1) ) );
		stateContainer.addChild( smallMap = new Bitmap( new Jou_map_mabel_town_map(1,1) ) );
		
		
		/*
		mapScreen = new MapScreen() as Sprite;
		mapScreen.x = 128.5;
		mapScreen.y = 164;
		trace(mapScreen.width); // 191
		trace(mapScreen.height); // 128 */
		
		rectMask = new Shape();
		rectMask.graphics.beginFill(0xFF0000, 1);
		//rectMask.graphics.drawRect(0, 0, mapScreen.width-1.5, mapScreen.height-1);
		rectMask.graphics.drawRect(0, 0, 189.5, 127);
		rectMask.graphics.endFill();
		rectMask.x = 128.5;
		rectMask.y = 164;
		stateContainer.addChild( rectMask );
		bigMap = new MabelMapFull();
		bigMap.mask = rectMask;
		bigMap.x = 115;
		bigMap.y = 156;
		
		/* Set up map objects */
		var currentMapCircleLocations:Dictionary = SEConfig.activeMapCircleLocations;
		var currentArrowDegrees:Number = SEConfig.currentArrowDegrees;
		var currentArrowLocation:String = SEConfig.currentMapArrowLocation;
		
		miniMapObjects = new MiniMapObjects();
		ClipUtils.hideChildren(miniMapObjects.arrows);
		ClipUtils.hideChildren(miniMapObjects.circles);
		ClipUtils.hideChildren(bigMap.arrows);
		ClipUtils.hideChildren(bigMap.circles);
		smallArrow = Sprite(miniMapObjects.playerArrow);
		largeArrow = Sprite(bigMap.playerArrow);
		smallArrow.rotation = largeArrow.rotation = currentArrowDegrees;
		
		var temp:Sprite; 
		if(currentArrowLocation != null)
		{
			if( Sprite(Sprite(miniMapObjects.arrows)[currentArrowLocation]) !=null )
			{
				temp = Sprite(Sprite(miniMapObjects.arrows)[currentArrowLocation]);
				smallArrow.x = temp.x;
				smallArrow.y = temp.y;
			}
			if( Sprite(Sprite(miniMapObjects.arrows)[currentArrowLocation]) !=null )
			{
				temp = Sprite(Sprite(bigMap.arrows)[currentArrowLocation]);
				largeArrow.x = temp.x;
				largeArrow.y = temp.y;
			}
		}
		
		if(currentMapCircleLocations != null)
		{
			for(var k:String in currentMapCircleLocations)
			{
				if( Sprite(Sprite(miniMapObjects.circles)[ currentMapCircleLocations[k] ]) !=null )
				{
					temp = Sprite(Sprite(miniMapObjects.circles)[ currentMapCircleLocations[k] ]);
					temp.visible = true;
					temp.alpha = 1;
				}
				
				if( Sprite(Sprite(bigMap.circles)[ currentMapCircleLocations[k] ]) !=null )
				{
					temp = Sprite(Sprite(bigMap.circles)[ currentMapCircleLocations[k] ]);
					temp.visible = true;
					temp.alpha = 1;
				}
				
			}
		}
		
		stateContainer.addChild(miniMapObjects);
		/*end set up map objects*/

		stateContainer.addChild( mapScrubber = new JouMapSmalRect() as Sprite );
		stateContainer.addChild( bigMap );
		stateContainer.addChild( bigMapOverlay = new Jou_map_magnified_screen() );
		miniMapScrollBounds = new JouMiniMapScrollBounds() as Sprite;
		
		mapDeco.x = 114;
		mapDeco.y = 116;
		smallMap.x = 357;
		smallMap.y = 90;

		bigMapOverlay.x = 121;
		bigMapOverlay.y = 155;
		mapScrubber.x = 372;
		mapScrubber.y = 103;
		miniMapScrollBounds.x = miniMapObjects.x = 372;
		miniMapScrollBounds.y = miniMapObjects.y = 103;
		
		surfaceScroller = new InteractiveSurfaceScroller();
		surfaceScroller.mouseOut.add(onMouseOut);
		surfaceScroller.mouseOver.add(onMouseOver);
		surfaceScroller.mouseDown.add(onMouseDown);
		surfaceScroller.setData(Sprite(bigMap), rectMask, miniMapScrollBounds, mapScrubber, 14, 10, jouRef.stage);
		surfaceScroller.activate();
		
		jouRef.soundAction.addOnce( onSoundPlayed );
		if (jouRef.freshOpen)
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_INTRO] as Sound, Journal_Menu.SOUND_JOURNAL_INTRO );
		else
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_PAGE] as Sound, Journal_Menu.SOUND_JOURNAL_INTRO );
	}	
	
	override public function action():void
	{
		/* add controls */
		/* end add controls */
	}
	
	override public function doOutro():void
	{
		/* remove controls */
		/* end remove Controls */
		
		jouRef.transitionAction.addOnce( unload );
		jouRef.bitmapTweenContainerOut();
	}
	
	private function unload():void
	{
		DisplayObjectUtil.removeAllChildren( stateContainer, false, true );
		jouRef.container.removeChild( stateContainer );
		surfaceScroller.destroy();
		surfaceScroller = null;
		stateContainer = null;
		smallMap = null;
		bigMap = null;
		mapDeco = null;
		bigMapOverlay = null;
		mapScrubber = null;
		miniMapScrollBounds = null;
		miniMapObjects = null;
		jouRef = null;
		this.signalOutroComplete();
	}
	
	private function onSoundPlayed():void
	{
		jouRef.transitionAction.addOnce( this.signalIntroComplete );
		jouRef.stateLoaded.dispatch( KEY );
	}
	
	private function onMouseOver():void
	{
		MouseIconHandler.onInteractiveRollOver();
		
	}
	
	private var stageRect:ShapeSprite;
	private function onMouseDown():void
	{
		if(stageRect==null)
		{
			stageRect = new ShapeSprite(760,512);
			stateContainer.addChildAt( stageRect, stateContainer.getChildIndex( mapScrubber ) );
		}
	}
	
	private function onMouseOut():void
	{
		//check if over hud items
		//jouRef.hud.checkRollOver();
		MouseIconHandler.onItemRollOut();
		if(stageRect !=null)
		{
			if( stateContainer.contains( stageRect ) )
				stateContainer.removeChild( stageRect );
			stageRect = null;
		}
	}
}

class NotesState extends State {
	
	// constants:
	public static const LOCATION:String = "notes state";
	public static const KEY:String = "notes";
	private static const BEGIN_Y:Number = 180;
	private static const BETWEEN_Y_OFFSET:Number = 15;
	private var jouRef:Journal_Menu;
	private var stateContainer:Sprite;
	private var notes:Array;
	private var noteKeys:Dictionary;
	private var noteTitles:Dictionary;
	private var noteInteractionSets:Dictionary;
	private var noteDisplays:Dictionary;
	private var activeDisplay:NoteDisplay;
	
	public function NotesState():void
	{
		
	}
	
	override public function doIntro():void
	{
		jouRef = Journal_Menu(this.context);
		jouRef.workingChange.dispatch(true);
		
		jouRef.container.addChild( stateContainer = new Sprite() );
		
		jouRef.soundAction.addOnce( onSoundPlayed );
		if (jouRef.freshOpen)
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_INTRO] as Sound, Journal_Menu.SOUND_JOURNAL_INTRO );
		else
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_PAGE] as Sound, Journal_Menu.SOUND_JOURNAL_PAGE );
	}
	
	override public function action():void
	{
		/* add controls */
		/* end add controls */
	}
	
	override public function doOutro():void
	{
		/* remove controls */
		/* end remove Controls */
		
		
		
		jouRef.transitionAction.addOnce( unload );
		jouRef.bitmapTweenContainerOut();
	}
	
	private function unload():void
	{
		DisplayObjectUtil.removeAllChildren( stateContainer, false, true );
		jouRef.container.removeChild( stateContainer );
		notes = null;
		stateContainer = null;
		for(var i:String in noteInteractionSets)
		{
			InteractiveObjectSignalSet(noteInteractionSets[i]).removeAll();
		}
		DictionaryUtils.emptyDictionary(noteDisplays);
		DictionaryUtils.emptyDictionary(noteKeys);
		DictionaryUtils.emptyDictionary(noteTitles);
		DictionaryUtils.emptyDictionary(noteInteractionSets);
		noteDisplays=noteKeys=noteTitles = noteInteractionSets=null;
		
		this.signalOutroComplete();
	}
	
	private function onSoundPlayed():void
	{
		//print out active goals in order
		noteInteractionSets = new Dictionary(true);
		notes=NoteManager.orderderedNotes;		
		noteDisplays = new Dictionary(true);
		noteKeys = new Dictionary(true);
		noteTitles = new Dictionary(true);
		var note:Note;
		var display:NoteDisplay;
		var set:InteractiveObjectSignalSet;
		var y:Number = BEGIN_Y;
		for(var i:uint=0; i<notes.length; i++)
		{
			note =Note(notes[i]);
			display=new NoteDisplay(note.title,note.read);
			stateContainer.addChild( display );
			set = new InteractiveObjectSignalSet(display.noteText);
			noteInteractionSets[note.title] = set;
			noteKeys[note.title]=note.key; 
			noteTitles[display]=note.title;
			noteDisplays[note.title]=display;
			
			set.mouseOver.add(onTitleOver);
			set.mouseOut.add(onTitleOut);
			set.click.add(onTitleClick);
			display.x = 145;
			display.y = y;
			y += display.height + BETWEEN_Y_OFFSET;
		}
		
		jouRef.transitionAction.addOnce( this.signalIntroComplete );
		jouRef.stateLoaded.dispatch( KEY );
	}
	
	private function onTitleOver(e:MouseEvent):void
	{
		var display:NoteDisplay = Sprite(GoalText(e.currentTarget).parent).parent as NoteDisplay;
		if(!display.active)
			display.underline();
		MouseIconHandler.onInteractiveRollOver();
	}
	
	private function onTitleOut(e:MouseEvent):void
	{
		var display:NoteDisplay = Sprite(GoalText(e.currentTarget).parent).parent as NoteDisplay;
		MouseIconHandler.onItemRollOut();
		if(!display.active)
			display.underline(false);
	}
	
	private function onTitleClick(e:MouseEvent):void
	{
		var display:NoteDisplay = Sprite(GoalText(e.currentTarget).parent).parent as NoteDisplay;
		activeDisplay = display;
		var title:String = String(noteTitles[display]);
		var key:String = String(noteKeys[title]);
		var nD:NoteDisplay;
		for (var k:String in noteDisplays)
		{
			nD=NoteDisplay(noteDisplays[k]);
			if(display==nD)
			{
				nD.underline( true );
				nD.active = true;
			}
			else
			{
				if(nD.active)
				{
					nD.underline( false );
					nD.active = false;
				}
			}
		}
		SESignalBroadcaster.noteOverlayFinished.addOnce( onNoteFinished );
		SESignalBroadcaster.doNoteOverlay.dispatch(key, false);
	}
	
	private function onNoteFinished():void
	{
		activeDisplay.active = false;
		if(!stateContainer.hitTestPoint(stateContainer.mouseX, stateContainer.mouseY))
			activeDisplay.underline(false);
		activeDisplay = null;
	}
}

class OptionsState extends State {
	
	public static const KEY:String = "options";
	private var jouRef:Journal_Menu;
	private var stateContainer:Sprite;
	private var titleScreenButton:MovieClip;
	private var configButton:MovieClip;
	private var helpButton:MovieClip;
	private var quitGameButton:MovieClip;
	private var optionsButtonsHitBg:Sprite;
	//title screen
	private var titleBG:Bitmap;
	private var titleYesButton:MovieClip;
	private var titleNoButton:MovieClip;
	//config
	private var configBG:Bitmap;
	private var muteButton:MovieClip;
	private var volumeSlider:Sprite;
	private var fullScreenOnButton:MovieClip;
	private var fullScreenOffButton:MovieClip;
	//help
	private var helpBG:Bitmap;
	//quit game
	private var quitBG:Bitmap;
	private var quitYesButton:MovieClip;
	private var quitNoButton:MovieClip;
	
	private var buttonMouseSets:Dictionary;
	private var sliderSet:InteractiveObjectSignalSet;
	
	private static const TITLE_SCREEN:String = "title screen";
	private static const CONFIG:String = "config";
	private static const HELP:String = "help";
	private static const QUIT_GAME:String = "quit game";
	
	private static const FULLSCREEN_ON:String = "on";
	private static const FULLSCREEN_OFF:String = "off";
	
	public function OptionsState():void
	{ 
		
	}
	
	override public function doIntro():void
	{
		jouRef = Journal_Menu(this.context);
		jouRef.workingChange.dispatch(true);
		
		jouRef.container.addChild( stateContainer = new Sprite() );
		stateContainer.addChild( titleScreenButton = new Jou_options_title_screen_button() as MovieClip );
		// left page
		stateContainer.addChild( configButton = new Jou_options_config_button() as MovieClip );
		stateContainer.addChild( helpButton = new Jou_options_help_button() as MovieClip );
		stateContainer.addChild( quitGameButton = new Jou_options_quit_game_button() as MovieClip );
		stateContainer.addChild( optionsButtonsHitBg = new Jou_options_hitBg() as Sprite );
		//title screen
		stateContainer.addChild( titleBG = new Bitmap( new Jou_options_title_right_bg(1,1) ) );
		stateContainer.addChild( titleYesButton = new Jou_yes_button() as MovieClip );
		stateContainer.addChild( titleNoButton = new Jou_no_button() as MovieClip );
		//config
		stateContainer.addChild( configBG = new Bitmap( new Jou_options_config_right_bg(1,1) ) );
		stateContainer.addChild( muteButton = new Jou_options_mute_button() as MovieClip );
		stateContainer.addChild( fullScreenOnButton = new Jou_options_on_button() as MovieClip );
		stateContainer.addChild( fullScreenOffButton = new Jou_options_off_button() as MovieClip );
		stateContainer.addChild( volumeSlider = new Jou_options_volume_slider() as Sprite );
		//help
		stateContainer.addChild( helpBG = new Bitmap( new Jou_options_help_right_bg(1,1) ) );
		//quit game
		stateContainer.addChild( quitBG = new Bitmap( new Jou_options_quit_right_bg(1,1) ) );
		stateContainer.addChild( quitYesButton = new Jou_yes_button() as MovieClip );
		stateContainer.addChild( quitNoButton = new Jou_no_button() as MovieClip );
		
		//left page
		titleScreenButton.x = 112;
		titleScreenButton.y = 134;
		configButton.x = 128;
		configButton.y = 183;
		helpButton.x = 147;
		helpButton.y = 236;
		quitGameButton.x = 116;
		quitGameButton.y = 280;
		optionsButtonsHitBg.x = 103.7;
		optionsButtonsHitBg.y = 134.7;
		optionsButtonsHitBg.alpha = 0;
		//title screen
		titleBG.x = 378;
		titleBG.y = 118.45;
		titleYesButton.x = 372.45;
		titleYesButton.y = 239;
		titleNoButton.x = 468.4;
		titleNoButton.y = 240.5;
		ClipUtils.makeInvisible( titleBG, titleYesButton, titleNoButton );
		//config
		configBG.x = 345;
		configBG.y = 79;
		muteButton.x = 535.7;
		muteButton.y = 165.4;
		if ( SEConfig.muted )
			muteButton.gotoAndStop( 2 );
		else
			muteButton.gotoAndStop( 1 );
		volumeSlider.x = 406;
		volumeSlider.y = 171;
		Sprite(volumeSlider["slider_handle"]).x = SEConfig.globalVolume * 122;
		Sprite(volumeSlider["slider_filled"]).x = SEConfig.globalVolume * 122 - 122;
		fullScreenOnButton.x = 347;
		fullScreenOnButton.y = 270;
		fullScreenOffButton.x = 454;
		fullScreenOffButton.y = 268.45
		ClipUtils.makeInvisible( configBG, muteButton, volumeSlider, fullScreenOnButton, fullScreenOffButton );
		//help
		helpBG.x = 358;
		helpBG.y = 76;
		ClipUtils.makeInvisible( helpBG );
		//quit game
		quitBG.x = 365;
		quitBG.y = 79;
		quitYesButton.x = 372.45;
		quitYesButton.y = 180;
		quitNoButton.x = 458.40;
		quitNoButton.y = 180.5;
		ClipUtils.makeInvisible( quitBG, quitYesButton, quitNoButton );
		
		ClipUtils.stopClips( titleScreenButton, configButton, helpButton, quitGameButton, titleYesButton, titleNoButton, fullScreenOnButton, fullScreenOffButton, quitYesButton, quitNoButton );
		
		initButton(titleScreenButton, TITLE_SCREEN);
		initButton(configButton, CONFIG);
		initButton(helpButton, HELP);
		initButton(quitGameButton, QUIT_GAME);
		initButton(fullScreenOnButton, FULLSCREEN_ON);
		initButton(fullScreenOffButton, FULLSCREEN_OFF);
		
		currentConfigMenu = ""
		
		jouRef.soundAction.addOnce( onSoundPlayed );
		if (jouRef.freshOpen)
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_INTRO] as Sound, Journal_Menu.SOUND_JOURNAL_INTRO );
		else
			jouRef.playSound( jouRef.sounds[Journal_Menu.SOUND_JOURNAL_PAGE] as Sound, Journal_Menu.SOUND_JOURNAL_PAGE );
	}
	
	override public function action():void
	{
		/* add controls */
		buttonMouseSets = ClipUtils.buttonRollSets( onButtonRollover, onButtonRollout, titleScreenButton, configButton, helpButton, quitGameButton, titleYesButton, titleNoButton, muteButton, fullScreenOnButton, fullScreenOffButton, quitYesButton, quitNoButton );
		ClipUtils.addNativeSignalCallback( onButtonClick, InteractiveObjectSignalSet(buttonMouseSets[titleScreenButton]).click, InteractiveObjectSignalSet(buttonMouseSets[configButton]).click, InteractiveObjectSignalSet(buttonMouseSets[helpButton]).click, InteractiveObjectSignalSet(buttonMouseSets[quitGameButton]).click );
		
		InteractiveObjectSignalSet(buttonMouseSets[titleYesButton]).click.add(titleButtonClick);
		InteractiveObjectSignalSet(buttonMouseSets[titleNoButton]).click.add(titleButtonClick);		
		sliderSet = new InteractiveObjectSignalSet( Sprite(volumeSlider["slider_handle"]) );
		sliderSet.mouseOver.add(onSliderOver);
		sliderSet.mouseOut.add(onSliderOut);
		sliderSet.mouseDown.add(startSliderDrag);
		InteractiveObjectSignalSet(buttonMouseSets[muteButton]).click.add(onMuteClick);
		InteractiveObjectSignalSet(buttonMouseSets[fullScreenOffButton]).click.add(onFullScreenChange);
		InteractiveObjectSignalSet(buttonMouseSets[fullScreenOnButton]).click.add(onFullScreenChange);
		InteractiveObjectSignalSet(buttonMouseSets[quitYesButton]).click.add(quitButtonClick);
		InteractiveObjectSignalSet(buttonMouseSets[quitNoButton]).click.add(quitButtonClick);
		/* end add controls */
	}
	
	override public function doOutro():void
	{
		/* remove controls */
		if ( buttonMouseSets != null ) {
			for ( var key:Object in buttonMouseSets ) {
				InteractiveObjectSignalSet(buttonMouseSets[key]).removeAll();
				buttonMouseSets[key] = null;
				delete buttonMouseSets[key];
			}
		}
		buttonMouseSets = null;
		if ( sliderSet != null ) {
			sliderSet.removeAll();
			sliderSet = null;
		}
		if ( buttons != null && labels != null ) {
			for ( var label:String in buttons ) {
				//remove label key at button
				delete labels[buttons[label]];
				//remove button key at label
				delete buttons[label];
			}
		}
		buttons = null;
		labels = null;
		/* end remove Controls */
		
		jouRef.transitionAction.addOnce( unload );
		jouRef.bitmapTweenContainerOut();
	}
	
	private var buttons:Dictionary;
	private var labels:Dictionary;
	private function initButton( button:MovieClip, label:String ):void
	{
		if ( buttons == null )
			buttons = new Dictionary(true);
		if ( labels == null )
			labels = new Dictionary(true);
		buttons[label] = button;
		labels[button] = label;
	}
	
	private function onButtonRollover(e:MouseEvent):void
	{
		MovieClip(e.target).gotoAndStop(2);
		jouRef.clickItemOver.dispatch();
	}
	
	private function onButtonRollout(e:MouseEvent):void
	{
		if ( e.target == muteButton ) {
			if ( !SEConfig.muted )
				MovieClip(e.target).gotoAndStop(1);
		} else {
			MovieClip(e.target).gotoAndStop(1);
		}
		jouRef.clickItemOut.dispatch();
	}
	
	private var currentConfigMenu:String;
	private function onButtonClick(e:MouseEvent):void
	{
		if (currentConfigMenu != labels[e.target]) {
			// hide old menu
			switch (currentConfigMenu)
			{
				case TITLE_SCREEN:
					ClipUtils.makeInvisible( titleBG, titleYesButton, titleNoButton );
					break;
				case CONFIG:
					ClipUtils.makeInvisible( configBG, muteButton, volumeSlider, fullScreenOnButton, fullScreenOffButton );
					break;
				case HELP:
					ClipUtils.makeInvisible( helpBG );
					break;
				case QUIT_GAME:
					ClipUtils.makeInvisible( quitBG, quitYesButton, quitNoButton);
					break;
				default:
					break;
			}
			
			currentConfigMenu = labels[e.target];
			// show current menu
			switch (currentConfigMenu)
			{
				case TITLE_SCREEN:
					ClipUtils.makeVisible( titleBG, titleYesButton, titleNoButton );
					break;
				case CONFIG:
					ClipUtils.makeVisible( configBG, muteButton, volumeSlider, fullScreenOnButton, fullScreenOffButton );
					break;
				case HELP:
					ClipUtils.makeVisible( helpBG );
					break;
				case QUIT_GAME:
					ClipUtils.makeVisible( quitBG, quitYesButton, quitNoButton );
					break;
				default:
					break;
			}
		}
	}
	
	private function titleButtonClick(e:MouseEvent):void 
	{
		if (e.target == titleYesButton)
			jouRef.quitTitleAction.dispatch();
		else if (e.target == titleNoButton) {
			ClipUtils.makeInvisible( titleBG, titleYesButton, titleNoButton );
			currentConfigMenu = '';
		}
	}

	private function onMuteClick(e:MouseEvent):void
	{
		if ( SEConfig.muted )
		{
			muteButton.gotoAndStop( 1 );
			jouRef.muteChange.dispatch( false );
		} else 
		{
			muteButton.gotoAndStop( 2 );
			jouRef.muteChange.dispatch( true );
		}
	}
	
	private function onSliderOver( e:MouseEvent ):void 
	{ 
		overSlider = true;
		jouRef.clickItemOver.dispatch(); 
	}
	
	private function onSliderOut( e:MouseEvent ):void 
	{ 
		overSlider = false;
		if(!dragging)
			jouRef.clickItemOut.dispatch(); 
	}
	
	private var stageRect:Sprite;
	private var stageRectUp:NativeSignal;
	private var sliderDragged:NativeSignal;
	private var mouseMove:NativeSignal;
	private var _stage:Stage;
	private var mouseOffStage:Boolean;
	private var overSlider:Boolean;
	private function startSliderDrag( e:MouseEvent ):void
	{
		var rect:Shape = new Shape();
		rect.graphics.beginFill(0x000000, 1);
		rect.graphics.drawRect(0, 0, 760, 512);
		rect.graphics.endFill();
		rect.alpha = 0;
		stageRect = new Sprite();
		stageRect.addChild(rect);
		stateContainer.addChildAt( stageRect, stateContainer.getChildIndex( volumeSlider ) );
		
		/*stageRectUp = new NativeSignal( stageRect, MouseEvent.MOUSE_UP, MouseEvent);
		stageRectUp.addOnce(onStageUp);
		sliderSet.mouseUp.addOnce(onSliderHandleUp);
		*/
		
		dragging = true;
		
		mouseMove = new NativeSignal( this.jouRef, MouseEvent.MOUSE_MOVE, MouseEvent );
		mouseMove.add( updateSliderBack );
		Sprite(volumeSlider["slider_handle"]).startDrag( false, new Rectangle(0, 0, 122, 0) );
		
		if(jouRef.stage!=null)
			_stage = jouRef.stage;
		if(_stage!=null){
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			_stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
		}	
	}
	
	private function onMouseUp(e:MouseEvent):void
	{
		//trace("Mouse Up On Stage")
		endDrag();
	}
	
	private function onMouseLeave(e:Event):void
	{
		if(mouseOffStage){
			//trace("mouse up and off stage");
			endDrag();
		}else{
			//trace("mouse has left the stage");
			//no reason to stop drag here as the user hasn't released the mouse yet
		}
	}
	
	private function onMouseOut(e:MouseEvent):void
	{
		mouseOffStage = true;
		//trace("mouse has left the stage");
	}
	
	private function onMouseOver(e:MouseEvent):void
	{
		mouseOffStage = false;
		//trace("mouse has come back on stage");
	}
	
	//private function onStageUp(e:MouseEvent):void { sliderSet.mouseUp.dispatch(new MouseEvent(MouseEvent.MOUSE_UP)); }
	
	private var dragging:Boolean;
	private function endDrag():void
	{
		//stageRectUp.remove(onStageUp);
		if(!dragging)
			return;
		dragging = false;
		if(_stage !=null)
		{
			if(_stage.hasEventListener(MouseEvent.MOUSE_UP))
			{
				_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
				_stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				_stage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
			}
			_stage = null;
		}
		
		if(!overSlider)
		{
			jouRef.clickItemOut.dispatch();
		}
		
		Sprite(volumeSlider["slider_handle"]).stopDrag();
		mouseMove.remove( updateSliderBack );
		jouRef.volumeChange.dispatch( Math.ceil( ( Sprite(volumeSlider["slider_handle"]).x / 122 ) * 100 ) );
		stageRect.removeChildAt(0);
		stateContainer.removeChild( stageRect );
		stageRect = null;
		mouseMove = null;
	}
	
	private function updateSliderBack(e:MouseEvent):void
	{
		Sprite(volumeSlider["slider_filled"]).x = ( Sprite(volumeSlider["slider_handle"]).x - 122 );
	}
	
	private function onSliderHandleUp(e:MouseEvent):void
	{
		
	}
	
	private function onFullScreenChange(e:MouseEvent):void
	{
		jouRef.fullScreeenChange.dispatch( (labels[e.target] == FULLSCREEN_ON) );
	}
	
	private function quitButtonClick(e:MouseEvent):void 
	{
		if (e.target == quitYesButton)
			jouRef.quitAction.dispatch();
		else if (e.target == quitNoButton) {
			ClipUtils.makeInvisible( quitBG, quitYesButton, quitNoButton );
			currentConfigMenu = '';
		}
	}
	
	private function unload():void
	{		
		DisplayObjectUtil.removeAllChildren( stateContainer, false, true );
		jouRef.container.removeChild( stateContainer );
		
		stateContainer = null;
		titleScreenButton = null;
		configButton = null;
		helpButton = null;
		quitGameButton = null;
		optionsButtonsHitBg = null;
		//title screen
		titleBG = null;
		titleYesButton = null;
		titleNoButton = null;
		//config
		configBG = null;
		muteButton = null;
		volumeSlider = null;
		fullScreenOnButton = null;
		fullScreenOffButton = null;
		//help
		helpBG = null;
		//quit game
		quitBG = null;
		quitYesButton = null;
		quitNoButton = null;
		
		this.signalOutroComplete();
	}
	
	private function onSoundPlayed():void
	{
		jouRef.transitionAction.addOnce( this.signalIntroComplete );
		jouRef.stateLoaded.dispatch( KEY );
	}
}

class OutState extends State {
	
	public static const KEY:String = "out state";
	private var jouRef:Journal_Menu;
	
	public function OutState() {
		super();
	}
	
	override public function doIntro():void
	{
		jouRef = Journal_Menu(this.context);
		jouRef.stateLoaded.dispatch( KEY );
		this.signalIntroComplete();
	}
}

class NoteDisplay extends Sprite
{
	private static const OFFSET_X:Number = 30;
	private var _container:Sprite;
	private var _noteText:GoalText;
	private var _active:Boolean;
	private var _checkBox:MovieClip;
	private var _read:Boolean;
	
	public function get read():Boolean
	{
		return _read;
	}

	public function set read(value:Boolean):void
	{
		_read = value;
		if(read)
			if(_checkBox.currentFrame!=2)
				_checkBox.gotoAndStop(2);
		else
			if(_checkBox.currentFrame!=1)
				_checkBox.gotoAndStop(1);
	}

	public function get noteText():GoalText
	{
		return _noteText;
	}
	
	public function get active():Boolean
	{
		return _active;
	}
	
	public function set active(value:Boolean):void
	{
		_active = value;
	}
	
	public function underline(on:Boolean=true):void
	{
		var textFormat:TextFormat = _noteText.tf.getTextFormat();
		textFormat.underline=on;
		_noteText.tf.setTextFormat(textFormat);
	}
	
	public function NoteDisplay(title:String, noteRead:Boolean = false)
	{
		_container=new Sprite();
		_noteText=new GoalText();
		_checkBox= new Jou_Notes_Checkbox() as MovieClip;
		read = noteRead;
		_noteText.tf.text=title;
		_noteText.x=OFFSET_X;
		_noteText.y=-5;
		_noteText.height=_noteText.tf.height=_noteText.tf.textHeight + 10;
		_container.addChild(_checkBox);
		_container.addChild(_noteText);
		addChild(_container);
		_active=false;
	}
}

class GoalDisplay extends Sprite
{
	private static const OFFSET_X:Number = 30;
	private var _container:Sprite;
	private var _icon:Sprite;
	private var _goalText:GoalText;
	private var _active:Boolean;
	
	public function get goalText():GoalText
	{
		return _goalText;
	}
	
	public function get active():Boolean
	{
		return _active;
	}
	
	public function set active(value:Boolean):void
	{
		_active = value;
	}
	
	public function GoalDisplay(title:String,type:String)
	{
		_container=new Sprite();
		_icon = AssetUtils.getAssetInstance( iconClass(type) ) as Sprite;
		_goalText=new GoalText();
		_goalText.tf.text=title;
		_goalText.x=OFFSET_X;
		_goalText.y=-5;
		_goalText.height=_goalText.tf.height=_goalText.tf.textHeight + 10;
		//_goalText.width=_goalText.tf.width=_goalText.tf.textWidth;
		_container.addChild(_icon);
		_container.addChild(_goalText);
		addChild(_container);
		_active=false;
	}
	
	public function underline(on:Boolean=true):void
	{
		var textFormat:TextFormat = _goalText.tf.getTextFormat();
		textFormat.underline=on;
		_goalText.tf.setTextFormat(textFormat);
	}
	
	private function iconClass(type:String):String
	{
		var className:String;
		if(type==GoalType.INSPECT)
			className=GoalIconClassName.INSPECT_LG;
		else if(type==GoalType.INTERACT)
			className=GoalIconClassName.INTERACT_LG;
		else if(type==GoalType.SPEECH)
			className=GoalIconClassName.SPEECH_LG;
		else if(type==GoalType.MAP)
			className=GoalIconClassName.MAP_LG;
		return className;
	}
}