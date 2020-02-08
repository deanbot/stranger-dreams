package development.scene.locationnodes
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.scene.data.Node;
	
	public class Node1 extends LocationNode implements INodeImplementor
	{
		private var nodeAsset:Yurt_Front_Door;
		
		public function Node1()
		{
			
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import development.scene.locationnodes.Node1;

class Default extends State
{
	public static var KEY:String = "Default";

	public function Default()
	{
		
	}
}