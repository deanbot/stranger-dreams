package net.strangerdreams.engine.events.data
{
	public class StoryEventResult
	{
		private var _type:String;
		private var _subtype:String;
		private var _target:String;
		private var _targetGroup:String;
		private var _key:String;
		private var _givesFlag:String;
		private var _mapLocation:String;
		public function StoryEventResult(t:String,s:String="",tar:String="",key:String="",flag:String="",targetGroup:String="",mapLocation:String="")
		{
			if(t==null||t=="")
				throw new Error("Event Result type must be set");
			if(!StoryEventResultType.isValidType(t))
				throw new Error("Event Result Type not valid: "+t);
			
			if(s!="")
				if(!StoryEventResultType.isValidSubtype(s))
					throw new Error("Event Result Subtype not valid: "+s);
			_type=t;
			_subtype=s;
			_target=tar;
			_targetGroup=targetGroup;
			_key=key;
			_givesFlag=flag;
			_mapLocation=mapLocation;
		}

		public function get mapLocation():String
		{
			return _mapLocation;
		}

		public function get targetGroup():String
		{
			return _targetGroup;
		}

		public function get givesFlag():String
		{
			return _givesFlag;
		}

		public function get key():String
		{
			return _key;
		}

		public function get target():String
		{
			return _target;
		}

		public function get subtype():String
		{
			return _subtype;
		}

		public function get type():String
		{
			return _type;
		}

	}
}