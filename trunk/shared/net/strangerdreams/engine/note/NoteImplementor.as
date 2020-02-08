package net.strangerdreams.engine.note
{
	import com.greensock.TweenLite;
	import com.meekgeek.statemachines.finite.events.StateManagerEvent;
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.gui.TextDisplayUtil;
	import net.strangerdreams.app.state.OutroState;
	import net.strangerdreams.engine.note.data.Note;
	import net.strangerdreams.engine.script.data.Caption;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class NoteImplementor extends Sprite
	{
		public static const LOCATION:String = "NoteImplementor";
		private var _asset:MovieClip;
		private var _noteFinished:Signal;
		private var _destroyed:Signal;
		private var _noteDataObject:Note;
		private var _assetAdded:Signal;
		private var _natAssetAdded:NativeSignal;
		private var _sm:StateManager;
		private var _caption:Caption;
		private var _textHolder:Sprite;
		private var _textDisplay:Sprite;
		private var _captionFinished:Signal;
		private var _endPrepCallback:Function;
		private var _endFinishedCallback:Function;
		private var _eachFrameCallback:Function;
		private var outroActionState:NativeSignal;

		public function NoteImplementor()
		{
			_noteFinished = new Signal();
			_assetAdded = new Signal();
			_captionFinished = new Signal();
			_destroyed = new Signal();
			super();
		}
		
		public function get asset():MovieClip
		{
			return _asset;
		}
		
		public function set asset(value:MovieClip):void
		{
			_asset = value;
		}
		
		public function get destroyed():Signal
		{
			return _destroyed;
		}
		
		public function get captionFinished():Signal
		{
			return _captionFinished;
		}
		
		public function get sm():StateManager
		{
			return _sm;
		}

		public function get assetAdded():Signal
		{
			return _assetAdded;
		}

		public function setData(note:Note):void
		{
			_noteDataObject = note;
		}

		public function get noteDataObject():Note
		{
			return _noteDataObject;
		}

		public function get noteFinished():Signal
		{
			return _noteFinished;
		}
		
		public function addAsset(asset:Sprite, invisibleByDefault:Boolean = true):void
		{
			if(asset==null)
			{ LoggingUtils.msgTrace("Asset cannot be null", LOCATION + ".addAsset()"); return; }
			annouceAssetAdded(asset);
			if(invisibleByDefault)
				ClipUtils.hide(asset);
			addChild(asset);
		}
		
		public function activateStateMachine(asset:Sprite):void
		{
			if(asset==null)
				return;
			_sm = new StateManager(asset);
		}
		
		/**
		 * 
		 * @param textFieldHolder Supply your own text field buddy!
		 * @param caption gimme a caption
		 * 
		 */
		public function activateLetterTextDisplay( textFieldHolder:Sprite, caption:Caption, endPrepCallback:Function = null, endFinishedCallback:Function = null, eachFrameCallback:Function = null ):void
		{
			if(textFieldHolder["textField"] == null)
				throw new Error("no text field in textFieldHolder [" + LOCATION + "]");
			if(caption == null)
				throw new Error("caption cannot be null [" + LOCATION + "]");
			_textHolder = textFieldHolder;
			_caption = caption;
			_endPrepCallback = (endPrepCallback !=null) ? endPrepCallback : function():void { };
			_endFinishedCallback = (endFinishedCallback !=null) ? endFinishedCallback : function():void { 
				TweenLite.to(_textHolder, 2, { alpha:0, onComplete:onCaptionFaded});
			};
			_eachFrameCallback = (eachFrameCallback !=null) ? eachFrameCallback : function():void { };
			ClipUtils.makeVisible(_textHolder);
			ClipUtils.hide( TextField(_textHolder["textField"]) );
			_textDisplay = TextDisplayUtil.getTextDisplayControl( _caption, TextField(_textHolder["textField"]), _textHolder, true );
			_textHolder.addChild(_textDisplay);
			addChild(_textHolder);
			TextDisplayUtil.textReady.addOnce( onTextReady );
			_captionFinished.addOnce( onCaptionFinished );
		}
		
		public function annouceAssetAdded(asset:Sprite):void
		{
			if(asset==null)
				return;
			_natAssetAdded = new NativeSignal(asset,Event.ADDED_TO_STAGE, Event);
			_natAssetAdded.addOnce( onAssetAdded );
		}

		public function destroyBase():void
		{
			_noteFinished.removeAll();
			_assetAdded.removeAll();
			_captionFinished.removeAll();
			_noteFinished = _assetAdded = _captionFinished = null;
			_noteDataObject = null;
			_endPrepCallback = _endFinishedCallback = _eachFrameCallback = null;
			if(_sm!=null)
			{
				_sm.addState(OutroState.KEY,new OutroState());
				outroActionState = new NativeSignal(sm,StateManagerEvent.ON_ACTION,StateManagerEvent);
				outroActionState.addOnce( onOutroComplete );
				_sm.setState(OutroState.KEY);
			} else 
			{
				_asset = null;
				_destroyed.dispatch();
				_destroyed.removeAll();
				_destroyed = null;
			}
		}
		
		public function onTextReady():void
		{
			TextDisplayUtil.textFadedIn.addOnce(onTextFadedIn);
			TextDisplayUtil.fadeInText();
		}
		
		public function onTextFadedIn():void
		{
			if(_eachFrameCallback!=null)
				_eachFrameCallback();
			if(_caption.currentScreen==_caption.numScreens)
			{
				if(_endPrepCallback != null)
					_endPrepCallback();
			} else 
			{
				TextDisplayUtil.arrowReady.addOnce(onArrowFadedIn);
				TextDisplayUtil.fadeInArrow();
			}
		}
		
		public function onTextFadedOut():void
		{
			TextDisplayUtil.textReady.addOnce(onTextReady);
			TextDisplayUtil.doCaptionScreen();
		}
		
		public function onArrowFadedIn():void
		{
			TextDisplayUtil.addArrowControls();
			TextDisplayUtil.arrowClicked.addOnce(onArrowClicked);
		}
		
		public function onArrowClicked():void
		{
			if(_caption.currentScreen==_caption.numScreens)
			{
				if(_endFinishedCallback != null)
					_endFinishedCallback();
			} else
			{
				TextDisplayUtil.textFadedOut.addOnce(onTextFadedOut);
				TextDisplayUtil.goToNextScreen();
			}
		}
		
		public function onCaptionFaded():void
		{
			_textHolder.removeChild(_textDisplay);
			TextDisplayUtil.fadeAndRemoveOverlay();
			removeChild(_textHolder);
			_textHolder=null;
			_textDisplay=null;
			_captionFinished.dispatch();
		}
		
		private function onAssetAdded(e:Event):void
		{
			_assetAdded.dispatch();
		}
		
		private function onCaptionFinished():void
		{
			_captionFinished.remove(onCaptionFinished);
			_noteFinished.dispatch();
		}
		
		private function onOutroComplete(e:StateManagerEvent):void
		{
			if(this.numChildren > 0)
				DisplayObjectUtil.removeAllChildren(this);
			_sm.destroy();
			_sm = null;
			_asset = null;
			_destroyed.dispatch();
			_destroyed.removeAll();
			_destroyed = null;
		}
	}
}