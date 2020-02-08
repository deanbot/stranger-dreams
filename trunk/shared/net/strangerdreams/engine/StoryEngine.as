package net.strangerdreams.engine
{	
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.character.CharacterManager;
	import net.strangerdreams.engine.events.EventManager;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.goal.GoalManager;
	import net.strangerdreams.engine.item.ItemManager;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.location.LocationNodeManager;
	import net.strangerdreams.engine.note.NoteManager;
	import net.strangerdreams.engine.scene.ISceneOrder;
	import net.strangerdreams.engine.scene.StorySceneManager;
	import net.strangerdreams.engine.scene.data.Node;
	import net.strangerdreams.engine.script.IScriptLanguageConfig;
	import net.strangerdreams.engine.script.ScriptLanguageConfig;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.sound.SoundInstructionManager;
	
	import org.osflash.signals.Signal;

	public class StoryEngine
	{
		public static const LOCATION:String = "StoryEngine";
		// private properties:		
		private var _storySceneManager:StorySceneManager;
		private var _storyScriptManager:StoryScriptManager;
		private var _locationNodeManager:LocationNodeManager;
		private var _currentScene:uint;
		private var _sceneLoaded:Signal;
		private var _sceneFinished:Signal;
		private static var _currentNode:uint;
		private static var _destinationNode:int;
		private static var _unload:Boolean;
		private static var _updateStateQueued:Boolean;
		private var _destroy:Boolean;
		private var _destroyed:Signal;
		private var _scriptLanguageConfig:IScriptLanguageConfig;
		private var _masterLanguageConfig:IScriptLanguageConfig;
		
		// public properties:
		// constructor:
		public function StoryEngine( sceneOrder:ISceneOrder, scriptLanguageConfig:IScriptLanguageConfig, startScene:uint = 0 ) 
		{
			SEConfig.sceneOrder = sceneOrder.sceneOrder;
			_currentScene = startScene;
			_scriptLanguageConfig = _masterLanguageConfig = scriptLanguageConfig;
			_storySceneManager = new StorySceneManager();
			_storyScriptManager = new StoryScriptManager(scriptLanguageConfig);
			_locationNodeManager = new LocationNodeManager();
			init();
			_destroy = false;
		}

		// public getter/setters:		

		public function get destroyed():Signal
		{
			return _destroyed;
		}

		public static function get updateStateQueued():Boolean
		{
			return _updateStateQueued;
		}

		public static function set updateStateQueued(value:Boolean):void
		{
			_updateStateQueued = value;
		}

		public static function get unload():Boolean
		{
			return _unload;
		}

		public static function set unload(value:Boolean):void
		{
			_unload = value;
		}

		public static function get currentNode():uint
		{
			return _currentNode;
		}
		
		public function get activeCompassDirections():Array
		{		
			return _storySceneManager.getMovementDirections( currentNode );
		}
		
		public function get sceneLoaded():Signal 
		{ 
			return _sceneLoaded; 
		}
		
		public function get sceneFinished():Signal
		{
			return _sceneFinished;
		}
		
		public function get currentScene():uint
		{
			return _currentScene;
		}
		
		public function get scriptID():String
		{
			return _storySceneManager.scriptID;
		}
		
		public function get sceneUsesHUD():Boolean 
		{
			return StorySceneManager.useHUD;
		}
		
		public static function set destinationNode( nodeID:int ):void
		{
			_destinationNode = nodeID;
		}
		
		public static function get destinationNode():int
		{
			//gets the next node or current node } *destination node should be set as minigame class or looked for in this function
			
			return _destinationNode;
		}
		
		public static function get currentLocationNodeImp():LocationNode
		{
			//return _loc
			//_loc _locationNodeManager._currentNode
			return LocationNodeManager.getLocationNode(_currentNode);
		}
		
		// public methods:	
		public function loadCurrentScene():void {
			_unload = false;
			_storySceneManager.sceneLoaded.addOnce( onStorySceneLoaded );
			_storySceneManager.loadStoryScene( SEConfig.sceneOrder[_currentScene] );
		}
		
		public function unloadCurrentScene():void
		{
			GoalManager.clear();
			NoteManager.clear();
			ItemManager.clear();
			_storyScriptManager.clear();
			_storySceneManager.unloadStoryScene();
			_locationNodeManager.clear();
			FlagManager.clear();
		}

		public function progressScene():void
		{
			_currentScene++;
		}
		
		public function unloadCurrentFrame():void
		{
			LoggingUtils.msgTrace("Unloading Current Frame ("+_currentNode+")",LOCATION);
			_locationNodeManager.unloadLocationNode( _currentNode );
		}
		
		/**
		 * Set the currentNode to the supplied id
		 * @param id node ID
		 * 
		 */
		public function moveTo( id:uint ):void
		{
			//LoggingUtils.msgTrace("Moving To: "+id,LOCATION);
			_currentNode = id;
			_destinationNode = 0;
		}
		
		/**
		 * set the currentNode to node id of node at supplied direction
		 * @param movementDirection valid CompassArrowDirection
		 * 
		 */
		public function moveInDirection( movementDirection:String ):void
		{
			if ( getIsValidMovement( movementDirection ) ) {
				moveTo ( _storySceneManager.getDirectionalNodeID( _currentNode, movementDirection ) );	
			}
		}
		
		public function getLocationNodeAsset( id:uint ):MovieClip 
		{
			return _locationNodeManager.locationNodeAsset( id );
		}
		
		public function getCurrentLocationNodeDegrees():Number
		{
			return _storySceneManager.getLocationNodeDegree( _currentNode );
		}
		
		public function getCurrentLocationNodeMapLocation():String
		{
			return  _storySceneManager.getLocationNodeMapLocation( _currentNode );
		}
		
		public function getAdjacentNodes( id:uint ):Dictionary
		{
			return Node( _storySceneManager.nodes[id]).adjacentNodes;
		}
		
		public function getIsValidMovement( arrowDirection:String ):Boolean
		{
			return _storySceneManager.getIsValidMovement( _currentNode, arrowDirection );
		}
		
		public function getEventInsteadOfMovement( arrowDirection:String ):Boolean
		{
			return _storySceneManager.getEventInsteadOfMovement( _currentNode, arrowDirection);
		}
		
		public function getMovementDirectionNode( arrowDirection:String ):int
		{
			return int(_storySceneManager.getDirectionalNodeID( _currentNode, arrowDirection ));
		}
		
		public function getIsValidNode( nodeID:uint ):Boolean
		{
			return _storySceneManager.getNodeExists( nodeID );
		}
		
		public function destroy():void
		{
			if(!_destroy)
			{
				_destroy = true;
				if(!GoalManager.destroyed)
					GoalManager.clear();
				if(!NoteManager.destroyed)
					NoteManager.clear();
				if(!ItemManager.destroyed)
					ItemManager.clear();
				if(!CharacterManager.destroyed)
					CharacterManager.clear();
				if(!_storyScriptManager.destroyed)
					_storyScriptManager.destroy();
				if(!_storySceneManager.destroyed)
					_storySceneManager.destroy();
				if(!_locationNodeManager.destroyed)
					_locationNodeManager.destroy();
				FlagManager.clear();
				_destroyed.dispatch();
				_destroyed.removeAll();
				_destroyed = null;
			}
		}
		
		// private methods:
		private function onStorySceneLoaded():void
		{
			_currentNode = _storySceneManager.defaultNode;
			
			_locationNodeManager.generateLocationNodes( _storySceneManager.nodes, _storySceneManager.implementationPackage );
			_locationNodeManager.loadLocationNode( _currentNode );
			
			SoundInstructionManager.generate(_storySceneManager.soundInstructions,_storySceneManager.soundObjects);
			EventManager.generate(_storySceneManager.events);
			CharacterManager.generate(_storySceneManager.characters);
			
			//set new script config
			if(_storySceneManager.scriptLanguageConfig == "")
				_scriptLanguageConfig = _masterLanguageConfig;
			else
				_scriptLanguageConfig = AssetUtils.getAssetInstance(_storySceneManager.scriptLanguageConfig) as IScriptLanguageConfig;
			_storyScriptManager.languagePackage = _scriptLanguageConfig.languagePackage;
			_storyScriptManager.scriptPackage = _scriptLanguageConfig.scriptPackage;
			_storyScriptManager.scriptSuffix = _scriptLanguageConfig.scriptSuffix;
			_storyScriptManager.scriptLoaded.addOnce( onScriptLoaded );
			_storyScriptManager.loadScript( _storySceneManager.scriptPackage, _storySceneManager.scriptID );
		}
		
		private function onScriptLoaded():void
		{
			ItemManager.generate(_storySceneManager.items);
			GoalManager.generate(_storySceneManager.goals);
			NoteManager.generate(_storySceneManager.notes);
			
			SESignalBroadcaster.queueUpdateState.add(onUpdateStateQueued);
			sceneLoaded.dispatch();
		}
		
		/**
		 * Initialize public Signals 
		 */
		private function init():void
		{
			_sceneLoaded = new Signal();
			_sceneFinished = new Signal();
			_destroyed = new Signal();
		}
		
		private function onUpdateStateQueued():void
		{
			if(!_updateStateQueued)
				updateStateQueued = true;
		}
	}
}