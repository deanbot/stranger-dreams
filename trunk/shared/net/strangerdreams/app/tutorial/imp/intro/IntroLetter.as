package net.strangerdreams.app.tutorial.imp.intro
{
	import flash.events.Event;
	
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class IntroLetter extends LocationNode implements INodeImplementor
	{
		private var nodeAsset:IntroFrame;
		private var readLetter:NativeSignal;
		public function IntroLetter()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
			this.sm.addState( Read.KEY, new Read() );
			readLetter=new NativeSignal(this.asset,"readLetter");
			readLetter.addOnce(readLetterState);
		}
		
		private function readLetterState(e:Event):void
		{
			FlagManager.addFlag("read");
			//changeState(Read.KEY);
			this.updateState();
		}
	}
}

import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Sound;
import flash.text.TextField;

import net.deanverleger.utils.LoggingUtils;
import net.deanverleger.utils.TweenUtils;
import net.strangerdreams.app.gui.MouseIconHandler;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.location.LocationNode;
import net.strangerdreams.engine.location.LocationNodeManager;
import net.strangerdreams.engine.scene.data.HoverType;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;
import net.strangerdreams.engine.script.data.ScriptScreen;
import net.strangerdreams.engine.sound.SoundInstructionManager;
import net.strangerdreams.engine.sound.SoundUtils;

import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class Default extends State
{
	public static const KEY:String = "Default";
	private var introRef:MovieClip;
	private var locNodeRef:LocationNode;
	private var bg:MovieClip;
	private var textField:TextField;
	private var arrow:MovieClip;
	private var sig:MovieClip;
	private var letterHit:MovieClip;
	private var letterSet:InteractiveObjectSignalSet;
	public function Default()
	{
		
	}
	
	override public function doIntro():void
	{
		introRef=this.context as MovieClip;
		locNodeRef=LocationNodeManager.getLocationNode(1);
		bg=IntroFrame(introRef).bg;
		letterHit=IntroFrame(introRef).letterHit;
		textField=IntroFrame(introRef).letterText;
		arrow=IntroFrame(introRef).arrow;
		sig=IntroFrame(introRef).sig;
		bg.alpha=textField.alpha=arrow.alpha=sig.alpha=0;
		TweenLite.to(bg,4.5,{delay:.5,alpha:1,onComplete:signalIntroComplete});
	}
	
	override public function action():void
	{
		letterSet=new InteractiveObjectSignalSet(letterHit);
		letterSet.rollOver.add(function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INSPECT);});
		letterSet.rollOut.add(function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); });
		letterSet.click.addOnce(change);
		if(letterHit.hitTestPoint(introRef.mouseX,introRef.mouseY))
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INSPECT);
	}
	
	override public function doOutro():void
	{
		locNodeRef=null;
		introRef=null;
		bg=arrow=sig=null;
		textField=null;
		letterSet.removeAll();
		letterSet=null;
		this.signalOutroComplete();
	}
	
	private function change(e:MouseEvent):void
	{
		SESignalBroadcaster.interactiveRollOut.dispatch();
		introRef.dispatchEvent(new Event("readLetter"));
	}
}

class Read extends State
{
	public static const KEY:String="Read";
	private static const CINEMATIC_NODE:uint = 2;
	private var introRef:MovieClip;
	private var bg:MovieClip;
	private var textField:TextField;
	private var arrow:MovieClip;
	private var sig:MovieClip;
	private var caption:Caption;
	private var arrowSet:InteractiveObjectSignalSet;
	private var currentPage:uint=0;
	private var maxPage:uint;
	public function Read()
	{
		
	}
	
	override public function doIntro():void
	{
		introRef=this.context as MovieClip;
		bg=IntroFrame(introRef).bg;
		textField=IntroFrame(introRef).letterText;
		arrow=IntroFrame(introRef).arrow;
		sig=IntroFrame(introRef).sig;
		caption=StoryScriptManager.getCaptionInstance("n"+StoryEngine.currentNode+"letter");
		textField.selectable=false;
		textField.condenseWhite=true;
		maxPage=caption.numScreens;
		currentPage++;
		textField.htmlText=ScriptScreen(caption.screens[currentPage]).text;
		TweenLite.to(bg,1,{alpha:.5,onComplete:onBgIntroComplete});
	}
	
	private function onBgIntroComplete():void
	{
		TweenLite.to(textField,3,{alpha:1,onComplete:onTextIntroComplete});
	}
	
	override public function action():void
	{
		arrowSet=new InteractiveObjectSignalSet(arrow);
		addArrowControls();	
	}
	
	override public function doOutro():void
	{
		introRef=null;
		bg=arrow=sig=null;
		textField=null;
		arrowSet.removeAll();
		arrowSet=null;
		this.signalOutroComplete();
	}
	
	private function addArrowControls():void
	{
		arrowSet.mouseOver.add(function(e:MouseEvent):void{ MouseIconHandler.onInteractiveRollOver(); });
		arrowSet.mouseOut.add(function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); });
		arrowSet.click.add(function(e:MouseEvent):void{ goToNextPage(); } );
		if(arrow.hitTestPoint(introRef.mouseX,introRef.mouseY))
			MouseIconHandler.onInteractiveRollOver();
	}
	
	private function onTextIntroComplete():void
	{
		TweenLite.to(arrow,2,{alpha:1,onComplete:signalIntroComplete});
	}
	
	private function goToNextPage():void
	{
		arrowSet.removeAll();
		SESignalBroadcaster.interactiveRollOut.dispatch();
		if(currentPage<maxPage)
		{
			TweenLite.to(textField,1.5,{alpha:0,onComplete:onTextFaded});
			TweenLite.to(arrow,1.5,{alpha:0});
		} else 
		{
			SoundUtils.fadeAmbientChannels(0,4.5,true);
			TweenLite.to(introRef,5,{alpha:0,onComplete:goToCinematic});
		}
		
	}
	
	private function onTextFaded():void
	{
		if(currentPage<maxPage)
		{
			currentPage++;
			textField.htmlText=ScriptScreen(caption.screens[currentPage]).text;
			TweenLite.to(textField,1.5,{alpha:1,onComplete:onTextFadedIn});
		}
	}
	
	private function onTextFadedIn():void
	{
		if(currentPage==maxPage)
			TweenLite.to(sig, 1, {alpha:1, onComplete:onSigFaded});
		else 
			TweenLite.to(arrow,1.5,{alpha:1,onComplete:onArrowFaded});
	}
	
	private function onSigFaded():void
	{
		TweenLite.to(arrow,1.5,{alpha:1,onComplete:onArrowFaded});
	}
	
	private function onArrowFaded():void
	{
		addArrowControls();
		arrowSet.mouseOver.add(function(e:MouseEvent):void{ MouseIconHandler.onInteractiveRollOver(); });
	}
	
	private function goToCinematic():void
	{
		SESignalBroadcaster.changeNode.dispatch(CINEMATIC_NODE);
	}
}