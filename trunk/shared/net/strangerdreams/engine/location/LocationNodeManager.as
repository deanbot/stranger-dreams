package net.strangerdreams.engine.location
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.scene.data.Node;
	
	import org.osflash.signals.Signal;

	/**
	 * 
	 * @author Dean
	 * 
	 */
	public class LocationNodeManager
	{
		// constants:
		public static const LOCATION:String = "LocationNodeManager";
		// private properties:
		private static var _locationNodes:Dictionary;
		private var _locationNodeLoaded:Signal;
		private var loadedNodes:Dictionary;
		private var cleared:Boolean;
		private var _destroyed:Boolean;
		
		// public properties:
		// constructor:
		public function LocationNodeManager()
		{
			init();
			cleared = _destroyed = false;
		}
		
		// public getter/setters:

		public function get destroyed():Boolean
		{
			return _destroyed;
		}

		public function get locationNodeLoaded():Signal
		{
			return _locationNodeLoaded;
		}
		
		// public methods:
		/**
		 * Generate location nodes from dictionary of location node data objects
		 * 
		 * @param nodes Dictionary - node data objects to build Location Nodes from
		 * 
		 */
		public function generateLocationNodes( nodes:Dictionary, implementationPackage:String ):void
		{
			if (_locationNodes != null )
				clear();
			_locationNodes = new Dictionary(true);
			for ( var k:Object in nodes ) {
				var locationNode:LocationNode = AssetUtils.getAssetInstance( implementationPackage + '.' + Node(nodes[k]).implementationClass ) as LocationNode;
				locationNode.setData( Node(nodes[k]) );
				_locationNodes[k] = locationNode;
			}
		}
		
		/**
		 * Clear all location nodes from dictionary and destroy them. 
		 * This should be called before loading a new scene
		 */
		public function clear():void
		{
			if(cleared)
				return;
			//LoggingUtils.msgTrace("Clearing Location Nodes",LOCATION);
			if (_locationNodes != null ) {
				if ( loadedNodes != null ) {
					for ( var key:Object in loadedNodes ) {
						loadedNodes[key] = null;
						delete loadedNodes[key];
					}
					loadedNodes = null;
				}
				
				for ( var k:Object in _locationNodes ) {
					LocationNode(_locationNodes[k]).destroy();
					_locationNodes[k] = null;
					delete _locationNodes[k];
				}
				_locationNodes = null;
			}
			cleared = true;
		}

		/**
		 * Loads a number of Location Node assets. 
		 * This should be called before accessing a location nodes asset.
		 * 
		 * @param rest - a number of uint ids of locaiton nodes to load
		 * 
		 */
		public function loadLocationNode( id:uint ):void
		{
			if ( loadedNodes == null )
				loadedNodes = new Dictionary();
			if (_locationNodes[id] != null ) {
				ILocationNode(_locationNodes[id]).load();
				//destroyed is issued when location node removed from the stage (unloading has already taken place)
				ILocationNode(_locationNodes[id]).destroyed.addOnce(function():void{
					//LoggingUtils.msgTrace("unload from set up from loading",LOCATION);
					unloadLocationNode(id);
				});
				loadedNodes[id] = id;
			}
		}
		
		/**
		 * Clears all references to the location node from memory 
		 * (unloading happens inside location node automoatically when removed from the stage)
		 * @param id location node's id
		 * 
		 */
		public function unloadLocationNode( id:uint ):void
		{
			//LoggingUtils.msgTrace("unloading location node ("+id+")",LOCATION);
			if(loadedNodes == null || _locationNodes == null)
				return;
			if (_locationNodes[id] != null ) {
				if(loadedNodes[id] != null) {
					loadedNodes[id] = null;
					delete loadedNodes[id];
				}
			}
		}
		
		public function locationNodeAsset( id:uint ):MovieClip
		{
			if ( !ILocationNode(_locationNodes[id]).loaded )
				loadLocationNode( id );
			return ILocationNode(_locationNodes[id]).asset;
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy():void
		{
			if(_destroyed)
				return;
			//LoggingUtils.msgTrace("destory", LOCATION);
			clear();
			_locationNodeLoaded.removeAll();
			_locationNodeLoaded = null;
			_destroyed = true;
		}
		
		public static function getLocationNode( id:uint ):LocationNode	
		{
			return _locationNodes[id];
		}
		
		// private methods:
		/**
		 * Initialize public signals
		 */
		private function init():void
		{
			_locationNodeLoaded = new Signal( uint );
		}
	}
}