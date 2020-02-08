package net.strangerdreams.engine.scene.data
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.DictionaryUtils;

	/**
	 * A data class describing a node within a story scene. 
	 * 
	 * @author Dean
	 * 
	 */
	public class Node
	{
		// constants:
		// private properties:
		private var _assetClass:String;
		private var _implementationClass:String;
		private var _id:uint;
		private var _compassDegree:uint;
		private var _mapLocation:String;
		private var _defaultStateKey:String;
		private var _nodeStates:Dictionary;
		private var _dialogTrees:Dictionary;
		private var _numNodeStates:uint;
		private var _numDialogTrees:uint;
		private var _adjacentNodes:Dictionary;
		private var _numAdjacentNodes:uint;
		private var _soundInstructionKey:String;
		
		// public properties:
		// constructor:
		public function Node()
		{
			
		}
		
		// public getter/setters:

		public function get mapLocation():String
		{
			return _mapLocation;
		}

		public function get numDialogTrees():uint
		{
			return _numDialogTrees;
		}

		public function get dialogTrees():Dictionary
		{
			return _dialogTrees;
		}

		public function get assetClass():String
		{
			return _assetClass;
		}
		
		public function get id():uint
		{
			return _id;
		}
		
		public function get compassDegree():uint
		{
			return _compassDegree;
		}
		
		public function get defaultStateKey():String
		{
			return _defaultStateKey;
		}
		
		public function get nodeStates():Dictionary
		{
			return _nodeStates;
		}
		
		public function get adjacentNodes():Dictionary
		{
			return _adjacentNodes;
		}
		
		public function get numAdjacentNodes():Number
		{
			return _numAdjacentNodes;
		}
		
		public function get implementationClass():String
		{
			return _implementationClass;
		}
		
		public function get soundInstructionKey():String
		{
			return _soundInstructionKey;
		}
		
		public function get numNodeStates():uint
		{
			return _numNodeStates;
		}
		
		// public methods:
		/**
		 * Processes xml data into Node properties
		 * 
		 * @param data - xml data to be processed
		 * 
		 */
		public function setData( data:XML ):void
		{
			_id = uint(data.@id);
			_assetClass = String(data.@assetClass);
			_implementationClass = String(data.@implementationClass);
			_compassDegree = uint(data.@compassDegree);
			_mapLocation = String(data.@mapLocation);
			_defaultStateKey = String(data.@defaultState);
			_nodeStates = new Dictionary(true);
			_dialogTrees = new Dictionary(true);
			_numNodeStates = 0;
			_numDialogTrees= 0;
			_soundInstructionKey = String(data.states.@soundInstructionKey);
			for each ( var nodeState:XML in data.states.state )
			{
				var nodeStateObject:NodeState = new NodeState();
				nodeStateObject.setData( nodeState );
				_nodeStates[nodeStateObject.key] = nodeStateObject;
				_numNodeStates++;
			}
			for each ( var dialog:XML in data.dialogs.dialog )
			{
				if(String(dialog.@key)==null||String(dialog.@key)=="")
					throw new Error("Node.setData() Dialog missing key");
				var dialogTree:DialogTree = new DialogTree();
				dialogTree.setData(dialog);
				_dialogTrees[String(dialog.@key)]=dialogTree;
				_numDialogTrees++;
			}
			//trace( "Node [" + _id + ": " + _assetClass + "] says, \"Created " + _numNodeStates + " node state(s).\"" );
			_adjacentNodes = new Dictionary(true);
			_numAdjacentNodes = 0;
			for each ( var adjacentNode:XML in data.adjacents.adjacent )
			{
				var adjacentNodeObject:AdjacentNode = new AdjacentNode();
				adjacentNodeObject.setData( adjacentNode );
				_adjacentNodes[adjacentNodeObject.movementDirection] = adjacentNodeObject;
				_numAdjacentNodes++;
			}
			//trace( "Node [" + _id + ": " + _assetClass + "] says, \"Created " + _numAdjacentNodes + " adjacent node(s).\"" );
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy():void
		{
			for ( var adjacentNode:Object in _adjacentNodes ) {
				AdjacentNode(_adjacentNodes[adjacentNode]).destroy();
				_adjacentNodes[adjacentNode] = null;
				delete _adjacentNodes[adjacentNode];
			}
			_adjacentNodes = null;
			_numAdjacentNodes = 0;
			for ( var nodeState:Object in _nodeStates ) {
				NodeState(_nodeStates[nodeState]).destroy();
				_nodeStates[nodeState] = null;
				delete _nodeStates[nodeState];
			}
			DictionaryUtils.emptyDictionary(_dialogTrees);
			_nodeStates = _dialogTrees = null;
			_numNodeStates = _numDialogTrees = 0;
			_defaultStateKey = null;
			_compassDegree = 0;
			_assetClass = null;
			_id = 0;
		}
		// private methods:
	}
}