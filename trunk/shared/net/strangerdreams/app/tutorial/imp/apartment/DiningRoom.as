package net.strangerdreams.app.tutorial.imp.apartment
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.scene.data.NodeObject;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class DiningRoom extends LocationNode implements INodeImplementor
	{
		public static const EVENT_NOTES_ADDED:String = "notesAdded";
		private static const BRIEFCASE_FLAG:String = "briefcaseTaken";
		private static const JOURNAL_FLAG:String = "journalTaken";
		private var assetClass:ApartmentDiningRoomFrame;
		private var removeFromStage:NativeSignal;
		private var obituaryHit:NativeSignal;
		private var brochureLetterHit:NativeSignal;
		private var notesAdded:NativeSignal;
		private var exit:NativeSignal;
		private var overlayActive:Boolean;
		
		public function DiningRoom()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			removeFromStage=new NativeSignal(asset, Event.REMOVED_FROM_STAGE, Event );
			removeFromStage.addOnce(cleanUp);
			
			obituaryHit=new NativeSignal(ApartmentDiningRoomFrame(asset).obituaryHit, MouseEvent.CLICK, MouseEvent);
			obituaryHit.add(onObituaryClicked);
			
			brochureLetterHit=new NativeSignal(ApartmentDiningRoomFrame(asset).brochureLetterHit, MouseEvent.CLICK, MouseEvent);
			brochureLetterHit.addOnce(onBrochureLetterClicked); 
			
			notesAdded = new NativeSignal(asset, EVENT_NOTES_ADDED, Event);
			notesAdded.addOnce(onNotesAdded);
			
			exit=new NativeSignal(asset, "exit", Event);
			this.sm.addState( Default.KEY, new Default(), (Default.KEY==defaultState)?true:false);
			this.sm.addState( LetterBrochure.KEY, new LetterBrochure() );
			this.sm.addState( ReadObiturary.KEY, new ReadObiturary() );
			this.sm.addState( BrochureLetterTaken.KEY, new BrochureLetterTaken(), (BrochureLetterTaken.KEY==defaultState)?true:false );

		}
		
		private function onObituaryClicked(e:MouseEvent):void
		{
			if(!overlayActive)
			{
				overlayActive=true;
				exit.addOnce( onExit );
				this.changeState(ReadObiturary.KEY); 
				SESignalBroadcaster.leaveInternalState.add( onSignalInternalExit );
				SESignalBroadcaster.interactiveRollOut.dispatch(); 
			}
		}
		
		private function onSignalInternalExit():void
		{
			//LoggingUtils.msgTrace("internal exit signalled",LOCATION);
			onExit(new Event("exit"));
		}
		
		private function onBrochureLetterClicked(e:MouseEvent):void
		{
			if( FlagManager.getHasFlag(BRIEFCASE_FLAG) && FlagManager.getHasFlag(JOURNAL_FLAG) )
			{
				if(!overlayActive)
				{
					overlayActive=true;
					brochureLetterHit.remove(onBrochureLetterClicked);
					FlagManager.addFlag(NodeObject(this.currentState.nodeObjects["brochureLetterHit"]).objectFlag);
					this.changeState(LetterBrochure.KEY);
					SESignalBroadcaster.interactiveRollOut.dispatch(); 
				}
			}
		}
		
		private function onExit(e:Event):void
		{
			overlayActive=false;
			updateState();
		}
		
		private function onNotesAdded(e:Event):void
		{
			overlayActive=false;
			//updateState();
		}
		
		private function cleanUp(e:Event):void
		{
			overlayActive=false;
			obituaryHit.removeAll();
			brochureLetterHit.removeAll();
			exit.removeAll();
			notesAdded.removeAll();
			SESignalBroadcaster.leaveInternalState.remove(onSignalInternalExit);
			removeFromStage=obituaryHit=brochureLetterHit=exit=notesAdded=null;
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
import net.strangerdreams.app.gui.OverlayUtil;
import net.strangerdreams.app.gui.TextDisplayUtil;
import net.strangerdreams.app.tutorial.imp.apartment.DiningRoom;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.flag.FlagManager;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.note.NoteManager;
import net.strangerdreams.engine.scene.data.HoverType;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;

import org.osflash.signals.natives.NativeSignal;
import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
import org.osflash.signals.natives.sets.NativeSignalSet;

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
	
	private var ref:ApartmentDiningRoomFrame;
	override public function doIntro():void
	{
		ref=ApartmentDiningRoomFrame(this.context);
		
		ClipUtils.makeVisible( MovieClip(ref.brochureLetter) );
		ClipUtils.makeInvisible( MovieClip(ref.obituary) );
		ClipUtils.hide( MovieClip(ref.obituaryHit), MovieClip(ref.tool), MovieClip(ref.brochureLetterHit), MovieClip(ref.compass), MovieClip(ref.picture), MovieClip(ref.clock) );
		
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		ref=null;
		this.signalOutroComplete();
	}
}

class LetterBrochure extends State
{
	public static const KEY:String = "LetterBrochure";
	private static const BERNARD_LETTER_NOTE_KEY:String = "bernardLetter";
	private static const BROCHURE_NOTE_KEY:String = "mabelBrochure";
	private var ref:MovieClip;
	
	public function LetterBrochure()
	{

	}
	
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		
		//remove click functionality
		ClipUtils.makeInvisible( MovieClip(ref.obituaryHit), MovieClip(ref.tool), MovieClip(ref.brochureLetterHit), MovieClip(ref.compass), MovieClip(ref.picture), MovieClip(ref.clock) );
		
		//queue brochure read and read barry letter
		SESignalBroadcaster.noteOverlayFinished.addOnce(onNoteOverlayFinished); // wait for note overlay finished
		SESignalBroadcaster.queueNoteOverlay.dispatch( BROCHURE_NOTE_KEY, false);
		SESignalBroadcaster.doNoteOverlay.dispatch( BERNARD_LETTER_NOTE_KEY, false);
		SESignalBroadcaster.queueUpdateState.dispatch();
		
		this.signalIntroComplete();
	}
	
	private function onNoteOverlayFinished():void
	{
		NoteManager.addNote(BERNARD_LETTER_NOTE_KEY);
		NoteManager.addNote(BROCHURE_NOTE_KEY);
		NoteManager.setNoteRead(BERNARD_LETTER_NOTE_KEY);
		NoteManager.setNoteRead(BROCHURE_NOTE_KEY);
		ref.dispatchEvent( new Event(DiningRoom.EVENT_NOTES_ADDED) );
	}
	
	override public function doOutro():void
	{
		ref = null;
		this.signalOutroComplete();
	}
}

class ReadObiturary extends State
{
	public static const KEY:String = "ReadObiturary";
	private var ref:ApartmentDiningRoomFrame;
	private var noteClick:NativeSignal;
	
	public function ReadObiturary()
	{
		
	}
	
	override public function doIntro():void
	{
		ref=ApartmentDiningRoomFrame(this.context);
		ClipUtils.makeInvisible( MovieClip(ref.obituaryHit), MovieClip(ref.tool), MovieClip(ref.brochureLetterHit), MovieClip(ref.compass), MovieClip(ref.picture), MovieClip(ref.clock) );
		ClipUtils.hide( MovieClip(ref.obituary) );
		ref.overlayHolder.addChild(OverlayUtil.getOverlay());
		OverlayUtil.bgAction.addOnce(fadeInNote);
		OverlayUtil.fadeIn();
	}
	
	override public function action():void
	{
		noteClick=new NativeSignal(	ref.obituary,MouseEvent.CLICK,MouseEvent);
		noteClick.add(checkOverHit)
	}
	
	private function checkOverHit(e:MouseEvent):void
	{
		if( !ref.obituary.hit.hitTestPoint(ref.mouseX,ref.mouseY) )
			ref.dispatchEvent(new Event("exit"));
	}
	
	override public function doOutro():void
	{
		TweenLite.to(ref.obituary, .3,{alpha:0, onComplete:cleanUp});
		OverlayUtil.fadeOut();
	}
	
	private function fadeInNote():void
	{
		ref.obituary.visible=true;
		TweenLite.to(ref.obituary, .3,{alpha:1,onComplete:this.signalIntroComplete});
	}
	
	private function cleanUp():void
	{
		ref.obituary.visible=false;
		ref.overlayHolder.removeChildAt(0);
		noteClick.removeAll();
		noteClick=null;
		ref=null;
		this.signalOutroComplete();
	}
}

class BrochureLetterTaken extends State
{
	public static const KEY:String = "BrochureLetterTaken";
	private var ref:ApartmentDiningRoomFrame;
	public function BrochureLetterTaken()
	{
		
	}

	override public function doIntro():void
	{
		ref=ApartmentDiningRoomFrame(this.context);
		ClipUtils.makeInvisible( MovieClip(ref.obituary) );
		ClipUtils.makeInvisible( MovieClip(ref.brochureLetterHit) );
		ClipUtils.hide( MovieClip(ref.obituaryHit), MovieClip(ref.tool), MovieClip(ref.compass), MovieClip(ref.picture), MovieClip(ref.clock) );
		if(!FlagManager.getHasFlag("objectsFaded"))
		{
			FlagManager.addFlag("objectsFaded");
			TweenLite.to( MovieClip(ref.brochureLetter), 2, {alpha: 0});
		} else 
		{
			ClipUtils.makeInvisible( MovieClip(ref.brochureLetter) );
		}
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		TweenLite.killTweensOf(MovieClip(ref.brochureLetter));
		ref=null;
		this.signalOutroComplete();
	}
}