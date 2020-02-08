package net.strangerdreams.app.scenes.imp.scene2
{
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class YourRoomImp extends LocationNode implements INodeImplementor
	{
		private var frame:SparkAndOatsRoom;
		
		public function YourRoomImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY == defaultState)?true:false );
			this.sm.addState( LeftRoom.KEY, new LeftRoom(), (LeftRoom.KEY == defaultState)?true:false );
			SEConfig.hasMap = true;
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
	
}

class LeftRoom extends State
{
	public static const KEY:String = "LeftRoom";
	public function LeftRoom()
	{
		
	}
}