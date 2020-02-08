package net.strangerdreams.engine.goal
{
	public class GoalType
	{
		public static const INSPECT:String = "inspect";
		public static const SPEECH:String = "speech";
		public static const INTERACT:String = "interact";
		public static const MAP:String = "map";
		
		public static function isValidType(type:String):Boolean
		{
			var valid:Boolean = false;
			if(type==INSPECT||type==SPEECH||type==INTERACT||type==MAP)
				valid=true;
			return valid;
		}
	}
}