package net.strangerdreams.app
{
	import org.osflash.signals.Signal;

	public class SEBetaBroadcaster
	{
		private static const _betaEndReached:Signal = new Signal();

		public static function get betaEndReached():Signal
		{
			return _betaEndReached;
		}

	}
}