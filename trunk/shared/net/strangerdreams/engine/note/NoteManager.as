package net.strangerdreams.engine.note
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.note.data.Note;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.ScriptNote;

	public class NoteManager
	{
		public static const LOCATION:String = "Note Manager";
		private static var _notes:Dictionary;
		private static var _noteOrder:Dictionary;
		private static var _noteOrderKey:Dictionary;
		private static var _activeNotes:Dictionary;
		private static var _numActiveNotes:uint = 0;
		private static var _destroyed:Boolean;
		
		public static function get destroyed():Boolean
		{
			return _destroyed;
		}

		public static function get numActiveNotes():uint
		{
			return _numActiveNotes;
		}

		public static function set numActiveNotes(value:uint):void
		{
			_numActiveNotes = value;
		}
		
		public static function get orderderedNotes():Array
		{
			var notes:Array = new Array();
			var note:Note;
			for (var i:uint=0; i<_numActiveNotes; i++)
			{
				note = Note(_notes[ String(_activeNotes[String(_noteOrder[i])])  ]);
				notes.push( note );
			}
			return notes;
		}

		public static function generate(sceneData:XML):void
		{
			
			if(sceneData==null)
				return;
			_notes = new Dictionary(true);
			_noteOrder = new Dictionary(true);
			_noteOrderKey = new Dictionary(true);
			_activeNotes = new Dictionary(true);
			_destroyed = false;
			for each(var noteData:XML in sceneData.note)
			{
				var k:String = String(noteData.@key);
				if(k==null)
					throw new Error("Note Manager: Note has no key.");
				_notes[k] = getNoteInstance(noteData, StoryScriptManager.getNoteInstance(k));
				if(String(noteData.@have)=="true")
				{
					addNote(noteData.@key, false);
					setNoteRead(noteData.@key);
				}
			} 
		}
		
		public static function getNoteImplementor(key:String):NoteImplementor
		{
			var noteImplementor:NoteImplementor = (_notes[key]!=null) ? AssetUtils.getAssetInstance( Note(_notes[key]).implementationClass) as NoteImplementor : null;
			if(noteImplementor != null)
				noteImplementor.setData(Note(_notes[key]));
			return noteImplementor;
		}
		
		public static function getNote(key:String):Note
		{
			return (_notes[key]!=null) ? _notes[key] as Note : null;
		}
		
		public static function hasNote(key:String):Boolean
		{
			if (_notes[key]==null)
				LoggingUtils.msgTrace("Note ["+key+"] doesn't exist",LOCATION + ".hasNote()");
			return (_activeNotes[key] == null) ? false : true;
		}
		
		public static function setNoteRead(key:String):void
		{
			if(_notes[key] != null)
				Note(_notes[key]).read = true;
		}
		
		public static function addNote(key:String, notify:Boolean = true):void
		{
			if (_notes[key]==null)
				LoggingUtils.msgTrace("Note ["+key+"] doesn't exist",LOCATION + ".addNote()");
			if(_activeNotes[key] != null)
			{ 
				//LoggingUtils.msgTrace("Already have Note ["+key+"]",LOCATION + ".addNote()"); 
				return; 
			}
			_activeNotes[key]=key;
			_noteOrder[_numActiveNotes]=key;
			_noteOrderKey[key]=_numActiveNotes;
			_numActiveNotes++;
			LoggingUtils.msgTrace("Adding Note: " + key, LOCATION);
		}

		
		public static function clear():void
		{
			if(!_destroyed)
			{
				_destroyed = true;
				DictionaryUtils.emptyDictionary(_notes);
				DictionaryUtils.emptyDictionary(_noteOrder);
				DictionaryUtils.emptyDictionary(_noteOrderKey);
				DictionaryUtils.emptyDictionary(_activeNotes);
				_notes = null;
				_activeNotes = _noteOrder = _noteOrderKey = _activeNotes = null;
			}
		}
		
		private static function getNoteInstance(data:XML, scriptNote:ScriptNote):Note
		{
			if(data.@key=='')
				throw new Error("Note Manager (getNoteInstance): no note key");
			if(data.@assetClass=='')
				throw new Error("Note Manager (generateItemInstance): no assetClass");
			if(data.@implementationClass=='')
				throw new Error("Note Manager (generateItemInstance): no implementationClass");
			var read:Boolean = (String(data.@read) == "" || String(data.@read) == null) ? false : (String(data.@read) == "true") ? true : false;
			return new Note(data.@key,scriptNote.title,data.@assetClass,data.@implementationClass, read);
		}
	}
}