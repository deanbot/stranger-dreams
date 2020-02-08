package net.strangerdreams.app.gui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import net.deanverleger.utils.LoggingUtils;
	import net.deanverleger.utils.TweenUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class QuestionCaption extends Sprite
	{
		// constants:
		public static const LOCATION:String = "QuestionCaption";
		
		private var _yesPressed:Signal;
		private var _noPressed:Signal;
		private var _unloadFinished:Signal;
		
		private var yesSet:InteractiveObjectSignalSet;
		private var noSet:InteractiveObjectSignalSet;
		private var container:Sprite;
		private var asset:QuestionBackground;
		
		private var _questionText:String;
		private var _yesText:String;
		private var _noText:String;
		private var _block:Block;
		
		public function QuestionCaption(_questionText:String = "Are you ready to leave?", _yesText:String = "Yes", _noText:String="No")
		{
			super();
			questionText=_questionText;
			yesText=_yesText;
			noText=_noText;
			init();
		}
		
		public function set noText(value:String):void
		{
			_noText = value;
		}

		public function set yesText(value:String):void
		{
			_yesText = value;
		}

		public function set questionText(value:String):void
		{
			_questionText = value;
		}

		public function get unloadFinished():Signal
		{
			return _unloadFinished;
		}

		public function get noPressed():Signal
		{
			return _noPressed;
		}

		public function get yesPressed():Signal
		{
			return _yesPressed;
		}

		public function unload():void
		{
			yesSet.removeAll();
			noSet.removeAll();
			
			TweenUtils.bitmapAlphaTween( this.container, this, 1, 0, .3, tweenOutFinished );
		}
		
		public function destroy():void
		{
			unloadFinished.removeAll();
			yesPressed.removeAll();
			noPressed.removeAll();
			yesSet.removeAll();
			noSet.removeAll();
			_yesPressed=_noPressed=_unloadFinished=null;
			yesSet=noSet=null;
			DisplayObjectUtil.removeAllChildren(this,false,true);
			asset=null;
			container=null;
			_block.destroy();
			_block = null;
		}
		
		private function init():void
		{
			_unloadFinished = new Signal();
			_yesPressed = new Signal();
			_noPressed = new Signal();
			container = new Sprite();
			asset = new QuestionBackground();
			yesSet = new InteractiveObjectSignalSet(MovieClip(asset.yes.hit));
			noSet = new InteractiveObjectSignalSet(MovieClip(asset.no.hit));
			asset.x = 210.75;
			asset.y = 197.45;
			asset.question.text = _questionText;
			TextField(asset.yes.tf).text = _yesText;
			TextField(asset.no.tf).text = _noText;
			container.alpha = 0;
			container.addChild(_block = new Block());
			container.addChild(asset);
			addChild(container);
			_block.show();
			TweenUtils.bitmapAlphaTween( this.container, this, 0, 1, SEConfig.transitionTime, tweenInFinished);
			SESignalBroadcaster.blockToggle.dispatch(true);
		}
		
		private function tweenInFinished():void
		{
			yesSet.click.add(onYesClicked);		
			yesSet.mouseOut.add(onMouseOut);
			yesSet.mouseOver.add(onMouseOver);
			noSet.click.add(onNoClicked);
			noSet.mouseOut.add(onMouseOut);
			noSet.mouseOver.add(onMouseOver);
		}
		
		private function tweenOutFinished():void
		{
			_block.hide();
			SESignalBroadcaster.blockToggle.dispatch(false);
			unloadFinished.dispatch();
		}
		
		private function onYesClicked(e:MouseEvent):void
		{
			yesPressed.dispatch();
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		}
		
		private function onNoClicked(e:MouseEvent):void
		{
			noPressed.dispatch();
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			MouseIconHandler.onInteractiveRollOver();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		}
	}
}