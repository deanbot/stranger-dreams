package net.strangerdreams.engine.scene
{
	public class SceneOrder implements ISceneOrder
	{
		private var _sceneOrder:Array;
		
		public function SceneOrder( so:Array )
		{
			_sceneOrder = so;
		}
		
		public function get sceneOrder():Array
		{
			return _sceneOrder;
		}
	}
}