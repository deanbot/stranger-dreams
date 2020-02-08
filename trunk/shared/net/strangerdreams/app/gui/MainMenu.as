package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.deanverleger.sound.BaseSoundObject;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class MainMenu extends Sprite
	{
		private var addedToStage:NativeSignal;
		private var menu:MainMenuScreen;
		private var _playClicked:Signal;
		private var _destroyed:Signal;
		private var playButtonSet:InteractiveObjectSignalSet;
		private var _destroy:Boolean = false;
		private var menuTheme:BaseSoundObject;
		
		public function MainMenu()
		{
			addedToStage = new NativeSignal(this,Event.ADDED_TO_STAGE, Event);
			addedToStage.addOnce(onStage);
			_playClicked = new Signal();
			_destroyed = new Signal();
			MouseIconHandler.init();
			_destroy = false;
			this.alpha = 0;
		}
		
		public function get destroyed():Signal
		{
			return _destroyed;
		}

		public function get playClicked():Signal
		{
			return _playClicked;
		}
		
		public function destroy():void
		{
			if(!_destroy)
			{
				playButtonSet.removeAll();
				playButtonSet=null;
				removeChild(menu);
				menu=null;
				_playClicked.removeAll();
				_playClicked = null;
				_destroyed.dispatch();
				_destroyed = null;
				_destroy = true;
			}
		}

		private function onStage(e:Event):void
		{
			TweenLite.to(this,1,{alpha:1});
			menuTheme = new BaseSoundObject(new MenuTheme(),1,999);
			menuTheme.playSound();
			addChild(menu = new MainMenuScreen);
			menu.playButton.stop();
			playButtonSet= new InteractiveObjectSignalSet(menu.playButton.hit);
			playButtonSet.mouseOver.add(onMouseOver);
			playButtonSet.mouseOut.add(onMouseOut);
			playButtonSet.click.add(onMouseClick);
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			MouseIconHandler.onInteractiveRollOver();
			MovieClip(menu.playButton).gotoAndStop(2);
		}
		private function onMouseOut(e:MouseEvent):void
		{
			MouseIconHandler.onItemRollOut();
			MovieClip(menu.playButton).gotoAndStop(1)
		}
		private function onMouseClick(e:MouseEvent):void
		{
			playButtonSet.removeAll();
			MouseIconHandler.onItemRollOut();
			menuTheme.fadeComplete.addOnce(onFadeComplete);
			menuTheme.fadeTo(0,2);
			TweenLite.to(menu,3,{alpha: 0, ease:Sine.easeOut, onComplete:_playClicked.dispatch});
		}
		
		private function onFadeComplete():void
		{
			menuTheme.destroy();
			menuTheme = null;
		}
	}
}