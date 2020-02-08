package net.strangerdreams.app.tutorial.imp.apartment
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class ClosetBox extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentClosetBoxFrame;
		public function ClosetBox()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY==defaultState)?true:false );
			this.sm.addState( FadeGun.KEY, new FadeGun(), (FadeGun.KEY==defaultState)?true:false );
			this.sm.addState( ClosetBoxGunRemoved.KEY, new ClosetBoxGunRemoved(), (ClosetBoxGunRemoved.KEY==defaultState)?true:false );
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import net.strangerdreams.app.tutorial.TutorialFlags;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.flag.FlagManager;

class Default extends State
{
	public static const KEY:String = "Default";
	public function Default()
	{
		
	}
}
class FadeGun extends State
{
	public static const KEY:String = "FadeGun";
	public function FadeGun()
	{
		
	}
	override public function doIntro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(true);
		FlagManager.addFlag("gunFaded");
		this.signalIntroComplete();
	}
	override public function doOutro():void
	{
		SESignalBroadcaster.blockToggle.dispatch(false);
		this.signalOutroComplete();
	}
}
class ClosetBoxGunRemoved extends State
{
	public static const KEY:String = "ClosetBoxGunRemoved";
	public function ClosetBoxGunRemoved()
	{
		
	}
	
	override public function doIntro():void
	{
		if( !FlagManager.getHasFlag(TutorialFlags.FLAG_KEY_ITEMS_HINT) )
			FlagManager.addFlag(TutorialFlags.FLAG_KEY_ITEMS_HINT);
		this.signalIntroComplete();
	}
}