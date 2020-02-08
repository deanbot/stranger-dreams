package net.strangerdreams.engine.events.data
{
	public class StoryEventResultType
	{
		public static const GOAL:String="goal";
		public static const GOAL_COMPLETE:String="complete";
		public static const GOAL_UPDATE:String="update";
		public static const GOAL_ADD:String="add";
		
		public static const CAPTION:String="caption";
		
		public static const MOVEMENT:String="movement";
		
		public static const MAP:String="map";
		public static const MAP_ADD_CIRCLE:String="addCircle";
		public static const MAP_REMOVE_CIRCLE:String="removeCircle";
		
		public static const FLAG:String="flag";
		public static const FLAG_ADD:String = "add";
		
		public static function isValidType(t:String):Boolean
		{
			var r:Boolean=false;
			if(t==GOAL||t==CAPTION||t==MOVEMENT||t==FLAG||t==MAP)
				r=true;
			return r;
		}
		public static function isValidSubtype(t:String):Boolean
		{
			var r:Boolean=false;
			if(t==GOAL_ADD||t==GOAL_COMPLETE||t==GOAL_UPDATE||t==FLAG_ADD||t==MAP_ADD_CIRCLE||t==MAP_REMOVE_CIRCLE)
				r=true;
			return r;
		}
	}
}