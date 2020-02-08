package net.strangerdreams.app.gui
{
	//import com.gmac.sound.SoundSkin;
	import com.greensock.TweenLite;
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.TweenUtils;
	import net.strangerdreams.app.keyboard.SEHotkeyListener;
	import net.strangerdreams.app.tutorial.TutorialFlags;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.scene.StorySceneManager;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Caption;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class Inventory_Menu extends Sprite implements IUIMenu
	{
		
		[Embed(source="../../libs/UI/sounds/UIsuitcaseOpen.mp3")]
		private var InventoryIntro:Class;
		[Embed(source="../../libs/UI/sounds/UIsuitcaseClose.mp3")]
		private var InventoryOutro:Class;
		[Embed(source="../../libs/UI/sounds/UIkeyItemsOpen.mp3")]
		private var KeyItemsIntro:Class;
		[Embed(source="../../libs/UI/sounds/UIkeyItemsClose.mp3")]
		private var KeyItmesOutro:Class;
		
		public static const PAGE_KEY_ITEMS:String = "key items";
		public static const SOUND_INVENTORY_INTRO:String = "inventoryIntro";
		public static const SOUND_INVENTORY_OUTRO:String = "inventoryOutro";
		public static const SOUND_KEY_ITEMS_INTRO:String = "keyItemsIntro";
		public static const SOUND_KEY_ITEMS_OUTRO:String = "keyItemsOutro";
		
		/* temp */
		private var timer:Timer;
		private var soundFinished:NativeSignal;
		/* end temp */
		
		private var transitionTime:Number = .45;
		private var _container:Sprite;
		private var _sounds:Dictionary;
		private var _sm:StateManager;
		private var _working:Boolean;
		private var _itemPosition:Array;
		private var _keyItemPosition:Array;
		private var _hud:HUD;
		private var _padding:Sprite;
		private var _active:Boolean;
		private var _itemGrid:ReversibleMovieClipGrid;
		private var _currentPage:String;
		
		public function Inventory_Menu(hud:HUD)
		{
			_hud=hud;
			super();
			init();
		}
		
		public function get keyItemPosition():Array
		{
			return _keyItemPosition;
		}

		public function set keyItemPosition(value:Array):void
		{
			_keyItemPosition = value;
		}

		public function get currentPage():String
		{
			return _currentPage;
		}

		public function get itemGrid():ReversibleMovieClipGrid
		{
			return _itemGrid;
		}

		public function set itemGrid(value:ReversibleMovieClipGrid):void
		{
			_itemGrid = value;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

		public function get padding():Sprite
		{
			return _padding;
		}
		
		public function set padding(value:Sprite):void
		{
			_padding = value;
		}

		public function get hud():HUD
		{
			return _hud;
		}

		public function set itemPosition(value:Array):void
		{
			_itemPosition = value;
		}

		public function get itemPosition():Array
		{
			return _itemPosition;
		}
		
		public function set working(value:Boolean):void
		{
			_working = value;
			if(value == true)
				SEHotkeyListener.halt();
			else
				SEHotkeyListener.resume();
		}

		/**
		 * Initialize public Signals 
		 * 
		 */
		private function init():void {
			_clickItemOver = new Signal();
			_clickItemOut = new Signal();
			_keyItemsActiveChange = new Signal( Boolean );
			_soundAction = new Signal();
			_stateLoaded = new Signal( String );
			_transitionAction = new Signal();
			_open = new Signal();
			_exit = new Signal();
			_itemPosition = new Array(8);
			for(var i:int=0; i<_itemPosition.length; i++)
				_itemPosition[i]==""
		}

		private var _freshOpen:Boolean;
		public function openMenu( startState:String = DefaultState.KEY ):void
		{
			if(startState == null)
				startState = DefaultState.KEY; 
			_currentPage = startState;
			//trace( "Inventory Menu says, \"opening menu[" + startState + "].\"");
			addChild( _container = new Sprite() );
			
			_sounds = new Dictionary(true);
			_sounds[SOUND_INVENTORY_INTRO] = new InventoryIntro() as Sound;
			_sounds[SOUND_INVENTORY_OUTRO] = new InventoryOutro() as Sound;
			_sounds[SOUND_KEY_ITEMS_INTRO] = new KeyItemsIntro() as Sound;
			_sounds[SOUND_KEY_ITEMS_OUTRO] = new KeyItmesOutro() as Sound;
			
			_container.alpha = 0;
			
			_freshOpen = true;
			working = true;
			
			_sm = new StateManager( this );
			_sm.addState( DefaultState.KEY, new DefaultState(), (startState == DefaultState.KEY) ? true : false );
			_sm.addState( KeyItemsState.KEY, new KeyItemsState(), (startState == KeyItemsState.KEY) ? true : false );
			_sm.addState( OutState.KEY, new OutState() );
			
			_stateLoaded.add( onStateLoaded );
		}
		
		public function openMenuPage(pageName:String):void
		{
			
		}
		
		public function exitMenu():void
		{
			//trace( "Inventory Menu says, \"exiting menu.\"");
			if(_sm == null)
				return;
			_sm.setState( OutState.KEY );
		}
		
		private function unload():void
		{
			stateLoaded.remove( onStateLoaded );
			
			_sm.destroy();
			_sm = null;
			
			DisplayObjectUtil.removeAllChildren( _container, false, true );
			removeChild( _container );
			
			for ( var k:String in _sounds )
			{
				_sounds[k] = null;
				delete _sounds[k];
			}
			_sounds = null;
			
			//trace( "Inventory Menu says, \"Finished cleaning up!\"");
		}
		
		public function update():void
		{
			
		}
		
		public function doState( stateKey:String ):void { _sm.setState( stateKey ); working = true; }
		
		public function get container():Sprite { return _container; }
		
		public function get freshOpen():Boolean { return _freshOpen; }
		
		/* Start State Actions */
		
		private var screenIntroTime:Number = .5;
		private var screenOutroTime:Number = .5;

		public function bitmapTweenContainerOut():void
		{
			TweenUtils.bitmapAlphaTween( this.container, this, 1, 0, transitionTime, transitionAction.dispatch );
		}
		
		public function playSound( sound:Sound, name:String ):void
		{
			//trace( "Inventory Menu says, \"playing sound [" + sound + "].\"" );
			SoundUtils.playUISound( sound, onSoundFinished, name );
		}
		
		private function onSoundFinished( name:String ):void
		{
			//soundFinished = null;
			soundAction.dispatch();
		}
		
		private function onStateLoaded( stateKey:String ):void
		{
			//trace ( "Inventory Menu says, \"State [ " + stateKey + "] is ready.\"" );
				
			if (stateKey != OutState.KEY) 
			{
				if (_freshOpen)
					transitionAction.addOnce(onFreshOpen);
				
				if(stateKey == DefaultState.KEY)
				{
					if(SEConfig.isTutorial)
					{
						if(!FlagManager.getHasFlag(TutorialFlags.FLAG_KEY_ITEMS_HINT_ANTI))
						{
							if(FlagManager.getHasFlag(TutorialFlags.FLAG_KEY_ITEMS_HINT))
							{
								SESignalBroadcaster.singleNotification.dispatch(Caption(StoryScriptManager.getCaptionInstance("keyItemsHint")).text);
							}
						}
					}
					
					if(itemGrid!=null)
					{
						this.itemGrid.permit=true;
						this.hud.itemGrid.permit=true;
						this.hud.itemGrid.mouseEnabled=true;
						this.hud.itemGrid.mouseChildren=true;
						this.hud.checkMouseOverItem();
					}
				} else if (stateKey == KeyItemsState.KEY)
				{
					if(!FlagManager.getHasFlag(TutorialFlags.FLAG_KEY_ITEMS_HINT_ANTI))
						FlagManager.addFlag(TutorialFlags.FLAG_KEY_ITEMS_HINT_ANTI);
				}
				_currentPage = stateKey;
				
				//trace ( "Inventory Menu says, \"Revealing the menu [" + _sm.getState() + "] now.\"" );
				this.transitionAction.addOnce( function():void { working = false; } );
				TweenUtils.bitmapAlphaTween( this._container, this, 0, 1, transitionTime, transitionAction.dispatch );	
			} else 
			{
				soundAction.addOnce( exit.dispatch );
				soundAction.addOnce( this.unload );
				playSound( Sound(_sounds[SOUND_INVENTORY_OUTRO]), SOUND_INVENTORY_OUTRO );
			}
		}
		
		private function onFreshOpen():void
		{
			//trace( "Inventory Menu says, \"There I've opened.\"" );
 			open.dispatch();
			_freshOpen = false;
		}
		
		private var _stateLoaded:Signal;
		private var _clickItemOver:Signal;
		private var _clickItemOut:Signal;
		private var _keyItemsActiveChange:Signal;
		private var _transitionAction:Signal;	
		private var _soundAction:Signal;
		private var _open:Signal;
		private var _exit:Signal;
		
		public function get stateLoaded():Signal { return _stateLoaded; }
		
		public function get clickItemOver():Signal { return _clickItemOver; }
		
		public function get clickItemOut():Signal { return _clickItemOut; } 
		
		public function get keyItemsActiveChange():Signal { return _keyItemsActiveChange; }

		public function get transitionAction():Signal { return _transitionAction; }
		
		public function get soundAction():Signal { return _soundAction; }
		
		public function get open():Signal { return _open; }

		public function get exit():Signal { return _exit; }

		public function get working():Boolean
		{
			return _working;
		}

		public function get sounds():Dictionary
		{
			return _sounds;
		}
		
		public function get quickSlots():Dictionary
		{
			return _hud.quickSlots;
		}
		public function set quickSlots(val:Dictionary):void
		{
			_hud.quickSlots = val;
		}
	
	}
}

import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Dictionary;
import flash.utils.Timer;

import net.deanverleger.gui.ShapeSprite;
import net.deanverleger.text.TextHandle;
import net.deanverleger.utils.AssetUtils;
import net.deanverleger.utils.ClipUtils;
import net.strangerdreams.app.gui.Inventory_Menu;
import net.strangerdreams.app.gui.ReversibleMovieClipGrid;
import net.strangerdreams.app.gui.ReversibleMovieClipWrapper;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.item.data.Item;
import net.strangerdreams.engine.scene.data.HoverType;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.ScriptItem;

import org.casalib.util.DisplayObjectUtil;
import org.osflash.signals.natives.NativeSignal;
import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class DefaultState extends State {
	
	public static const KEY:String = "default"
	
	private var invRef:Inventory_Menu;
	private var stateContainer:Sprite;
	private var bg:Bitmap;
	private var keyItemsButton:ReversibleMovieClipWrapper
	private var buttonSet:InteractiveObjectSignalSet;
	private var textHandle:TextHandle;
	private var inventory:Dictionary;
	private var itemSlots:Dictionary;
	private var itemIcons:Dictionary;
	private var itemSets:Dictionary;
	private var draggingItem:Boolean;
	
	
	public function DefaultState():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		invRef = Inventory_Menu(this.context);
		
		invRef.container.addChild( stateContainer = new Sprite() );
		stateContainer.addChild( bg = new Bitmap( new Inv_bg(1,1) ) );
		stateContainer.addChild( keyItemsButton = new ReversibleMovieClipWrapper( new Inv_key_items_btn(), "empty", "filled" ) );
		stateContainer.addChild( textHandle = new TextHandle("",11,0xFFFFFF,false,TextFormatAlign.LEFT,300,56) );
		stateContainer.addChild( invRef.padding = new InventoryItemsPadding() as Sprite );	
		stateContainer.addChild( itemGrid = new ReversibleMovieClipGrid(2,4,76,79,27,true) );
		itemGrid.setInventoryRef(invRef);
		itemGrid.removedFromInventory.add(onItemRemovedFromInventory);
		invRef.hud.addedToInventory.add(onItemAddedToInventory);
		invRef.hud.itemGrid.setInventoryRef(invRef);
		
		bg.x = 23;
		bg.y = 16;
		keyItemsButton.x = 265;
		keyItemsButton.y = 57;
		keyItemsButton.stop();
		keyItemsButton.mouseChildren = false;
		textHandle.multiline=true;
		textHandle.wordWrap=true;
		textHandle.alpha=0;
		textHandle.x=183;
		textHandle.y=407;
		invRef.padding.alpha=0;
		invRef.padding.x = 100;
		invRef.padding.y = 111;
		itemGrid.x=142;
		itemGrid.y=165;
		
		updateInventory();
		
		if ( invRef.freshOpen ) {
			this.invRef.itemGrid.permit=false;
			this.invRef.hud.itemGrid.permit=false;
			this.invRef.hud.itemGrid.mouseEnabled=false;
			this.invRef.hud.itemGrid.mouseChildren=false;
			this.invRef.hud.checkMouseOverItem();
			invRef.soundAction.addOnce( onSoundPlayed );
			invRef.playSound( Sound(invRef.sounds[Inventory_Menu.SOUND_INVENTORY_INTRO]), Inventory_Menu.SOUND_INVENTORY_INTRO );
		} else {
			invRef.transitionAction.addOnce( this.signalIntroComplete );
			invRef.stateLoaded.dispatch( KEY );
		}
		
		invRef.active=true;
	}
	
	override public function action():void
	{
		/* add controls */
		buttonSet = new InteractiveObjectSignalSet( keyItemsButton );
		buttonSet.mouseOver.add( onKeyItemsButtonOver );
		buttonSet.mouseOut.add( onKeyItemsButtonOut );
		buttonSet.click.add( onKeyItemsButtonClick );
		keyItemsButton.stopFrame.add( checkMouseOverReversible );
		/* end add controls */
	}
	
	override public function doOutro():void
	{
		if(ItemManager.numInventory>0)
		{
			/* store positions */
			var position:Array=invRef.itemPosition;
			for (var i:int=0; i<position.length; i++)
			{
				var r:int = i / 4;
				var c:int = i;
				if (i>3)
					c = c-4;
				var icon:ReversibleMovieClipWrapper = itemGrid.getItemAtPosition(r,c);
				if(icon.name=="empty")
					position[i]="";
				else
					position[i]=itemIcons[icon];
			}
		}
		
		/* remove controls */
		if(buttonSet!=null)
			buttonSet.removeAll();
		keyItemsButton.stopFrame.removeAll();
		buttonSet = null;
		var set:InteractiveObjectSignalSet;
		for (var k:String in itemSets)
		{
			set = InteractiveObjectSignalSet(itemSets[k]);
			set.removeAll();
			set = null;
			delete itemSets[k];
			ReversibleMovieClipWrapper(itemSlots[k]).stopFrame.removeAll();
		}
		/* end remove controls */
		
		invRef.transitionAction.addOnce( unload );
		invRef.bitmapTweenContainerOut();
	}
	
	private function get itemGrid():ReversibleMovieClipGrid
	{
		return this.invRef.itemGrid;
	}
	private function set itemGrid(value:ReversibleMovieClipGrid):void
	{
		this.invRef.itemGrid=value;
	}
	
	private function onItemRemovedFromInventory(icon:ReversibleMovieClipWrapper, toQuickslot:Boolean):void
	{
		if(itemSlots==null)
			return;
		if(itemIcons==null)
			return;
		if(itemSets==null)
			return;
		
		var key:String = itemIcons[icon];
		if(itemSets[key]!=null)
		{
			var target:ReversibleMovieClipWrapper = icon;
			if ( !target.reversing && target.currentFrameLabel != "normal" )
				target.reverse();
			
			textHandle.htmlText="";
			TweenLite.killTweensOf(textHandle, false);
			textHandle.alpha=0;
			
			InteractiveObjectSignalSet(itemSets[key]).removeAll();
			itemSets[key]=null;
			delete itemSets[key];
		}
		if(toQuickslot)
		{
			invRef.hud.initQuickSlotItem(icon, key);
			if( !invRef.hud.checkMouseOverItem() )
				SESignalBroadcaster.interactiveRollOut.dispatch();
		} else {
			//SESignalBroadcaster.interactiveRollOut.dispatch();
		}
		itemIcons[icon]=null;
		delete itemIcons[icon];
		delete itemSlots[key];
	}
	
	private function onItemAddedToInventory(icon:ReversibleMovieClipWrapper, k:String):void
	{
		if(itemSlots==null)
			return;
		if(itemIcons==null)
			return;
		if(itemSets==null)
			return;
		
		itemSlots[k]=icon;
		itemIcons[icon]=k;
		var set:InteractiveObjectSignalSet=new InteractiveObjectSignalSet(icon);
		itemSets[k]=set;
		set.rollOver.add(onItemIconOver);
		set.rollOut.add(onItemIconOut);
		icon.stopFrame.add(checkIconOver);
		if(icon.hitTestPoint(this.invRef.mouseX,this.invRef.mouseY))
		{
			var target:ReversibleMovieClipWrapper = icon;
			if ( target.reversing )
				target.play();
			else if ( target.currentFrameLabel != "noir")
				target.play();
			
			textHandle.htmlText="<b>"+Item(inventory[ itemIcons[target] ]).title+"</b><br/>"+Item(inventory[ itemIcons[target] ]).description;
			TweenLite.to(textHandle,1,{alpha:1});
			
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
		}
	}
	
	private function updateInventory():void
	{
		if(ItemManager.numInventory>0)
		{
			if(itemSlots==null)
				itemSlots=new Dictionary(true);
			if(itemIcons==null)
				itemIcons=new Dictionary(true);
			if(itemSets==null)
				itemSets=new Dictionary(true);
			inventory=ItemManager.inventory;
			validadeItemPosition();
			var position:Array=invRef.itemPosition;
			var item:Item;
			var icon:ReversibleMovieClipWrapper;
			var set:InteractiveObjectSignalSet;
			for (var k:String in inventory)
			{
				if(itemSlots[k]==null && invRef.quickSlots[k]==null)
				{
					// check if in positions.
					if(position.indexOf(k)==-1)
					{
						// add to first empty position
						var found:Boolean=false;
						var pos:int=0;
						while(!found && pos<position.length) {
							if(position[pos]=="")
								found=true;
							else
								pos++;
						}
						if(found)
						{
							position[pos]=k;
						} else
						{
							trace("uhoh, the inventory is full!");
						}
					}
					
					//create item
					item=Item(inventory[k]);
					icon=new ReversibleMovieClipWrapper(MovieClip(AssetUtils.getAssetInstance(item.assetClass)),"normal","noir");
					itemSlots[k]=icon;
					itemIcons[icon]=k;
					set=new InteractiveObjectSignalSet(icon);
					itemSets[k]=set;
					set.rollOver.add(onItemIconOver);
					set.rollOut.add(onItemIconOut);
					icon.stopFrame.add(checkIconOver);
				}
			}
			//add all by position
			for (var i : int = 0;i < position.length; i++)
			{
				var r:int = i / 4;
				var c:int = i;
				if (i>3)
					c = c-4;
				if(position[i]!="")
					itemGrid.addItemAt( ReversibleMovieClipWrapper(itemSlots[ position[i] ]),r,c );
				else
				{
					var blank:ReversibleMovieClipWrapper = new ReversibleMovieClipWrapper( new MovieClip() );
					blank.name="empty";
					itemGrid.addItemAt(blank,r,c);
				}
			}
		}
	}
	
	private function validadeItemPosition():void
	{
		var position:Array=invRef.itemPosition;
		for(var i:int=0; i<position.length; i++)
		{
			if(!ItemManager.hasItem(position[i]))
				position[i]="";
		}
	}
	
	private function onItemIconOver(e:MouseEvent):void
	{
		//trace("over");
		if(!draggingItem)
		{
			var target:ReversibleMovieClipWrapper = (e.target as ReversibleMovieClipWrapper);
			if ( target.reversing )
				target.play();
			else if ( target.currentFrameLabel != "noir")
				target.play();
			
			textHandle.htmlText="<b>"+Item(inventory[ itemIcons[target] ]).title+"</b><br/>"+Item(inventory[ itemIcons[target] ]).description;
			TweenLite.to(textHandle,1,{alpha:1});
			
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
		}
	}
	
	private function onItemIconOut(e:MouseEvent):void
	{
		//trace("out");
		if(!draggingItem)
		{
			var target:ReversibleMovieClipWrapper = ( e.target as ReversibleMovieClipWrapper );
			if ( !target.reversing && target.currentFrameLabel != "normal" )
				target.reverse();

			textHandle.htmlText="";
			TweenLite.killTweensOf(textHandle, false);
			textHandle.alpha=0;
			
			SESignalBroadcaster.interactiveRollOut.dispatch();
		}
	}
	
	private function checkIconOver(icon:ReversibleMovieClipWrapper):void
	{
		if( !icon.hitTestPoint(this.invRef.mouseX,this.invRef.mouseY) )
			icon.reverse();
	}
	
	private function unload():void
	{
		itemGrid.destroy();
		var icon:ReversibleMovieClipWrapper;
		for (var k:String in itemSlots)
		{
			icon = ReversibleMovieClipWrapper(itemSlots[k]);
			itemIcons[icon]=null;
			delete itemIcons[icon];
			icon = null;
			delete itemSlots[k];
		}
		DisplayObjectUtil.removeAllChildren( stateContainer, false, true);
		invRef.container.removeChild( stateContainer );
		invRef.padding=null;
		itemGrid=null;
		itemSets=itemIcons=itemSlots=inventory=null;
		stateContainer=null;
		textHandle=null;
		this.signalOutroComplete();
		invRef.active=false;
	}
	
	private function onKeyItemsButtonOver(e:MouseEvent):void
	{
		var target:ReversibleMovieClipWrapper = (e.target as ReversibleMovieClipWrapper);
		if ( target.reversing )
			target.play();
		else if ( target.currentFrameLabel != target.endLabel)
			target.play();
		
		invRef.clickItemOver.dispatch();
	}
	
	private function onKeyItemsButtonOut(e:MouseEvent):void
	{
		var target:ReversibleMovieClipWrapper = (e.target as ReversibleMovieClipWrapper);
		if ( !target.reversing && target.currentFrameLabel != target.startLabel )
			target.reverse();
		
		invRef.clickItemOut.dispatch();
	}
	
	private function checkMouseOverReversible(reversible:ReversibleMovieClipWrapper):void
	{
		if( ! reversible.hitTestPoint( invRef.mouseX, invRef.mouseY ) )
			reversible.reverse();
	}
	
	private function onKeyItemsButtonClick(e:MouseEvent):void 
	{ 
		// drop items?
		invRef.clickItemOut.dispatch();
		invRef.doState( KeyItemsState.KEY );
		
	}
	
	private function onSoundPlayed():void
	{
		invRef.transitionAction.addOnce( this.signalIntroComplete );
		invRef.stateLoaded.dispatch( KEY );
	}
	
}

class KeyItemsState extends State {
	
	public static const KEY:String = "key items";
	private static const BUTTON_LEFT:String = "left button";
	private static const BUTTON_RIGHT:String = "right button";
	private static const TITLE_X:Number = 644.75;
	private static const TITLE_Y_START:Number = 19.2;

	private var invRef:Inventory_Menu;
	private var stateContainer:Sprite;
	
	private var keyItemsBg:Bitmap;
	private var buttonLeft:MovieClip;
	private var buttonRight:MovieClip;
	private var buttonBack:MovieClip;
	private var keyItemsContainer:Sprite;
	private var buttonSets:Dictionary;
	private var buttonBackSet:Dictionary;
	
	private var keyItems:Dictionary;
	private var itemGraphics:Dictionary;
	private var itemTitles:Dictionary; // display object
	private var itemDescriptions:Dictionary; // strings
	private var itemSets:Dictionary;
	private var itemHits:Dictionary;
	private var itemHitLookup:Dictionary;
	private var order:Array;
	private var currentItem:uint;
	private var currentGraphic:Sprite;
	
	private var textHandleTitle:TextHandle;
	private var textHandleDescription:TextHandle;
	
	private var working:Boolean;
	
	private var labels:Dictionary;	
	
	public function KeyItemsState():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		invRef = Inventory_Menu(this.context);
		
		invRef.container.addChild( stateContainer = new Sprite() );
		stateContainer.addChild( keyItemsBg = new Bitmap( new Inv_key_items_bg(1,1) ) );
		stateContainer.addChild( buttonLeft = new Inv_key_items_button_left() as MovieClip );
		stateContainer.addChild( buttonRight = new Inv_key_items_button_right() as MovieClip );
		stateContainer.addChild( buttonBack = new KeyItemsBackButton() as MovieClip );
		
		buttonLeft.x = 40.55;
		buttonLeft.y = 467.95;
		buttonRight.x = 679;
		buttonRight.y = 467.4;
		buttonBack.x = 650.95;
		buttonBack.y = 314;
		
		ClipUtils.stopClips( buttonLeft, buttonRight, buttonBack );

		labels = new Dictionary(true);
		labels[buttonLeft] = BUTTON_LEFT;
		labels[buttonRight] = BUTTON_RIGHT;
		
		if(ItemManager.numKey>0)
		{
			if(itemGraphics==null)
				itemGraphics=new Dictionary(true);
			if(itemTitles==null)
				itemTitles=new Dictionary(true);
			if(itemDescriptions==null)
				itemDescriptions=new Dictionary(true);
			if(itemSets==null)
				itemSets=new Dictionary(true);
			if(itemHits==null)
				itemHits=new Dictionary(true);
			if(itemHitLookup==null)
				itemHitLookup=new Dictionary(true);
			order = new Array(ItemManager.numKey);
			currentItem=0;
			keyItems=ItemManager.keyItems;
			var item:Item;
			var sItem:ScriptItem;
			var itemGraphic:Sprite;
			var set:InteractiveObjectSignalSet;
			var i:uint = 0;
			var title:KeyItemTitle;
			var shapeSprite:Sprite
			var curY:Number = TITLE_Y_START;
			for (var k:String in keyItems)
			{
				item = keyItems[k] as Item;
				sItem = ScriptItem(StoryScriptManager.getItemInstance(item.key));
				order[i]=item.key;
				i++;
				itemGraphics[k] = AssetUtils.getAssetInstance( item.assetClass ) as Sprite;
				title = new KeyItemTitle();
				title.tf.text = sItem.title;
				title.height = title.tf.height = title.tf.numLines * 25;
				itemTitles[k] = title;
				itemDescriptions[k]= sItem.description;
				shapeSprite = new ShapeSprite(title.tf.textWidth, title.tf.textHeight) as Sprite;
				title.addChild(shapeSprite);
				shapeSprite.x = title.tf.x;
				shapeSprite.y = title.tf.y;
				itemHits[k] = shapeSprite;
				itemHitLookup[shapeSprite] = k;
				set = new InteractiveObjectSignalSet(shapeSprite);
				set.mouseOver.add(onKeyTitleOver);
				set.mouseOut.add(onKeyTitleOut);
				set.click.add(onKeyTitleClick);
				itemSets[k] = set;
				stateContainer.addChild(title);
				title.x = TITLE_X;
				title.y = curY;
				curY += title.height + 5;
			}
		}
		
		stateContainer.addChild( textHandleTitle = new TextHandle("",13,0xFFFFFF,true,TextFormatAlign.LEFT,320,0,"",true) );
		stateContainer.addChild( textHandleDescription = new TextHandle("",13,0xFFFFFF,false,TextFormatAlign.LEFT,320,150,"",true,true, 20) );
		textHandleTitle.x = textHandleDescription.x = 217;
		textHandleTitle.y = 410;
		textHandleDescription.y = 430;
		textHandleTitle.alpha = textHandleDescription.alpha = 0;
		
		working = false;
			
		invRef.soundAction.addOnce( onIntroSoundPlayed );
		invRef.playSound( Sound(invRef.sounds[Inventory_Menu.SOUND_KEY_ITEMS_INTRO]), Inventory_Menu.SOUND_KEY_ITEMS_INTRO );
	}
	
	override public function action():void
	{
		invRef.keyItemsActiveChange.dispatch( true );
		if(ItemManager.numKey==0)
		{
			// send back
			SESignalBroadcaster.captionComplete.addOnce(function():void { invRef.doState(DefaultState.KEY); });
			SESignalBroadcaster.singleCaption.dispatch("noKeyItems");
		} else {
			/* add controls */
			buttonSets = ClipUtils.buttonRollSets( onKeyItemsNavigationButtonRollOver, onKeyItemsNavigationButtonRollOut, buttonLeft, buttonRight );
			buttonBackSet = ClipUtils.buttonRollSets( onBackButtonOver, onBackButtonOut, buttonBack );
			ClipUtils.addNativeSignalCallback( onKeyItemsNavigationClick, InteractiveObjectSignalSet(buttonSets[buttonLeft]).click, InteractiveObjectSignalSet(buttonSets[buttonRight]).click );
			ClipUtils.addNativeSignalCallback( onBackButtonClicked, InteractiveObjectSignalSet(buttonBackSet[buttonBack]).click );
			ClipUtils.addNativeSignalCallback( onBackButtonDown, InteractiveObjectSignalSet(buttonBackSet[buttonBack]).mouseDown );
			/* end add controls */
			doCurrentKeyItem();
		}
	}
	
	override public function doOutro():void
	{
		/* remove controls */
		for ( var key:Object in buttonSets ) {
			InteractiveObjectSignalSet(buttonSets[key]).removeAll();
			buttonSets[key] = null;
			delete buttonSets[key];
		}
		buttonSets = null;
		for ( var k:Object in buttonBackSet ) {
			InteractiveObjectSignalSet(buttonBackSet[k]).removeAll();
			buttonBackSet[k] = null;
			delete buttonBackSet[k];
		}
		buttonBackSet = null;
		/* end remove controls */
		
		invRef.keyItemsActiveChange.dispatch( false );
		
		invRef.transitionAction.addOnce( playOutroSound );
		invRef.transitionAction.addOnce( unload );
		invRef.bitmapTweenContainerOut();
	}
	
	private function doCurrentKeyItem():void
	{
		var curItem:String = String( order[currentItem] );
		var item:Sprite = Sprite( itemGraphics[ curItem ] );
		currentGraphic = item;
		bolden(curItem);
		item.alpha = 0;
		stateContainer.addChild(item);
		TweenLite.to(item, 1.5, {alpha:1, onComplete:fadeInText});
	}
	
	private function fadeInText():void
	{
		var curItem:String = String( order[currentItem] );
		var item:Item = keyItems[curItem] as Item;
		textHandleTitle.text = item.title;
		textHandleDescription.text = String( itemDescriptions[ curItem ] );
		TweenLite.to(textHandleTitle,.5,{ alpha: 1});
		TweenLite.to(textHandleDescription,.5,{ alpha: 1,onComplete:notWorking});
	}
	
	private function notWorking():void { working = false; }
	
	private function onKeyTitleOver(e:MouseEvent):void
	{
		invRef.clickItemOver.dispatch();
	}
	
	private function onKeyTitleOut(e:MouseEvent):void
	{
		invRef.clickItemOut.dispatch();
	}
	
	private function onKeyTitleClick(e:MouseEvent):void
	{
		if(working)
			return;
		var curItem:String = String( order[currentItem] );
		var clickedKey:String = itemHitLookup[e.target as Sprite];
		if(clickedKey != curItem)
		{
			working = true;
			bolden(curItem,false);
			bolden(clickedKey,true);
			currentItem = order.indexOf(clickedKey);
			TweenLite.to(currentGraphic,.5,{alpha:0});
			TweenLite.to(textHandleTitle,.5,{alpha:0});
			TweenLite.to(textHandleDescription,.5,{alpha:0,onComplete:doCurrentKeyItem});
		}
	}
	
	private function bolden( itemKey:String, bolden:Boolean = true):void
	{
		var title:KeyItemTitle = KeyItemTitle( itemTitles[ itemKey ] );
		var textFormat:TextFormat = title.tf.getTextFormat();
		textFormat.bold = bolden;
		title.tf.setTextFormat(textFormat);
	}
	
	private function unload():void
	{
		DisplayObjectUtil.removeAllChildren( stateContainer, false, true);
		invRef.container.removeChild( stateContainer );
		stateContainer = null;	
	}
	
	private function onKeyItemsNavigationButtonRollOver(e:MouseEvent):void
	{
		if ( ( labels[e.target] = BUTTON_LEFT && hasKeyItemLeft ) || ( labels[e.target] = BUTTON_RIGHT && hasKeyItemRight ))
		{
			invRef.clickItemOver.dispatch();
			MovieClip(e.target).gotoAndStop(2);
		} 
	}
	
	private function onKeyItemsNavigationButtonRollOut(e:MouseEvent):void
	{
		if ( ( labels[e.target] = BUTTON_LEFT && hasKeyItemLeft ) || ( labels[e.target] = BUTTON_RIGHT && hasKeyItemRight ))
		{
			invRef.clickItemOut.dispatch();
			MovieClip(e.target).gotoAndStop(1);
		} 
	}
	
	private function onBackButtonOver( e:MouseEvent ):void
	{
		invRef.clickItemOver.dispatch();
		buttonBack.gotoAndStop( "hover" );
	}
	
	private function onBackButtonOut( e:MouseEvent ):void
	{
		invRef.clickItemOut.dispatch();
		buttonBack.gotoAndStop( "normal" );
	}
	
	private function onBackButtonDown( e:MouseEvent ):void
	{
		buttonBack.gotoAndStop( "down" );
	}
	
	private function onBackButtonClicked( e:MouseEvent ):void
	{
		buttonBack.gotoAndStop( "normal" );
		invRef.doState( DefaultState.KEY );
		invRef.clickItemOut.dispatch();
	}
	
	private function onKeyItemsNavigationClick(e:MouseEvent):void
	{
		//trace( labels[e.target] );
		if( labels[e.target] == BUTTON_LEFT )
		{
			
		} else if ( labels[e.target] == BUTTON_RIGHT )
		{
			
		}
	}
	
	/**
	 * Just Placeholders
	 */	
	private function get hasKeyItemRight():Boolean 
	{ 
		return (currentItem<order.length-1);
	}
	private function get hasKeyItemLeft():Boolean 
	{ 
		return (currentItem>0);
	}
	
	private function playOutroSound():void
	{
		invRef.soundAction.addOnce( signalOutroComplete );
		invRef.playSound( Sound(invRef.sounds[Inventory_Menu.SOUND_KEY_ITEMS_OUTRO]), Inventory_Menu.SOUND_KEY_ITEMS_OUTRO );
	}
	
	private function onIntroSoundPlayed():void
	{
		invRef.transitionAction.addOnce( signalIntroComplete );
		invRef.stateLoaded.dispatch( KEY );
	}
}

class OutState extends State {
	
	public static const KEY:String = "out state";
	private var invRef:Inventory_Menu;

	public function OutState() {
		super();
	}
	
	override public function doIntro():void
	{
		invRef = Inventory_Menu(this.context);
		invRef.stateLoaded.dispatch( KEY );
		this.signalIntroComplete();
	}
}