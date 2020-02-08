package net.deanverleger.utils
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.core.IDestroyable;

	public class DictionaryUtils
	{
		public static function deleteAt(needle:*,haystack:Dictionary):Boolean {
			var removed:Boolean=false;
			for(var k:Object in haystack)
			{
				if(haystack[k]==needle)
				{
					haystack[k]=null;
					delete haystack[k]
					removed = true;
				}
			}
			return removed;
		}
		
		public static function emptyDestroyable(dict:Dictionary):void
		{
			for(var k:Object in dict)
			{
				Destroyable(dict[k]).destroy();
				dict[k] = null;
				delete dict[k];
			}
		}
		
		public static function emptyDictionary(dict:Dictionary, destroy:Boolean=false, holdsDictionaries:Boolean=false):void
		{
			if (dict==null)
				return;
			var dict2:Dictionary;
			for(var k:String in dict)
			{
				if(holdsDictionaries)
				{
					dict2 = Dictionary(dict[k]);
					for(var k2:String in dict2)
					{
						if(destroy)
							Destroyable(dict2[k2]).destroy();
						dict2[k2]=null;
						delete dict2[k2];
					}
					dict2=null;
				} else if(destroy)
					dict[k]["destroy"]();
				dict[k]=null;
				delete dict[k];
			}
		}
	}
}

interface Destroyable
{
	function destroy():void;
}