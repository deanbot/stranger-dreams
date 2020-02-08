package net.strangerdreams.engine.script
{
	public class ScriptLanguageConfig implements IScriptLanguageConfig
	{
		private var _languagePackage:String;
		private var _scriptRootPackage:String;
		private var _scriptSuffix:String;
		public function ScriptLanguageConfig( lp:String, sr:String, ss:String )
		{
			_languagePackage = lp;
			_scriptRootPackage = sr;
			_scriptSuffix = ss;
		}
		
		public function get languagePackage():String
		{
			return _languagePackage;
		}
		
		public function get scriptPackage():String
		{
			return _scriptRootPackage;
		}
		
		public function get scriptSuffix():String
		{
			return _scriptSuffix;
		}
	}
}