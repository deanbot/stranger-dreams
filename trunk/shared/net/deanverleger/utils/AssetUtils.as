package net.deanverleger.utils
{
	import flash.utils.getDefinitionByName;

	public class AssetUtils
	{
		public static function getAssetInstance( definitionName:String ):Object
		{
			if (definitionName==null)
				throw new Error("getAssetInstance(): Definition Name cannot be null");
			//trace(definitionName);
			var assetClass:Class;
			var assetInstance:Object;
			assetClass = getDefinitionByName( definitionName ) as Class;
			assetInstance = new assetClass();
			assetClass = null;
			return assetInstance;
		}
	}
}