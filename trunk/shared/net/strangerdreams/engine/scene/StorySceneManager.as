package net.strangerdreams.engine.scene
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import net.deanverleger.data.IXMLObject;
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.gui.UI;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.scene.data.AdjacentNode;
	import net.strangerdreams.engine.scene.data.Node;
	import net.strangerdreams.engine.util.StoryDataObjectUtil;
	
	import org.osflash.signals.Signal;

	public class StorySceneManager
	{
		// constants:
		// private properties:
		private var _nodes:Dictionary;
		private var _numNodes:uint;
		private var _defaultNode:uint;
		private var _scriptPackage:String;
		private var _scriptID:String;
		private var _implementationPackage:String
		private static var _useHUD:Boolean;
		private var _sceneLoaded:Signal;
		private var _soundInstructions:XML;
		private var _soundObjects:XML;
		private var _items:XML;
		private var _goals:XML;
		private var _events:XML;
		private var _notes:XML;
		private var _unload:Boolean;
		private var _destroyed:Boolean;
		private var _scriptLanguageConfig:String;
		private var _characters:XML;
		
		// public properties:
		// constructor:
		public function StorySceneManager()
		{
			init();
		}
		
		// public getter/setters:

		public function get characters():XML
		{
			return _characters;
		}

		public function get scriptLanguageConfig():String
		{
			return _scriptLanguageConfig;
		}

		public function get destroyed():Boolean
		{
			return _destroyed;
		}

		public function get notes():XML
		{
			return _notes;
		}

		public function get events():XML
		{
			return _events;
		}

		public function get goals():XML
		{
			return _goals;
		}

		public function get items():XML
		{
			return _items;
		}

		public function get nodes():Dictionary
		{
			return _nodes;
		}
		
		public function get defaultNode():uint
		{
			return _defaultNode;
		}
		
		public function get implementationPackage():String
		{
			return _implementationPackage;
		}
		
		public static function get useHUD():Boolean
		{
			return _useHUD;
		}
		
		public function get sceneLoaded():Signal 
		{ 
			return _sceneLoaded; 
		}
		
		public function get scriptID():String
		{
			return _scriptID;
		}
		
		public function get scriptPackage():String
		{
			return _scriptPackage;
		}
		
		public function get soundObjects():XML
		{
			return _soundObjects;
		}
		
		public function get soundInstructions():XML
		{
			return _soundInstructions;
		}
		
		// public methods:
		/**
		 * Load and process scene data into scene objects and properties
		 * 
		 * Scene is identified by scene class name
		 * 
		 * Wait for sceneLoaded before referencing.
		 * 
		 * @param sceneClass Story Scene data class name to load
		 * 
		 */
		public function loadStoryScene( sceneClass:String ):void
		{
			_unload = _destroyed = false;
			var storySceneData:XML = ( AssetUtils.getAssetInstance(sceneClass) as IXMLObject ).xml;
			var storyScene:Object = StoryDataObjectUtil.processStoryScene( storySceneData );
			_scriptLanguageConfig = storyScene.config;
			_scriptPackage = storyScene.scriptPackage;
			_scriptID = storyScene.scriptID;
			_defaultNode = (storyScene.defaultNode == null) ? 1 : storyScene.defaultNode;
			_implementationPackage = storyScene.implementationPackage;
			_nodes = storyScene.nodes;
			_numNodes = storyScene.numElements;
			_useHUD = (storyScene.useHUD == null) ? true : storyScene.useHUD;
			_soundInstructions = storyScene.soundInstructions[0];
			_soundObjects = storyScene.soundObjects[0];
			_items=storyScene.items[0];
			_goals=storyScene.goals[0];
			_events=storyScene.events[0];
			_notes=storyScene.notes[0];
			_characters=storyScene.characters[0];
			storySceneData = null;
			storyScene = null;
			_sceneLoaded.dispatch();
		}
		
		/**
		 * resets and data objects from memory. destroys all nodes.
		 */
		public function unloadStoryScene():void
		{
			if(_unload || _destroyed)
				return;
			_useHUD = false;
			_numNodes = 0;
			for each ( var node:Node in _nodes )
				node.destroy();
			_nodes = null;
			_implementationPackage = _scriptLanguageConfig = null;
			_defaultNode = 1;
			_scriptID = null;
			_soundInstructions = _soundObjects = _items = _goals = _events = _notes = _characters = null;
			_unload = true;
		}
		
		public function getNode( id:uint ):Node
		{
			return _nodes[id];
		}
		
		public function getNodeExists( id:uint ):Boolean
		{
			return (_nodes[id] != null) ? true : false;
		}

		public function getIsValidMovement( id:uint, arrowDirection:String ):Boolean
		{
			var valid:Boolean;
			try {
				valid = ( Node(_nodes[id]).adjacentNodes[arrowDirection] != null ) ? true : false;
			} catch (e:Error) {
				LoggingUtils.errorTrace( e, 'Story Scene Manager' );
			}
			return valid;
		}
		
		public function getEventInsteadOfMovement( id:uint, arrowDirection:String ):Boolean
		{
			var doEvent:Boolean;
			try {
				doEvent = AdjacentNode(Node(_nodes[id]).adjacentNodes[arrowDirection]).issueEvent;
			} catch (e:Error) {
				LoggingUtils.errorTrace( e, 'Story Scene Manager' );
			}
			return doEvent;
		}
		
		public function getMovementDirections( id:uint ):Array
		{
			var returnVal:Array = new Array();
			try {
				for ( var k:String in Node(_nodes[id]).adjacentNodes ) {
					// if has flags required or adjacent has no flagrequirement
					var adjNode:AdjacentNode = AdjacentNode(Node(_nodes[id]).adjacentNodes[k]);
					if ( adjNode.hasFlagRequirement != "" ) {
						if ( FlagManager.getHasFlag(adjNode.flagRequirement) )
							returnVal.push( k );
						else
							trace('flag needed: ' + adjNode.flagRequirement + ' to travel ' + k);
					} else
						returnVal.push( k );	
				}
			} catch (e:Error) {
				LoggingUtils.errorTrace( e, 'Story Scene Manager' );
			}
			return returnVal;
		}
		
		public function getDirectionalNodeID( id:uint, direction:String ):uint
		{
			var nodeID:uint;
			try { 
				nodeID = ( Node(_nodes[id]).adjacentNodes[direction] as AdjacentNode ).id;
			} catch (e:Error) {
				LoggingUtils.errorTrace( e, 'Story Scene Manager' );
			}
			return nodeID;
		}

		public function getLocationNodeDegree( id:uint ):Number
		{
			var compassDegree:Number;
			try { 
				compassDegree = Node(_nodes[id]).compassDegree;
			} catch (e:Error) {
				LoggingUtils.errorTrace( e, 'Story Scene Manager' );
			}
			return compassDegree;
		}
		
		public function getLocationNodeMapLocation( id:uint ):String
		{
			var mapLocation:String = "";
			try { 
				mapLocation = Node(_nodes[id]).mapLocation;
			} catch (e:Error) {
				LoggingUtils.errorTrace( e, 'Story Scene Manager' );
			}
			return mapLocation;
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy():void
		{
			if(_destroyed)
				return;
			unloadStoryScene();
			_sceneLoaded.removeAll();
			_sceneLoaded = null;
			_destroyed = true;
		}
		
		// private methods:
		/**
		 * Initialize public Signals 
		 */
		private function init():void
		{
			_sceneLoaded = new Signal();
		}
	}
}