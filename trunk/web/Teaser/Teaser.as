package
{
	import app.Line;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import flash.events.MouseEvent;
	
	public class Teaser extends MovieClip
	{
		private static const PLAYER_WIDTH:int = 760;
		private static const PLAYER_HEIGHT:int = 512;
		private static const NUM_FRAMES:int = 100; // 674; 
		private static const MAX_DELAY:int = NUM_FRAMES / 2 - 1;
		private static const PLAY_FRAME:int = NUM_FRAMES / 2;
		
		private var playPause:String = "play";
		
		private var frames:Vector.<BitmapData> = new Vector.<BitmapData>(NUM_FRAMES, true);
		private var lines:Vector.<Line> = new Vector.<Line>(PLAYER_HEIGHT, true);
		
		private var display:Bitmap;
		private var displayData:BitmapData;
		private var guideLayer:Sprite;
		private var videoLayer:Sprite;
		private var altVideoLayer:Sprite;
		
		private var index:int = 0;
		private var applyDist:Number;
		
		private var destPoint:Point = new Point();
		private var sourceRect:Rectangle = new Rectangle(0, 0, PLAYER_WIDTH, 1);
		
		private var pressX:Number;
		private var pressY:Number;
		
		private var normal:Boolean = false;
		private var alternate:Boolean = false;
		
		private static const ALT_SHOW:int = 3500;
		private static const ALT_BETWEEN:int = 12000;
		private static const TIMER_MIN:int = 1000;
		private static const TIMER_MAX:int = 4000;
		private var altSceneCounter:int;
		private var normalTimer:Timer;
		private var altTimer:Timer;
		private var altVideo:MovieClip;
		
		private var snd:Sound;
		private var channel:SoundChannel;
		private var _transform:SoundTransform;
		
		private var muteButton:MovieClip;
		
		private var statusTextField:TextField  = new TextField();
		
		public function Teaser()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onStage, false, 0, true);
		}
		
		private function onStage(e:Event):void
		{		
			/*
			statusTextField.autoSize = TextFieldAutoSize.LEFT;
			this.addChild(statusTextField);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler2);
			*/
			
			for (var i:int = 0; i < NUM_FRAMES; ++i) {
				frames[i] = new BitmapData(PLAYER_WIDTH, PLAYER_HEIGHT, false, 0x0);
			}
			
			for (var yy:int = 0; yy < PLAYER_HEIGHT; ++yy) {
				var line:Line = new Line();
				lines[yy] = line;
			}
			
			displayData = new BitmapData(PLAYER_WIDTH, PLAYER_HEIGHT, true, 0x0)
			display = new Bitmap(displayData);
			addChild(display);
			
			this.rotationY = 180;
			this.x = PLAYER_WIDTH;
			display.x = (stage.stageWidth - display.width) / 2;
			display.y = (stage.stageHeight - display.height) / 2;
			
			videoLayer = new Sprite();
			var video:MovieClip = new TitleScreen() as MovieClip;
			videoLayer.addChild(video);
			
			altVideoLayer = new Sprite();
			altVideo = new AltVideo() as MovieClip;
			altVideoLayer.addChild(altVideo);
			altVideo.gotoAndStop(altVideo.totalFrames);
			
			this.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			normalTimer = new Timer(3000);
			normalTimer.addEventListener(TimerEvent.TIMER, onNormalTimer, false, 0, true);
			normalTimer.start();
			altTimer = new Timer(ALT_BETWEEN);
			altTimer.addEventListener(TimerEvent.TIMER, onAlternateTimer, false, 0, true);
			altTimer.start();
			
			muteButton=new MuteButton() as MovieClip;
			muteButton.x = 12.95;
			muteButton.y = 477.95;
			addChild(muteButton);
			muteButton.buttonMode = true;
			muteButton.addEventListener(MouseEvent.CLICK,onMutePressed,false,0,true);
			
			//load sounds
			snd = new Sound();
			channel = new SoundChannel();
			_transform = new SoundTransform();
			snd.load(new URLRequest("wp-content/themes/stranger_dreams/04_Parting_At_Morning_edit2.mp3"));
			snd.addEventListener(Event.COMPLETE, onSoundLoaded, false, 0, true);
			snd.addEventListener(IOErrorEvent.IO_ERROR, onSoundError, false, 0, true);
		}
		
		private var muted:Boolean = false;
		
		private function onMutePressed(e:MouseEvent):void
		{
			if(muted)
				muted = false;
			else
				muted = true;
			_transform = channel.soundTransform;
			_transform.volume = (muted == true) ? 0 : 1;
			channel.soundTransform = _transform;
		}
		
		private function onSoundLoaded(evt:Event):void {
			snd.removeEventListener(Event.COMPLETE, onSoundLoaded);
			snd.removeEventListener(IOErrorEvent.IO_ERROR, onSoundError);
			//startTeaser();
			channel = snd.play(0,3);
		}
		
		private function enterFrameHandler2(event:Event):void {    
			var loadTime:Number = snd.bytesLoaded / snd.bytesTotal;
			var loadPercent:uint = Math.round(100 * loadTime);
			var estimatedLength:int = Math.ceil(snd.length / (loadTime));
			var playbackPercent:uint = Math.round(100 * (channel.position / estimatedLength));
			
			statusTextField.text = "Sound file's size is " + snd.bytesTotal + " bytes.\n" 
				+ "Bytes being loaded: " + snd.bytesLoaded + "\n" 
				+ "Percentage of sound file that is loaded " + loadPercent + "%.\n"
				+ "Sound playback is " + playbackPercent + "% complete.";     
		}
		
		private function onSoundError(evt:IOErrorEvent):void {
			//trace(evt);
			//statusTextField.text = "The sound could not be loaded: " + evt.text;
			snd.removeEventListener(Event.COMPLETE, onSoundLoaded);
			snd.removeEventListener(IOErrorEvent.IO_ERROR, onSoundError);
			//startTeaser();
		}
		
		private function startTeaser():void
		{
			for (var i:int = 0; i < NUM_FRAMES; ++i) {
				frames[i] = new BitmapData(PLAYER_WIDTH, PLAYER_HEIGHT, false, 0x0);
			}
			
			for (var yy:int = 0; yy < PLAYER_HEIGHT; ++yy) {
				var line:Line = new Line();
				lines[yy] = line;
			}
			
			displayData = new BitmapData(PLAYER_WIDTH, PLAYER_HEIGHT, true, 0x0)
			display = new Bitmap(displayData);
			addChild(display);
			
			this.rotationY = 180;
			this.x = PLAYER_WIDTH;
			display.x = (stage.stageWidth - display.width) / 2;
			display.y = (stage.stageHeight - display.height) / 2;
			
			videoLayer = new Sprite();
			var video:MovieClip = new TitleScreen() as MovieClip;
			videoLayer.addChild(video);
			
			altVideoLayer = new Sprite();
			altVideo = new AltVideo() as MovieClip;
			altVideoLayer.addChild(altVideo);
			altVideo.gotoAndStop(altVideo.totalFrames);
			
			this.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			normalTimer = new Timer(3000);
			normalTimer.addEventListener(TimerEvent.TIMER, onNormalTimer, false, 0, true);
			normalTimer.start();
			altTimer = new Timer(ALT_BETWEEN);
			altTimer.addEventListener(TimerEvent.TIMER, onAlternateTimer, false, 0, true);
			altTimer.start();
			
			muteButton=new MuteButton() as MovieClip;
			muteButton.x = 12.95;
			muteButton.y = 477.95;
			addChild(muteButton);
			muteButton.buttonMode = true;
			muteButton.addEventListener(MouseEvent.CLICK,onMutePressed,false,0,true);
		}
		
		private function onNormalTimer(e:TimerEvent):void 
		{ 
			normal = !normal; 
			normalTimer.stop();
			normalTimer.removeEventListener(TimerEvent.TIMER, onNormalTimer);
			
			normalTimer = new Timer( (normal)?Math.floor(Math.random()*(1+1500-500))+500:Math.floor(Math.random()*(1+TIMER_MAX-TIMER_MIN))+TIMER_MIN );
			normalTimer.addEventListener(TimerEvent.TIMER, onNormalTimer, false, 0, true);
			normalTimer.start();
		}
		
		private function onAlternateTimer(e:TimerEvent):void
		{
			alternate = !alternate; 
			altTimer.stop();
			altTimer.removeEventListener(TimerEvent.TIMER, onAlternateTimer);
			
			if(alternate)
				altVideo.gotoAndStop( (altVideo.currentFrame==altVideo.totalFrames)?1:altVideo.currentFrame+1);
			
			
			altTimer = new Timer( (alternate)?ALT_SHOW:ALT_BETWEEN );
			altTimer.addEventListener(TimerEvent.TIMER, onAlternateTimer, false, 0, true);
			altTimer.start();			
		}
		
		private function enterFrameHandler(event:Event):void 
		{
			//AutoPlay
			pressX = (Math.floor(Math.random()*(1+465-10))+10);
			pressY = (Math.floor(Math.random()*(1+465-10))+10);
			if(!normal)
			{
				var delay:int = (300 - pressX);
				if (delay > MAX_DELAY) {
					delay = MAX_DELAY
				}
				else if (delay < -MAX_DELAY) {
					delay = -MAX_DELAY;
				}
					
				applyDist = 200 - pressY;
				if (applyDist < 0) applyDist *= -1;
			}
			
			update(applyDist, delay);
			
			++index;
			index %= NUM_FRAMES;
		}
		
		private function update(applyDist:int, delay:int = 0):void {
			if(alternate)
				frames[index].draw(altVideoLayer);
			else
				frames[index].draw(videoLayer);
			
			for (var yy:int = 0; yy < PLAYER_HEIGHT; ++yy) {
				var line:Line = lines[yy];
				sourceRect.y = yy;
				destPoint.y = yy;
				
				if(!normal) {
					var dist:Number = pressY - yy;
					if (dist < 0) dist *= -1;
					
					if(dist <= applyDist){
						var per:Number = dist / applyDist;
						line.changeDelayDirect(delay * (1 - per));
					}
					else {
						line.changeDelay(0);
					}
				} else {
					line.changeDelay(0);
				}
				
				var targetFrame:int = (index + PLAY_FRAME + line.delay) % NUM_FRAMES;
				if (targetFrame < 0) {
					targetFrame = NUM_FRAMES + targetFrame;
				}
				
				displayData.copyPixels(frames[targetFrame], sourceRect, destPoint);
			}
		}
	}
}