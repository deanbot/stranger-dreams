package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.utils.ArrayUtils;
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.deanverleger.utils.StringUtils;
	import net.strangerdreams.engine.goal.GoalType;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.casalib.util.ArrayUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class HUD_goalUpdater extends Sprite
	{
		private static const LOCATION:String="HUD_goalUpdater";
		private static const Q_ADD:String="add";
		private static const Q_UPDATE:String="update";
		private static const Q_REMOVE:String="remove";
		private static const SOUND_STRIKE_THROUGH:String = "strikeThrough";
		private static const SOUND_STRIKE_THROUGH_TWO:String = "strikeThrough2";
		private static const SOUND_ADD:String = "add";
		private static const SOUND_ADD_2:String = "add2";
		private static const SOUND_ADD_TWO:String = "addTwo";
		private static const MAX_ACTIVE:uint=2;
		private static const TIME_BETWEEN:Number=500;
		private static const TIME_FADE_START:Number=1200;
		private static const TIME_FADE:Number=3;
		private static const TIME_WAIT:uint = 150;
		
		private var _queueAdd:Array;
		private var _queueUpdate:Array;
		private var _queueRemove:Array;
		private var _queues:Dictionary;
		private var _goalDisplays:Dictionary;
		private var _goalDisplaysOrder:Dictionary;
		private var _sounds:Dictionary;
		private var waitTimer:Timer;
		private var waitTimerFinished:NativeSignal;
		private var _working:Boolean;
		private var _shiftComplete:Function;
		private var _destroyed:Boolean = false;
		private var updateFinished:Signal;
		
		[Embed(source="../../libs/Sounds/mp3/ui-goalStrikeThrough.mp3")]
		private var StrikeThrough:Class;
		[Embed(source="../../libs/Sounds/mp3/ui-goalStrikeThrough.mp3")]
		private var StrikeThrough2:Class;
		[Embed(source="../../libs/Sounds/mp3/ui-goalAdd.mp3")]
		private var Add1:Class;
		[Embed(source="../../libs/Sounds/mp3/ui-goalAdd2.mp3")]
		private var Add2:Class;
		[Embed(source="../../libs/Sounds/mp3/ui-goalAddTwo.mp3")]
		private var AddTwo:Class;
		
		public var soundFinished:Signal;
		
		public function HUD_goalUpdater()
		{
			super();
			init();
		}
		
		public function addGoal(title:String, type:String, auto:Boolean=true):void
		{
			if(_destroyed)
				return;
			if(!GoalType.isValidType(type))
			{ trace("HUD_goalUpdater: not a valid Goal Type, \""+type+"\""); return; }
			
			//trace ("goal updater queue goal");
			_queueAdd.push(new GoalDisplay(title,type));
			wait();
		}
		
		public function updateGoal(oldTitle:String, newTitle:String ):void
		{
			if(_destroyed)
				return;
			if(_goalDisplays[oldTitle]==null)
			{ trace("HUD_goalUpdater: goal \""+oldTitle+"\" not in goals."); return; }
			
			_queueUpdate.push(new Array(oldTitle,newTitle));
			wait();
		}
		
		public function removeGoal(title:String):void
		{
			if(_destroyed)
				return;
			if(_goalDisplays[title]==null)
			{ trace("HUD_goalUpdater: goal \""+title+"\" not in goals."); return; }
			
			//trace("goal updater: remove goal");
			_queueRemove.push(title);
			wait();
		}
		
		/**
		 * will validate existing goals, seeing if they are active, adding and removing active goals, grabbing the latest goals (implement goalOrder dictionary in goal manager) 
		 * 
		 */
		public function updateGoals():void
		{
			if(_destroyed)
				return;
		}
		
		public function destroy():void
		{
			init(true);
		}
		
		private function validate(key:String, distance:uint, reverse:Boolean=false):uint
		{
			if(_destroyed)
				return 0;
			var queue:Array = _queues[key] as Array;
			var removed:uint=0;
			var i:uint;
			var d:uint = distance;
			var ev:Function;
			if(queue==null)
			{ LoggingUtils.msgTrace("Queue ("+key+") not found.",LOCATION); return removed; }
			else if(queue.length<distance)
			{ LoggingUtils.msgTrace("Queue ("+key+") distance ("+distance+") out of range.",LOCATION); return removed; }
			else
			{
				if(key==Q_ADD)
					ev = function(i:uint):Boolean
					{
						var gd:GoalDisplay=GoalDisplay(queue[i]);
						return (_goalDisplays[gd.text]!=null);
					};
				else if(key==Q_UPDATE)
					ev = function(i:uint):Boolean
					{
						var pair:Array=queue[i] as Array;
						return (_goalDisplays[String(pair[0])]==null || _goalDisplays[String(pair[1])]!=null);
					};
				else if(key==Q_REMOVE)
					ev = function(i:uint):Boolean
					{
						return (_goalDisplays[String(queue[i])]==null);
					};
				//trace("before while loop validate");
				if(reverse)
					i=queue.length-1;
				else
					i=0;
				while(d--)
				{
					//trace("while loop validate: " + d);
					if( ev(i) ) //if evaluates to true then item is invalid
					{
						queue.splice(i,1);
						if(reverse)
							i--;
						removed++;
					}
					else
						if(reverse)
							i--;
						else
							i++;
				}
			}
			return removed;
		}

		private function shift(distance:uint):void
		{
			if(_destroyed)
				return;
			if(distance > MAX_ACTIVE)
				distance=MAX_ACTIVE;
			else if(distance < 1)
			{ trace("HUD_goalUpdater: " + "can't shift negative or zero displays."); return; }
			var i:uint = 0;
			var d:uint = distance;
			var goalDisplay:GoalDisplay;
			var goalDisplay2:GoalDisplay;
			//trace("before while loop shift");
			if(d==MAX_ACTIVE)
			{
				goalDisplay=GoalDisplay(_goalDisplays[String(_goalDisplaysOrder[0])]);
				goalDisplay2=GoalDisplay(_goalDisplays[String(_goalDisplaysOrder[1])]);
				goalDisplay.hideFinished.addOnce(function():void { 
					cleanDisplay(goalDisplay);
				});
				goalDisplay.hide();
				goalDisplay2.hideFinished.addOnce(function():void {
					cleanDisplay(goalDisplay2);
					if(_shiftComplete!=null)
						_shiftComplete();
				});
				goalDisplay2.hide();
			} else if (d==1)
			{
				goalDisplay=GoalDisplay(_goalDisplays[String(_goalDisplaysOrder[0])]);
				goalDisplay.hideFinished.addOnce(function():void {
					cleanDisplay(goalDisplay);
					updateFinished.addOnce(function():void {
						if(_shiftComplete!=null)
							_shiftComplete();
					});
					updateDisplayPositions();
				});
				goalDisplay.hide();
				//hide one with callback>updatePostitions>updateComplete:>shiftComplete
			}
			
		}
		
		private function cleanDisplay(disp:GoalDisplay):void
		{
			var title:String = disp.text;
			if(this.contains(disp))
				removeChild(disp);
			disp.destroy();
			_goalDisplays[title]=null;
			DictionaryUtils.deleteAt(title,_goalDisplaysOrder);
			delete _goalDisplays[title];
		}
		
		private function updateDisplayPositions():void
		{
			if(_destroyed)
				return;
			for( var k:String in _goalDisplays)
			{
				GoalDisplay(_goalDisplays[k]).y=(_goalDisplaysOrder[k]-1)*(20+3);
			}
			//tween instead
			updateFinished.dispatch();
		}
		
		private function init(destroy:Boolean=false):void
		{
			if(destroy)
			{
				_destroyed=true;
				updateFinished.removeAll();
				updateFinished=null;
				soundFinished.removeAll();
				soundFinished=null;
				waitTimerFinished.removeAll();
				waitTimerFinished=null;
				if(waitTimer.running)
					waitTimer.stop();
				waitTimer=null;
				ArrayUtils.empty(_queueAdd);
				ArrayUtils.empty(_queueUpdate);
				ArrayUtils.empty(_queueRemove);
				DictionaryUtils.emptyDictionary(_queues);
				DictionaryUtils.emptyDictionary(_goalDisplaysOrder);
				DictionaryUtils.emptyDictionary(_goalDisplays,true);
				DictionaryUtils.emptyDictionary(_sounds);
				_queues=_goalDisplaysOrder=_goalDisplays=_sounds=null;
			}
			else
			{
				_destroyed=false;
				_queueAdd=new Array();
				_queueUpdate=new Array();
				_queueRemove=new Array();
				_queues=new Dictionary(true);
				_queues[Q_ADD]=_queueAdd;
				_queues[Q_UPDATE]=_queueUpdate;
				_queues[Q_REMOVE]=_queueRemove;
				_goalDisplays=new Dictionary(true);
				_goalDisplaysOrder=new Dictionary(true);
				
				soundFinished=new Signal();
				_sounds = new Dictionary(true);
				_sounds[SOUND_STRIKE_THROUGH] = new StrikeThrough() as Sound;
				_sounds[SOUND_STRIKE_THROUGH_TWO] = new StrikeThrough2() as Sound;
				_sounds[SOUND_ADD] = new Add1() as Sound;
				_sounds[SOUND_ADD_2] = new Add2() as Sound;
				_sounds[SOUND_ADD_TWO] = new AddTwo() as Sound;
				
				updateFinished=new Signal();
				
				waitTimer=new Timer(TIME_WAIT);
				waitTimerFinished=new NativeSignal(waitTimer,TimerEvent.TIMER,TimerEvent);
			}
		}
		
		private function loop():void
		{
			if(_destroyed)
				return;
			var updatePair:Array;
			var updatePair2:Array;
			var goalDisplay:GoalDisplay;
			var goalDisplay2:GoalDisplay;
			var removeTitle:String;
			var removeTitle2:String;
			var valid:uint=0;
			_shiftComplete=null;
			if(_queueRemove.length>0)
			{
				//trace("loop, complete (" + _queueRemove.length + ")");
				
				if (_queueRemove.length==1)
				{
					valid=validate(Q_REMOVE,_queueRemove.length);
					if( valid==0)
					{
						//trace("valid");
						playSound(SOUND_STRIKE_THROUGH);
						removeTitle=_queueRemove.shift() as String;
						complete(removeTitle,false);
					} else
						loop();
				}
				else if (_queueRemove.length>=2)
				{
					valid=validate(Q_REMOVE,2);
					if ( valid == 0)
					{
						playSound(SOUND_STRIKE_THROUGH_TWO);
						removeTitle=_queueRemove.shift() as String;
						removeTitle2=_queueRemove.shift() as String;
						complete(removeTitle,true);
						complete(removeTitle2,false);
					} else
						loop();
				}
			} 
			else if(_queueUpdate.length>0)
			{
				//trace("loop, update (" + _queueUpdate.length + ")");
				
				if (_queueUpdate.length == 1)
				{
					valid=validate(Q_UPDATE,_queueUpdate.length);
					if (valid == 0)
					{
						playSound(SOUND_STRIKE_THROUGH);
						updatePair=_queueUpdate.shift() as Array;
						update(updatePair[0],updatePair[1]);
					} else
						loop();
				}
				else if (_queueUpdate.length >= 2)
				{
					valid=validate(Q_UPDATE,2);
					if (valid == 0)
					{
						playSound(SOUND_STRIKE_THROUGH_TWO);
						updatePair=_queueUpdate.shift() as Array;
						updatePair2=_queueUpdate.shift() as Array;
						update(updatePair[0],updatePair[1],true,false,true);
						update(updatePair2[0],updatePair2[1],false,true);
					} else
						loop();
				}
			}
			else if(_queueAdd.length>0)
			{
				//trace("loop, add");
				
				if (_queueAdd.length == 1)
				{
					if (this.numChildren < 2)
					{
						valid=validate(Q_ADD,_queueAdd.length);
						if(valid == 0 )
						{
							playSound(StringUtils.randomString(SOUND_ADD, SOUND_ADD_2));
							goalDisplay=_queueAdd.shift() as GoalDisplay;
							add(goalDisplay);
						} else
							loop();
					}
					else
					{
						valid=validate(Q_ADD,_queueAdd.length);
						if(valid == 0 )
						{
							_shiftComplete=loop;
							shift(_queueAdd.length);
						} else
							loop();
					}
				}
				else if (_queueAdd.length == 2)
				{
					if (this.numChildren == 0)
					{
						valid=validate(Q_ADD,_queueAdd.length);
						if(valid == 0 )
						{
							playSound(SOUND_ADD_TWO);
							goalDisplay=_queueAdd.shift() as GoalDisplay;
							goalDisplay2=_queueAdd.shift() as GoalDisplay;
							add(goalDisplay,true);
							add(goalDisplay2);
						} else
							loop();
					}
					else if (this.numChildren >= 1)
					{
						valid=validate(Q_ADD,_queueAdd.length);
						if(valid == 0 )
						{
							_shiftComplete=loop;
							shift(this.numChildren);
						} else
							loop();
					}
				}
				else if (_queueAdd.length > 2)
				{
					if (this.numChildren == 0)
					{
						valid=validate(Q_ADD,2,true);
						if(valid == 0 )
						{
							playSound(SOUND_ADD_TWO);
							goalDisplay2=_queueAdd.pop() as GoalDisplay;
							goalDisplay=_queueAdd.pop() as GoalDisplay;
							add(goalDisplay,true);
							add(goalDisplay2);
							ArrayUtils.empty(_queueAdd);
						} else
							loop();
					}
					else if (this.numChildren >= 1)
					{
						valid=validate(Q_ADD,2,true);
						if(valid == 0 )
						{
							_shiftComplete=loop;
							shift(this.numChildren);
						} else
							loop();
					}
				}
			} else {
				//trace("Goal Updater: done with loop!");
				_working = false;
				return;
			}
		}
		
		private function add(goalDisplay:GoalDisplay,ignoreFinished:Boolean=false):void
		{
			if(_destroyed)
				return;
			if(goalDisplay.text==null||goalDisplay.text=='')
				throw new Error("Goal Display has no text. Can't add");
			_goalDisplays[goalDisplay.text]=goalDisplay;
			goalDisplay.y=(this.numChildren)*(20+3);
			_goalDisplaysOrder[this.numChildren]=goalDisplay.text;
			this.addChild(goalDisplay);
			if(!ignoreFinished)
				goalDisplay.showFinished.addOnce(loop);
			//trace("added goalDisplay");
			goalDisplay.show();
		}
		
		private function update(oldTitle:String,newTitle:String,two:Boolean=false,silent:Boolean=false,ignoreFinished:Boolean=false):void
		{
			if(_destroyed)
				return;
			var goalDisplay:GoalDisplay = GoalDisplay(_goalDisplays[oldTitle]);
			if(goalDisplay==null)
				throw new Error("Goal Display doesn't exist. Can't update.");
			
			goalDisplay.strikeFinished.addOnce(onStrikeFinished);
			goalDisplay.strikeThrough(true);
			
			function onStrikeFinished():void
			{
				if(two)
				{
					if(!silent)
						playSound(SOUND_ADD_TWO);
				}
				else
				{
					if(!silent)
						playSound(StringUtils.randomString(SOUND_ADD, SOUND_ADD_2));
				}
	
				_goalDisplays[newTitle]=goalDisplay;
				delete _goalDisplays[oldTitle];
				goalDisplay.text=newTitle;
				if(!ignoreFinished)
					goalDisplay.showFinished.addOnce(loop);
				goalDisplay.show(true);
			}
		}
		
		private function complete(title:String,ignoreFinished:Boolean=false):void
		{
			if(_destroyed)
				return;
			var goalDisplay:GoalDisplay = GoalDisplay(_goalDisplays[title]);
			if(goalDisplay==null)
				throw new Error("Goal Display doesn't exist. Can't update.");
			
			goalDisplay.strikeFinished.addOnce(onStrikeFinished);
			goalDisplay.strikeThrough();
			
			function onStrikeFinished():void
			{
				cleanDisplay(goalDisplay);
				updateDisplayPositions();
				loop();
			}
		}
		
		private static const VOLUME:Number = .35;
		private function playSound(soundKey:String):void
		{
			if(_destroyed)
				return;
			var sound:Sound=_sounds[soundKey] as Sound;
			if(soundKey==null)
			{ trace("HUD_goalUpdater: sound ["+soundKey+"] not found");	return; }
			SoundUtils.playUISound(sound,soundFinished.dispatch,soundKey,false,VOLUME);
		}
		
		private function wait():void
		{
			if(_destroyed)
				return;
			if(!_working)
			{
				_working=true;
				waitTimerFinished.addOnce(function(e:TimerEvent):void { loop(); } );
				waitTimer.start();
			} else {
				//trace("working");
			}
		}
	}
}

import com.greensock.TweenLite;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextFormatAlign;

import net.deanverleger.core.IDestroyable;
import net.deanverleger.text.TextHandle;
import net.deanverleger.utils.AssetUtils;
import net.strangerdreams.app.gui.GoalIconClassName;
import net.strangerdreams.engine.goal.GoalType;

import org.casalib.util.DisplayObjectUtil;
import org.osflash.signals.Signal;

class GoalDisplay extends Sprite implements IDestroyable
{
	private static const FADE_IN:Number=.3;
	private static const FADE_OUT:Number=.3;
	private static const FONT:String = "Times New Roman";
	private static const OFFSET_X:Number = 24;
	private var _working:Boolean;
	private var _th:TextHandle;
	private var _icon:Sprite;
	private var _strikeThrough:Bitmap
	private var _container:Sprite;
	
	public var hideFinished:Signal;
	public var strikeFinished:Signal;
	public var showFinished:Signal;
	
	public function get text():String
	{
		return _th.text;
	}
	
	public function set text(value:String):void
	{
		if(_working)
		{ trace ("Goal Display working. Can't set text yet.");	return; }
		_th.text=value;
	}
	
	public function GoalDisplay(title:String,type:String)
	{
		super();
		strikeFinished=new Signal();
		showFinished=new Signal();
		hideFinished=new Signal();
		
		_container=new Sprite();
		_icon = AssetUtils.getAssetInstance( iconClass(type) ) as Sprite;
		_th=new TextHandle(title,13,0xCCCCCC,false,TextFormatAlign.LEFT,116,0,FONT,false,true,20);
		_icon.alpha=_th.alpha=_container.alpha=0;
		_th.x=OFFSET_X;
		_th.y=-5;
		_container.addChild(_icon);
		_container.addChild(_th);
		addChild(_container);
	}
	
	/**
	 * Fades in goal display.
	 * 
	 * @param update will just fade in text
	 */
	public function show(update:Boolean=false):void
	{
		if(_working)
		{ trace ("Goal Display working. Can't show yet.");	return; }
		//trace("showing goal display");
		fade(update);
	}
	
	/**
	 * Shows strike through graphic and fades out text.
	 * 
	 * @param update will just fade out text
	 */
	public function strikeThrough(update:Boolean=false):void
	{
		if(_working)
		{ trace ("Goal Display working. Can't strikeThrough yet.");	return; }
		_strikeThrough= new Bitmap( new GoalUpdateStrikethrough(1,1) );
		_strikeThrough.alpha=0;
		fade(update);
	}
	
	public function hide():void
	{
		if(_working)
		{ trace ("Goal Display working. Can't hide yet.");	return; }
		TweenLite.to(_container,FADE_OUT,{alpha:0,onComplete:function():void {
			_working=false; 
			hideFinished.dispatch();
		} });
	}
	
	public function destroy():void
	{
		TweenLite.killTweensOf(_container);
		TweenLite.killTweensOf(_th);
		strikeFinished.removeAll();
		showFinished.removeAll();
		strikeFinished=showFinished=null;
		
		DisplayObjectUtil.removeAllChildren(_container);
		removeChild(_container);
		_container=_icon=null;
		_th=null;
	}
	
	/**
	 * Fade in or out depending upon current alpha.
	 * 
	 * @param update only fade in or out text
	 */
	private function fade(update:Boolean=false):void
	{
		if(_working)
		{ trace ("Goal Display working. Can't fade yet.");	return; }
		_working=true;
		var duration:Number;
		var to:Number;
		var callback:Function;
			
		if(_container.alpha==0)
		{
			if(!update)
			{
				_icon.alpha=1;
				_th.alpha=1;
			}
			callback = function():void { _working=false; showFinished.dispatch(); };
			duration=FADE_IN;
			to=1;
		} else {
			if(_th.alpha==0)
			{
				callback = function():void { _working=false; showFinished.dispatch(); };
				duration=FADE_IN
				to=1;
			} else 
			{
				callback = function():void { _working=false; strikeFinished.dispatch(); };
				duration=FADE_OUT;
				to=0;
			}
		}
		
		if(update)
		{
			/*trace("fading text...");
			trace("to :" + to);
			trace("current :" + _th.alpha);*/
			TweenLite.to(_th,duration,{alpha:to,onComplete:callback});
		}
		else
		{
			/*trace("fading container...");
			trace("to :" + to);
			trace("current :" + _container.alpha);*/
			TweenLite.to(_container,duration,{alpha:to,onComplete:callback});
		}
	}
	
	private function iconClass(type:String):String
	{
		var className:String;
		if(type==GoalType.INSPECT)
			className=GoalIconClassName.INSPECT;
		else if(type==GoalType.INTERACT)
			className=GoalIconClassName.INTERACT;
		else if(type==GoalType.SPEECH)
			className=GoalIconClassName.SPEECH;
		else if(type==GoalType.MAP)
			className=GoalIconClassName.MAP;
		return className;
	}
}