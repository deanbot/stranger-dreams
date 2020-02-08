package net.strangerdreams.app.tutorial.imp.intro
{
	import com.gskinner.utils.FrameScriptManager;
	
	import flash.events.Event;
	
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class DreamSequence01 extends LocationNode implements INodeImplementor
	{
		private static const CAVE_NODE:uint = 3;
		private var dream:DreamSequence1;
		private var fsm:FrameScriptManager;
		public function DreamSequence01()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
			fsm = new FrameScriptManager(this.asset);
			fsm.setFrameScript(this.asset.totalFrames,endScene)
		}
		
		private function endScene():void
		{
			LoggingUtils.msgTrace("End of Scene");
			this.asset.stop();
			fsm=null;
			SESignalBroadcaster.noTransition.dispatch();
			SESignalBroadcaster.changeNode.dispatch(CAVE_NODE);
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
}