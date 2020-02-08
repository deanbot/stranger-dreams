package net.strangerdreams.app.gui
{
	import flash.display.Sprite;
	
	import net.deanverleger.graphics.shapes.SolidFadingBG;
	
	public class Block extends SolidFadingBG
	{
		public function Block()
		{
			super(760, 512, 0, 0x000000, .3);
			this.visible = false;
		}
	}
}