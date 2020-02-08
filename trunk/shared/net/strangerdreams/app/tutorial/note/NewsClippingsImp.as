package net.strangerdreams.app.tutorial.note
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.deanverleger.core.IDestroyable;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.note.NoteImplementor;
	import net.strangerdreams.engine.scene.data.HoverType;
	
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class NewsClippingsImp extends NoteImplementor implements IDestroyable
	{
		public static const LOCATION:String = "NewsClippingsImp";
		private static const CLIPPING_1:String = "Clipping1"; 
		private static const CLIPPING_2:String = "Clipping2"; 
		
		private var clippingsClicked:NativeSignal;
		private var clipping1Set:InteractiveObjectSignalSet;
		private var clipping2Set:InteractiveObjectSignalSet;
		private var textFieldHolder:Sprite;
		
		public function NewsClippingsImp()
		{
			super();
			asset = new Clippings();
			addAsset(asset);
			
			clippingsClicked=new NativeSignal(	asset, MouseEvent.CLICK, MouseEvent);
			clippingsClicked.add(checkOverHit);
			clipping1Set=new InteractiveObjectSignalSet( MovieClip(asset.clipping1Hit) );
			clipping2Set=new InteractiveObjectSignalSet( MovieClip(asset.clipping2Hit) );
			clipping1Set.mouseOver.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOver.dispatch( HoverType.INSPECT ); } );
			clipping2Set.mouseOver.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOver.dispatch( HoverType.INSPECT ); } );
			clipping1Set.mouseOut.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); } );
			clipping2Set.mouseOut.add( function(e:MouseEvent):void{ SESignalBroadcaster.interactiveRollOut.dispatch(); } );
			clipping1Set.click.add( function(e:MouseEvent):void { doClipping(CLIPPING_1); } );		
			clipping2Set.click.add( function(e:MouseEvent):void { doClipping(CLIPPING_2); } );	
			
			if(isOverClipping)
				SESignalBroadcaster.interactiveRollOver.dispatch( HoverType.INSPECT ); 
		}

		public function destroy():void
		{
			clippingsClicked.removeAll();
			clipping1Set.removeAll();
			clipping2Set.removeAll();
			clippingsClicked=null;
			clipping1Set=clipping2Set=null;
		}
		
		private function get isOverClipping():Boolean
		{
			var over:Boolean = false;
			if( Clippings(asset.clipping1Hit.hitTestPoint(asset.mouseX,asset.mouseY) )
				over= true;
			else if( asset.clipping2Hit.hitTestPoint(ref.mouseX,ref.mouseY) )
				over=true;
			return over;
		}
		
		private function checkOverHit(e:MouseEvent):void
		{
			if(!isOverClipping)
				this.noteFinished.dispatch();
		}
		
		//private var textDisplay:Sprite;
		private function doClipping(clipping:String):void
		{
			textFieldHolder = new LivingRoomTextField() as Sprite;
			var clippingCaptionKey:String = (clipping==CLIPPING_1)?("n"+StoryEngine.currentNode+"craneDenies"):("n"+StoryEngine.currentNode+"craneClean");
			activateLetterTextDisplay(textFieldHolder, StoryScriptManager.getCaptionInstance(clippingCaptionKey));
			//captionFinished.addOnce(onCaptionFinished);
			//textDisplay=TextDisplayUtil.getTextDisplayControl(StoryScriptManager.getCaptionInstance(clippingCaptionKey),ApartmentLivingRoomFrame(ref).textFieldHolder.textField,ApartmentLivingRoomFrame(ref).textFieldHolder, false, 380, 355);
			//ApartmentLivingRoomFrame(ref).textFieldHolder.addChild(textDisplay);
			//TextDisplayUtil.captionFinished.addOnce(onCaptionFinished);
		}
		/*
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
		}*/
		/*
		private function cleanUp():void
		{
			clippingsClicked.removeAll();
			clipping1Set.removeAll();
			clipping2Set.removeAll();
			clippingsClicked=null;
			clipping1Set=clipping2Set=null;
			ApartmentLivingRoomFrame(ref).clippings.visible=ApartmentLivingRoomFrame(ref).textFieldHolder.visible=false;
			ApartmentLivingRoomFrame(ref).overlayHolder.removeChildAt(0);
			this.signalOutroComplete();
		}	*/
		

	}
}