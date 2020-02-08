package net.strangerdreams.engine.location
{
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.MovieClip;
	
	import net.strangerdreams.engine.scene.data.Node;
	
	import org.osflash.signals.Signal;

	public interface ILocationNode
	{
		function setData( node:Node ):void;
		function load():void;
		function get asset():MovieClip;
		function get sm():StateManager;
		function get loaded():Boolean; //probably not needed
		function get destroyed():Signal;
	}
}