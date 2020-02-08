package net.strangerdreams.app.gui
{
	import org.osflash.signals.Signal;

	public interface IUIMenu
	{
		function openMenu(startState:String = null):void;
		function exitMenu():void;
		function update():void;
		function get open():Signal;
		function get exit():Signal;
		function get working():Boolean;
		//function get transitionAction():Signal;
		//function show():void;
		//function hide():void;
		//function set currentState():void;
	}
}