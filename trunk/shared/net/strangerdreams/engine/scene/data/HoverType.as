package net.strangerdreams.engine.scene.data
{
	public class HoverType
	{
		public static const INTERACT:String = "interact";
		public static const GRAB:String = "grab";
		public static const INSPECT:String = "inspect";
		public static const SPEAK:String = "speak";
		public static const ARROW:String = "arrow";
		public static const NONE:String = "none";
		
		public static function isValidType ( typeCheck:String ):Boolean
		{
			var returnVal:Boolean = false;
			if ( typeCheck == INTERACT || typeCheck == INSPECT || typeCheck == SPEAK || typeCheck == ARROW || typeCheck== GRAB || typeCheck == NONE)
				returnVal = true;
			return returnVal;
		}
	}
}