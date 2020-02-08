package net.strangerdreams.app.tutorial.note
{	
	import com.greensock.TweenLite;
	import com.meekgeek.statemachines.finite.events.StateManagerEvent;
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.deanverleger.core.IDestroyable;
	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.gui.TextDisplayUtil;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.note.NoteImplementor;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Caption;
	
	import org.osflash.signals.natives.NativeSignal;

	public class BernardLetterImp extends NoteImplementor implements IDestroyable
	{
		public static const LOCATION:String = "BernardLetterImp";
		public static const EVENT_LETTER_CLICKED:String = "letterClicked";
		public static const DINING_ROOM_NODE_ID:String = "7";
		//private var asset:BernardLetter;
		private var readLetter:NativeSignal;
		private var introComplete:NativeSignal;
		private var textFieldHolder:Sprite;
		
		public function BernardLetterImp()
		{
			super();
			asset = new BernardLetter();
			addAsset(asset);
			activateStateMachine(asset);
			
			readLetter=new NativeSignal(asset, EVENT_LETTER_CLICKED, Event);
			readLetter.addOnce(onReadLetter);
			
			sm.addState( Default.KEY, new Default(), true );
			sm.addState( LetterRead.KEY, new LetterRead() );			
		}
		
		private function onReadLetter(e:Event):void
		{
			//LoggingUtils.msgTrace("letter clicked", LOCATION);
			introComplete = new NativeSignal(sm,StateManagerEvent.ON_INTRO_COMPLETE,StateManagerEvent);
			introComplete.addOnce( activateLetter );
			sm.setState( LetterRead.KEY );	
		}
		
		private function activateLetter(e:StateManagerEvent):void
		{
			//LoggingUtils.msgTrace("activating Letter", LOCATION);
			textFieldHolder = new DiningRoomTextHolder() as Sprite;
			var endFinishedInstruction:Function = function():void
			{
				TextDisplayUtil.goToNextScreen();
				TweenLite.to(MovieClip(asset.sig), 2, {alpha:0});
				TweenLite.to(textFieldHolder, 2, { alpha:0, onComplete:onCaptionFaded});
			};
			var endPrepInstruction:Function = function():void
			{
				ClipUtils.hide( MovieClip(asset.sig) );
				TweenLite.to( MovieClip(asset.sig), 1.5, {alpha:1, onComplete:onSigFadedIn});
			};
			var onSigFadedIn:Function = function():void
			{
				TextDisplayUtil.arrowReady.addOnce(onArrowFadedIn);
				TextDisplayUtil.fadeInArrow();
			}
			activateLetterTextDisplay(textFieldHolder, StoryScriptManager.getCaptionInstance("bernardApologyletter"), endPrepInstruction, endFinishedInstruction);
		}
		
		public function destroy():void
		{
			textFieldHolder = null;
			readLetter.remove(onReadLetter);
			readLetter = null;
		}
	}
}

import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import net.deanverleger.utils.ClipUtils;
import net.deanverleger.utils.LoggingUtils;
import net.strangerdreams.app.tutorial.note.BernardLetterImp;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.scene.data.HoverType;

import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class Default extends State
{
	public static const KEY:String = "Default";
	private var ref:BernardLetter;
	private var letterSet:InteractiveObjectSignalSet;
	
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		ref = BernardLetter(this.context);
		
		//fade in letter
		ClipUtils.makeInvisible(MovieClip(ref.sig));
		TweenLite.to(ref, .3,{alpha:1, onComplete:this.signalIntroComplete});
	}
	
	override public function action():void
	{
		letterSet = new InteractiveObjectSignalSet( MovieClip(ref.hit) );
		letterSet.rollOver.add(
			function(e:MouseEvent):void { 
				SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INSPECT);
			}
		);
		letterSet.rollOut.add( 
			function(e:MouseEvent):void { SESignalBroadcaster.interactiveRollOut.dispatch(); 
			}
		);
		letterSet.click.addOnce(change);
			
		if( MovieClip(ref.hit).hitTestPoint(ref.mouseX,ref.mouseY) )
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INSPECT);
	}
	
	private function change(e:MouseEvent):void
	{
		//LoggingUtils.msgTrace("Letter clicked", KEY);
		SESignalBroadcaster.interactiveRollOut.dispatch();
		ref.dispatchEvent(new Event(BernardLetterImp.EVENT_LETTER_CLICKED));
	}
	
	override public function doOutro():void
	{
		letterSet.removeAll();
		letterSet=null;
		ref = null;
		this.signalOutroComplete();
	}
}

class LetterRead extends State
{
	public static const KEY:String = "LetterRead";
	private var ref:BernardLetter;
	
	public function LetterRead()
	{
		
	}
	
	override public function doOutro():void
	{
		ref = BernardLetter(this.context);
		TweenLite.to(ref, .3,{alpha:0, onComplete: onLetterFadedOut});
	}
	
	private function onLetterFadedOut():void
	{
		ClipUtils.makeInvisible(MovieClip(ref.sig));
		ClipUtils.makeInvisible(ref);
		this.signalOutroComplete();
	}
}