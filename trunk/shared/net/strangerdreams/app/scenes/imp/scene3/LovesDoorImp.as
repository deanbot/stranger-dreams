package net.strangerdreams.app.scenes.imp.scene3
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class LovesDoorImp extends LocationNode implements INodeImplementor
	{
		private var frame:LovesDoor;
		public function LovesDoorImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY == defaultState)?true:false );
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
	
	private var ref:LovesDoor;
	private var doorClick:NativeSignal;
	
	override public function doIntro():void
	{
		ref = this.context as LovesDoor;
		doorClick = new NativeSignal(ref["door"],MouseEvent.CLICK, MouseEvent);
		doorClick.addOnce(onDoorClick);
		SESignalBroadcaster.compassDirectionClicked.add(onArrowPressed);
		SEConfig.doorReset = true;
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
		//SoundUtils.playSingleSoundObject("LovesDoorOpen",SoundObjectType.AMBIENT,1,changeNode);
		SoundUtils.playSingleSoundObject("lovesOpen",SoundObjectType.AMBIENT,.8,changeNode);
	}
	
	private function changeNode():void
	{
		SESignalBroadcaster.changeNode.dispatch(10);
	}
}