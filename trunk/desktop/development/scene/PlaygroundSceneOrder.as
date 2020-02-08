package development.scene
{
	import net.strangerdreams.engine.scene.SceneOrder;
	
	public class PlaygroundSceneOrder extends SceneOrder
	{		
		//enumeration
		private static const PLAYGROUND_SCENE:String = "development.scene.Playground_Scene_Data";
		
		public function PlaygroundSceneOrder()
		{
			super( new Array(PLAYGROUND_SCENE) );
		}
	}
}