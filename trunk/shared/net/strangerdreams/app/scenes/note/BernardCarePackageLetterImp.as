package net.strangerdreams.app.scenes.note
{
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import net.deanverleger.core.IDestroyable;
	import net.deanverleger.utils.ClipUtils;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.app.gui.TextDisplayUtil;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.note.NoteImplementor;
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.script.StoryScriptManager;
	
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class BernardCarePackageLetterImp extends NoteImplementor implements IDestroyable
	{
		private var textFieldHolder:Sprite;
		private var objectSet:InteractiveObjectSignalSet;
		public function BernardCarePackageLetterImp()
		{
			super();
			asset = new BernardCarePackageLetter();
			addAsset(asset,false);
			objectSet = new InteractiveObjectSignalSet(BernardCarePackageLetter(asset).hit );
			objectSet.mouseOver.add(onOver);
			objectSet.mouseOut.add(onOut);
			objectSet.click.add(onClick);
			assetAdded.addOnce(checkMouseOver);
		}
		
		private function checkMouseOver():void
		{
			var hit:MovieClip = BernardCarePackageLetter(asset).hit;
			if(hit.hitTestPoint(asset.stage.mouseX,asset.stage.mouseY))
				MouseIconHandler.onInspectableRollOver();
		}
		
		public function destroy():void
		{
		}
		
		private function onOver(e:MouseEvent):void
		{
			MouseIconHandler.onInspectableRollOver();
		}
		
		private function onOut(e:MouseEvent):void
		{
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
		}
		
		private function onClick(e:MouseEvent):void
		{
			objectSet.removeAll();
			objectSet = null;
			textFieldHolder = new DiningRoomTextHolder() as Sprite;
			SESignalBroadcaster.interactiveRollOut.dispatch(); 
			var endFinishedInstruction:Function = function():void
			{
				TextDisplayUtil.goToNextScreen();
				TweenLite.to(MovieClip(asset.sig), 2, {alpha:0});
				TweenLite.to(textFieldHolder, 2, { alpha:0, onComplete:onCaptionFaded});
			};
			var endPrepInstruction:Function = function():void
			{
				ClipUtils.hide( MovieClip(asset.sig) );
				TweenLite.to( MovieClip(asset.sig), 1.5, {alpha:1, onComplete:onSigFadedIn});
			};
			var onSigFadedIn:Function = function():void
			{
				TextDisplayUtil.arrowReady.addOnce(onArrowFadedIn);
				TextDisplayUtil.fadeInArrow();
			}
			activateLetterTextDisplay(textFieldHolder,StoryScriptManager.getCaptionInstance("carePackageLetter"),endPrepInstruction, endFinishedInstruction);
		}
	}
}