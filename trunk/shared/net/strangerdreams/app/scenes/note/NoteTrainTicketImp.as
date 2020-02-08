package net.strangerdreams.app.scenes.note
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.deanverleger.core.IDestroyable;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.item.ItemManager;
	import net.strangerdreams.engine.note.NoteImplementor;
	
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class NoteTrainTicketImp extends NoteImplementor implements IDestroyable
	{
		private var ticketSet:InteractiveObjectSignalSet;
		public function NoteTrainTicketImp()
		{
			super();
			asset = new NoteTrainTicket();
			addAsset(asset,false);
			ItemManager.addItemInventory("ticket",true);
			ticketSet = new InteractiveObjectSignalSet(NoteTrainTicket(asset).hit);
			ticketSet.mouseOver.add(onTicketOver);
			ticketSet.mouseOut.add(onTicketOut);
			ticketSet.click.add(onTicketClick);
			assetAdded.addOnce(checkMouseOver);
		}
		
		private function checkMouseOver():void
		{
			var hit:MovieClip = NoteTrainTicket(asset).hit;
			if(hit.hitTestPoint(asset.stage.mouseX,asset.stage.mouseY))
				MouseIconHandler.onGrabableRollOver();
		}
		
		
		public function destroy():void
		{
			ticketSet.removeAll();
			ticketSet = null;
		}
		
		private function onTicketOver(e:MouseEvent):void
		{
			MouseIconHandler.onGrabableRollOver();
		}
		
		private function onTicketOut(e:MouseEvent):void
		{
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		}
		
		private function onTicketClick(e:MouseEvent):void
		{
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
			this.noteFinished.dispatch();
		}
	}
}