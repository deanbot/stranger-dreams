package net.strangerdreams.app.tutorial.imp.apartment
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class Exit extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentExitFrame;
		public function Exit()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.MouseEvent;

import net.deanverleger.utils.LoggingUtils;
import net.strangerdreams.app.gui.QuestionCaption;
import net.strangerdreams.app.gui.QuestionOptionSelectionItem;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.flag.FlagManager;
import net.strangerdreams.engine.scene.data.CompassArrowDirection;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private var ref:ApartmentExitFrame;
	private var doorClicked:NativeSignal;
	private var busy:Boolean;
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		//FlagManager.addFlag("exitNow");
		ref = ApartmentExitFrame(this.context);
		busy = false;
		doorClicked = new NativeSignal(MovieClip(ref.door),MouseEvent.CLICK, MouseEvent);
		doorClicked.add(onDoorClicked);
		SESignalBroadcaster.compassDirectionClicked.add(onCompassClicked);
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		if(doorClicked!=null)
			doorClicked.remove(onDoorClicked);
		doorClicked = null;
		SESignalBroadcaster.compassDirectionClicked.remove(onCompassClicked);
		ref = null;
		this.signalOutroComplete();
	}
	
	private function onCompassClicked( direction:String ):void
	{
		if(direction==CompassArrowDirection.ARROW_N)
			leaveApartment();
	}
	
	private function onDoorClicked(e:MouseEvent):void
	{
		if(FlagManager.getHasFlag("exitNow"))
		{
			if(busy)
				return;
			busy = true;
			leaveApartment();
		}
	}

	private function leaveApartment():void
	{
		SESignalBroadcaster.questionOptionSelected.addOnce(optionSelected);
		SESignalBroadcaster.questionTriggered.dispatch( "Are you ready to leave?" , "Yes", "No");
	}
	
	private function optionSelected(selection:String):void
	{
		busy = false;
		if(selection == QuestionOptionSelectionItem.OPTION_A)
		{
			//TweenLite.to(ref,3,{alpha:0,onComplete:endScene});
			//SESignalBroadcaster.blockToggle.dispatch(true);
			SESignalBroadcaster.sceneEndReached.dispatch();
		}
	}
	
	private function endScene():void
	{
		SESignalBroadcaster.blockToggle.dispatch(false);
		SESignalBroadcaster.sceneEndReached.dispatch();
	}
}