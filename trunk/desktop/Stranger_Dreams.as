package
{
	//import development.Dev_Stranger_Dreams;
	
	import com.gskinner.utils.FrameScriptManager;
	
	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import net.strangerdreams.app.StrangerDreamsTheWatch;
	import net.strangerdreams.app.gui.MainMenu;
	import net.strangerdreams.app.tutorial.TutorialLevel;
	
	[SWF(width="760", height="512", frameRate="25", backgroundColor="#000000")]
	public class Stranger_Dreams extends Sprite
	{
		public function Stranger_Dreams()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(e:Event):void
		{
			this.stage.nativeWindow.visible = true;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			init();	
		}

		private function init():void
		{
			desktopInit();
		}
		
		/**
		 * Load game as it appears on the website 
		 * 
		 */
		private function webInit():void
		{
			
		}
		
		//private var tutorial_game:TutorialLevel
		private var stranger_dreams_the_watch:StrangerDreamsTheWatch;
		private var main_menu:MainMenu;
		/**
		 * Load game as it appears on the desktop 
		 * 
		 */
		private function desktopInit():void
		{
			//onMainMenuDestroyed();
			dreamfedBumper();
		}
		
		private var bumper:MovieClip;
		private var fsm:FrameScriptManager;
		private function dreamfedBumper():void
		{
			bumper = new DreamfedBumper() as MovieClip;
			fsm = new FrameScriptManager(bumper);
			fsm.setFrameScript(bumper.totalFrames,endBumper)
			addChild(bumper);
		}
		
		private function endBumper():void
		{
			bumper.stop();
			removeChild(bumper);
			bumper=null;
			fsm=null;
			loadMainMenu();
		}
		
		private function loadMainMenu():void
		{
			main_menu = new MainMenu();
			main_menu.playClicked.addOnce(onPlayButtonClicked);
			addChild( main_menu );
		}
		
		private function onPlayButtonClicked():void
		{
			removeChild( main_menu );
			main_menu.destroyed.addOnce(onMainMenuDestroyed);
			main_menu.destroy();
		}
		
		private function onMainMenuDestroyed():void
		{
			main_menu = null;
			stranger_dreams_the_watch=new StrangerDreamsTheWatch();
			stranger_dreams_the_watch.quitToMainMenu.addOnce(onQuitToMainMenu);
			stranger_dreams_the_watch.quitGame.addOnce(onQuitGame);
			
			// mask stage 
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0,0,760,512);
			mask.graphics.endFill();
			addChild(mask);
			stranger_dreams_the_watch.mask = mask;
			
			addChild( stranger_dreams_the_watch );
		}
		
		private static const INTENT_MENU:String = "MainMenu";
		private static const INTENT_QUIT:String = "Quit";
		private var intent:String;
		
		private function onQuitToMainMenu():void
		{
			stranger_dreams_the_watch.destroyed.addOnce(onStrangerDreamsTheWatchDestroyed);
			intent = INTENT_MENU;
			stranger_dreams_the_watch.destroy();
		}
		
		private function onQuitGame():void
		{
			stranger_dreams_the_watch.destroyed.addOnce(onStrangerDreamsTheWatchDestroyed);
			intent = INTENT_QUIT;
			stranger_dreams_the_watch.destroy();
		}
		
		private function onStrangerDreamsTheWatchDestroyed():void
		{
			if(mask!=null)
				if(contains(mask))
					removeChild(mask);
			mask = null;
			removeChild(stranger_dreams_the_watch);
			stranger_dreams_the_watch = null;
			if(intent == INTENT_MENU)
			{
				loadMainMenu();
			} else if (intent == INTENT_QUIT)
			{
				NativeApplication.nativeApplication.exit();
			}
			intent = "";				
		}
		
		//private var dev_game:Dev_Stranger_Dreams;
		/**
		 * Load development version of game
		 * 
		 */
		private function devInit():void
		{
			//addChild( new Dev_Stranger_Dreams() );
		}
	}
}