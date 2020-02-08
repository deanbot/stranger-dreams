package net.strangerdreams.engine.data
{
	import flash.utils.Dictionary;

	public interface IVersioned
	{
		function get hasVersions():Boolean;
		function get versions():Dictionary;
		function get numVersions():uint;
	}
}