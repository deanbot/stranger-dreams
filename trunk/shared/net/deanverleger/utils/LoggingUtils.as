package net.deanverleger.utils
{
	public class LoggingUtils
	{
		public static function errorTrace( e:Error, location:String = null):void
		{
			var prefix:String = (location != null) ? '[' + location + '] ' : '';
			trace( prefix + e.name + e.message );
		}
		
		public static function msgTrace( msg:String, location:String = null):void
		{
			var prefix:String = (location != null) ? '[' + location + '] ' : '';
			trace( prefix + msg );
		}
	}
}