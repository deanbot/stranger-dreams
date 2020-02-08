package development
{
	import net.strangerdreams.engine.ISEConfig;

	/**
	 * Stores the class name of the Playground Scene's XML Data
	 */
	public class StoryEngineConfig implements ISEConfig
	{	
		
		/* Make this into a static thingy */
		//scenes
		public static const PLAYGROUND_SCENE:String = "development.scene.Playground_Scene_Data";
		
		//language packages
		public static const ENGLISH:String = "en";
		
		//scripts config
		/* scripts are loaded from an ID in scene */
		private static const DEVELOPMENT_SCRIPT_PACKAGE:String = "development.script";
		private static const DEVELOPMENT_SCRIPT_CLASS_SUFFIX:String = "_Script_Data";
		
		/**
		 * //////////////////////////////////////
		 *  Current Story Engine Instance Config
		 * //////////////////////////////////////
		 */		
		
		public var sceneOrder:Array = new Array(PLAYGROUND_SCENE);
		
		private var _startScene:Number = 0;
		public function get startScene():Number { return _startScene; }
		
		private var _languagePackage:String = ENGLISH;
		public function get languagePackage():String { return _languagePackage; }
		
		private var _scriptPackage:String = DEVELOPMENT_SCRIPT_PACKAGE;
		public function get scriptPackage():String { return _scriptPackage; }
		
		private var _scriptSuffix:String = DEVELOPMENT_SCRIPT_CLASS_SUFFIX;
		public function get scriptSuffix():String { return _scriptSuffix; }
	}
}