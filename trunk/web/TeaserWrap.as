package
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class TeaserWrap extends Sprite
	{
		private var barWidth:Number;
		public function TeaserWrap()
		{
			LoaderMax.activate([SWFLoader]);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onStage,false,0,true);
			//create a LoaderMax named "mainQueue" and set up onProgress, onComplete and onError listeners
		}
		
		private function onStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,onStage);
			
			var loader:SWFLoader = new SWFLoader("wp-content/themes/stranger_dreams/Teaser.swf", {onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});	
			this.container.addChild(loader.content);
			container.x=760;
			loader.load();
			barWidth = 376;
		}
		
		private function progressHandler(event:LoaderEvent):void {
			this.progress.mask.x = Math.ceil(event.target.progress*barWidth);
		}
		
		private function completeHandler(event:LoaderEvent):void {
			this.progress.visible=false;
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("error occured with " + event.target + ": " + event.text);
		}
		
	}
}