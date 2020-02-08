package net.strangerdreams.app.scenes.imp.scene1
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class SparkAndOatsDoorImp extends LocationNode implements INodeImplementor
	{
		private var assetClass:SparkAndOatsDoor;
		public function SparkAndOatsDoorImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import flash.events.MouseEvent;

import net.strangerdreams.engine.SEConfig;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.sound.SoundInstructionManager;
import net.strangerdreams.engine.sound.SoundObjectType;
import net.strangerdreams.engine.sound.SoundUtils;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
	private var ref:SparkAndOatsDoor;
	private var doorClick:NativeSignal;
	
	override public function doIntro():void
	{
		ref = this.context as SparkAndOatsDoor;
		doorClick = new NativeSignal(ref["doorHandle"],MouseEvent.CLICK, MouseEvent);
		doorClick.addOnce(onDoorClick);
		SESignalBroadcaster.compassDirectionClicked.add(onArrowPressed);
		this.signalIntroComplete();
	}
	
	private function onDoorClick(e:MouseEvent):void
	{
		goInside();
	}
	
	private function onArrowPressed(dir:String):void
	{
		if(dir =="N")
			goInside();
	}
	
	private function goInside():void
	{
		SESignalBroadcaster.compassDirectionClicked.remove(onArrowPressed);
		doorClick = null;
		ref = null;
		SoundUtils.playSingleSoundObject("hotelDoorOpen",SoundObjectType.AMBIENT,.7,changeNode);
	}
	
	private function changeNode():void
	{
		SESignalBroadcaster.changeNode.dispatch(3);
	}
}