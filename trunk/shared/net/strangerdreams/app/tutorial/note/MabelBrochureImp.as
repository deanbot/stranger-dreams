package net.strangerdreams.app.tutorial.note
{
	import flash.events.Event;
	
	import net.deanverleger.core.IDestroyable;
	import net.strangerdreams.engine.note.NoteImplementor;
	
	import org.osflash.signals.natives.NativeSignal;
	
	public class MabelBrochureImp extends NoteImplementor implements IDestroyable
	{
		public static const EVENT_BROCHURE_FINISHED:String = "brochureFinished";
		private var brochureFinished:NativeSignal;
		
		public function MabelBrochureImp()
		{
			super();
			asset = new MabelBrochure();
			asset.stop();
			brochureFinished = new NativeSignal(asset, EVENT_BROCHURE_FINISHED, Event);
			brochureFinished.addOnce(onBrochureFinished);
			addAsset(asset,false);
			activateStateMachine(asset);
			sm.addState( Default.KEY, new Default(), true);
		}
		
		public function destroy():void
		{
			brochureFinished = null;
		}
		
		private function onBrochureFinished(e:Event):void
		{
			this.noteFinished.dispatch();
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

import net.deanverleger.utils.ClipUtils;
import net.strangerdreams.app.gui.MouseIconHandler;
import net.strangerdreams.app.gui.OverlayUtil;
import net.strangerdreams.app.tutorial.note.MabelBrochureImp;
import net.strangerdreams.engine.SEConfig;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.goal.GoalManager;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.scene.data.HoverType;

import org.osflash.signals.natives.NativeSignal;
import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

class Default extends State
{
	public static const KEY:String = "Default";
	private static const FRONT_PAGE:String="front";
	private static const INSIDE_PAGE:String="inside";
	private static const BACK_PAGE:String="back";
	
	private var ref:MabelBrochure
	private var frontSet:InteractiveObjectSignalSet;
	private var insideLeftSet:InteractiveObjectSignalSet;
	private var insideRightSet:InteractiveObjectSignalSet;
	private var ticketSet:InteractiveObjectSignalSet;
	private var backSet:InteractiveObjectSignalSet;
	private var backClick:NativeSignal;
	private var intent:String;
	
	override public function doIntro():void
	{
		ref=MabelBrochure(this.context);
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		doPage(FRONT_PAGE);
	}
	
	override public function doOutro():void
	{
		TweenLite.to(ref, .3,{alpha:0, onComplete:cleanUp});
	}
	
	private function doPage(page:String):void
	{
		if(page==FRONT_PAGE)
		{
			ref.brochureFront.visible=true;
			ref.brochureInside.visible=ref.brochureBack.visible=false;
			TweenLite.to(ref.brochureFront, .3,{alpha:1, onComplete:onFrontFadedIn});
		} else if(page==INSIDE_PAGE)
		{
			ref.brochureFront.visible=ref.brochureBack.visible=false;
			ref.brochureInside.visible=true;
			if(!ItemManager.hasItem("ticket"))
				ref.brochureInside.ticket.visible=ref.brochureInside.brochureInsideTicket.visible = true;
			else
				ref.brochureInside.ticket.visible=ref.brochureInside.brochureInsideTicket.visible=false;
			TweenLite.to(ref.brochureInside, .3,{alpha:1, onComplete:onInsideFadedIn});
		} else if(page==BACK_PAGE)
		{
			ref.brochureBack.visible=true;
			ref.brochureFront.visible=ref.brochureInside.visible=false;
			TweenLite.to(ref.brochureBack, .3,{alpha:1, onComplete:onBackFadedIn});
		}
	}
	
	private function onFrontFadedIn():void
	{
		frontSet=new InteractiveObjectSignalSet(ref.brochureFront.hit);
		frontSet.rollOver.add( function(e:MouseEvent):void { 
			MouseIconHandler.onInteractiveRollOver();
		});
		frontSet.rollOut.add( function(e:MouseEvent):void { 
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		});
		frontSet.click.addOnce( function(e:MouseEvent):void { 
			fadeOutFront(); 
			SESignalBroadcaster.interactiveRollOut.dispatch();
		});
		if(!ref.brochureFront.hit.hitTestPoint(ref.mouseX,ref.mouseY))
			SESignalBroadcaster.interactiveRollOut.dispatch();
		else
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
	}
	
	private function fadeOutFront():void
	{
		TweenLite.to(ref.brochureFront, .3, {alpha:0, onComplete:onFrontFadedOut});
	}
	
	private function onFrontFadedOut():void
	{
		doPage(INSIDE_PAGE);
		if(frontSet!=null)
		{
			frontSet.removeAll();
			frontSet=null;
		}
	}
	
	private function onInsideFadedIn():void
	{
		ref.brochureInside.ticketOverlay.visible=false;
		if(!ItemManager.hasItem("ticket"))
		{
			ticketSet = new InteractiveObjectSignalSet(ref.brochureInside.ticket);
			ticketSet.rollOver.add( function(e:MouseEvent):void { 
				SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
			});
			ticketSet.rollOut.add( function(e:MouseEvent):void { 
				SESignalBroadcaster.interactiveRollOut.dispatch(); 
			});
			ticketSet.click.addOnce( function(e:MouseEvent):void { 
				onTicketClicked(); 
				SESignalBroadcaster.interactiveRollOut.dispatch();
			});
		}
		
		insideLeftSet=new InteractiveObjectSignalSet(ref.brochureInside.pageLeft);
		insideLeftSet.rollOver.add( function(e:MouseEvent):void { 
			MouseIconHandler.onInteractiveRollOver();
		});
		insideLeftSet.rollOut.add( function(e:MouseEvent):void { 
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		});
		insideLeftSet.click.addOnce( function(e:MouseEvent):void { 
			intent=FRONT_PAGE;
			fadeOutInside();
			SESignalBroadcaster.interactiveRollOut.dispatch();
		});
		
		insideRightSet=new InteractiveObjectSignalSet(ref.brochureInside.pageRight);
		insideRightSet.rollOver.add( function(e:MouseEvent):void { 
			MouseIconHandler.onInteractiveRollOver();
		});
		insideRightSet.rollOut.add( function(e:MouseEvent):void {
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		});
		insideRightSet.click.addOnce( function(e:MouseEvent):void { 
			intent=BACK_PAGE;
			fadeOutInside();
			SESignalBroadcaster.interactiveRollOut.dispatch();
		});
		var found:Boolean=false;
		if(!ItemManager.hasItem("ticket"))
		{
			if(ref.brochureInside.ticket.hitTestPoint(ref.mouseX,ref.mouseY,true))
			{
				SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
				found=true;
			}
		}
		if(!found)
		{
			if(ref.brochureInside.pageLeft.hitTestPoint(ref.mouseX,ref.mouseY))
				found=true;
			else if(ref.brochureInside.pageRight.hitTestPoint(ref.mouseX,ref.mouseY))
				found=true;
			
			if(!found)
				SESignalBroadcaster.interactiveRollOut.dispatch();
		}
	}
	
	private function fadeOutInside():void
	{
		TweenLite.to(ref.brochureInside, .3, {alpha:0, onComplete:onInsideFadedOut});
	}
	
	private function onInsideFadedOut():void
	{	
		doPage(intent);
		intent=null;
		if(insideRightSet!=null)
		{
			insideRightSet.removeAll();
			insideRightSet=null;
		}
		if(insideLeftSet!=null)
		{
			insideLeftSet.removeAll();
			insideLeftSet=null;
		}
		if(ticketSet!=null)
		{
			ticketSet.removeAll();
			ticketSet=null;
		}
	}
	
	private var backMove:NativeSignal;
	private function onBackFadedIn():void
	{
		backMove = new NativeSignal(ref.brochureBack,MouseEvent.MOUSE_MOVE,MouseEvent);
		backMove.add(onBackMove);
		//ref.brochureBack.hit.mouseEnabled = false;
		backClick=new NativeSignal(ref.brochureBack,MouseEvent.CLICK,MouseEvent);
		backClick.add(checkLeaveBrochure);
		if(!ref.brochureBack.hit.hitTestPoint(ref.mouseX,ref.mouseY))
			SESignalBroadcaster.interactiveRollOut.dispatch();
	}
	
	private function onBackMove(e:MouseEvent):void
	{
		if(ref.brochureBack.hit.hitTestPoint(ref.mouseX,ref.mouseY,true))
			MouseIconHandler.onInteractiveRollOver();
		else
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
	}
	
	private function checkLeaveBrochure(e:MouseEvent):void
	{
		if(!ref.brochureBack.hit.hitTestPoint(ref.mouseX,ref.mouseY,true))
		{
			if(backSet!=null)
			{
				backSet.removeAll();
				backSet=null;
			}
			if(backClick!=null)
			{
				backClick.removeAll();
				backClick=null;
			}
			this.ref.dispatchEvent(new Event(MabelBrochureImp.EVENT_BROCHURE_FINISHED));
		} else {
			fadeOutBack(); 
			SESignalBroadcaster.interactiveRollOut.dispatch();
		}
	}
	
	private function fadeOutBack():void
	{
		TweenLite.to(ref.brochureBack, .3, {alpha:0, onComplete:onBackFadedOut});
	}
	
	private function onBackFadedOut():void
	{
		doPage(INSIDE_PAGE);
		if(backMove!=null)
		{
			backMove.removeAll();
			backMove=null;
		}
		if(backClick!=null)
		{
			backClick.removeAll();
			backClick=null;
		}
	}
	
	private var ticketOverlaySet:InteractiveObjectSignalSet;
	private function onTicketClicked():void
	{
		SESignalBroadcaster.queueUpdateState.dispatch();
		SESignalBroadcaster.interactiveRollOut.dispatch();
		ticketSet.removeAll();
		ticketSet=null;
		ItemManager.addItemInventory("ticket",true);
		if(SEConfig.isTutorial)
			GoalManager.removeActiveGoal("2",true);
		ref.brochureInside.ticketOverlay.visible=true;
		ref.brochureInside.ticketOverlay.alpha=1;
		ticketOverlaySet = new InteractiveObjectSignalSet(ref.brochureInside.ticketOverlay.hit);
		ticketOverlaySet.click.add(returnFromOverlay);
		ticketOverlaySet.rollOver.add( function(e:MouseEvent):void { 
			SESignalBroadcaster.interactiveRollOver.dispatch(HoverType.INTERACT);
		});
		ticketOverlaySet.rollOut.add( function(e:MouseEvent):void { 
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		});
	}
	
	private function returnFromOverlay(e:MouseEvent):void
	{
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
		ClipUtils.makeInvisible(MovieClip(ref.brochureInside.ticketOverlay));
		ref.brochureInside.ticket.visible=ref.brochureInside.brochureInsideTicket.visible=false;
		ticketOverlaySet.removeAll();
		ticketOverlaySet = null;
	}
	
	
	
	private function cleanUp():void
	{
		if(frontSet!=null)
			frontSet.removeAll();
		if(insideLeftSet!=null)
			insideLeftSet.removeAll();
		if(insideRightSet!=null)
			insideRightSet.removeAll();
		if(ticketSet!=null)
			ticketSet.removeAll();
		if(backSet!=null)
			backSet.removeAll();
		if(ticketOverlaySet!=null)
			ticketOverlaySet.removeAll();
		backSet = frontSet = insideLeftSet = insideRightSet = ticketSet = ticketOverlaySet = null;
		if(backClick!=null)
			backClick.removeAll();
		backClick = null;
		ref = null;
		if(GoalManager.getHasGoal("2"))
		{
			if(ItemManager.hasItem("ticket"))
				GoalManager.removeActiveGoal("2",true);
		}
		this.signalOutroComplete();
	}	
}