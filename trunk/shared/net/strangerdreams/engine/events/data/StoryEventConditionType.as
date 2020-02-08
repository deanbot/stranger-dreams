package net.strangerdreams.engine.events.data
{
	public class StoryEventConditionType
	{
		public static const LOCATION:String="location";
		public static const ITEM:String ="item";
		public static const FLAG:String="flag";
		public static const NOTE:String="note";
		public static function isValidType(t:String):Boolean
		{
			var r:Boolean=false;
			if(t==LOCATION||t==ITEM||t==FLAG||t==NOTE)
				r=true;
			return r;
		}
	}
}