package net.strangerdreams.app.keyboard
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import org.osflash.signals.natives.NativeSignal;

	public class SEAuxKeyboardListener
	{
		private static var _keyDown:NativeSignal;
		private static var _keyUp:NativeSignal;
		private static var _stageRef:Stage;

		public static function get keyUp():NativeSignal
		{
			return _keyUp;
		}

		public static function get keyDown():NativeSignal
		{
			return _keyDown;
		}
		
		public static function set stageRef(value:Stage):void
		{
			_stageRef = value;
			init();
		}
		
		private static function init():void
		{
			if(_stageRef == null)
				return;
			_keyDown = new NativeSignal(_stageRef,KeyboardEvent.KEY_DOWN,KeyboardEvent);
			_keyUp = new NativeSignal(_stageRef,KeyboardEvent.KEY_UP,KeyboardEvent);
		}
	}
}