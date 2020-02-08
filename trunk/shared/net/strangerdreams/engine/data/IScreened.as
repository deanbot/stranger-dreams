package net.strangerdreams.engine.data
{
	import flash.utils.Dictionary;

	public interface IScreened
	{
		function get hasScreens():Boolean;
		function get screens():Dictionary;
		function get numScreens():uint;
		function get alternateBetweenScreens():Boolean;
		function get currentScreen():uint;
		function nextScreen():void;
		function resetScreen():void;
	}
}