package net.strangerdreams.engine.scene.data
{
	import flash.utils.Dictionary;

	/**
	 * A data class describing a state (for use with state machine) in a node withing a story scene.
	 * 
	 * @author Dean
	 * 
	 */
	public class NodeState
	{
		// constants:
		// private properties:
		private var _key:String;
		private var _startFrame:String;
		private var _stopFrame:String;
		private var _loopStart:String;
		private var _loopEnd:String;
		private var _nodeObjects:Dictionary;
		private var _numNodeObjects:uint;
		private var _soundInstructionKey:String;
		private var _priority:uint;
		private var _triggeredObjectName:String;
		private var _haltControls:Boolean;
		private var _nextState:String;
		private var _flagRequirement:String;
		private var _hideHUD:Boolean;
		private var _hideMouse:Boolean;
		private var _internalState:Boolean; //is an internal state that sets the compass to show "back"
		
		// public properties:
		// constructor:
		public function NodeState()
		{
			
		}
		
		// public getter/setters:
		
		public function get internalState():Boolean
		{
			return _internalState;
		}

		public function get hideMouse():Boolean
		{
			return _hideMouse;
		}

		public function get hideHUD():Boolean
		{
			return _hideHUD;
		}

		public function get flagRequirement():String
		{
			return _flagRequirement;
		}	
		
		public function get nextState():String
		{
			return _nextState;
		}
		
		public function get haltControls():Boolean
		{
			return _haltControls;
		}
		
		public function get priority():uint
		{
			return _priority;
		}
		
		public function get soundInstructionKey():String
		{
			return _soundInstructionKey;
		}
		
		public function get numNodeObjects():uint
		{
			return _numNodeObjects;
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function get startFrame():String
		{
			return _startFrame;
		}
		
		public function get stopFrame():String
		{
			return _stopFrame;
		}
		
		public function get loopStart():String
		{
			return _loopStart;
		}
		
		public function get loopEnd():String
		{
			return _loopEnd;
		}
		
		public function get nodeObjects():Dictionary
		{
			return _nodeObjects;
		}
		
		public function get triggeredObjectName():String
		{
			return _triggeredObjectName;
		}
		
		public function get hasTriggeredObjectAtStart():Boolean { 
			return (_triggeredObjectName == "" ? false : true); 
		}
		
		// public methods:
		/**
		 * Processes xml data into NodeState properties
		 * 
		 * @param data - xml data to be processed
		 * 
		 */
		public function setData( data:XML ):void
		{
			_key = String(data.@key);
			_startFrame = String(data.@startFrame);
			_stopFrame = String(data.@stopFrame);
			_loopStart = String(data.@loopStart);
			_loopEnd = String(data.@loopEnd);
			_soundInstructionKey = (String(data.@soundInstructionKey) != '') ? String(data.@soundInstructionKey) : null;
			_nodeObjects = new Dictionary(true);
			_numNodeObjects = 0;
			_internalState = (String(data.@type) == 'internal') ? true : false;
			for each ( var object:XML in data.object )
			{
				var nodeObject:NodeObject = new NodeObject();
				nodeObject.setData( object );
				_nodeObjects[nodeObject.name] = nodeObject;
				_numNodeObjects++;
			}
			//trace ("Node State [" + _key + "] says, \"Created " + _numNodeObjects + " node object(s).\"" );
			_triggeredObjectName = String(data.@triggeredObjectAtStart);
			_priority = uint(data.@priority);
			_haltControls = (String(data.@haltControls) == 'true') ? true : false;
			_nextState = String(data.@nextState);
			_flagRequirement = String(data.@flagRequirement);
			_hideHUD= (String(data.@hideHUD) == 'true') ? true : false;
			_hideMouse=(String(data.@hideMouse) == 'true') ? true : false;
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy():void
		{
			_triggeredObjectName = null;
			for ( var object:Object in _nodeObjects ) {
				NodeObject(_nodeObjects[object]).destroy();
				_nodeObjects[object] = null;
				delete _nodeObjects[object];
			}
			_nodeObjects = null;
			_numNodeObjects = 0;
			_loopEnd = null;
			_loopStart = null;
			_stopFrame = null;
			_startFrame = null;
			_soundInstructionKey = null;
			_key = null;
			_priority = 0;
			_haltControls = false;
			_nextState = null;
			_hideHUD = false;
		}
		// private methods:
	}
}