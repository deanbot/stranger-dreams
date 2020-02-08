package net.strangerdreams.engine.goal
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.DictionaryUtils;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.goal.data.Goal;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.ScriptItem;
	
	import org.osflash.signals.Signal;

	public class GoalManager
	{
		// constants:
		public static const LOCATION:String = "Goal Manager";
		
		// private properties:
		private static var _goals:Dictionary = new Dictionary(true);
		private static var _activeGoals:Dictionary = new Dictionary(true);
		private static var _orderedGoals:Array = new Array();
		private static var _destroyed:Boolean;
		
		// public properties:
		// constructor:
		// public getter/setters:

		public static function get destroyed():Boolean
		{
			return _destroyed;
		}

		public static function get orderderedGoals():Array
		{
			var goals:Array = new Array();
			for (var i:uint=0; i<_orderedGoals.length; i++)
			{
				goals.push( Goal( _goals[String(_orderedGoals[i])] ) );
			}
			return goals;
		}
		
		// public methods:
		public static function generate(sceneData:XML):void
		{
			if(sceneData==null)
				return;
			_destroyed = false;
			_goals = new Dictionary(true);
			_activeGoals = new Dictionary(true);
			_orderedGoals = new Array();
			for each(var goalData:XML in sceneData.goal)
			{
				var k:String = String(goalData.@key);
				if(k==null)
					throw new Error("Goal Manager: Goal has no key.");
				_goals[k] = getGoalInstance(goalData, StoryScriptManager.getGoalInstance(k));
				if(String(goalData.@have)=="true")
				{
					addActiveGoal(goalData.@key, false);
				}
			} 
		}
		
		public static function getGoal(key:String):Goal
		{
			return (_goals[key]!=null)?Goal(_goals[key]):null;
		}
		
		public static function getActiveGoals():Dictionary
		{
			return _activeGoals;
		}
		
		public static function getHasGoal(key:String):Boolean
		{
			var val:Boolean = false;
			if(getGoal(key)!=null)
				if(_activeGoals[key]!=null)
					val = true;
			return val;
		}
		
		public static function addActiveGoal(key:String, notify:Boolean=false):void
		{
			if(_goals[key]!=null)
			{
				if(_activeGoals[key]==null)
				{
					_activeGoals[key]=_goals[key];
					_orderedGoals.push(key);
					SESignalBroadcaster.goalAdded.dispatch( Goal(_goals[key]).title, Goal(_goals[key]).type, notify );	
				} //else trace("goal ["+key+"] already an active goal");
			}
		}
		
		public static function updateActiveGoal(targetKey:String, newKey:String, notify:Boolean=false):void
		{
			if(_activeGoals[targetKey]==null)
				return;
			if(_goals[newKey]!=null)
			{
				_activeGoals[newKey]=Goal(_goals[newKey]);
				delete _activeGoals[targetKey];
				_orderedGoals[_orderedGoals.indexOf(targetKey)] = newKey;
				SESignalBroadcaster.goalUpdated.dispatch(Goal(_goals[targetKey]).title,Goal(_goals[newKey]).title,Goal(_activeGoals[newKey]).type,notify);
			}
		}
		
		public static function removeActiveGoal(targetKey:String,notify:Boolean=false):void
		{
			if(_activeGoals[targetKey]!=null&&_goals[targetKey]!=null)
			{
				_activeGoals[targetKey]=null;
				delete _activeGoals[targetKey];
				_orderedGoals.splice(_orderedGoals.indexOf(targetKey),1);
				SESignalBroadcaster.goalComplete.dispatch(Goal(_goals[targetKey]).title,notify);
			} else {
				//trace("goal ["+targetKey+"] not active, failing silently");
			}
		}
		
		public static function removeActiveGoalGroup(targetGroupKey:String,notify:Boolean=false):void
		{
			var goal:Goal;
			for(var i:String in _activeGoals)
			{
				goal=Goal(_activeGoals[i]);
				if(	goal.group == targetGroupKey)
					removeActiveGoal(goal.key,notify)
			}
		}
		
		public static function clear():void
		{
			if(!_destroyed)
			{
				DictionaryUtils.emptyDictionary(_goals);
				DictionaryUtils.emptyDictionary(_activeGoals);
				_goals = _activeGoals = null;
				_destroyed = true;
			}
		}
		
		public static function get numActiveGoals():uint
		{
			return _orderedGoals.length;
		}
		
		// private methods:
		private static function getGoalInstance(data:XML, scriptItem:ScriptItem):Goal
		{
			if(data.@key=='')
				throw new Error("Goal Manager (generateItemInstance): no key");
			if(data.@type=='')
				throw new Error("Goal Manager (generateItemInstance): no type");
			if(!GoalType.isValidType(data.@type))
				throw new Error("Goal Manager (generateItemInstance): goal not valid type");
			return new Goal(data.@key, data.@group, data.@type, scriptItem.title, scriptItem.description);
		}
	}
}