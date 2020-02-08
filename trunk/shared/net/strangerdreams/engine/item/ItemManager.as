package net.strangerdreams.engine.item
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.item.data.Item;
	import net.strangerdreams.engine.item.data.ItemType;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.ScriptItem;
	
	import org.osflash.signals.Signal;
	
	public class ItemManager
	{
		public static const LOCATION:String = "Item Manager";
		// private properties:
		private static var _items:Dictionary = new Dictionary(true);
		private static var _inventory:Dictionary = new Dictionary(true);
		private static var _keyItems:Dictionary = new Dictionary(true);
		private static var _numInventory:uint = 0;
		private static var _numKey:uint = 0;
		private static var _destroyed:Boolean;
		
		// public methods:	

		public static function get keyItems():Dictionary
		{
			return _keyItems;
		}

		public static function get destroyed():Boolean
		{
			return _destroyed;
		}

		public static function generate(sceneData:XML):void
		{
			if(sceneData==null)
				return;
			_destroyed = false;
			for each(var itemData:XML in sceneData.item)
			{
				var k:String = String(itemData.@key);
				if(k==null)
					throw new Error("Item Manager: Item has no key.");
				_items[k] = getItemInstance(itemData, StoryScriptManager.getItemInstance(k));
				if(String(itemData.@have)=="true")
				{
					addItemInventory(itemData.@key, false);
				}
			} 
		}
		
		public static function get numKey():uint
		{
			return _numKey;
		}
		
		public static function get inventory():Dictionary
		{
			return _inventory;
		}
		
		public static function get numInventory():uint
		{
			return _numInventory;
		}
		
		public static function getItem(key:String):Item
		{
			return (_items[key]!=null)?Item(_items[key]):null;
		}
			
		public static function hasItem(key:String):Boolean
		{
			var value:Boolean=false;
			if(_items[key]!=null)
			{
				if(Item(_items[key]).type==ItemType.INVENTORY)
				{
					if(_inventory[key]!=null)
						value=true;
				} else if (Item(_items[key]).type==ItemType.KEY)
				{
					if(_keyItems[key]!=null)
						value=true;
				} else 
					trace("ItemManager: Item type ("+Item(_items[key]).type+") not supported");
			}
			return value;
		}
				   
		public static function addItemInventory(key:String,notify:Boolean=false):void
		{
			if(_items[key]!=null)
			{
				if(Item(_items[key]).type==ItemType.INVENTORY)
				{
					_inventory[key]=_items[key];
					_numInventory++;
					SESignalBroadcaster.inventoryItemAdded.dispatch(Item(_items[key]).title, notify);
					LoggingUtils.msgTrace("Adding Item: " + key, LOCATION);
				} else if (Item(_items[key]).type==ItemType.KEY)
				{
					_keyItems[key]=_items[key];
					_numKey++;
					SESignalBroadcaster.keyItemAdded.dispatch(Item(_items[key]).title, notify);
					LoggingUtils.msgTrace("Adding Key Item: " + key, LOCATION);
				} else 
					trace("ItemManager: Item type ("+Item(_items[key]).type+") not supported");
			}
		}
		
		public static function removeItemInventory(key:String,notify:Boolean=false):void
		{
			if(hasItem(key))
			{
				
			} else
				trace("Item "+key+"not in inventory or key items");
		}
		
		//public static function addItemsPlayer
		
		public static function clear():void
		{
			if(!_destroyed)
			{
				var k:Object;
				for(k in _inventory)
				{
					_inventory[k]=null;
					delete _inventory[k];
				}
				for(k in _keyItems)
				{
					_keyItems[k]=null;
					delete _keyItems[k];
				}
				for(k in _items)
				{
					_items[k]=null;
					delete _items[k];
				}
				_destroyed = true;
			}
		}
		
	// private methods:	
		private static function getItemInstance(data:XML, scriptItem:ScriptItem):Item
		{
			if(data.@key=='')
				throw new Error("Item Manager (generateItemInstance): no item key");
			if(data.@assetClass=='')
				throw new Error("Item Manager (generateItemInstance): no assetClass");
			if(data.@type=='')
				throw new Error("Item Manager (generateItemInstance): no assetClass");
			if(!ItemType.isValidType(data.@type))
				throw new Error("Item Manager (generateItemInstance): item not valid type");
			return new Item(data.@key, scriptItem.title, scriptItem.description, data.@assetClass, data.@type);
		}
	}
}