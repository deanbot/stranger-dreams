package net.strangerdreams.app.tutorial.imp.apartment
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class OutsideWindow extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentOutsideWindowFrame;
		public function OutsideWindow()
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

import net.strangerdreams.engine.SESignalBroadcaster;

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
	
	override public function action():void 
	{
		SESignalBroadcaster.captionComplete.addOnce(onCaptionComplete);
	}
	
	private function onCaptionComplete():void
	{
		SESignalBroadcaster.changeNode.dispatch(4);
	}
}