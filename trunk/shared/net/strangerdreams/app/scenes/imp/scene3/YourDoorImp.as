package net.strangerdreams.app.scenes.imp.scene3
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class YourDoorImp extends LocationNode implements INodeImplementor
	{
		public function YourDoorImp()
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

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
}