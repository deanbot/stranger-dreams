package net.strangerdreams.app.screens.config
{
	import net.strangerdreams.engine.script.ScriptLanguageConfig;

	public class ScreensScriptLanguageConfig extends ScriptLanguageConfig
	{
		private static const ENGLISH:String = "en";
		private static const SCRIPT_PACKAGE:String = "net.strangerdreams.app";
		private static const SCRIPT_CLASS_SUFFIX:String = "_Script_Data";
		
		public function ScreensScriptLanguageConfig()
		{
			super( ENGLISH, SCRIPT_PACKAGE, SCRIPT_CLASS_SUFFIX );
		}
	}
}