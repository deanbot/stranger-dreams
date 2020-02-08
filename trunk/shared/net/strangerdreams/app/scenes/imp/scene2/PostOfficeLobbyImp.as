package net.strangerdreams.app.scenes.imp.scene2
{
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class PostOfficeLobbyImp extends LocationNode implements INodeImplementor
	{
		private var frame:PostOfficeLobby;
		public function PostOfficeLobbyImp()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), (Default.KEY == defaultState)?true:false );
			this.sm.addState( FadeToCounter.KEY, new FadeToCounter(), (FadeToCounter.KEY == defaultState)?true:false );
			this.sm.addState( Counter.KEY, new Counter(), (Counter.KEY == defaultState)?true:false );
			this.sm.addState( PassOut.KEY, new PassOut(), (PassOut.KEY == defaultState)?true:false );
		}
	}
}

import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import flash.events.MouseEvent;

import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.flag.FlagManager;
import net.strangerdreams.engine.item.ItemManager;
import net.strangerdreams.engine.note.NoteManager;
import net.strangerdreams.engine.scene.data.NodeObject;

import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	private var ref:PostOfficeLobby;
	private var janeClicked:NativeSignal;
	public function Default()
	{
		
	}
	override public function doIntro():void
	{
		ref = this.context as PostOfficeLobby;
		janeClicked = new NativeSignal(ref.jane,MouseEvent.CLICK,MouseEvent);
		janeClicked.addOnce(onJaneClicked);
		SESignalBroadcaster.compassDirectionClicked.add(onArrowPressed);
		//FlagManager.addFlag("passOut");
		this.signalIntroComplete();
	}
	private function onArrowPressed(dir:String):void
	{
		if(dir =="S")
		{
			SESignalBroadcaster.compassDirectionClicked.remove(onArrowPressed);
			SESignalBroadcaster.changeNode.dispatch(7);
		}
	}
	
	private function onJaneClicked(e:MouseEvent):void
	{
		FlagManager.addFlag("gotPackage");
		janeClicked = null;
		SESignalBroadcaster.interactiveRollOut.dispatch();
		SESignalBroadcaster.updateState.dispatch();
	}
}

class FadeToCounter extends State
{
	public static const KEY:String = "FadeToCounter";
	public function FadeToCounter()
	{
		
	}
}

class Counter extends State
{
	public static const KEY:String = "Counter";
	
	private static const NOTE_TICKET:String = "noteTrainTicket";
	private static const NOTE_PHOTO:String = "notePhotoStrangeMan";
	private static const NOTE_LETTER:String = "carePackageLetter";
	private var ref:PostOfficeLobby;
	private var carePackageClick:NativeSignal;
	public function Counter()
	{
		
	}
	
	override public function doIntro():void
	{
		ref = this.context as PostOfficeLobby;
		carePackageClick = new NativeSignal(ref["carePackage"],MouseEvent.CLICK,MouseEvent);
		carePackageClick.addOnce(onCarePackageClicked);
		this.signalIntroComplete();
	}
	
	private function onCarePackageClicked(e:MouseEvent):void
	{
		carePackageClick = null;
		SESignalBroadcaster.interactiveRollOut.dispatch(); 
		
		//queue brochure read and read barry letter
		SESignalBroadcaster.noteOverlayFinished.addOnce(onNotesFinished); // wait for note overlay finished
		SESignalBroadcaster.queueNoteOverlay.dispatch( NOTE_PHOTO, false);
		SESignalBroadcaster.queueNoteOverlay.dispatch( NOTE_LETTER, false);
		SESignalBroadcaster.doNoteOverlay.dispatch( NOTE_TICKET, false);
		SESignalBroadcaster.queueUpdateState.dispatch();

		FlagManager.addFlag("passOut");
	}	
	
	private function onNotesFinished():void
	{
		NoteManager.addNote(NOTE_LETTER);
		NoteManager.setNoteRead(NOTE_LETTER);
		ItemManager.addItemInventory("flashlight",true);
	}
}

import com.greensock.TweenLite;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TweenPlugin;
import com.greensock.easing.Bounce;
import com.greensock.easing.Sine;
import flash.display.Shape;
import flash.filters.BlurFilter;
import com.greensock.easing.Circ;
import com.greensock.easing.Back;
import com.greensock.easing.Expo;

class PassOut extends State
{
	public static const KEY:String = "PassOut";
	private var ref:PostOfficeLobby;
	private var eyeLidTop:Shape;
	private var eyeLidBottom:Shape;
	private var lidBlur:BlurFilter;
	//public var bmp : Bitmap;
	//public var shader : Shader = new Shader;3
	//public var loaderShader : URLLoader = new URLLoader;
	
	public function PassOut()
	{
		
	}
	
	override public function doIntro():void
	{
		ref = this.context as PostOfficeLobby;
		this.signalIntroComplete();
	}
	
	private var step:uint = 0;
	private function blurNext():void
	{
		/*
		if(step == 0)
		{
			
			TweenLite.to(ref, .5, {alpha: .5, onComplete:blurNext});
		} else if (step == 1)
		{
			TweenLite.to(ref, .3, {alpha: .1, onComplete:blurNext});

		} else if (step == 2)
		{
			TweenLite.to(ref, 2, {delay: 1, blurFilter:{blurY:15}, ease:Bounce.easeOut, onComplete:blurNext});
		} else if (step == 3)
		{
			TweenLite.to(ref, 1, {delay: 1, blurFilter:{blurY:0}, ease:Bounce.easeOut, onComplete:blurNext});
			TweenLite.to(ref, 1, {delay: 1, blurFilter:{blurX:15}, ease:Sine.easeIn});
		}
		step++;
		*/
		
		if(step == 0)
		{
			//trace(step);
			TweenLite.to(ref, 2, {blurFilter:{blurY:15}, ease:Circ.easeIn, onComplete:blurNext});
		} 
		else if (step == 1)
		{
			//trace(step);
			TweenLite.delayedCall(.5,blurNext);
		} 
		else if (step == 2)
		{
			//trace(step);
			TweenLite.to(ref, 1.5, { blurFilter:{blurY:0}, onComplete:blurNext});
		} 
		else if (step == 3)
		{
			//trace(step);
			TweenLite.to(ref, 1.5, { blurFilter:{blurX:20,blurY:10}, ease:Bounce.easeIn, onComplete:blurNext});
		}
		else if (step == 4)
		{
			//trace(step);
			TweenLite.delayedCall(.5,blurNext);
		}
		else if (step == 5)
		{
			//trace(step);
			//eyeLidTop.visible = eyeLidBottom.visible = true;
			TweenLite.to(ref, 1.5, { blurFilter:{blurY:15} });
			TweenLite.to(eyeLidTop, .4, {alpha: 1 });
			TweenLite.to(eyeLidBottom, .4, {alpha: 1 });
			TweenLite.to(eyeLidTop, 2.5, { delay: .2, y:"+256", ease:Circ.easeIn });
			TweenLite.to(eyeLidBottom, 2.5, { delay: .2, y:"-256", ease:Circ.easeIn, onComplete:blurNext });
		}
		else if (step == 6)
		{
			
			ref = null;
			SESignalBroadcaster.sceneEndReached.dispatch();
		}
		step++;
	}
	
	override public function action():void
	{
		lidBlur = new BlurFilter();
		lidBlur.blurX = 10;
		lidBlur.blurY = 10;
		ref.addChild(eyeLidTop = new Shape());
		ref.addChild(eyeLidBottom = new Shape());
		eyeLidTop.graphics.beginFill( 0x000000, 1);
		eyeLidTop.graphics.drawRect(0, -256, 760, 256);
		eyeLidTop.graphics.endFill();
		eyeLidBottom.graphics.beginFill( 0x000000, 1);
		eyeLidBottom.graphics.drawRect(0, 512,  760, 256);
		eyeLidBottom.graphics.endFill();
		eyeLidTop.filters=[lidBlur];
		eyeLidBottom.filters=[lidBlur];
		eyeLidTop.cacheAsBitmap=true;
		eyeLidBottom.cacheAsBitmap=true;
		//eyeLidTop.alpha = eyeLidBottom.alpha = 0;
		//eyeLidTop.visible = eyeLidBottom.visible = false;
		TweenPlugin.activate([BlurFilterPlugin]);
		blurNext();
	}
}

/*
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class LensBlur extends Sprite{
		public var loaderImage : Loader = new Loader;
		
		public var bmp : Bitmap;
		public var shader : Shader = new Shader;
		
		public function LensBlur(){
			graphics.beginFill(0, 1);
			graphics.drawRect(0, 0, 760, 512);
			graphics.endFill();
			//loaderImage.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded);
			//loaderImage.load(new URLRequest("http://www.bongiovi.tw/wonderfl/mood.jpg"), new LoaderContext(true));
		}
		
		
		private function imgLoaded(e:Event) : void {
			bmp = Bitmap(loaderImage.content);
			addChild(bmp).y = ( 465 - bmp.height ) * .5;
			loaderShader.addEventListener(Event.COMPLETE, shaderLoaded);
			loaderShader.dataFormat = URLLoaderDataFormat.BINARY;
			loaderShader.load(new URLRequest("http://www.bongiovi.tw/wonderfl/LensBlur.pbj"));
		}
		
		
		private function shaderLoaded(e:Event) : void {
			shader.byteCode = ByteArray(loaderShader.data);
			var bmpdBlur:BitmapData = bmp.bitmapData.clone();
			bmpdBlur.applyFilter(bmpdBlur, bmpdBlur.rect, new Point, new BlurFilter(10, 10, 3));
			shader.data.srcBlur.input = bmpdBlur;
			render(465 / 2 , 465 / 2);
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		
		public function loop(e:Event) : void {
			render(mouseX, mouseY);
		}
		
		
		public function render(tx:Number, ty:Number) : void {
			shader.data.center.value = [tx, ty];
			bmp.filters = [new ShaderFilter(shader)];
		}
	}
*/