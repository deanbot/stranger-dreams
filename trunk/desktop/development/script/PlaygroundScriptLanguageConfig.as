package development.script
{
	import net.strangerdreams.engine.script.ScriptLanguageConfig;
	
	public class PlaygroundScriptLanguageConfig extends ScriptLanguageConfig
	{
		//enumeration
		private static const ENGLISH:String = "en";
		private static const DEVELOPMENT_SCRIPT_PACKAGE:String = "development.script";
		private static const DEVELOPMENT_SCRIPT_CLASS_SUFFIX:String = "_Script_Data";
		
		public function PlaygroundScriptLanguageConfig()
		{
			super( ENGLISH, DEVELOPMENT_SCRIPT_PACKAGE, DEVELOPMENT_SCRIPT_CLASS_SUFFIX )
		}
	}
}