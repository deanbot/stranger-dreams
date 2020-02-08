package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.script.data.Caption;
	import net.strangerdreams.engine.script.data.ScriptScreen;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	public class TextDisplayUtil
	{
		private static const MANUAL:String = "manual";
		private static const CAPTION:String = "caption";
		private static const CAPTION_FINISHED:String = "captionFinished";
		private static const TEXT_READY:String = "textReady";
		private static const TEXT_FADED_IN:String = "textFadedIn";
		private static const TEXT_FADED_OUT:String = "textFadedIn";
		private static const TEXT_DISPLAY:String = "textDisplay";
		private static const OVERLAY_HOLDER:String = "overlayHolder";
		private static const TEXT_FIELD:String = "textField";
		private static const ARROW:String = "arrow";
		private static const ARROW_SET:String = "arrowSet";
		private static const ARROW_READY:String = "arrowReady";
		private static const ARROW_CLICKED:String = "arrowClicked";
		private static const OVERLAY:String = "overlay";
		private static var vars:Dictionary= new Dictionary(true);
		
		/**
		 * 
		 * @param caption Caption
		 * @param textField textField to update
		 * @param manual whether tweening is handled automatically
		 * @return 
		 * 
		 */
		public static function getTextDisplayControl(caption:Caption,textField:TextField,overlayHolder:Sprite,manual:Boolean=false,arrowX:Number=650.45, arrowY:Number=429.45):Sprite
		{
			/*SESignalBroadcaster.hideHUD.dispatch(false);*/
			var textDisplayController:Sprite;
			vars[TEXT_DISPLAY] = textDisplayController = new Sprite();
			
			vars[CAPTION]=caption;
			vars[TEXT_FIELD]=textField;
			vars[OVERLAY_HOLDER]=overlayHolder;
			vars[MANUAL]=manual;
			
			caption.resetScreen();
			textField.selectable=false;
			textField.condenseWhite=true;
			
			var arrow:Sprite
			arrow=new TextDisplayArrow() as Sprite;
			vars[ARROW]=arrow;
				arrow.x=arrowX;
				arrow.y=arrowY;
				arrow.alpha=0;
			
			if(!textDisplayController.contains(arrow))
				textDisplayController.addChild(arrow);
			
			var arrowSet:InteractiveObjectSignalSet;
			if(vars[ARROW_SET]!=null)
			{
				arrowSet=InteractiveObjectSignalSet(vars[ARROW_SET]);
				arrowSet.removeAll();
			}
			vars[ARROW_SET]=new InteractiveObjectSignalSet(arrow);
			
			if(vars[TEXT_READY]!=null)
				Signal(vars[TEXT_READY]).removeAll();
			vars[TEXT_READY]=new Signal();
			if(vars[TEXT_FADED_IN]!=null)
				Signal(vars[TEXT_FADED_IN]).removeAll();
			vars[TEXT_FADED_IN]=new Signal();
			if(vars[TEXT_FADED_OUT]!=null)
				Signal(vars[TEXT_FADED_OUT]).removeAll();
			vars[TEXT_FADED_OUT]=new Signal();
			if(vars[CAPTION_FINISHED]!=null)
				Signal(vars[CAPTION_FINISHED]).removeAll();
			vars[CAPTION_FINISHED] = new Signal();
			if(vars[ARROW_READY]!=null)
				Signal(vars[ARROW_READY]).removeAll();
			vars[ARROW_READY]=new Signal();
			if(vars[ARROW_CLICKED]!=null)
				Signal(vars[ARROW_CLICKED]).removeAll();
			vars[ARROW_CLICKED]=new Signal();
			
			vars[OVERLAY]=LetterOverlayUtil.getOverlay()
			Sprite(vars[OVERLAY_HOLDER]).addChildAt(Shape(vars[OVERLAY]),0);
			LetterOverlayUtil.bgAction.addOnce(doCaptionScreen);
			LetterOverlayUtil.fadeIn();
			
			return textDisplayController;
		}
		
		public static function get captionFinished():Signal
		{
			return vars[CAPTION_FINISHED] as Signal;
		}
		
		public static function get textReady():Signal
		{
			return vars[TEXT_READY] as Signal;
		}
		
		public static function get textFadedIn():Signal
		{
			return vars[TEXT_FADED_IN] as Signal;
		}
		
		public static function get textFadedOut():Signal
		{
			return vars[TEXT_FADED_OUT];
		}
		
		public static function get backgroundAction():Signal
		{
			return LetterOverlayUtil.bgAction as Signal;
		}
		
		public static function get arrowReady():Signal
		{
			return vars[ARROW_READY] as Signal;
		}
		
		public static function get arrowClicked():Signal
		{
			return vars[ARROW_CLICKED] as Signal;
		}
		
		public static function doCaptionScreen():void
		{
			var caption:Caption = Caption(vars[CAPTION]);

			TextField(vars[TEXT_FIELD]).htmlText=ScriptScreen(caption.screens[caption.currentScreen]).text;

			if(vars[MANUAL])
				Signal(vars[TEXT_READY]).dispatch();
			else
			{
				textFadedIn.addOnce(onTextFaded);
				fadeInText();
			}
		}
		
		public static function goToNextScreen():void
		{
			InteractiveObjectSignalSet(vars[ARROW_SET]).removeAll();
			SESignalBroadcaster.interactiveRollOut.dispatch();
			if(Caption(vars[CAPTION]).currentScreen < Caption(vars[CAPTION]).numScreens)
			{
				Caption(vars[CAPTION]).nextScreen();
				if(!vars[MANUAL])
					textFadedOut.addOnce(doCaptionScreen);
				fadeOutText();
				fadeOutArrow();
			} else
			{
				captionFinished.dispatch();
				cleanUp();
			}
		}

		public static function addArrowControls():void
		{
			var textDisplay:Sprite = vars[TEXT_DISPLAY] as Sprite;
			var arrow:Sprite = vars[ARROW];
			var arrowSet:InteractiveObjectSignalSet=vars[ARROW_SET] as InteractiveObjectSignalSet;
			
			arrowSet.mouseOver.add(function(e:MouseEvent):void{ MouseIconHandler.onInteractiveRollOver();});
			arrowSet.mouseOut.add(function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); });
			arrowSet.click.add(function(e:MouseEvent):void{ arrowClicked.dispatch();});
			if(!vars[MANUAL])
				arrowSet.click.add(function(e:MouseEvent):void{ goToNextScreen(); } );
			if(arrow.hitTestPoint(textDisplay.mouseX,textDisplay.mouseY))
				MouseIconHandler.onInteractiveRollOver();
		}
		
		public static function fadeAndRemoveOverlay():void
		{
			LetterOverlayUtil.fadeOut();
			backgroundAction.addOnce(onBackgroundFadedOut);
		}
		
		public static function fadeInText():void
		{
			TextField(vars[TEXT_FIELD]).alpha=0;
			TweenLite.to(TextField(vars[TEXT_FIELD]),1.5,{alpha:1, onComplete:textFadedIn.dispatch});
		}
		
		public static function fadeOutText():void
		{
			TextField(vars[TEXT_FIELD]).alpha=1;
			TweenLite.to(TextField(vars[TEXT_FIELD]),1.5,{alpha:0,onComplete:textFadedOut.dispatch});
		}
		
		public static function fadeInArrow():void
		{
			Sprite(vars[ARROW]).alpha=0;
			TweenLite.to(Sprite(vars[ARROW]), 1.5, {alpha:1, onComplete: arrowReady.dispatch});
		}
		
		public static function fadeOutArrow():void
		{
			Sprite(vars[ARROW]).alpha=1;
			TweenLite.to(Sprite(vars[ARROW]), 1.5, {alpha:0});
		}
		
		private static function onTextFaded():void
		{
			arrowReady.addOnce(addArrowControls);
			fadeInArrow();
		}
		
		private static function onBackgroundFadedOut():void
		{
			Sprite(vars[OVERLAY_HOLDER]).removeChild( Shape(vars[OVERLAY]) );
		}
		
		private static function cleanUp():void
		{
			if(vars[TEXT_READY]!=null)
				Signal(vars[TEXT_READY]).removeAll();
			if(vars[TEXT_FADED_IN]!=null)
				Signal(vars[TEXT_FADED_IN]).removeAll();
			if(vars[TEXT_FADED_OUT]!=null)
				Signal(vars[TEXT_FADED_OUT]).removeAll();
			if(vars[ARROW_READY]!=null)
				Signal(vars[ARROW_READY]).removeAll();
			if(vars[ARROW_CLICKED]!=null)
				Signal(vars[ARROW_CLICKED]).removeAll();
			if(vars[CAPTION_FINISHED]!=null)
				Signal(vars[CAPTION_FINISHED]).removeAll();
			if(InteractiveObjectSignalSet(vars[ARROW_SET]))
				InteractiveObjectSignalSet(vars[ARROW_SET]).removeAll();
			vars[ARROW_SET]=null;
			vars[TEXT_READY]=vars[TEXT_FADED_IN]=vars[TEXT_FADED_OUT]=vars[ARROW_READY]=vars[ARROW_CLICKED]=null;
		}
	}
}