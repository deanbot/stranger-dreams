package net.strangerdreams.app.scenes.config
{
	import net.strangerdreams.engine.script.ScriptLanguageConfig;
	
	public class SceneScriptLanguageConfig extends ScriptLanguageConfig
	{
		private static const ENGLISH:String = "en";
		private static const SCRIPT_PACKAGE:String = "net.strangerdreams.app";
		private static const SCRIPT_CLASS_SUFFIX:String = "ScriptData";
		
		public function SceneScriptLanguageConfig()
		{
			super( ENGLISH, SCRIPT_PACKAGE, SCRIPT_CLASS_SUFFIX );
		}
	}
}