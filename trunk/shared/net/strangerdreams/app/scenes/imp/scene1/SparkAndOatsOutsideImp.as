package net.strangerdreams.app.scenes.imp.scene1
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class SparkAndOatsOutsideImp extends LocationNode implements INodeImplementor
	{
		private var assetClass:SparkAndOatsOutside;
		public function SparkAndOatsOutsideImp()
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
	function Default()
	{
		//SEConfig.hasMap = true;
	}

}