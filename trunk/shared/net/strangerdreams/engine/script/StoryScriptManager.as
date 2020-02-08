package net.strangerdreams.engine.script
{
	import flash.display.Screen;
	import flash.utils.Dictionary;
	
	import net.deanverleger.data.IXMLObject;
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.DictionaryUtils;
	import net.strangerdreams.engine.goal.data.Goal;
	import net.strangerdreams.engine.script.data.Caption;
	import net.strangerdreams.engine.script.data.Dialog;
	import net.strangerdreams.engine.script.data.DialogOption;
	import net.strangerdreams.engine.script.data.ScriptItem;
	import net.strangerdreams.engine.script.data.ScriptNote;
	import net.strangerdreams.engine.script.data.ScriptScreen;
	import net.strangerdreams.engine.script.data.ScriptVersion;
	
	import org.osflash.signals.Signal;

	public class StoryScriptManager
	{
		// constants:
		// private properties:
		private static var _dialogs:Dictionary;
		private static var _dialogOptions:Dictionary;
		private static var _captions:Dictionary;
		private static var _items:Dictionary;
		private static var _goals:Dictionary;
		private static var _notes:Dictionary;
		private static var _events:Dictionary;
		private var _scriptRootPackage:String = "net.strangerdreams.app";
		private var _languagePackage:String = "en";
		private var _scriptSuffix:String = "_Script_Data";
		private var _scriptLoaded:Signal;
		private var _destroyed:Boolean;
		private var cleared:Boolean;
		
		// public properties:
		// constructor:
		public function StoryScriptManager( scriptLanguageConfig:IScriptLanguageConfig )
		{
			_languagePackage = scriptLanguageConfig.languagePackage;
			_scriptRootPackage = scriptLanguageConfig.scriptPackage;
			_scriptSuffix = scriptLanguageConfig.scriptSuffix;
			init();
			_destroyed = cleared = false;
		}
		
		// public getter/setters:

		public function get destroyed():Boolean
		{
			return _destroyed;
		}

		public function get languagePackage():String
		{
			return _languagePackage;
		}
		
		public function set languagePackage(value:String):void
		{
			_languagePackage = value;
		}
		
		public function get scriptPackage():String
		{
			return _scriptRootPackage;
		}
		
		public function set scriptPackage(value:String):void
		{
			_scriptRootPackage = value;
		}
		
		public function get scriptSuffix():String
		{
			return _scriptSuffix;
		}
		
		public function set scriptSuffix(value:String):void
		{
			_scriptSuffix = value;
		}
		
		public function get scriptLoaded():Signal
		{
			return _scriptLoaded;
		}
		
		// public methods:
		/**
		 * Load and process script data into script objects. 
		 * 
		 * Script is identified by:
		 * 		> script package (i.e. "net.strangerdreams.app")
		 * 		> language package (i.e. "en")
		 * 		> supplied story scene id (i.e. "tutorial")
		 * 		> script suffix (i.e. "Script_Data") (possibly optional)
		 * 
		 * Wait for scriptLoaded before referencing.
		 * 
		 * @param storySceneID Script ID from Scene
		 * 
		 */
		public function loadScript(scriptPackage:String, storySceneID:String):void
		{
			//trace(_scriptRootPackage + '.' + scriptPackage + '.' + _languagePackage + '.' + storySceneID + _scriptSuffix);
			var data:XML = ( AssetUtils.getAssetInstance(_scriptRootPackage + '.' + scriptPackage + '.' + _languagePackage + '.' + storySceneID + _scriptSuffix) as IXMLObject ).xml;
			_items = generateItems(data);
			_dialogs = generateDialogs(data);
			_dialogOptions = generateDialogOptions(data);
			_captions = generateCaptions(data);
			_goals = generateGoals(data);
			_notes = generateNotes(data);
			_scriptLoaded.dispatch();
		}
		
		/**
		 * Stub for now. will destroy all script objects 
		 */
		public function clear():void
		{
			if(cleared)
				return;
			DictionaryUtils.emptyDictionary(_dialogs);
			DictionaryUtils.emptyDictionary(_dialogOptions);
			DictionaryUtils.emptyDictionary(_captions);
			DictionaryUtils.emptyDictionary(_items);
			DictionaryUtils.emptyDictionary( _goals);
			DictionaryUtils.emptyDictionary( _notes);
			DictionaryUtils.emptyDictionary( _events);
			_dialogs = _dialogOptions = _captions = _items = _goals = _notes = _events = null;
			_scriptRootPackage = "net.strangerdreams.app";
			_languagePackage = "en";
			_scriptSuffix = "_Script_Data";
			cleared = true;
		}
		
		public function destroy():void
		{
			if(!_destroyed)
			{
				clear();
				if(_scriptLoaded!=null)
					_scriptLoaded.removeAll();
				_scriptLoaded = null;
				_destroyed = true;
			}
		}
		
		public static function isValidCaption(captionKey:String):Boolean
		{
			return (_captions[captionKey]!=null)?true:false;
		}
		
		public static function getCaptionInstance(captionKey:String):Caption
		{
			return Caption(_captions[captionKey]);
		}
		
		public static function getItemInstance(itemKey:String):ScriptItem
		{
			return ScriptItem(_items[itemKey]);
		}
		
		public static function getGoalInstance(itemKey:String):ScriptItem
		{
			return ScriptItem(_goals[itemKey]);
		}
		
		public static function getNoteInstance(itemKey:String):ScriptNote
		{
			return ScriptNote(_notes[itemKey]);
		}
		
		public static function getDialogInstance(key:String):Dialog
		{
			return Dialog(_dialogs[key]);
		}
		
		public static function getDialogOptionInstance(key:String):DialogOption
		{
			return DialogOption(_dialogOptions[key]);
		}
		
		// private methods:
		/** 
		 * Initialize public Signals 
		 */
		private function init():void
		{
			_scriptLoaded = new Signal();
		}
		
		private function generateCaptions(data:XML):Dictionary
		{
			var captions:Dictionary = new Dictionary(true);
			var caption:XML;
			for each(caption in data.captions.caption)
			{
				captions[String(caption.@key)]=generateCaptionInstance(caption);
			}
			for each(var node:XML in data.captions.node)	
				for each(caption in node.caption)
					captions["n"+String(node.@id)+caption.@objectKey]=generateCaptionInstance(caption,true);
			return captions;
		}
		
		private function generateDialogs(data:XML):Dictionary
		{
			var dialogs:Dictionary = new Dictionary(true);
			var dialog:XML;
			for each (dialog in data.dialogs.dialog)
				dialogs[String(dialog.@key)]=generateDialogInstance(dialog);
			for each( var node:XML in data.dialogs.node)
				for each(dialog in node.dialog)
					dialogs["n"+String(node.@id)+dialog.@key]=generateDialogInstance(dialog);
			return dialogs;
		}
		
		private function generateDialogOptions(data:XML):Dictionary
		{
			var dialogOptions:Dictionary = new Dictionary(true);
			var option:XML;
			for each (option in data.dialogs.option)
				dialogOptions[String(option.@key)]=generateDialogOptionInstance(option);
			for each( var node:XML in data.dialogs.node)
				for each(option in node.option)
					dialogOptions["n"+String(node.@id)+option.@key]=generateDialogOptionInstance(option);
			return dialogOptions;
		}
		
		private function generateItems(data:XML):Dictionary
		{
			var items:Dictionary = new Dictionary(true);
			for each(var item:XML in data.items.item)
				items[String(item.@key)] = generateItemInstance(item);
			return items;
		}
		
		private function generateGoals(data:XML):Dictionary
		{
			var goals:Dictionary = new Dictionary(true);
			for each(var goal:XML in data.goals.goal)
				goals[String(goal.@key)] = generateGoalInstance(goal);
			return goals;
		}
		
		private function generateNotes(data:XML):Dictionary
		{
			var notes:Dictionary = new Dictionary(true);
			for each(var note:XML in data.notes.note)
				notes[String(note.@key)] = generateNoteInstance(note);
			return notes;
		}
		
		private function generateCaptionInstance(data:XML,node:Boolean=false):Caption
		{
			var captionKey:String;
			if(node)
				captionKey=data.@objectKey;
			else
				captionKey=data.@key;
			
			if(captionKey=='')
				throw new Error("Story Script Manager (generateCaptionInstance): caption has no Object Key");
			
			var text:String=data.text();
			var screens:Dictionary;
			var alternateBetweenScreens:Boolean=(String(data.@alternate)=="true")?true:false;
			var versions:Dictionary;
			if(text=='')
			{
				if(data.screen.length()>0)
				{
					screens = generateScreens(data.screen)
				} else if(data.version.length()>0)
				{
					versions=new Dictionary(true);
					for each(var version:XML in data.version)
					{
						var vScreens:Dictionary;
						if(version.screen.length()>0)
						{
							vScreens = generateScreens(version.screen);
						}
						var vAlternateBetweenScreens:Boolean = (String(version.@alternate)=="true")?true:false;
						if(uint(version.@priority)==0)
							throw new Error("Story Script Manager (generateCaptionInstance): version priority cannot be 0");
						var versionO:ScriptVersion=new ScriptVersion(uint(version.@priority),version.text(),String(version.@flagRequirement),vScreens,vAlternateBetweenScreens);
						versions[( (alternateBetweenScreens==true)?uint(version.@order): uint(version.@priority) )]=versionO;
					}
				}
			}
			if(text==''&&screens==null&&versions==null)
				throw new Error("Story Script Manager (generateCaptionInstance): generated empty caption");
			return new Caption(captionKey,text,screens,alternateBetweenScreens,versions);
		}
		
		private function generateDialogInstance(data:XML):Dialog
		{
			var key:String = data.@key;
			
			if(key=='')
				throw new Error("Story Script Manager (generateDialogInstance): dialog has no key");
			
			var text:String=data.text();
			var screens:Dictionary;
			var alternateBetweenScreens:Boolean=(String(data.@alternate)=="true")?true:false;
			var versions:Dictionary;
			if(text=='')
			{
				if(data.screen.length()>0)
				{
					screens = generateScreens(data.screen)
				} else if(data.version.length()>0)
				{
					versions=new Dictionary(true);
					for each(var version:XML in data.version)
					{
						var vScreens:Dictionary;
						if(version.screen.length()>0)
						{
							vScreens = generateScreens(version.screen);
						}
						var vAlternateBetweenScreens:Boolean = (String(version.@alternate)=="true")?true:false;
						if(uint(version.@priority)==0)
							throw new Error("Story Script Manager (generateCaptionInstance): version priority cannot be 0");
						var versionO:ScriptVersion=new ScriptVersion(uint(version.@priority),version.text(),String(version.@flagRequirement),vScreens,vAlternateBetweenScreens);
						versions[( (alternateBetweenScreens==true)?uint(version.@order): uint(version.@priority) )]=versionO;
					}
				}
			}
			if(text==''&&screens==null&&versions==null)
				throw new Error("Story Script Manager (generateCaptionInstance): generated empty caption");
			return new Dialog(key,text,screens,alternateBetweenScreens,versions);
		}
		
		private function generateDialogOptionInstance(data:XML):DialogOption
		{
			var key:String = data.@key;	
			if(key=='')
				throw new Error("Story Script Manager (generateDialogOptionInstance): dialogOption has no key");
			var text:String=data.text();
			var screens:Dictionary;
			var alternateBetweenScreens:Boolean=(String(data.@alternate)=="true")?true:false;
			if(text=='')
				if(data.screen.length()>0)
					screens = generateScreens(data.screen);
			if(text==''&&screens==null)
				throw new Error("Story Script Manager (generateDialogOptionInstance): generated empty dialog option");
			return new DialogOption(key,text,screens,alternateBetweenScreens);
		}
		
		private function generateItemInstance(data:XML):ScriptItem
		{
			evaluateScriptItemData(data);
			return new ScriptItem(data.@key,data.@title,data.@description);
		}
		
		private function generateGoalInstance(data:XML):ScriptItem
		{
			evaluateScriptItemData(data);
			return new ScriptItem(data.@key,data.@title,data.@description);
		}
		
		private function evaluateScriptItemData(data:XML):void
		{
			if(data.@key=='')
				throw new Error("Story Script Manager (evaluateScriptItemData): no item key");
			if(data.@title=='')
				throw new Error("Story Script Manager (evaluateScriptItemData): no item title");
			if(data.@description=='')
				throw new Error("Story Script Manager (evaluateScriptItemData): no item description");
		}
		
		private function generateNoteInstance(data:XML):ScriptNote
		{
			if(data.@key=='')
				throw new Error("Story Script Manager (generateNoteInstance): no item key");
			if(data.@title=='')
				throw new Error("Story Script Manager (generateNoteInstance): no item title");
			return new ScriptNote(data.@key, data.@title);
		}
		
		private function generateScreens(data:XMLList):Dictionary
		{
			var screens:Dictionary=new Dictionary(true);
			var subScreens:Dictionary;
			
			for each(var screen:XML in data)
			{
				subScreens = null;
				if(uint(screen.@order)==0)
					throw new Error("Story Script Manager (generateCaptionInstance): screen order cannot be 0");
				
				if(screen.screen.length()>0)
					subScreens = generateSubScreens(screen.screen);
				else
					if(screen.text()=='')
						throw new Error("Story Script Manager (generateCaptionInstance): generated empty screen");
				var screenO:ScriptScreen=new ScriptScreen(uint(screen.@order),screen.text(),subScreens);
				screens[uint(screen.@order)]=screenO;
			}
			return screens;
		}
		
		
		private function generateSubScreens(data:XMLList):Dictionary
		{
			var subScreens:Dictionary=new Dictionary(true);
			for each(var screen:XML in data)
			{
				if(uint(screen.@order)==0)
					throw new Error("Story Script Manager (generateCaptionInstance): screen order cannot be 0");
				if(screen.text()=='')
					throw new Error("Story Script Manager (generateCaptionInstance): generated empty screen");
				
				var screenO:ScriptScreen=new ScriptScreen(uint(screen.@order),screen.text());
				subScreens[uint(screen.@order)]=screenO;
			}
			return subScreens;
		}
	}
}