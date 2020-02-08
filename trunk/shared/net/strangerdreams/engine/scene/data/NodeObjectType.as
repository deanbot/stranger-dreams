package net.strangerdreams.engine.scene.data
{
	public class NodeObjectType
	{
		public static const INTERACT:String = "interact";
		public static const GRAB:String = "grab";
		public static const LINK:String = "link";
		public static const DIALOG:String = "dialog";
		/*public static const INSPECT:String = "inspect";*/
		public static const PICK_UP:String = "pickUp";
		public static const CAPTION:String = "caption";
		public static const SAVE:String = "save";
		public static const	MINIGAME:String = "minigame";
		
		public static function isValidType( typeCheck:String ):Boolean
		{
			var returnVal:Boolean = false;
			if ( typeCheck == INTERACT || typeCheck == LINK || typeCheck == CAPTION || typeCheck == DIALOG || typeCheck == SAVE || typeCheck == MINIGAME || typeCheck==PICK_UP || typeCheck==GRAB )
				returnVal = true;
			return returnVal;
		}
	}
}