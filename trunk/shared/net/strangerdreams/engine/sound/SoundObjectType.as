package net.strangerdreams.engine.sound
{
	public class SoundObjectType
	{
		public static var MUSIC:String = "music";
		public static var AMBIENT:String = "ambient";
		
		public static function getIsValidType( typeCheck:String ):Boolean
		{
			var valid:Boolean = false;
			if (typeCheck == MUSIC || typeCheck ==AMBIENT)
				valid = true;
			return valid;
		}
	}
}