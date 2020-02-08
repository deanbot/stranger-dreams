package development.minigames
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.deanverleger.core.IDestroyable;
	import net.strangerdreams.engine.SESignalBroadcaster;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class RockGameTime extends MovieClip implements IDestroyable
	{
		//emumeration
		private var rockGame:MovieClip;
		private var exitButtonClick:NativeSignal;
		
		public function RockGameTime()
		{
			addChild( rockGame = new RockGame() as MovieClip );
			exitButtonClick = new NativeSignal( MovieClip(rockGame["exit"]), MouseEvent.CLICK, MouseEvent );
			exitButtonClick.addOnce( onExitButtonClick );
		}
		
		public function destroy():void
		{
			exitButtonClick = null;
			removeChild( rockGame );
			rockGame = null;
		}
		
		private function onExitButtonClick( e:MouseEvent ):void
		{
			SESignalBroadcaster.miniGameExit.dispatch();
		}
	}
}