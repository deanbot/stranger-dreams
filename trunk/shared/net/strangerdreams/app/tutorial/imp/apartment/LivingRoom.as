package net.strangerdreams.app.tutorial.imp.apartment
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.item.ItemManager;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class LivingRoom extends LocationNode implements INodeImplementor
	{
		private var assetClass:ApartmentLivingRoomFrame;
		private var poemClick:NativeSignal;
		private var clippingsClick:NativeSignal;
		private var removeFromStage:NativeSignal;
		private var exit:NativeSignal;
		private var overlayActive:Boolean;
		
		public function LivingRoom()
		{
			super();
		}	
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY==defaultState)?true:false );
			this.sm.addState( ReadClippings.KEY, new ReadClippings(), (ReadClippings.KEY==defaultState)?true:false );
			this.sm.addState( ReadHypnosPoem.KEY, new ReadHypnosPoem(), (ReadHypnosPoem.KEY==defaultState)?true:false );
			this.sm.addState( BriefcaseTaken.KEY, new BriefcaseTaken(), (BriefcaseTaken.KEY==defaultState)?true:false );
			
			//make objects not visible
			ApartmentLivingRoomFrame(asset).textFieldHolder.visible=false;
			//set up cleanup
			removeFromStage=new NativeSignal(asset, Event.REMOVED_FROM_STAGE, Event );
			removeFromStage.addOnce(cleanUp);
			//set up poem to be read
			poemClick=new NativeSignal(ApartmentLivingRoomFrame(asset).hypnosPoem, MouseEvent.CLICK, MouseEvent);
			poemClick.add(onPoemClicked);
			//set up clippings to be viewed
			clippingsClick=new NativeSignal(ApartmentLivingRoomFrame(asset).clippingsHit, MouseEvent.CLICK,MouseEvent);
			clippingsClick.add(onClippingsClicked);
			
			exit=new NativeSignal(asset, "exit", Event);
			//set up poem and clippings to be exited
			exit.addOnce( onExit );
			
			SESignalBroadcaster.leaveInternalState.add( onSignalInternalExit );
		}
		
		private function onSignalInternalExit():void
		{
			onExit(new Event("exit"));
		}
		
		private function onPoemClicked(e:MouseEvent):void 
		{ 
			if(!overlayActive)
			{
				overlayActive=true;
				this.changeState(ReadHypnosPoem.KEY); 
				SESignalBroadcaster.interactiveRollOut.dispatch(); 
			}
		}
		
		private function onClippingsClicked(e:MouseEvent):void 
		{ 
			if(!overlayActive)
			{
				overlayActive=true;
				this.changeState(ReadClippings.KEY); 
				SESignalBroadcaster.interactiveRollOut.dispatch();
			}
		}
		
		private function onExit(e:Event):void
		{
			overlayActive=false;
			updateState();
		}
		
		private function cleanUp(e:Event):void
		{
			poemClick.removeAll();
			clippingsClick.removeAll();
			exit.removeAll();
			removeFromStage.removeAll();
			SESignalBroadcaster.leaveInternalState.remove( onSignalInternalExit );
			poemClick=clippingsClick=removeFromStage=exit=null;
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Mouse;
import flash.utils.Timer;

import net.strangerdreams.app.SETutorialBroadcaster;
import net.strangerdreams.app.gui.OverlayUtil;
import net.strangerdreams.app.gui.TextDisplayUtil;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.StoryEngine;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.scene.data.HoverType;
import net.strangerdreams.engine.script.StoryScriptManager;
import net.strangerdreams.engine.script.data.Caption;

import org.osflash.signals.Signal;
import org.osflash.signals.natives.NativeSignal;
import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class Default extends State
{
	public static const KEY:String = "Default";
	private var briefcaseClick:NativeSignal;
	public function Default()
	{
		
	}
	private var ref:MovieClip;
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		ApartmentLivingRoomFrame(ref).poem.visible=ApartmentLivingRoomFrame(ref).clippings.visible = false;
		ApartmentLivingRoomFrame(ref).books.visible=ApartmentLivingRoomFrame(ref).briefcase.visible=ApartmentLivingRoomFrame(ref).deskDrawerHit.visible=ApartmentLivingRoomFrame(ref).tv.visible=ApartmentLivingRoomFrame(ref).clippingsHit.visible=ApartmentLivingRoomFrame(ref).hypnosPoem.visible=ApartmentLivingRoomFrame(ref).hypnosStatue.visible=true;
		
		briefcaseClick=new NativeSignal(ApartmentLivingRoomFrame(ref).briefcase, MouseEvent.CLICK, MouseEvent);
		briefcaseClick.addOnce( function(e:MouseEvent):void {
			SESignalBroadcaster.interactiveRollOut.dispatch();
			//give access to inventory in hud
			SETutorialBroadcaster.briefcasePickedUp.dispatch(); 
			//give notification
			var briefcasePickedUpCaptionKey:String = ("n"+StoryEngine.currentNode+"briefcasePickedUp");
			var timer:Timer=new Timer(300);
			var timerFinished:NativeSignal=new NativeSignal(timer, TimerEvent.TIMER, TimerEvent);
			timer.start();
			timerFinished.addOnce( function(e:TimerEvent):void {
				timerFinished=null;
				timer=null;
				SESignalBroadcaster.singleNotification.dispatch(Caption(StoryScriptManager.getCaptionInstance(briefcasePickedUpCaptionKey)).text);
			});
		});
		
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		briefcaseClick.removeAll();
		briefcaseClick=null;
		ApartmentLivingRoomFrame(ref).books.visible=ApartmentLivingRoomFrame(ref).briefcase.visible=ApartmentLivingRoomFrame(ref).deskDrawerHit.visible=ApartmentLivingRoomFrame(ref).tv.visible=ApartmentLivingRoomFrame(ref).clippingsHit.visible=ApartmentLivingRoomFrame(ref).hypnosPoem.visible=ApartmentLivingRoomFrame(ref).hypnosStatue.visible=false;
		ref=null;
		this.signalOutroComplete();
	}
	
}
class ReadClippings extends State
{
	public static const KEY:String = "ReadClippings";
	private var ref:MovieClip;
	
	public function ReadClippings()
	{
		
	}
	
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		ApartmentLivingRoomFrame(ref).overlayHolder.addChild(OverlayUtil.getOverlay());
		OverlayUtil.bgAction.addOnce(fadeInClippings);
		OverlayUtil.fadeIn();
	}
	
	private static const CLIPPING_1:String = "Clipping1"; 
	private static const CLIPPING_2:String = "Clipping2"; 
	private var clippingsClicked:NativeSignal;
	private var clipping1Set:InteractiveObjectSignalSet;
	private var clipping2Set:InteractiveObjectSignalSet;
	override public function action():void
	{
		clippingsClicked=new NativeSignal(	ApartmentLivingRoomFrame(ref).clippings,MouseEvent.CLICK,MouseEvent);
		clippingsClicked.add(checkOverHit);
		clipping1Set=new InteractiveObjectSignalSet( Clippings(ApartmentLivingRoomFrame(ref).clippings).clipping1Hit);
		clipping2Set=new InteractiveObjectSignalSet( Clippings(ApartmentLivingRoomFrame(ref).clippings).clipping2Hit);
		clipping1Set.mouseOver.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOver.dispatch( HoverType.INSPECT ); } );
		clipping2Set.mouseOver.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOver.dispatch( HoverType.INSPECT ); } );
		clipping1Set.mouseOut.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); } );
		clipping2Set.mouseOut.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); } );
		clipping1Set.click.add( function(e:MouseEvent):void { doClipping(CLIPPING_1); } );		
		clipping2Set.click.add( function(e:MouseEvent):void { doClipping(CLIPPING_2); } );	

		if(isOverClipping)
			SESignalBroadcaster.interactiveRollOver.dispatch( HoverType.INSPECT ); 
	}
	
	private function get isOverClipping():Boolean
	{
		var over:Boolean = false;
		if( Clippings(ApartmentLivingRoomFrame(ref).clippings).clipping1Hit.hitTestPoint(ref.mouseX,ref.mouseY) )
			over= true;
		else if( Clippings(ApartmentLivingRoomFrame(ref).clippings).clipping2Hit.hitTestPoint(ref.mouseX,ref.mouseY) )
			over=true;
		return over;
	}
	
	private function checkOverHit(e:MouseEvent):void
	{
		if(!isOverClipping)
			ref.dispatchEvent(new Event("exit"));
	}
	
	private var textDisplay:Sprite;
	private function doClipping(clipping:String):void
	{
		SESignalBroadcaster.hideHUD.dispatch(false);
		ApartmentLivingRoomFrame(ref).textFieldHolder.visible=true;
		ApartmentLivingRoomFrame(ref).textFieldHolder.alpha=1;
		ApartmentLivingRoomFrame(ref).textFieldHolder.textField.alpha=0;
		var clippingCaptionKey:String = (clipping==CLIPPING_1)?("n"+StoryEngine.currentNode+"craneDenies"):("n"+StoryEngine.currentNode+"craneClean");
		textDisplay=TextDisplayUtil.getTextDisplayControl(StoryScriptManager.getCaptionInstance(clippingCaptionKey),ApartmentLivingRoomFrame(ref).textFieldHolder.textField,ApartmentLivingRoomFrame(ref).textFieldHolder, false, 380, 355);
		ApartmentLivingRoomFrame(ref).textFieldHolder.addChild(textDisplay);
		TextDisplayUtil.captionFinished.addOnce(onCaptionFinished);
	}
	
	override public function doOutro():void
	{
		TweenLite.to(ApartmentLivingRoomFrame(ref).clippings, .3,{alpha:0, onComplete:cleanUp});
		OverlayUtil.fadeOut();
	}
	
	private function onCaptionFinished():void
	{
		TextDisplayUtil.backgroundAction.addOnce(onCaptionFaded);
		TextDisplayUtil.fadeAndRemoveOverlay();
		TextDisplayUtil.fadeOutText();
		TextDisplayUtil.fadeOutArrow();
		SESignalBroadcaster.showHUD.dispatch(false);
	}
	
	private function onCaptionFaded():void
	{
		ApartmentLivingRoomFrame(ref).textFieldHolder.removeChild(textDisplay);
		textDisplay=null;
		ApartmentLivingRoomFrame(ref).textFieldHolder.alpha=0;
		ApartmentLivingRoomFrame(ref).textFieldHolder.visible=false;
	}
	
	private function fadeInClippings():void
	{
		ApartmentLivingRoomFrame(ref).clippings.visible=true;
		TweenLite.to(ApartmentLivingRoomFrame(ref).clippings, .3,{alpha:1, onComplete:this.signalIntroComplete});
	}
	
	private function cleanUp():void
	{
		clippingsClicked.removeAll();
		clipping1Set.removeAll();
		clipping2Set.removeAll();
		clippingsClicked=null;
		clipping1Set=clipping2Set=null;
		ApartmentLivingRoomFrame(ref).clippings.visible=ApartmentLivingRoomFrame(ref).textFieldHolder.visible=false;
		ApartmentLivingRoomFrame(ref).overlayHolder.removeChildAt(0);
		ref=null;
		this.signalOutroComplete();
	}	
}
class ReadHypnosPoem extends State
{
	public static const KEY:String = "ReadHypnosPoem";
	private var ref:MovieClip;
	private var noteClick:NativeSignal;
	
	public function ReadHypnosPoem()
	{
		
	}
	
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		ApartmentLivingRoomFrame(ref).overlayHolder.addChild(OverlayUtil.getOverlay());
		OverlayUtil.bgAction.addOnce(fadeInPoem);
		OverlayUtil.fadeIn();
	}
	
	override public function action():void
	{
		noteClick=new NativeSignal(	ApartmentLivingRoomFrame(ref).poem,MouseEvent.CLICK,MouseEvent);
		noteClick.add(checkOverHit)
	}
	
	private function checkOverHit(e:MouseEvent):void
	{
		if( !HypnosPoem(ApartmentLivingRoomFrame(ref).poem).hit.hitTestPoint(ref.mouseX,ref.mouseY) )
			ref.dispatchEvent(new Event("exit"));
	}
	
	override public function doOutro():void
	{
		TweenLite.to(ApartmentLivingRoomFrame(ref).poem, .3,{alpha:0, onComplete:cleanUp});
		OverlayUtil.fadeOut();
	}
	
	private function fadeInPoem():void
	{
		ApartmentLivingRoomFrame(ref).poem.visible=true;
		TweenLite.to(ApartmentLivingRoomFrame(ref).poem, .3,{alpha:1,onComplete:this.signalIntroComplete});
	}

	private function cleanUp():void
	{
		ApartmentLivingRoomFrame(ref).poem.visible=false;
		ApartmentLivingRoomFrame(ref).overlayHolder.removeChildAt(0);
		noteClick.removeAll();
		noteClick=null;
		ref=null;
		this.signalOutroComplete();
	}
}
class BriefcaseTaken extends State
{
	public static const KEY:String = "BriefcaseTaken";
	public function BriefcaseTaken()
	{
		
	}
	private var ref:MovieClip;
	override public function doIntro():void
	{
		ref=MovieClip(this.context);
		ApartmentLivingRoomFrame(ref).poem.visible=ApartmentLivingRoomFrame(ref).clippings.visible = false;
		ApartmentLivingRoomFrame(ref).books.visible=ApartmentLivingRoomFrame(ref).deskDrawerHit.visible=ApartmentLivingRoomFrame(ref).tv.visible=ApartmentLivingRoomFrame(ref).clippingsHit.visible=ApartmentLivingRoomFrame(ref).hypnosPoem.visible=ApartmentLivingRoomFrame(ref).hypnosStatue.visible=true;
		this.signalIntroComplete();
	}
	
	override public function doOutro():void
	{
		ApartmentLivingRoomFrame(ref).books.visible=ApartmentLivingRoomFrame(ref).briefcase.visible=ApartmentLivingRoomFrame(ref).deskDrawerHit.visible=ApartmentLivingRoomFrame(ref).tv.visible=ApartmentLivingRoomFrame(ref).clippingsHit.visible=ApartmentLivingRoomFrame(ref).hypnosPoem.visible=ApartmentLivingRoomFrame(ref).hypnosStatue.visible=false;
		ref=null;
		this.signalOutroComplete();
	}
}