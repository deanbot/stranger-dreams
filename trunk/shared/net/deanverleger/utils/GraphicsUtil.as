package net.deanverleger.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;

	public class GraphicsUtil
	{
		public static function getBitmapSnapshot( object:DisplayObject, w:Number, h:Number, translateX:Number = 0, translateY:Number = 0):Bitmap
		{
			var bmp:BitmapData = new BitmapData( w, h, true, 0 );
			var matrix:Matrix = new Matrix();
			matrix.translate(translateX,translateY);
			bmp.draw( object, matrix);
			var bitmap:Bitmap = new Bitmap( bmp );
			
			return bitmap;
		}
	}
}