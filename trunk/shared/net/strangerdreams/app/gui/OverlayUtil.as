package net.strangerdreams.app.gui
{
	import flash.display.Shape;
	import flash.utils.Dictionary;
	
	import net.deanverleger.graphics.shapes.SolidFadingBG;
	
	import org.osflash.signals.Signal;

	public class OverlayUtil
	{
		private static const OVERLAY:String = "overlay";
		private static const BG_ACTION:String = "bgAction";
		private static var overlayVars:Dictionary = new Dictionary(true);
		
		public static function getOverlay(alpha:Number=.85):Shape
		{
			var overlay:SolidFadingBG;
			if (overlayVars[OVERLAY]==null)
			{
				overlay=new SolidFadingBG(760, 512, alpha);
				overlayVars[OVERLAY]=overlay;
				overlayVars[BG_ACTION]=overlay.bgAction;
			}
			else 
				overlay=overlayVars[OVERLAY];
			return overlay as Shape;
		}
		public static function get bgAction():Signal
		{
			var signal:Signal;
			if (overlayVars[BG_ACTION]==null)
				trace("returning an empty signal. overlay not set. call getOverlay first.");
			else 
				signal = Signal(overlayVars[BG_ACTION]);
			return signal;
		}
		
		public static function fadeIn():void
		{
			if (overlayVars[OVERLAY]==null)
				trace("call getOVerlay First. Cannot fade in. There is no overlay set");
			else
				SolidFadingBG(overlayVars[OVERLAY]).show();
		}
		
		public static function fadeOut():void
		{
			if (overlayVars[OVERLAY]==null)
				trace("call getOVerlay First. Cannot fade out. There is no overlay set");
			else
				SolidFadingBG(overlayVars[OVERLAY]).hide();
		}
	}
}