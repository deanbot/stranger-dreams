package net.strangerdreams.engine.events.data
{
	public class StoryEventCondition
	{
		private var _type:String;
		private var _value:*;
		public function StoryEventCondition(t:String,v:*)
		{
			if(!StoryEventConditionType.isValidType(t))
				throw new Error("Not Valid Event Condition Type: "+t);
			_type=t;
			_value=(_type==StoryEventConditionType.LOCATION)?int(v):v;
		}
		public function get type():String { return _type; }
		public function get locationNodeID():int { return (_type!=StoryEventConditionType.LOCATION)? 0 : _value as int; }
		public function get flagKey():String { return (_type==StoryEventConditionType.LOCATION)? null : _value as String; }
		public function get noteKey():String { return (_type==StoryEventConditionType.LOCATION)? null : _value as String; }
		public function get itemKey():String { return (_type==StoryEventConditionType.LOCATION)? null : _value as String; }
	}
}