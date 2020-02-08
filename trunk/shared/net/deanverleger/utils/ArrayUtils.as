package net.deanverleger.utils
{
	public class ArrayUtils
	{
		public static function empty(tarArray:Array):void
		{
			var l:uint = tarArray.length;
			while (l--)
				tarArray.pop();
		}
	}
}