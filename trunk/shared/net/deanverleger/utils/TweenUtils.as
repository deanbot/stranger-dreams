package net.deanverleger.utils
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;

	public class TweenUtils
	{
		public static function bitmapAlphaTween( object:DisplayObject, parent:DisplayObjectContainer, from:uint, to:uint, duration:Number, callback:Function = null ):void
		{
			if (from < 1)
				object.alpha = to;
			
			var prevX:Number = object.x;
			object.x = 6000;
			
			var bmp:BitmapData = new BitmapData( object.width + 100, object.height + 100, true, 0x00000000 );
			bmp.draw( object );
			var bitmap:Bitmap = new Bitmap( bmp );
			parent.addChild( bitmap );
			
			if ( from < 1 )
				bitmap.alpha = from;
			
			object.alpha = to;
			
			var tweenCallback:Function = function():void { 
				object.x = prevX; 
				parent.removeChild( bitmap ); 
				bitmap = null;
				bmp = null;
				prevX = NaN;
				callback();
			}
			
			TweenLite.to(bitmap, duration, { alpha:to, onComplete:tweenCallback }); // possibly hook in 'from'
		}
	}
}