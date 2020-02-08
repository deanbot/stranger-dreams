package app
{
	public class Line
	{
		import org.libspark.betweenas3.BetweenAS3;
		import org.libspark.betweenas3.tweens.ITween;
		import org.libspark.betweenas3.easing.Linear;
		import org.libspark.betweenas3.easing.Bounce;
		import org.libspark.betweenas3.easing.Elastic;
		
		public var delay:int = 0;
		private var t:ITween;
		private var prev:int = 0;
		
		public function changeDelayDirect(value:int):void {
			if(t && t.isPlaying) t.stop();
			delay = value;
			prev = value;
		}
		
		public function changeDelay(value:int):void {
			if (prev != value) {
				if(t && t.isPlaying) t.stop();
				//t = BetweenAS3.tween(this, { delay: value }, null, 1.5, Bounce.easeOut);
				t = BetweenAS3.tween(this, { delay: value }, null, 3, Elastic.easeOut);
				//t = BetweenAS3.tween(this, { delay: value }, null, 0.5, Linear.easeNone);
				t.play();
				prev = value;
			}
		}

	}
}