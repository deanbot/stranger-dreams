package development.scene.locationnodes
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.scene.data.Node;
	
	public class Node4 extends LocationNode implements INodeImplementor
	{
		private var nodeAsset:Grasslands;
		
		public function Node4()
		{
			
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Bunny.KEY, new Bunny(), true );
			this.sm.addState( PokeballOpen.KEY, new PokeballOpen() );
			this.sm.addState( PokeballClosed.KEY, new PokeballClosed() );
			this.sm.addState( Empty.KEY, new Empty() );
			this.sm.addState( WithSign.KEY, new WithSign() );
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

class Bunny extends State
{
	public static var KEY:String = "Bunny";
	public function Bunny()
	{
		
	}
}

class PokeballOpen extends State
{
	public static var KEY:String = "PokeballOpen";
	public function PokeballOpen()
	{
		
	}
}

class PokeballClosed extends State
{
	public static var KEY:String = "PokeballClosed";
	public function PokeballClosed()
	{
		
	}
}

class Empty extends State
{
	public static var KEY:String = "Empty";
	public function Empty()
	{
		
	}
}

class WithSign extends State
{
	public static var KEY:String = "WithSign";
	public function WithSign()
	{
		
	}
}