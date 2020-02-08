package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.text.TextHandle;
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SESignalBroadcaster;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class NotificationDisplay extends Sprite
	{
		public static const LOCATION:String = "Notification Display"
		private static const STATUS_QUEUED:String = "queued";
		private static const STATUS_ACTIVE:String = "active";
		private static const STATUS_FADING_OUT:String = "fading out";
		private static const STATUS_FADING_IN:String = "fading in";
		
		public var activity:Signal;
		private static const TIME_BETWEEN:Number=500;
		private static const TIME_FADE_START:Number=1400;
		private static const TIME_FADE:Number=2.6;
		private static const MAX_CHILDREN:Number=3;
		
		private var queuedNotifications:Array;
		private var activeNotifications:Array;
		private var positions:Array;
		
		private var sprites:Dictionary = new Dictionary(true);
		private var fadeStartTimers:Dictionary = new Dictionary(true);
		private var fadeStartSignals:Dictionary = new Dictionary(true);
		private var tweenIns:Dictionary = new Dictionary(true);
		private var tweenOuts:Dictionary = new Dictionary(true);
		private var status:Dictionary = new Dictionary(true);
		
		private var working:Boolean = false;
		private var paused:Boolean = false;
		private var _destroy:Boolean = false;
		private var timerBetween:Timer;
		private var timerBetweenInterval:NativeSignal;
		
		public function NotificationDisplay()
		{
			super();
			init();
		}
		
		public function destroy():void
		{
			if(!_destroy)
			{
				_destroy = true;
				activity.removeAll();
				SESignalBroadcaster.inventoryItemAdded.remove(onInventoryItemAdded);
				SESignalBroadcaster.keyItemAdded.remove(onKeyItemAdded);
				SESignalBroadcaster.singleNotification.remove(onSingleNotification);
				SESignalBroadcaster.goalAdded.remove(onGoalAdded);
				SESignalBroadcaster.goalUpdated.remove(onGoalUpdated);
				SESignalBroadcaster.goalComplete.remove(onGoalCompleted);
				timerBetweenInterval.removeAll();
				timerBetweenInterval = null;
				timerBetween = null;
				queuedNotifications = null;
				
				var tweenIn:TweenLite;
				var tweenOut:TweenLite;
				if(activeNotifications.length > 0)
				{
					while(activeNotifications.length != 0)
					{
						clearSprite(String(activeNotifications[0]));
					}
				}
				positions = null;
				DictionaryUtils.emptyDictionary(tweenIns);
				DictionaryUtils.emptyDictionary(tweenOuts);
				DictionaryUtils.emptyDictionary(sprites);
				DictionaryUtils.emptyDictionary(fadeStartSignals);
				DictionaryUtils.emptyDictionary(fadeStartTimers);
				DictionaryUtils.emptyDictionary(status);
				sprites = fadeStartTimers = fadeStartSignals = tweenIns = tweenOuts = status = null;
				activity = null;
			}
		}
		
		public function pause():void
		{
			if(!paused)
			{
				//LoggingUtils.msgTrace("pause (and hide) notifications",LOCATION);
				paused=true;
				this.visible = false;
				var notification:String;
				for(var i:uint = 0; i< activeNotifications.length; i++)
				{
					notification = String(activeNotifications[i]);
					if (status[notification] == STATUS_FADING_IN )
						TweenLite(tweenIns[notification]).pause();
					else if (status[notification] == STATUS_ACTIVE )
						Timer(fadeStartTimers[notification]).stop();
					else if (status[notification] == STATUS_FADING_OUT )
						TweenLite(tweenOuts[notification]).pause();
					else
						LoggingUtils.msgTrace("notifaction status not supported", LOCATION);
				}
				activity.dispatch(false);
			}
		}
		
		public function resume():void
		{
			if(paused)
			{
				//LoggingUtils.msgTrace("resume (and reveal) notifications",LOCATION);
				paused=false;
				this.visible = true;
				if (activeNotifications.length > 0)
				{
					activity.dispatch(true);
					var notification:String;
					for(var i:uint = 0; i< activeNotifications.length; i++)
					{
						notification = String(activeNotifications[i]);
						if (status[notification] == STATUS_FADING_IN )
							TweenLite(tweenIns[notification]).resume();
						else if (status[notification] == STATUS_ACTIVE )
							Timer(fadeStartTimers[notification]).start();
						else if (status[notification] == STATUS_FADING_OUT )
							TweenLite(tweenOuts[notification]).resume();
						else
							LoggingUtils.msgTrace("notifaction status not supported", LOCATION);
					}
				} else if(queuedNotifications.length > 0)
					checkQueue();
			}
		}
		
		private function init():void
		{
			activity=new Signal(Boolean);
			activeNotifications=new Array();
			queuedNotifications=new Array();
			positions=new Array(3);
			SESignalBroadcaster.inventoryItemAdded.add(onInventoryItemAdded);
			SESignalBroadcaster.keyItemAdded.add(onKeyItemAdded);
			SESignalBroadcaster.singleNotification.add(onSingleNotification);
			SESignalBroadcaster.goalAdded.add(onGoalAdded);
			SESignalBroadcaster.goalUpdated.add(onGoalUpdated);
			SESignalBroadcaster.goalComplete.add(onGoalCompleted);
			timerBetween=new Timer(TIME_BETWEEN);
			timerBetweenInterval=new NativeSignal(timerBetween, TimerEvent.TIMER, TimerEvent);
			this.y=390;
			this.x=120;
			this.mouseChildren=false;
			_destroy = false;
		}
		
		private function onInventoryItemAdded(itemTitle:String,notify:Boolean):void
		{
			var notification:String = "Gained item - '" + itemTitle + "'";
			queueNotification(notification);
			/*notification = itemTitle + ' has been added to inventory.';
			queueNotification(notification);*/
			
			if(notify && (!working && !paused))
				updateNotificationDisplay();
		}
		
		private function onKeyItemAdded(itemTitle:String,notify:Boolean):void
		{
			var notification:String = "Gained key item - '" + itemTitle + "'";
			queueNotification(notification);
			/*notification = itemTitle + ' has been added to key items.';
			queueNotification(notification); */
			
			if(notify && (!working && !paused))
				updateNotificationDisplay();
		}
		
		private function onSingleNotification(notification:String):void
		{
			if(sprites[notification]==null)
			{
				queueNotification(notification);
			
				if(!working && !paused)
					updateNotificationDisplay();
			}
		}
		
		private function onGoalAdded(title:String,type:String,notify:Boolean):void
		{
			queueNotification("Goal added - '"+title+"'");
				
			if(notify && (!working && !paused))
				updateNotificationDisplay();
		}
		
		private function onGoalUpdated(title:String,newTitle:String,type:String,notify:Boolean):void
		{
			queueNotification("Goal updated - '"+newTitle+"'");
			
			if(notify && (!working && !paused))
				updateNotificationDisplay();
		}
		
		private function onGoalCompleted(title:String,notify:Boolean):void
		{
			queueNotification("Goal complete - '"+title+"'");
			
			if(notify && (!working && !paused))
				updateNotificationDisplay();
		}
		
		private function queueNotification(notification:String):void
		{
			//LoggingUtils.msgTrace("queuingNotification : "+notification,LOCATION);
			var notificationSprite:Sprite = new Sprite();
			var th:TextHandle = new TextHandle(notification,15,0xFFFFFF,false,TextFormatAlign.LEFT,0,0,"Verdana",true);
			notificationSprite.addChild( th );
			sprites[notification] = notificationSprite;
			notificationSprite.alpha = 0;
			
			status[notification] = STATUS_QUEUED;
			
			var timer:Timer = new Timer(TIME_FADE_START);
			var signal:NativeSignal = new NativeSignal( timer, TimerEvent.TIMER, TimerEvent );
			fadeStartTimers[notification] = timer;
			fadeStartSignals[notification] = signal;
			var onFadeOutTimerFinished:Function = function(e:TimerEvent):void {
				//LoggingUtils.msgTrace("Fade out starting [" + notification + "]",LOCATION);
				status[notification] = STATUS_FADING_OUT;
				TweenLite(tweenOuts[notification]).play();
			};
			signal.addOnce(onFadeOutTimerFinished);
			
			var onFadeInFinished:Function = function():void { 
				//LoggingUtils.msgTrace("Fade in finished  [" + notification + "]",LOCATION);
				status[notification] = STATUS_ACTIVE;
				Timer(fadeStartTimers[notification]).start();
			};
			var onFadeOutFinished:Function = function():void { 
				//LoggingUtils.msgTrace("Fade out finished [" + notification + "]",LOCATION);
				clearSprite(notification);
				checkQueue();
			};
			var tweenIn:TweenLite = new TweenLite( notificationSprite, 1.5, {alpha:1, paused:true, onComplete: onFadeInFinished});
			var tweenOut:TweenLite = new TweenLite( notificationSprite, TIME_FADE, {alpha:0, paused:true, onComplete: onFadeOutFinished, ease:Quad.easeOut});
			tweenIns[notification] = tweenIn;
			tweenOuts[notification] = tweenOut;

			queuedNotifications.push(notification);
		}		
		
		private function updateNotificationDisplay():void
		{
			if(!working && !paused && !_destroy)
			{
				if(queuedNotifications.length>0)
				{
					// add notification to display list
					
					working=true;
					activity.dispatch(true);
					var notification:String = queuedNotifications.shift();
					activeNotifications.push(notification);
					var sprite:Sprite = Sprite(sprites[notification]);
					
					//adjust positioning
					if (this.numChildren == 0)
					{
						positions[0] = notification;
					}
					else
					{
						if(positions[2] != null)
						{
							if(positions[1] != null)
								positions[0] = positions[1];
							positions[1] = positions[2];
							positions[2] = notification;
						}
						else if(positions[1] != null)
						{
							if(positions[0] == null)
							{
								positions[0] = positions[1];
								positions[1] = notification;
							} 
							else
							{
								positions[2] = notification;
							}
						}
						else if(positions[0] != null)
						{
							positions[1] = notification;
						}
						else
						{
							positions[0] = notification
						}
					}
					
					//update y position based on positioning
					for(var i:uint; i<MAX_CHILDREN; i++)
					{
						if(positions[i] != null)
							Sprite(sprites[positions[i]]).y = i * (22 + 3); //sprite height plus 3
					}
					
					addChild(sprite);
					
					status[notification] = STATUS_FADING_IN;	
					TweenLite(tweenIns[notification]).play();
					
					if (this.numChildren < MAX_CHILDREN)
					{
						timerBetweenInterval.addOnce( function(e:TimerEvent):void {
							working=false;
							timerBetween.stop();
							timerBetween.reset();
							updateNotificationDisplay();
						});
						timerBetween.start();
					}
				}
			}
		}
		
		private function checkQueue():void
		{
			//LoggingUtils.msgTrace("Checking Queue (timerRunning: " + timerBetween.running + ")",LOCATION);
			if(timerBetween.running)
				return;
			working=false;
			updateNotificationDisplay();
		}

		private function clearSprite(notification:String):void
		{
			//sLoggingUtils.msgTrace("clearing sprite", LOCATION);
			var popped:String = String( (activeNotifications.splice( activeNotifications.indexOf(notification), 1) as Array)[0] );
			//remove from active notifications (should be the first)
			//LoggingUtils.msgTrace( "Clearing Sprite " + notification + "(popped notification : " + popped + ")", LOCATION);
			
			//clear tweens
			TweenLite(tweenIns[notification]).kill();
			TweenLite(tweenOuts[notification]).kill();
			tweenIns[notification] = null;
			tweenOuts[notification] = null;
			delete tweenIns[notification];
			delete tweenOuts[notification];
			
			//clear timer signal
			NativeSignal(fadeStartSignals[notification]).removeAll();
			fadeStartSignals[notification]=null;
			delete fadeStartSignals[notification];
			
			//remove from statuses
			status[notification] = null;
			delete status[notification];
			
			//remove from positions
			positions[ positions.indexOf(notification) ] = null;
			
			//clear timer
			fadeStartTimers[notification]=null;
			delete fadeStartTimers[notification];
			
			//remove and clear sprite
			Sprite(sprites[notification]).removeChildAt(0);
			this.removeChild( Sprite(sprites[notification]) );
			sprites[notification]=null;
			delete sprites[notification];
			
			//dispatch something or other
			if(this.numChildren==0)
				activity.dispatch(false);
		}
	}
}