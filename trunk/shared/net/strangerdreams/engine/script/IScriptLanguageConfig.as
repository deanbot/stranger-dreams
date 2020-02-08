package net.strangerdreams.engine.script
{
	public interface IScriptLanguageConfig
	{
		function get languagePackage():String;
		function get scriptPackage():String;
		function get scriptSuffix():String;
	}
}