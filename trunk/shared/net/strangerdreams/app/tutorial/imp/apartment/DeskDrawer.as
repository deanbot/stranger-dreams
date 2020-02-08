package net.strangerdreams.app.tutorial.imp.apartment
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class DeskDrawer extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentDeskDrawerFrame;
		public function DeskDrawer()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY==defaultState)?true:false );
			this.sm.addState( JournalTaken.KEY, new JournalTaken(), (JournalTaken.KEY==defaultState)?true:false);
		}
	}
}
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import net.strangerdreams.app.SETutorialBroadcaster;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private var ref:MovieClip;
	private var journalClick:NativeSignal;
	public function Default()
	{
		
	}
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		journalClick=new NativeSignal(ApartmentDeskDrawerFrame(ref).journal, MouseEvent.CLICK, MouseEvent);
		journalClick.addOnce( function(e:MouseEvent):void { 
			SESignalBroadcaster.interactiveRollOut.dispatch();
			//give access to journal in hud
			SETutorialBroadcaster.journalPickedUp.dispatch(); 
			//give notification
			var journalPickedUpCaptionKey:String = ("n"+StoryEngine.currentNode+"journalPickedUp");
			var timer:Timer=new Timer(300);
			var timerFinished:NativeSignal=new NativeSignal(timer, TimerEvent.TIMER, TimerEvent);
			timer.start();
			timerFinished.addOnce( function(e:TimerEvent):void {
				timerFinished=null;
				timer=null;
				SESignalBroadcaster.singleNotification.dispatch(Caption(StoryScriptManager.getCaptionInstance(journalPickedUpCaptionKey)).text);
			});
		});
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		journalClick.removeAll();
		journalClick=null;
		ref=null;
		this.signalOutroComplete();
	}
}
class JournalTaken extends State
{
	public static const KEY:String = "JournalTaken";
	public function JournalTaken()
	{
		
	}
}