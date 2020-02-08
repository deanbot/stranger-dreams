package development.scene.locationnodes
{
	import development.minigames.RockGameTime;
	
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.scene.data.Node;
	
	public class Node2 extends LocationNode implements INodeImplementor
	{
		private var nodeAsset:Yurt_Rock;
		private var rockGameTime:RockGameTime;
		
		public function Node2()
		{
			
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

class Default extends State
{
	public static var KEY:String = "Default";
	
	public function Default()
	{
		
	}
}

