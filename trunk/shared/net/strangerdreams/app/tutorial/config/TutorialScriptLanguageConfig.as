package net.strangerdreams.app.tutorial.config
{
	import net.strangerdreams.engine.script.ScriptLanguageConfig;

	public class TutorialScriptLanguageConfig extends ScriptLanguageConfig
	{
		private static const ENGLISH:String = "en";
		private static const SCRIPT_PACKAGE:String = "net.strangerdreams.app.tutorial.script";
		private static const SCRIPT_CLASS_SUFFIX:String = "ScriptData";
		
		public function TutorialScriptLanguageConfig()
		{
			super( ENGLISH, SCRIPT_PACKAGE, SCRIPT_CLASS_SUFFIX );
		}
	}
}