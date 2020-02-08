package net.strangerdreams.engine.goal.data
{
	public class Goal implements IGoal
	{
		private var _key:String;
		private var _group:String;
		private var _type:String;
		private var _title:String;
		private var _description:String;

		public function Goal(key:String,group:String,type:String,title:String,description:String)
		{
			_key=key;
			_group=group;
			_type=type;
			_title=title;
			_description=description;
		}
		
		public function get group():String
		{
			return _group;
		}

		public function get key():String
		{
			return _key;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get title():String
		{
			return _title;
		}
	}
}