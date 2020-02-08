package development
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.strangerdreams.app.tutorial.TutorialLevel;
	import net.strangerdreams.app.gui.HUD;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class Dev_Stranger_Dreams extends Sprite
	{
		public function Dev_Stranger_Dreams()
		{
			super();
			
			var staged:NativeSignal = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			staged.addOnce( init );
		}
		
		private var dev_menu:Sprite;
		/**
		 * Create development menu that switches between playground and tutorial 
		 * 
		 */
		private function init(e:Event):void
		{				
			stage.frameRate = 30;
			stage.scaleMode = "noScale";
			stage.align = "TL";
			// create development menu
			dev_menu = new Dev_Menu() as Sprite;
			dev_menu.y = 60;

			var playground_clicked:NativeSignal = new NativeSignal( dev_menu['btn_playground'],MouseEvent.CLICK, MouseEvent);
			var tutorial_clicked:NativeSignal = new NativeSignal( dev_menu['btn_tutorial'], MouseEvent.CLICK, MouseEvent);
			playground_clicked.addOnce(onPlaygroundClicked);
			tutorial_clicked.addOnce(onTutorialClicked);
			var dev_menu_removed:NativeSignal = new NativeSignal( dev_menu, Event.REMOVED_FROM_STAGE, Event);
			dev_menu_removed.addOnce(nullMenu);
			addChild(dev_menu);
		}

		private function onPlaygroundClicked(e:MouseEvent):void { initPlayground(); removeChild(dev_menu); }
		
		private function onTutorialClicked(e:MouseEvent):void { initTutorial(); removeChild(dev_menu); }
		
		private function nullMenu(e:Event):void	{ dev_menu = null; }
		
		private function initTutorial():void { addChild( new TutorialLevel()); }
		
		private function initPlayground():void { addChild( new Playground_Level() ); }
	}
}