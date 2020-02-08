package net.strangerdreams.engine.item.data
{
	public class ItemType
	{
		public static const INVENTORY:String = "inventory";
		public static const KEY:String = "key";
		
		public static function isValidType ( typeCheck:String ):Boolean
		{
			var returnVal:Boolean = false;
			if ( typeCheck == INVENTORY || typeCheck == KEY )
				returnVal = true;
			return returnVal;
		}
	}
}