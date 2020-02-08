package net.strangerdreams.app.master
{
	import net.strangerdreams.engine.script.ScriptLanguageConfig;
	
	public class MasterScriptLanguageConfig extends ScriptLanguageConfig
	{
		private static const ENGLISH:String = "en";
		private static const SCRIPT_ROOT:String = "net.strangerdreams.app";
		private static const SCRIPT_CLASS_SUFFIX:String = "ScriptData";
		
		public function MasterScriptLanguageConfig()
		{
			super( ENGLISH, SCRIPT_ROOT, SCRIPT_CLASS_SUFFIX )
		}
	}
}