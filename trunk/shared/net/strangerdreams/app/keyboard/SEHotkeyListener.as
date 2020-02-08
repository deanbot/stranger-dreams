package net.strangerdreams.app.keyboard
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import net.deanverleger.utils.LoggingUtils;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	/**
	 * 	J - Journal
	 *	I - Inventory
	 *	G - Goals
	 *	Esc or O - Options
	 *	K - Key Items
	 *	N - Notes
	 *	M - Map
	 * 	Compass Arrows & WASD - Movement 
	 * 
	 * @author Dean
	 * 
	 */
	public class SEHotkeyListener
	{
	// constants:
		public static const LOCATION:String = "SDHotkeyListener";
		public static const STATUS_INACTIVE:String = "inactive";
		public static const STATUS_ACTIVE:String = "active";
		
		private static const KEYCODE_J:uint = 74;
		private static const KEYCODE_I:uint = 73;
		private static const KEYCODE_G:uint = 71;
		private static const KEYCODE_ESC:uint = 27;
		private static const KEYCODE_O:uint = 79;
		private static const KEYCODE_K:uint = 75;
		private static const KEYCODE_N:uint = 78;
		private static const KEYCODE_M:uint = 77;
		private static const KEYCODE_W:uint = 87;
		private static const KEYCODE_A:uint = 65;
		private static const KEYCODE_S:uint = 83;
		private static const KEYCODE_D:uint = 68;
		private static const KEYCODE_LEFT:uint = 37;
		private static const KEYCODE_UP:uint = 38;
		private static const KEYCODE_RIGHT:uint = 39;
		private static const KEYCODE_DOWN:uint = 40;
		
	// private properties:
		private static var _status:String = STATUS_INACTIVE;
		private static var _stageRef:Stage;
		private static var keyDown:NativeSignal;
		private static var movementHalted:Boolean;
		private static var UIHalted:Boolean;
		private static var journalHalted:Boolean;
		private static var inventoryHalted:Boolean;
		
	// public properties:
		public static var journalKeyPressed:Signal = new Signal();
		public static var inventoryKeyPressed:Signal = new Signal();
		public static var goalKeyPressed:Signal = new Signal();
		public static var optionsKeyPressed:Signal = new Signal();
		public static var backKeyPressed:Signal = new Signal();
		public static var keyItemsKeyPressed:Signal = new Signal();
		public static var notesKeyPressed:Signal = new Signal();
		public static var mapKeyPressed:Signal = new Signal();
		public static var moveUpKeyPressed:Signal = new Signal();
		public static var moveRightKeyPressed:Signal = new Signal();
		public static var moveDownKeyPressed:Signal = new Signal();
		public static var moveLeftKeyPressed:Signal = new Signal();
		
	// constructor:
	// public getter/setters:
		public static function get ready():Boolean 
		{
			return (keyDown!=null);
		}
		
		public static function get status():String
		{
			return _status;
		}
		
		public static function set stageRef(value:Stage):void
		{
			_stageRef = value;
		}
		
	// public methods:
		public static function activate():void
		{
			//LoggingUtils.msgTrace("Activating.",LOCATION);
			if(_status==STATUS_INACTIVE)
			{
				if(_stageRef==null)
				{
					LoggingUtils.msgTrace("Stage not set. Can't activate.",LOCATION);
					return;
				}
				keyDown = new NativeSignal(_stageRef,KeyboardEvent.KEY_DOWN,KeyboardEvent);
				resume();
				movementHalted=false;
			} else
			{
				//LoggingUtils.msgTrace("Already active.",LOCATION);
			}
		}
		
		public static function deactivate():void
		{
			if(_status==STATUS_ACTIVE)
			{
				//LoggingUtils.msgTrace("Clearing stage ref.",LOCATION);
				_stageRef=null;
				halt();
			} else {
				//LoggingUtils.msgTrace("Already inactive.",LOCATION);
			}
		}
		
		public static function halt():void
		{
			//LoggingUtils.msgTrace("halt",LOCATION);
			_status=STATUS_INACTIVE;
			keyDown.remove(onKeyDown);
		}
		
		public static function resume():void
		{
			//LoggingUtils.msgTrace("resume",LOCATION);
			_status=STATUS_ACTIVE;
			keyDown.add(onKeyDown);
		}

		public static function haltMovement():void
		{
			//LoggingUtils.msgTrace("haltMovement",LOCATION);
			movementHalted=true;
		}
		
		public static function resumeMovement():void
		{
			//LoggingUtils.msgTrace("resumeMovement",LOCATION);
			movementHalted=false;
		}
		
		public static function haltUI():void
		{
			//LoggingUtils.msgTrace("haltUI",LOCATION);
			UIHalted=true;	
		}
		
		public static function resumeUI():void
		{
			//LoggingUtils.msgTrace("resumeUI",LOCATION);
			UIHalted=false;
		}
		
		public static function haltJournal():void
		{
			
			journalHalted=true;
		}
		
		public static function resumeJournal():void
		{
			journalHalted=false;
		}
		
		public static function haltInventory():void
		{
			inventoryHalted=true;
		}
		
		public static function resumeInventory():void
		{
			inventoryHalted=false;
		}
		
	// private methods:	
		private static function onKeyDown(e:KeyboardEvent):void
		{
			if(_status==STATUS_INACTIVE)
				return;
			var k:uint = e.keyCode;
			var signal:Signal; // thought I could see if the signal was initialized using a simple if null then init at the end, but it's pass by reference, duh.
			if(!UIHalted)
			{
				
				if(k==KEYCODE_J)
					if(!journalHalted)
						signal = journalKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open journal, Journal Halted",LOCATION);
				else if(k==KEYCODE_I)
					if(!inventoryHalted)
						signal = inventoryKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open inventory, Inventory Halted",LOCATION);
				else if(k==KEYCODE_G)
					if(!journalHalted)
						signal = goalKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open goals, Journal Halted",LOCATION);
				else if(k==KEYCODE_ESC)
					signal = backKeyPressed;
				else if(k==KEYCODE_O)
					if(!journalHalted)
						signal = optionsKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open options, Journal Halted",LOCATION);
				else if(k==KEYCODE_K)
					if(!inventoryHalted)
						signal = keyItemsKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open key items, Inventory Halted",LOCATION);
				else if(k==KEYCODE_N)
					if(!journalHalted)
						signal = notesKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open notes, Journal Halted",LOCATION);
				else if(k==KEYCODE_M)
					if(!journalHalted)
						signal = mapKeyPressed;
					else
						LoggingUtils.msgTrace("Can't open map, Journal Halted",LOCATION);
			}
			if(!movementHalted)
			{	
				if(k==KEYCODE_A || k==KEYCODE_LEFT)
					signal = moveLeftKeyPressed;
				else if(k==KEYCODE_W|| k==KEYCODE_UP)
					signal = moveUpKeyPressed;
				else if(k==KEYCODE_D || k==KEYCODE_RIGHT)
					signal = moveRightKeyPressed;
				else if(k==KEYCODE_S || k==KEYCODE_DOWN)
					signal = moveDownKeyPressed;
			}
			if(signal!=null)
				signal.dispatch();
			else
				LoggingUtils.msgTrace("Signal not set (uiHalted: "+UIHalted+", movementHalted: "+movementHalted+")",LOCATION);
		}
	}
}