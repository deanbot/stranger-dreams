package net.strangerdreams.app.master
{
	import net.strangerdreams.engine.scene.SceneOrder;
	
	public class MasterSceneOrder extends SceneOrder
	{
		private static const SLOW_DOWN_SCREEN:String = "net.strangerdreams.app.screens.scene.SlowDownScene";
		private static const INTRO_SCENE:String = "net.strangerdreams.app.tutorial.scene.IntroSceneData";
		private static const BENS_APARTMENT_SCENE:String = "net.strangerdreams.app.tutorial.scene.BensApartmentSceneData";
		private static const END_APARTMENT_SCENE:String = "net.strangerdreams.app.screens.scene.ApartmentEnd";
		private static const CHAPTER_START_SCENE:String = "net.strangerdreams.app.screens.scene.ChapterStart";
		private static const SCENE_1:String = "net.strangerdreams.app.scenes.scene.Scene1";
		private static const SCENE_2:String = "net.strangerdreams.app.scenes.scene.Scene2";
		private static const SCENE_3:String = "net.strangerdreams.app.scenes.scene.Scene3";
		private static const SCENE_4:String = "net.strangerdreams.app.scenes.scene.Scene4";
		
		public function MasterSceneOrder()
		{
			var sceneOrder:Array=new Array();
			
		 	/****************************
		 	* Intro & Tutorial (Prologue)
		 	*****************************/
		/*	
			// Slow Down!
			sceneOrder.push(SLOW_DOWN_SCREEN);
			
			// Prologue #0
			sceneOrder.push(INTRO_SCENE);
			
			// Prologue #1
			sceneOrder.push(BENS_APARTMENT_SCENE);
	
			// End Prologue #1
			sceneOrder.push(END_APARTMENT_SCENE);
			
			// Quotes Chapter 1
			sceneOrder.push(CHAPTER_START_SCENE);
			
			// Scene #1
			sceneOrder.push(SCENE_1);
			*/
			// Scene #2
			sceneOrder.push(SCENE_2);
			
			// Scene #3
			sceneOrder.push(SCENE_3);
			
			// Scene #4
			sceneOrder.push(SCENE_4);
			
			/****************************
			 * END: Intro & Tutorial (Prologue)
			 *****************************/
			
			super(sceneOrder);
		}
	}
}