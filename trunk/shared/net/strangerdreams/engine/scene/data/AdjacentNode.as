package net.strangerdreams.engine.scene.data
{
	/**
	 * A data class describing an adjacent node of a node within a story scene
	 *
	 * @author Dean
	 * 
	 */
	public class AdjacentNode
	{
		private var _id:uint = 0;
		private var _movementDirection:String;
		private var _flagRequirement:String;
		private var _issueEvent:Boolean;
		
		public function AdjacentNode()
		{
			
		}
		


		/**
		 * Processes xml data into AdjacentNode properties
		 * 
		 * @param data - xml data to be processed
		 * 
		 */
		public function setData( data:XML ):void
		{
			if( String(data.@issueEvent) == "true")
				_issueEvent = true;
			else
				_id = uint(data.@id);
			_movementDirection = String(data.@movementDirection);
			if ( !CompassArrowDirection.isValidDirection(_movementDirection) )
				throw Error("Adjacent Node - Movement Direction: " + _movementDirection + " is not a valid compass direction. " );
			_flagRequirement = String(data.@flagRequirement);
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy():void
		{
			_flagRequirement = null;
			_movementDirection = null;
			_id = 0;
			_issueEvent = false;
		}
		
		public function get issueEvent():Boolean
		{
			return _issueEvent;
		}

		/**
		 * @return uint - the id of adjacent node's node object
		 */
		public function get id():uint
		{
			return _id;
		}

		/**
		 * @return String - the movement direction used to reach adjacent node from node
		 */
		public function get movementDirection():String
		{
			return _movementDirection;
		}
		
		/**
		 * @return Boolean - whether adjacent node has a flag requirement to meet before being able to be accessed
		 */
		public function get hasFlagRequirement():Boolean { 
			return (_flagRequirement == '' ? false : true); 
		}
		
		/**
		 * @return String - the flag required to access adjacent node
		 */
		public function get flagRequirement():String
		{
			return _flagRequirement;
		}
	}
}