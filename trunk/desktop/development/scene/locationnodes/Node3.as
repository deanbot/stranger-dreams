package development.scene.locationnodes
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.scene.data.Node;
	
	public class Node3 extends LocationNode implements INodeImplementor
	{
		private var nodeAsset:Town_Gate;
		
		public function Node3()
		{
			
		}

		public function loadStates(defaultState:String):void
		{
			this.sm.addState( GateClosed.KEY, new GateClosed(), true );
			this.sm.addState( OakCloseup.KEY, new OakCloseup() );
			this.sm.addState( GateOpen.KEY, new GateOpen() );
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

class GateClosed extends State
{
	public static var KEY:String = "GateClosed";
	public function GateClosed()
	{
		
	}
}

class OakCloseup extends State
{
	public static var KEY:String = "OakCloseup";
	public function OakCloseup()
	{
		
	}
}

class GateOpen extends State
{
	public static var KEY:String = "GateOpen";
	public function GateOpen()
	{
		
	}
}