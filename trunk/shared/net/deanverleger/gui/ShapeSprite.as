package net.deanverleger.gui
{
	import flash.display.Sprite;
	
	public class ShapeSprite extends Sprite
	{
		public function ShapeSprite(width:Number, height:Number, hidden:Boolean=true)
		{
			super();
			this.graphics.beginFill( 0x000000, 1);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			this.alpha = (hidden==true)?0:1;
		}
	}
}