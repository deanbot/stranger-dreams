package net.strangerdreams.engine.character
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.DictionaryUtils;

	public class CharacterManager
	{
		private static var _characters:Dictionary = new Dictionary(true);
		private static var _destroyed:Boolean;
		
		public static function get destroyed():Boolean
		{
			return _destroyed;
		}

		public static function generate(sceneData:XML):void
		{
			if(sceneData==null)
				return;
			var k:String;
			var a:String;
			_destroyed = false;
			for each(var char:XML in sceneData.character)
			{
				k = String(char.@key);
				if(k==null)
					throw new Error("CharacterManager: Character has no key.");
				a = String(char.@asset);
				if(a==null)
					throw new Error("CharacterManager: Character has no asset.");
				_characters[k] = new Character(k,a);
			}
		}
		
		public static function validChar(k:String):Boolean
		{
			return (_characters[k]!=null)?true:false;
		}
		
		public static function getCharAsset(k:String):MovieClip
		{
			return AssetUtils.getAssetInstance(IKeyAndAsset(_characters[k]).asset) as MovieClip;
		}
		
		public static function clear():void
		{
			if(!_destroyed)
			{
				DictionaryUtils.emptyDictionary(_characters);
				_characters = null;
				_destroyed = true;
			}
		}
	}
}