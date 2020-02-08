package net.strangerdreams.app
{
	import org.osflash.signals.Signal;

	public class SETutorialBroadcaster
	{
		private static var _journalPickedUp:Signal = new Signal();
		private static var _briefcasePickedUp:Signal = new Signal();
		
		public static function get briefcasePickedUp():Signal
		{
			return _briefcasePickedUp;
		}

		public static function get journalPickedUp():Signal
		{
			return _journalPickedUp;
		}
	}
}