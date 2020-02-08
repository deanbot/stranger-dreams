package net.strangerdreams.engine.scene.data
{
	/**
	 * A data class describing an object in a state of a node within a story scene. 
	 *
	 * @author Dean
	 * 
	 */
	public class NodeObject
	{
		// constants:
		// private properties:
		private var _name:String;
		private var _type:String;
		private var _hoverType:String;
		private var _givesFlag:String;
		private var _acceptsItem:String;
		private var _flagRequirements:Array;
		private var _antiFlagRequirement:String;
		private var _linkedNode:uint;
		private var _miniGameClass:String;
		private var _calculateAfter:Boolean;
		private var _itemKey:String;
		private var _dialogKey:String;
		private var _itemRemoved:Boolean; //when item is dropped on this node object it is removed from inventory.
		private var _itemUsedNotificationKey:String; //notification key to issue when item is dropped on node object that it accepts
		
		// public properties:
		// constructor:
		public function NodeObject() {
			
		}
		
		// public getter/setters:

		public function get itemUsedNotificationKey():String
		{
			return _itemUsedNotificationKey;
		}

		public function get itemRemoved():Boolean
		{
			return _itemRemoved;
		}

		public function get dialogKey():String
		{
			return _dialogKey;
		}

		public function get antiFlagRequirement():String
		{
			return _antiFlagRequirement;
		}

		public function get itemKey():String
		{
			return _itemKey;
		}
		
		public function get calculateAfter():Boolean
		{
			return _calculateAfter;
		}
		
		/**
		 * @return String - the name of object
		 */
		public function get name():String
		{
			return _name;
		}

		/**
		 * @return String - the type of object (see NodeObjectType.as for list of types)
		 */
		public function get type():String
		{
			return _type;
		}

		/**
		 * @return String - the type of hover icon to be used when hovering over object
		 */
		public function get hoverType():String
		{
			return _hoverType;
		}

		/**
		 * @return String - the flag granted when sufficently interacted with
		 */
		public function get objectFlag():String
		{
			return _givesFlag;
		}

		/**
		 * @return String - the itemkey that node object accepts
		 */
		public function get acceptsItem():String
		{
			return _acceptsItem;
		}

		/**
		 * @return String - the flag required to access object within the node
		 */
		public function get flagRequirements():Array
		{
			return _flagRequirements;
		}

		public function get linkedNode():uint
		{
			return _linkedNode;
		}		
		
		/**
		 * @return the string name of the miniGameClass linked to object
		 */
		public function get miniGameClass():String
		{
			return _miniGameClass;
		}		

		// public methods:
		/**
		 * Processes xml data into NodeObject properties
		 * 
		 * @param data - xml data to be processed
		 * 
		 */
		public function setData( data:XML ):void
		{
			_name = String(data.@name);
			_type = String(data.@type);
			if ( !NodeObjectType.isValidType( _type ) )
				throw Error ("Node Object - Object Type: " + _type + " is not a valid object type.");
			if ( (_hoverType = String(data.@hoverType) ) == '' )
				_hoverType = HoverType.NONE;
			if ( !HoverType.isValidType( _hoverType ) )
				throw Error ("Node Object - Hover Type: " + _hoverType + " is not a valid hover type.");
			_givesFlag = String(data.@givesFlag);
			_acceptsItem = String(data.@acceptsItem);
			_dialogKey = String(data.@dialogKey);
			_flagRequirements = new Array();
			var fr:String = String(data.@flagRequirement);
			if(fr==null||fr=="") {
				if(data.flagRequirement.length() > 0)
					for each( var flagRequirement:XML in data.flagRequirement )
						_flagRequirements.push(flagRequirement.@key);
			} else
				_flagRequirements.push(fr);
			_antiFlagRequirement = String(data.@antiFlagRequirement);
			_linkedNode = uint(data.@linkedNode);
			_miniGameClass = String(data.@miniGameClass);
			_calculateAfter = ( String(data.@calculateAfterFinished) == 'true' ) ? true : false;
			_itemKey = String(data.@itemKey);
			_itemRemoved = (String(data.@itemRemoved) == 'true') ? true: false;
			_itemUsedNotificationKey = String(data.@itemUsedNotificationKey);
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy():void
		{
			_acceptsItem = null;
			_flagRequirements = null;
			_antiFlagRequirement = null;
			_givesFlag = null;
			_hoverType = null;
			_type = null;
			_name = null;
			_linkedNode = 0;
			_miniGameClass = null;
			_calculateAfter = false;
			_itemKey = null;
			_dialogKey = null;
		}	
		// private methods:
	}
}