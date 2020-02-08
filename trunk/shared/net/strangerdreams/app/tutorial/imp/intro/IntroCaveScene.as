package net.strangerdreams.app.tutorial.imp.intro
{
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.location.INodeImplementor;
	import net.strangerdreams.engine.location.LocationNode;
	
	public class IntroCaveScene extends LocationNode implements INodeImplementor
	{
		private var nodeAsset:DreamCaveScene;
		public function IntroCaveScene()
		{
			super();
		}
		
		public function loadStates(defaultState:String):void
		{
			this.sm.addState( Default.KEY, new Default(), true );
		}
		
		public function caveEndReached():void
		{
			SESignalBroadcaster.sceneEndReached.dispatch();
		}
	}
}
import com.greensock.TweenLite;
import com.greensock.easing.Quad;
import com.greensock.easing.Sine;
import com.meekgeek.statemachines.finite.states.State;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.Timer;

import net.deanverleger.utils.GraphicsUtil;
import net.deanverleger.utils.LoggingUtils;
import net.deanverleger.utils.TweenUtils;
import net.strangerdreams.app.keyboard.SEAuxKeyboardListener;
import net.strangerdreams.engine.SESignalBroadcaster;
import net.strangerdreams.engine.sound.SoundUtils;

import org.casalib.ui.Key;
import org.casalib.util.DisplayObjectUtil;
import org.osflash.signals.natives.NativeSignal;

class Default extends State
{
	public static const KEY:String = "Default";
	public static const LOCATION:String = "CaveDream";
	private static const KEYCODE_DOWN:uint = 40;
	private static const MOVE_SPEED:Array = new Array(.15,.19,.27);
	private static const SCALE_SPEED:Array =  new Array(.0007,0.0009025,0.0012825);
	private static const TRANSITION_TIME:Number = 3;
	
	private static const BEN_SCALE:Array = new Array(.26, .48, .72);
	private static const benPoint1:Point = new Point(387.65,198.45);
	private static const benScale1:Number = .26;
	private static const benPoint2:Point = new Point(386.1,238.6);
	private static const benScale2:Number = .48;
	private static const benPoint3:Point = new Point(390.1,274.95);
	private static const benScale3:Number = .72;
	private static const STOP_1:Number = 210;
	private static const STOP_2:Number = 254;
	private static const STOP_3:Number = 300;
	private static const LIGHT_SIZE:Array = new Array(3.1,3.1,3.1);
	private static const STANDING_TIME:Number = 3500;
	private static const MAX_HINTS:uint = 3;
	
	private var asset:MovieClip;
	private var activeBen:CaveBen;
	private var oldBen:CaveBen;
	private var newBen:CaveBen;
	
	private var enterFrame:NativeSignal;
	private var moving:Boolean;
	private var currentBen:uint = 1;
	
	private var mirrorSprite:Sprite;
	private var _mirrorBmp:Bitmap = new Bitmap();
	private var _mirrorBmd:BitmapData = new BitmapData(760,512,true,0);
	private var _mirrorMtx:Matrix;
	private var _transPoint:Point = new Point(760/2, 512/2);
	private var lightAddition:Number = 0;
	private var lightAddition2:Number = 0;
	
	private var _particleLayer:Sprite;
	private var _particles:Array = [];
	private var _oldParticles:Array = [];
	private var _oldParticleLayer:Sprite;
	private var _emitter:Emitter;
	private var _oldEmitter:Emitter;
	private var _standingTimer:Timer;
	private var _standingTImerComplete:NativeSignal;
	private var _numHints:uint = 0;
	private var _arrowHint:Sprite;
	
	public function Default()
	{
		super();
	}
	
	override public function doIntro():void
	{
		asset = this.context as MovieClip;
		activeBen = new CaveBen();
		oldBen = new CaveBen();
		
		activeBen.scaleX = activeBen.scaleY = benScale1;
		activeBen.x = benPoint1.x;
		activeBen.y = benPoint1.y;
		asset.addChild(activeBen);
		
		_particleLayer = new Sprite();
		_oldParticleLayer = new Sprite();
		light_setup();
		prepareNewBen();
		
		enterFrame = new NativeSignal(asset.stage,Event.ENTER_FRAME,Event);
		this.signalIntroComplete();
		SoundUtils.playSingleSound("Cave1", new Cave1(), 1);
		
		_arrowHint = new ArrowHint() as Sprite;
		_arrowHint.alpha = 0;
		_arrowHint.visible = false;
		_arrowHint.x = 666;
		_arrowHint.y = 442;
		asset.addChild( _arrowHint );
		
		_standingTimer = new Timer(STANDING_TIME);
		_standingTImerComplete = new NativeSignal(_standingTimer,TimerEvent.TIMER, TimerEvent);
		_standingTImerComplete.addOnce(onStandingTimer);
		_standingTimer.start();
	}
	
	private function haltStandingTimer():void
	{
		TweenLite.killTweensOf(_arrowHint);
		_arrowHint.alpha = 0;
		_arrowHint.visible = false;
		_standingTimer.stop();
		_standingTimer.reset();
		_standingTImerComplete.remove(onStandingTimer);
	}
	
	private function resumeStandingTimer():void
	{
		_standingTImerComplete.addOnce(onStandingTimer);
		_standingTimer.start();
	}
	
	private function onStandingTimer(e:TimerEvent):void
	{
		if(moving)
			return;
		_standingTimer.stop();
		_standingTimer.reset();
		_arrowHint.visible = true;
		phaseIn();
		_numHints++;
	}
	
	private function phaseOut():void
	{
		if(moving)
			return;
		TweenLite.to(_arrowHint, 2, { alpha: 0, ease:Sine.easeIn, onComplete: phaseIn });
	}
	
	private function phaseIn():void
	{
		if(moving)
			return;
		TweenLite.to(_arrowHint, 2, { alpha: 1, ease:Sine.easeIn, onComplete: phaseOut });
	}
	
	private function light_setup():void
	{
		mirrorSprite = new Sprite();
		asset.addChild(mirrorSprite);
		_mirrorBmp.bitmapData = _mirrorBmd;
		mirrorSprite.addChild(_mirrorBmp);
		
		_emitter = new Emitter();
		_particleLayer.addChild(_emitter);
		activeBen.lightPoint.addChild(_particleLayer);
		_oldEmitter = new Emitter();
		_oldParticleLayer.addChild(_oldEmitter);
		
		_particles.push(new Particle(30));
		_particles.push(new Particle(100, 100, 100));
		_oldParticles.push(new Particle());
		_oldParticles.push(new Particle(350, 100));
		_oldParticles.push(new Particle(350, 50));
		_oldParticles.push(new Particle(100, 100));
	}

	private function onEnterFrame(e:Event):void
	{
		if(moving)
			doMovement();
		
		if(moving && (currentBen == 3))
			lightAddition+=.56;
		if(moving && (currentBen == 2))
			lightAddition2+=.2;
		createParticle();
		
		_mirrorMtx = new Matrix();
		var ram:Number;
		if(currentBen==1)
		{
			_transPoint.x = activeBen.x + activeBen.lightPoint.x;
			_transPoint.y = activeBen.y + activeBen.lightPoint.y + 340 -2 + 2*Math.random();
			ram = LIGHT_SIZE[currentBen-1] * activeBen.scaleX -.02 + .02 *Math.random();
			mirrorSprite.alpha = .8;
		}
		else if (currentBen == 2)
		{
			_transPoint.x = activeBen.x + activeBen.lightPoint.x -3 + 3*Math.random();
			_transPoint.y = activeBen.y + activeBen.lightPoint.y + 280 -2 + 2*Math.random() - lightAddition2;
			ram = LIGHT_SIZE[currentBen-1] * activeBen.scaleX -.002 + .02 *Math.random();
			mirrorSprite.alpha = .8;
		}
		else if (currentBen == 3)
		{
			_transPoint.x = activeBen.x + activeBen.lightPoint.x -3 + 3*Math.random();
			_transPoint.y = activeBen.y + activeBen.lightPoint.y + 100 - lightAddition;
			ram = (LIGHT_SIZE[currentBen-1] * activeBen.scaleX) + (lightAddition*.02) - .02 + (.02 *Math.random());
			mirrorSprite.alpha = .8 + (lightAddition *.01);
		}
		_mirrorMtx.scale(ram,ram); 
		_mirrorMtx.translate(_transPoint.x, _transPoint.y);
		_mirrorBmd.fillRect(_mirrorBmd.rect, 0x000000);
		_mirrorBmd.draw( _oldParticleLayer, _mirrorMtx);
	}

	private function createParticle():void
	{
		for each (var p:Particle in _particles) {
			if (p.destroy) {
				p.init();
				_particleLayer.addChild(p);
			}
		}
		for each (var p2:Particle in _oldParticles) {
			if (p2.destroy) {
				p2.init();
				_oldParticleLayer.addChild(p2);
			}
		}
	}
	
	private function doMovement():void
	{
		if(currentBen!=4)
		{
			activeBen.scaleX = activeBen.scaleY += Number(SCALE_SPEED[currentBen-1]);
			activeBen.y += Number(MOVE_SPEED[currentBen-1]);
		}
		if(currentBen==1)
		{
			_numHints = MAX_HINTS;
			if(activeBen.y >= STOP_1)
				transitionBen();
		} 
		else if(currentBen == 2)
		{
			if(activeBen.y >= STOP_2)
				transitionBen();
		}
		else if(currentBen == 3)
		{
			if(activeBen.y >= STOP_3)
				fadeScene();
		}
	}
	
	override public function action():void
	{
		moving = false;
		SEAuxKeyboardListener.keyDown.add(onKeyDown);
		SEAuxKeyboardListener.keyUp.add(onKeyUp);
		enterFrame.add(onEnterFrame);
	}
	
	override public function doOutro():void
	{
		enterFrame.remove(onEnterFrame);
		enterFrame = null;
		DisplayObjectUtil.removeAllChildren(asset,false,true);
		mirrorSprite = _particleLayer = _oldParticleLayer = null;
		_mirrorBmp = null;
		_emitter = _oldEmitter = null;
		_mirrorMtx = null;
		activeBen = oldBen = newBen = null;
		this.signalOutroComplete();
	}
	
	private function onKeyDown(e:KeyboardEvent):void
	{
		if(!moving && currentBen < 4)
		{
			if(e.keyCode == KEYCODE_DOWN)
			{
				moving = true;
				haltStandingTimer();
			}
		}
	}
	
	private function onKeyUp(e:KeyboardEvent):void
	{
		if(moving)
		{
			if(e.keyCode == KEYCODE_DOWN)
			{
				moving = false;
				if(_numHints < MAX_HINTS)
					resumeStandingTimer();
			}
		}
	}
	
	
	
	private function transitionBen():void
	{
		enterFrame.remove(onEnterFrame);
		currentBen++;
		oldBen=activeBen;
		activeBen=newBen;
		activeBen.visible = true;
		oldBen.alpha = .8;
		//oldBen.lightPoint.addChild(_oldParticleLayer);
		activeBen.lightPoint.addChild(_particleLayer);
		TweenLite.to(oldBen,TRANSITION_TIME + (currentBen==4)?4:0,{alpha:0,onUpdate:updateOldBen});
		TweenLite.to(activeBen,TRANSITION_TIME + (currentBen==4)?4:0,{alpha:1,onComplete: transitionFinished});
		enterFrame.add(onEnterFrame);
		if(currentBen == 2)
			SoundUtils.playSingleSound("Cave2", new Cave2(), 1);
		if(currentBen == 3)
		{
			SoundUtils.playSingleSound("Cave3", new Cave3(), 1, endScene);
			SEAuxKeyboardListener.keyDown.remove(onKeyDown);
			SEAuxKeyboardListener.keyUp.remove(onKeyUp);
			moving = true;
		} else
		{
			prepareNewBen();
		}
	}
	
	private function fadeScene():void
	{
		TweenLite.to(asset,1,{alpha: 0});
	}
	
	private function endScene():void
	{
		SESignalBroadcaster.sceneEndReached.dispatch();
	}
	
	private function updateOldBen():void
	{
		if(oldBen==null)
			return;
		oldBen.scaleX = oldBen.scaleY += SCALE_SPEED[currentBen-2];
		oldBen.y += MOVE_SPEED[currentBen-2];
	}
	
	private function transitionFinished():void
	{
		asset.removeChild(oldBen)
		oldBen = null;
	}
	
	private function prepareNewBen():void
	{
		asset.addChildAt(newBen = new CaveBen(),asset.numChildren-2);
		newBen.alpha = 0;
		newBen.visible = false;
		if(currentBen == 1)
		{
			newBen.x = benPoint2.x;
			newBen.y = benPoint2.y;
			newBen.scaleX = newBen.scaleY = benScale2;
		} 
		else if(currentBen == 2)
		{
			newBen.x = benPoint3.x;
			newBen.y = benPoint3.y;
			newBen.scaleX = newBen.scaleY = benScale3;
		}
	}
}

import flash.display.Sprite;
import flash.display.GradientType;

class Emitter extends Sprite
{
	public function Emitter(){}
}

import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.display.SpreadMethod;

class Particle extends Sprite
{
	public var size:Number;
	
	private var _destroy:Boolean;
	
	public function Particle(size:Number = 30, aS:Number = 100, aE:Number = 0)
	{
		size = size;
		
		var fillType:String = GradientType.RADIAL;
		var colors:Array = [0xe9e699 , 0x000000];
		var alphas:Array = [aS,aE];
		var ratios:Array = [0, 255];
		var mat:Matrix = new Matrix();
		mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
		var spreadMethod:String = SpreadMethod.PAD;
		
		graphics.clear();
		graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
		graphics.drawCircle(0, 0, size);
		graphics.endFill();
		
		blendMode = "add";
		
		_destroy = true;
	}
	
	public function init():void
	{
		_destroy = false;
	}
	
	public function get destroy():Boolean
	{
		return _destroy;
	}
}