package net.strangerdreams.app.scenes.note
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.deanverleger.core.IDestroyable;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.item.ItemManager;
	import net.strangerdreams.engine.note.NoteImplementor;
	import net.strangerdreams.engine.scene.data.HoverType;
	
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class NotePhotoStrangeManImp extends NoteImplementor implements IDestroyable
	{
		private var objectSet:InteractiveObjectSignalSet;
		private var onBack:Boolean;
		public function NotePhotoStrangeManImp()
		{
			super();
			asset = new NotePhotoStrangeMan();
			asset.stop();
			addAsset(asset,false);
			ItemManager.addItemInventory("photo",true);
			objectSet = new InteractiveObjectSignalSet( NotePhotoStrangeMan(asset).hit );
			objectSet.mouseOver.add(onOver);
			objectSet.mouseOut.add(onOut);
			objectSet.click.add(onClick);
			assetAdded.addOnce(checkMouseOver);
		}
		
		private function checkMouseOver():void
		{
			var hit:MovieClip = NotePhotoStrangeMan(asset).hit;
			if(hit.hitTestPoint(asset.stage.mouseX,asset.stage.mouseY))
				MouseIconHandler.onInteractiveRollOver();
		}
		
		public function destroy():void
		{
			objectSet.removeAll();
			objectSet = null;
		}
		
		private function onOver(e:MouseEvent):void
		{
			MouseIconHandler.onInteractiveRollOver();
		}
		
		private function onOut(e:MouseEvent):void
		{
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		}
		
		private function onClick(e:MouseEvent):void
		{
			if(onBack)
			{
				SESignalBroadcaster.interactiveRollOut.dispatch(); 
				this.noteFinished.dispatch();
			} else
			{
				asset.gotoAndStop("back");
				onBack = true;
			}
		}
	}
}