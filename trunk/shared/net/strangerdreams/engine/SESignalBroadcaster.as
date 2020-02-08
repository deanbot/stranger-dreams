package net.strangerdreams.engine
{
	import net.strangerdreams.engine.scene.data.DialogTree;
	import net.strangerdreams.engine.scene.data.NodeObject;
	import net.strangerdreams.engine.script.data.Caption;
	
	import org.osflash.signals.Signal;

	public class SESignalBroadcaster
	{
		//story engine
		private static var _changeNode:Signal = new Signal( uint );
		private static var _sceneEndReached:Signal = new Signal();
		private static var _miniGameExit:Signal = new Signal();
		private static var _miniGameEnter:Signal = new Signal( String );
		private static var _queueUpdateState:Signal = new Signal(); //queues updateState
		private static var _updateState:Signal = new Signal(); // initiates or queuesupdate state
		private static var _quitToMain:Signal = new Signal();
		private static var _quitGame:Signal = new Signal();
		//ui
		private static var _interactiveRollOver:Signal = new Signal( String );
		private static var _interactiveRollOut:Signal = new Signal();
		private static var _interactiveClick:Signal = new Signal( NodeObject );
		private static var _hideHUD:Signal = new Signal(Boolean);
		private static var _showHUD:Signal = new Signal(Boolean);
		private static var _calculateCompassCommand:Signal = new Signal();
		private static var _enterInternalState:Signal = new Signal();
		private static var _leaveInternalState:Signal = new Signal();
		private static var _noTransition:Signal = new Signal();
		private static var _compassDirectionClicked:Signal = new Signal( String );
		private static var _blockToggle:Signal = new Signal(Boolean); // just blocks stuff from being pressed. you can't see it.
		private static var _itemUsed:Signal = new Signal( String ); //item key
		private static var _saveTriggered:Signal = new Signal( String, String, String ); // save dialog text (ex. "Save Game?"), yes text ("Yes"), no text ("No")
		private static var _questionOptionSelected:Signal = new Signal( String );
		private static var _questionTriggered:Signal = new Signal( String, String, String );
		//caption
		private static var _captionComplete:Signal = new Signal();
		private static var _captionTriggered:Signal = new Signal( NodeObject,Boolean ); //boolean - whether to wait for transition
		private static var _singleCaption:Signal = new Signal( String );
		//dialog
		private static var _dialogComplete:Signal = new Signal();
		private static var _dialogTriggered:Signal = new Signal( DialogTree, NodeObject, Boolean) ; //boolean - whether to wait for transition
		//notification
		private static var _singleNotification:Signal = new Signal(String);
		private static var _pauseNotification:Signal = new Signal();
		private static var _resumeNotification:Signal = new Signal();
		//inventory
		private static var _inventoryItemAdded:Signal = new Signal(String,Boolean);
		private static var _keyItemAdded:Signal = new Signal(String,Boolean);
		//goals
		private static var _goalAdded:Signal = new Signal(String,String,Boolean); //title,type,notify
		private static var _goalUpdated:Signal = new Signal(String,String,String,Boolean); //oldTitle,newTitle,type,notify
		private static var _goalComplete:Signal = new Signal(String,Boolean); //title,notify
		//notes
		private static var _doNoteOverlay:Signal = new Signal(String,Boolean); //note key, whether to call from menu or from frame (useFrameOverlay:Boolean = false);
		private static var _queueNoteOverlay:Signal = new Signal(String,Boolean); //note key, whether to call from menu or from frame
		private static var _noteOverlayFinished:Signal = new Signal();


		public static function get questionTriggered():Signal
		{
			return _questionTriggered;
		}

		public static function get questionOptionSelected():Signal
		{
			return _questionOptionSelected;
		}

		public static function get saveTriggered():Signal
		{
			return _saveTriggered;
		}

		public static function get itemUsed():Signal
		{
			return _itemUsed;
		}

		public static function get dialogTriggered():Signal
		{
			return _dialogTriggered;
		}

		public static function get dialogComplete():Signal
		{
			return _dialogComplete;
		}

		public static function get quitGame():Signal
		{
			return _quitGame;
		}

		public static function get quitToMain():Signal
		{
			return _quitToMain;
		}

		public static function get queueUpdateState():Signal
		{
			return _queueUpdateState;
		}

		public static function get updateState():Signal
		{
			return _updateState;
		}

		public static function get blockToggle():Signal
		{
			return _blockToggle;
		}

		public static function get compassDirectionClicked():Signal
		{
			return _compassDirectionClicked;
		}

		public static function get noteOverlayFinished():Signal
		{
			return _noteOverlayFinished;
		}

		public static function get queueNoteOverlay():Signal
		{
			return _queueNoteOverlay;
		}

		public static function get doNoteOverlay():Signal
		{
			return _doNoteOverlay;
		}

		public static function get noTransition():Signal
		{
			return _noTransition;
		}

		public static function get leaveInternalState():Signal
		{
			return _leaveInternalState;
		}

		public static function get enterInternalState():Signal
		{
			return _enterInternalState;
		}

		public static function get singleCaption():Signal
		{
			return _singleCaption;
		}

		public static function get goalComplete():Signal
		{
			return _goalComplete;
		}

		public static function get goalUpdated():Signal
		{
			return _goalUpdated;
		}

		public static function get goalAdded():Signal
		{
			return _goalAdded;
		}

		public static function get singleNotification():Signal
		{
			return _singleNotification;
		}

		public static function get keyItemAdded():Signal
		{
			return _keyItemAdded;
		}

		public static function get inventoryItemAdded():Signal
		{
			return _inventoryItemAdded;
		}

		public static function get captionTriggered():Signal
		{
			return _captionTriggered;
		}

		public static function get captionComplete():Signal
		{
			return _captionComplete;
		}

		public static function get showHUD():Signal
		{
			return _showHUD;
		}

		public static function get hideHUD():Signal
		{
			return _hideHUD;
		}

		public static function get sceneEndReached():Signal
		{
			return _sceneEndReached;
		}

		/**
		 * String parameter is the hovertype of the interactive object 
		 * @return the node object rollover signal
		 */
		public static function get interactiveRollOver():Signal
		{
			return _interactiveRollOver;
		}
		
		public static function get interactiveRollOut():Signal
		{
			return _interactiveRollOut;
		}
	
		public static function get interactiveClick():Signal
		{
			return _interactiveClick;
		}
		
		public static function get miniGameExit():Signal
		{
			return _miniGameExit;
		}
		
		public static function get miniGameEnter():Signal
		{
			return _miniGameEnter;
		}

		public static function get calculateCompassCommand():Signal
		{
			return _calculateCompassCommand;
		}

		public static function get changeNode():Signal
		{
			return _changeNode;
		}
	}
}