package net.strangerdreams.app.tutorial.scene
{
	import net.strangerdreams.engine.scene.SceneOrder;
	
	public class TutorialSceneOrder extends SceneOrder
	{
		private static const INTRO_SCENE:String = "net.strangerdreams.app.tutorial.scene.IntroSceneData";
		private static const BENS_APARTMENT_SCENE:String = "net.strangerdreams.app.tutorial.scene.BensApartmentSceneData";
		
		public function TutorialSceneOrder()
		{
			super( new Array( /*INTRO_SCENE,*/ BENS_APARTMENT_SCENE) );
		}
	}
}