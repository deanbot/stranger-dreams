package net.strangerdreams.app.state
{
	import com.meekgeek.statemachines.finite.states.State;
	
	import net.deanverleger.utils.LoggingUtils;
	
	public class OutroState extends State
	{
		public static const KEY:String = "OutroState";
		public function OutroState()
		{
			super();
		}
		/*
		override public function doIntro():void
		{
			LoggingUtils.msgTrace("intro",KEY);
			this.signalIntroComplete();
		}
		
		override public function action():void
		{
			LoggingUtils.msgTrace("action",KEY);
		}*/
	}
}