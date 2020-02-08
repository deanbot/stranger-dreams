package net.strangerdreams.engine.events
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.utils.ArrayUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.events.data.StoryEvent;
	import net.strangerdreams.engine.events.data.StoryEventCondition;
	import net.strangerdreams.engine.events.data.StoryEventConditionType;
	import net.strangerdreams.engine.events.data.StoryEventResult;
	import net.strangerdreams.engine.events.data.StoryEventResultType;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.goal.GoalManager;
	import net.strangerdreams.engine.item.ItemManager;
	import net.strangerdreams.engine.map.MapObjectManager;
	import net.strangerdreams.engine.note.NoteManager;
	
	import org.casalib.util.ArrayUtil;
	import org.osflash.signals.natives.NativeSignal;

	public class EventManager
	{
		// constants:
		// private properties:
		//private static var _eventActionActive:Boolean;
		private static var _busy:Boolean;
		private static var _silent:Boolean;
		private static var _events:Array;
		private static var _event:StoryEvent;
		private static var _eventQueue:Array;
		private static var _working:Boolean;
		private static var _transitionDelayTimer:Timer;
		private static var _transitionDelay:NativeSignal;
		private static var _eventsCompleteCallback:Function;
		private static var _eventQueueFinishedCallback:Function;
		private static var _oldEventsCompleteCallback:Function;
		
		// public properties:
		// constructor:
		// public getter/setters:
		//public static function get actionActive():Boolean { return _eventActionActive; }
		
		// public methods:
		/**
		 * 
		 * @param transitionCommands commands to do immediately if not moving to a new node
		 * @param frameCommands commands to do when completely finished with any event action if not moving to a new node
		 * @param delayForTransition whether to postpone first event until movement (to new node) is complete (may be switching to state not node)
		 * 
		 */
		public static function doEvents(transitionCommands:Function,frameCommands:Function,delayForTransition:Boolean=false):void
		{
			if(_event==null)
			{
				SESignalBroadcaster.blockToggle.dispatch(false);
				return;
			}
			if(_busy)
			{ 
				//trace("Event Manager busy."); 
				return; 
			}
			_busy=true;
			var r:StoryEventResult;
			var rType:String;
			var rSubtype:String;
			if(_eventQueue!=null)
				if(_eventQueue.length>0) trace("Warning. Events currently in queue will be erased.");
			_eventQueue=new Array();
			var remove:Array = _event.remove.slice();
			if(remove.length>0)
				_eventQueueFinishedCallback = function():void
				{
					var removed:Boolean = removeItems(_events,remove);
				};
			if(_eventsCompleteCallback == null)
				_eventsCompleteCallback = function():void { frameCommands(); };
			//add events to queue
			var moving:Boolean=false;
			for(var i:uint=0;i<_event.results.length;i++)
			{
				r=StoryEventResult(_event.results[i]);
				_eventQueue.push(r);
				//check if moving
				rType=r.type;
				rSubtype=r.subtype;
				if(rType==StoryEventResultType.MOVEMENT)
					moving=true;
			}
			_event=null;
			
			if(!moving)
				transitionCommands();
			else
				_eventsCompleteCallback = null;
			_silent=moving;
			
			//if moving may want to issue move and then delay for larger? transition may not want to call callback 
			// or maybe go through all events on silent and issue a display after movement
			
			if(delayForTransition)
			{
				_transitionDelayTimer=new Timer((SEConfig.transitionTime*1000)*5);
				_transitionDelay=new NativeSignal(_transitionDelayTimer, TimerEvent.TIMER,TimerEvent);
				_transitionDelay.addOnce(function(e:TimerEvent):void {
					SESignalBroadcaster.blockToggle.dispatch(false);
					eventLoop(); 
					_transitionDelay.removeAll();
					_transitionDelay=null;
					_transitionDelayTimer=null;
				});
				_transitionDelayTimer.start();
			} else
			{
				SESignalBroadcaster.blockToggle.dispatch(false);
				eventLoop();
			}
		}
		
		public static function generate(sceneData:XML):void
		{
			if(sceneData==null)
				return;
			_events=new Array();
			for each(var eventData:XML in sceneData.event)
			{
				if(String(eventData.@key)==null)
					throw new Error("Event Manager: Event has no key.");
				_events.push(getEventInstance(eventData));
			}
		}
		
		public static function get hasEvents():Boolean
		{
			
			var hasEvent:Boolean=false;
			checkEvents();
			if(_event!=null)
				hasEvent=true;
			return hasEvent;
		}
		
		private static function removeItems(tarArray:Array, items:Array):Boolean 
		{
			var removed:Boolean = false;
			var l:uint          = tarArray.length;
			
			for (var i:uint=0; i<l-1; i++)
			{
				if(items.indexOf(StoryEvent(tarArray[i]).key) > -1)
				{
					tarArray.splice(i, 1);
					removed = true;
				}
			}
			
			return removed;
		}
		
		private static var _hasCheckedEvents:Boolean;
		private static function eventLoop():void
		{
			if(_eventQueue == null)
				return;
			if(_eventQueue.length>0)
			{
				var r:StoryEventResult = _eventQueue.shift() as StoryEventResult;
				var rType:String = r.type;
				var rSubtype:String = r.subtype;
				if(rType==StoryEventResultType.GOAL)
				{
					//trace("goal["+r.key + "." + r.target + "] event: " + rSubtype);
					if(rSubtype==StoryEventResultType.GOAL_ADD)
						GoalManager.addActiveGoal(r.key,!_silent);
					else if(rSubtype==StoryEventResultType.GOAL_UPDATE)
						GoalManager.updateActiveGoal(r.target,r.key,!_silent);
					else if(rSubtype==StoryEventResultType.GOAL_COMPLETE)
						if(r.targetGroup!="")
							GoalManager.removeActiveGoalGroup(r.targetGroup,!_silent);
						else
							GoalManager.removeActiveGoal(r.target,!_silent);
					if(r.givesFlag!=null&&r.givesFlag!="")
					{
						FlagManager.addFlag(r.givesFlag);
					}
					eventLoop();
				} else if(rType==StoryEventResultType.CAPTION)
				{
					//trace("caption event");
					SESignalBroadcaster.captionComplete.addOnce(eventLoop);
					SESignalBroadcaster.singleCaption.dispatch(r.key);
					if(r.givesFlag!=null&&r.givesFlag!="")
					{
						FlagManager.addFlag(r.givesFlag);
					}
				} else if(rType==StoryEventResultType.FLAG)
				{
					if(rSubtype==StoryEventResultType.FLAG_ADD)
						if(r.givesFlag!=null&&r.givesFlag!="")
							FlagManager.addFlag(r.givesFlag);
					eventLoop();
				} else if(rType==StoryEventResultType.MOVEMENT)
				{
					//trace("story engine does not currently support movement in events");
					if(r.givesFlag!=null&&r.givesFlag!="")
					{
						FlagManager.addFlag(r.givesFlag);
					}
					eventLoop();
				} else if(rType==StoryEventResultType.MAP)
				{
					if(rSubtype==StoryEventResultType.MAP_ADD_CIRCLE)
						MapObjectManager.addMapCircleLocation(r.mapLocation);
					else if(rSubtype==StoryEventResultType.MAP_REMOVE_CIRCLE)
						MapObjectManager.removeRemoveCircleLocation(r.mapLocation);
					eventLoop();
				}
			} else {
				_busy=false;
				_silent=false;
				var blank:Function = function():void { };
				if(_eventQueueFinishedCallback!=null)
				{
					_eventQueueFinishedCallback();
					_eventQueueFinishedCallback = null;
				}
				// check for more events
				if( hasEvents )	{	
					_eventQueue=null;
					doEvents( blank, blank );
				} else {
					//trace("done with events!");
					SESignalBroadcaster.blockToggle.dispatch(false);
					if(_eventsCompleteCallback !=null)
					{	
						_eventsCompleteCallback();
						_eventsCompleteCallback=null;
					}
					return;
				}
			}
		}
		
		// private methods:
		private static function checkEvents():void
		{
			if(_events==null)
				return;
			if(_event!=null||_events.length==0)
			{	/*LoggingUtils.msgTrace("event not null");*/ return; }
			var i:uint = 0;
			var ci:uint;
			var e:StoryEvent;
			var c:StoryEventCondition;
			var cType:String;
			var keepGoing:Boolean=true;
			var fail:Boolean;
			while(keepGoing)
			{
				e=StoryEvent(_events[i]);
				if(e.conditions.length==0)
				{
					_event=e;
					_events.splice(i,1);
				} else {
					fail=false;
					for(ci=0;ci<e.conditions.length;ci++)
					{
						if(!fail)
						{
							c=StoryEventCondition(e.conditions[ci]);
							cType=c.type;
							if(cType==StoryEventConditionType.FLAG)
							{
								//if(c.flagKey=="") trace("Event Manager: no flagType on flag condition");
								if(FlagManager.getHasFlag(c.flagKey))
									keepGoing=false;
								else
									fail=keepGoing=true;
							} else if(cType==StoryEventConditionType.ITEM)
							{
								if(ItemManager.hasItem(c.itemKey))
									keepGoing=false;
								else
									fail=keepGoing=true;
							} else if(cType==StoryEventConditionType.LOCATION)
							{
								if(StoryEngine.currentNode==c.locationNodeID)
									keepGoing=false;
								else
									fail=keepGoing=true;
							}
						}
					}
					if(!fail && !keepGoing)
					{
						_event=e;
						_events.splice(i,1);
					}
				}
				
				if(keepGoing)
					if(i>=_events.length-1||_event!=null)
						keepGoing=false;
					else
						i++;
			}
		}
		
		private static function getEventInstance(data:XML):StoryEvent
		{
			var conditions:Array=new Array();
			var t:String;
			var v:String;
			for each(var condition:XML in data.condition)
			{
				t=String(condition.@type);
				if(t==StoryEventConditionType.FLAG)
					v=condition.@flagKey.toString();
				if(t==StoryEventConditionType.ITEM)
					v=condition.@itemKey;
				if(t==StoryEventConditionType.LOCATION)
					v=condition.@locationNodeID;
				if(t==StoryEventConditionType.NOTE)
					v=condition.@noteKey;
				conditions.push(new StoryEventCondition(t,v));
			}
			var results:Array=new Array();
			var s:String;
			var tar:String="";
			var key:String="";
			var flag:String="";
			var tarG:String="";
			var mapL:String="";
			for each(var result:XML in data.result)
			{
				t=String(result.@type);
				s=String(result.@subtype);
				tar=String(result.@target);
				key=String(result.@key);
				flag=String(result.@givesFlag);
				tarG=String(result.@targetGroup);
				mapL=String(result.@mapLocation);
				results.push(new StoryEventResult(t,s,tar,key,flag,tarG,mapL));
			}
			var remove:Array=new Array();
			if(data.@remove.toString()!="")
			{
				remove.push( String(data.@remove) );
			}
			if(data.@key.toString()=="")
				throw new Error("Story Event must have a key assigned");
			return new StoryEvent(data.@key.toString(),conditions,results,remove);
		}
	}
}