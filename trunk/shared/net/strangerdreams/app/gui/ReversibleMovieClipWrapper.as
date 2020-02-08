package net.strangerdreams.app.gui
{
	import com.gskinner.utils.FrameScriptManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	/**
	 * Wrapper for a MovieClip that allows reversing
	 * @author Dean
	 * 
	 */
	public class ReversibleMovieClipWrapper extends Sprite
	{
		private var _clip:MovieClip;
		private var _loop:Boolean
		protected var _isReversing:Boolean;
		private var _startLabel:String;
		private var _endLabel:String;
		private var enterFrame:NativeSignal;
		private var fsm:FrameScriptManager;
		
		public function ReversibleMovieClipWrapper(clip:MovieClip, startLabel:String = "start", endLabel:String = "end", loop:Boolean = false)
		{
			super();
			if (clip == null)
				_clip = new MovieClip();
			else
				_clip = clip;
			_loop = loop;
			_startLabel = startLabel;
			_endLabel = endLabel;
			addChild(_clip);
			enterFrame = new NativeSignal(_clip, Event.ENTER_FRAME, Event);
			fsm = new FrameScriptManager(_clip);
			fsm.setFrameScript(_endLabel, this.stopAndDispatch);
			if (!_loop)
				fsm.setFrameScript(_startLabel, this.stop);
		}
		
		/**
		 Plays the timeline in reverse from current playhead position.
		 */
		public function reverse():void {
			this._playInReverse();
		}
		
		/**
		 Sends the playhead to the specified frame on and reverses from that frame.
		 
		 @param frame: A number representing the frame number or a string representing the label of the frame to which the playhead is sent.
		 */
		public function gotoAndReverse(frame:Object):void {
			this._clip.gotoAndStop(frame);
			
			this._playInReverse();
		}
		
		public function gotoAndPlay(frame:Object, scene:String = null):void {
			this._stopReversing();
			
			this._clip.gotoAndPlay(frame, scene);
		}
		
		public function gotoAndStop(frame:Object, scene:String = null):void {
			this._stopReversing();
			
			this._clip.gotoAndStop(frame, scene);
		}
		
		public function stop():void { 
			this._stopReversing();
			this._clip.stop(); 
		}
		
		private var _stopFrame:Signal = new Signal(ReversibleMovieClipWrapper);
		
		public function get stopFrame():Signal { return _stopFrame; }
		
		private function stopAndDispatch():void {
			this.stop();
			_stopFrame.dispatch(this);
		}
		
		public function play():void { 
			this._stopReversing();
			this._clip.play();
		}
		
		/**
		 Determines if the MovieClip is currently reversing <code>true</code>, or is stopped or playing <code>false</code>.
		 */
		public function get reversing():Boolean {
			return this._isReversing;
		}

		public function get currentFrameLabel():String {
			return this._clip.currentLabel;
		}
		
		protected function _stopReversing():void {
			if (!this._isReversing)
				return;
			
			this._isReversing = false;
			
			this.enterFrame.remove(this._gotoFrameBefore);
		}
		
		protected function _playInReverse():void {
			if (this._isReversing)
				return;
			
			this._isReversing = true;
			
			this.enterFrame.add(this._gotoFrameBefore);
		}
		
		protected function _gotoFrameBefore(e:Event):void {
			if (this._clip.currentFrame == 1) {
				if (this._loop)
					this._clip.gotoAndStop(this._clip.totalFrames);
				else
					this._stopReversing();
			} else
				this._clip.prevFrame();
		}

		public function get startLabel():String
		{
			return _startLabel;
		}

		public function get endLabel():String
		{
			return _endLabel;
		}


	}
}