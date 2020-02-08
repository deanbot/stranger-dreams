package net.strangerdreams.app.scenes.imp.scene1
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class YourRoomImp extends LocationNode implements INodeImplementor
	{
		private var frame:SparkAndOatsRoom;
		private var removeFromStage:NativeSignal;
		private var busy:Boolean;
		
		public function YourRoomImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY == defaultState)?true:false );
			this.sm.addState( StreamlinedSave.KEY, new StreamlinedSave(), (StreamlinedSave.KEY == defaultState)?true:false );
			
			removeFromStage=new NativeSignal(this.asset, Event.REMOVED_FROM_STAGE, Event );
			removeFromStage.addOnce(cleanUp);
			SESignalBroadcaster.compassDirectionClicked.add(compassArrowPressed);
			busy = false;
		}
		
		private function cleanUp(e:Event):void
		{
			removeFromStage.removeAll();
			removeFromStage = null;
			SESignalBroadcaster.compassDirectionClicked.remove(compassArrowPressed);
			busy = false
		}
		
		private function compassArrowPressed(dir:String):void
		{
			if(busy)
				return;
			
			if(dir == "S")
			{
				busy = true;
				SESignalBroadcaster.captionComplete.addOnce(resetCaption)
				SESignalBroadcaster.singleCaption.dispatch("noLeave");
			}
		}
		
		private function resetCaption():void
		{
			busy = false;
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.MouseEvent;

import net.strangerdreams.app.gui.QuestionOptionSelectionItem;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.goal.GoalManager;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private var ref:SparkAndOatsRoom;
	private var bedClicked:NativeSignal;
	private var busy:Boolean;
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		ref = this.context as SparkAndOatsRoom;
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		bedClicked = new NativeSignal(MovieClip(ref.bed), MouseEvent.CLICK, MouseEvent);
		bedClicked.add(onBedClicked);
	}
	
	override public function doOutro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(false);
		bedClicked = null;
		ref = null;
		this.signalOutroComplete();
	}
	
	private function onBedClicked(e:MouseEvent):void
	{
		if(busy)
			return;
		busy = true;
		SESignalBroadcaster.questionOptionSelected.addOnce(optionSelected);
		SESignalBroadcaster.questionTriggered.dispatch(Caption(StoryScriptManager.getCaptionInstance("sleep")).text,Caption(StoryScriptManager.getCaptionInstance("yes")).text,Caption(StoryScriptManager.getCaptionInstance("no")).text);
	}
	
	private function optionSelected(selection:String):void
	{
		busy = false;
		if(bedClicked == null)
			return;
		if(selection == QuestionOptionSelectionItem.OPTION_A)
		{
			GoalManager.removeActiveGoal("1",true);
			bedClicked.removeAll();
			SESignalBroadcaster.sceneEndReached.dispatch();
			//SESignalBroadcaster.blockToggle.dispatch(true);
			//TweenLite.to(ref,3,{alpha:0,onComplete:endScene});
		}
	}
	
	private function endScene():void
	{
		SESignalBroadcaster.sceneEndReached.dispatch();
	}
}
class StreamlinedSave extends State
{
	public static const KEY:String = "StreamlinedSave";
	private var ref:SparkAndOatsRoom;
	private var bedClicked:NativeSignal;
	public function StreamlinedSave()
	{
		
	}

	override public function doIntro():void
	{
		ref = this.context as SparkAndOatsRoom;
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		bedClicked = new NativeSignal(MovieClip(ref.bed), MouseEvent.CLICK, MouseEvent);
		bedClicked.add(onBedClicked);
	}

	override public function doOutro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(false);
		bedClicked = null;
		ref = null;
		this.signalOutroComplete();
	}
	
	private function onBedClicked(e:MouseEvent):void
	{
		SESignalBroadcaster.questionOptionSelected.addOnce(optionSelected);
		SESignalBroadcaster.questionTriggered.dispatch(Caption(StoryScriptManager.getCaptionInstance("sleep")).text,Caption(StoryScriptManager.getCaptionInstance("yes")).text,Caption(StoryScriptManager.getCaptionInstance("no")).text);
	}
	
	private function optionSelected(selection:String):void
	{
		if(selection == QuestionOptionSelectionItem.OPTION_A)
		{
			GoalManager.removeActiveGoal("1",true);
			bedClicked.removeAll();
			SESignalBroadcaster.interactiveRollOut.dispatch();
			SESignalBroadcaster.blockToggle.dispatch(true);
			TweenLite.to(ref,3,{alpha:0,onComplete:endScene});
		}
	}
		
	private function endScene():void
	{
		SESignalBroadcaster.sceneEndReached.dispatch();
	}
}