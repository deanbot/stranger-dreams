package net.strangerdreams.app.tutorial.imp.apartment
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class Window extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentWindowFrame;
		public function Window()
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

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
}