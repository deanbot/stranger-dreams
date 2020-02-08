package net.strangerdreams.app.scenes.imp.scene1
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class SparkAndOatsHallwayImp extends LocationNode implements INodeImplementor
	{
		private var assetClass:SparkAndOatsHallway;
		public function SparkAndOatsHallwayImp()
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