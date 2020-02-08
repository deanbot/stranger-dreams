package net.strangerdreams.engine.scene.data
{
	public class CompassArrowDirection
	{
		public static const ARROW_N:String = "N";
		public static const ARROW_E:String = "E";
		public static const ARROW_S:String = "S";
		public static const ARROW_W:String = "W";
		
		public static function isValidDirection ( direction:String ):Boolean
		{
			var returnVal:Boolean = false;
			if ( direction == ARROW_N || direction == ARROW_E || direction == ARROW_S || direction == ARROW_W )
				returnVal = true;
			return returnVal;
		}
	}
}