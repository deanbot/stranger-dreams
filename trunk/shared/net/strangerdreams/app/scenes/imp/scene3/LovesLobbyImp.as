package net.strangerdreams.app.scenes.imp.scene3
{
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class LovesLobbyImp extends LocationNode implements INodeImplementor
	{
		private var frame:LovesLobby;
		public function LovesLobbyImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY == defaultState)?true:false );
		}
	}
}

import com.meekgeek.statemachines.finite.states.State;

import flash.events.MouseEvent;
import flash.utils.Dictionary;

import net.strangerdreams.engine.sound.SoundObjectType;
import net.strangerdreams.engine.sound.SoundUtils;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private static const SONG:String = "jukebox";
	
	private var ref:LovesLobby;
	private var jukeboxClicked:NativeSignal;
	public function Default()
	{
		
	}
	override public function doIntro():void
	{
		ref = this.context as LovesLobby;
		jukeboxClicked = new NativeSignal(ref.jukebox,MouseEvent.CLICK,MouseEvent);
		jukeboxClicked.addOnce(onJukeBoxClicked);
		ref = null;
		this.signalIntroComplete();
	}
	
	private function onJukeBoxClicked(e:MouseEvent):void
	{
		jukeboxClicked = null;
		SoundUtils.playSingleSoundObject(SONG,SoundObjectType.MUSIC,.7);
	}
}