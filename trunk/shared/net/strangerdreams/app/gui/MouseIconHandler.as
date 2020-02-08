package net.strangerdreams.app.gui
{
	import flash.display.BitmapData;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.scene.data.NodeObjectType;

	public class MouseIconHandler
	{
		private static var CURSOR_HAND:String = "hand cursor";
		private static var CURSOR_SPEECH:String = "speech cursor";
		private static var CURSOR_EYE:String = "eye cursor";
		private static var CURSOR_ARROW:String = "arrow cursor";
		private static var CURSOR_GRAB:String = "grab cursosr";
		private static var initialized:Boolean = false;
		
		public static function init():void
		{
			if(!initialized)
			{
				initialized=true;
				SESignalBroadcaster.interactiveRollOver.add(onItemRollOver);
				SESignalBroadcaster.interactiveRollOut.add(onItemRollOut);
				
				var mouseCursorData:MouseCursorData = new MouseCursorData();
				var cursorData:Vector.<BitmapData> = new Vector.<BitmapData>();
				var cursors:Vector.<BitmapData> = new Vector.<BitmapData>();
				cursors.push( new HoverIconHand(1,1), new HoverIconGrab(1,1), new HoverIconEye(1,1), new HoverIconSpeech(1,1), new HoverIconArrow(1,1) );
				var cursorLabels:Vector.<String> = new Vector.<String>;
				cursorLabels.push( CURSOR_HAND, CURSOR_GRAB, CURSOR_EYE, CURSOR_SPEECH, CURSOR_ARROW );
				var cursorLength:Number = cursors.length;
				for ( var i:uint = 0; i < cursorLength; i++ )
				{
					cursorData.push( cursors.pop() );
					mouseCursorData.data = cursorData;
					Mouse.registerCursor( cursorLabels.pop(), mouseCursorData );
					cursorData.pop();
				}
				cursorLabels = null;
				cursors = cursorData = null;
				Mouse.cursor = CURSOR_ARROW;
			}
		}
		
		public static function onInteractiveRollOver():void
		{
			Mouse.cursor = CURSOR_HAND;
		}
		
		public static function onGrabableRollOver():void
		{
			Mouse.cursor = CURSOR_GRAB;
		}
		
		public static function onSpeakableRollOver():void
		{
			Mouse.cursor = CURSOR_SPEECH;
		}
		
		public static function onInspectableRollOver():void
		{
			Mouse.cursor = CURSOR_EYE;
		}
		
		public static function onItemRollOut():void
		{
			Mouse.cursor = CURSOR_ARROW;
		}
		
		public static function hideMouse():void
		{
			Mouse.hide();
		}
			
		public static function showMouse():void
		{
			Mouse.show();
		}
		
		private static function onItemRollOver(hoverType:String):void
		{
			//trace("rollout");
			if (hoverType == HoverType.INSPECT)
				onInspectableRollOver();
			else if (hoverType == HoverType.INTERACT)
				onGrabableRollOver();//onInteractiveRollOver();
			else if (hoverType == HoverType.GRAB)
				onGrabableRollOver();
			else if (hoverType == HoverType.SPEAK)
				onSpeakableRollOver();
			else if (hoverType == NodeObjectType.PICK_UP)
				onGrabableRollOver();
		}
	}
}