package net.deanverleger.utils
{
	public class StringUtils
	{
		public static function randomString(... rest):String
		{
			var chosen:String = rest[MathUtils.randomNumber(0,rest.length-1)] as String;
			return chosen;
		}
	}
}