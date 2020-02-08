package net.strangerdreams.engine.flag
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.DictionaryUtils;

	public class FlagManager
	{
		private static var _flags:Dictionary = new Dictionary(true);
		
		public static function getHasFlag( flagKey:String ):Boolean
		{
			return (_flags[flagKey] != null) ? true : false;
		}
		
		public static function addFlag(flagKey:String):void
		{
			if(!getHasFlag(flagKey))
				_flags[flagKey]=flagKey;
		}
		
		public static function getHasFlagRequirements( flagRequirements:Array ):Boolean
		{
			var flagReqsMet:Boolean = true;
			if(flagRequirements != null)
			{
				for (var i:uint = 0; i < flagRequirements.length; i++)
				{
					if( !getHasFlag(String(flagRequirements[i])) )
						flagReqsMet = false;
				}
			}
			return flagReqsMet;
		}
		
		public static function clear():void
		{
			DictionaryUtils.emptyDictionary(_flags);
		}
	}
}