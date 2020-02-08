package net.strangerdreams.engine
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.LoggingUtils;

	public class SEConfig
	{
		public static const LOCATION:String = "SEConfig";
		// private constants:
		private static var GLOBAL_VOLUME:String = "globalVolume";
		private static var UI_VOLUME_OFFSET:String = "uiVolumeOffset";
		private static var MUSIC_VOLUME_OFFSET:String = "musicVolumeOffset";
		private static var AMBIENT_VOLUME_OFFSET:String = "ambientVolumeOffset";
		private static var MUTED:String = "muted";
		private static var FULLSCREEN:String = "fullscreen";
		private static var SCENE_ORDER:String = "sceneOrder";
		private static var TRANSITION_TIME:String = "frameInOrOutTransitionTime";
		private static var TUTORIAL:String = "isTutorial";
		private static var HAS_MAP:String = "hasMap";
		private static var DOOR_RESET:String = "doorReset";
		private static var ACTIVE_MAP_CIRCLE_LOCATIONS:String = "activeMapCircleLocations";
		private static var CURRENT_MAP_ARROW_LOCATION:String = "currentMapArrowLocation";
		private static var CURRENT_ARROW_DEGREES:String = "currentArrowDegrees";
		
		// private properties:
		private static var CONFIG:Dictionary = new Dictionary(true);

		// public getter/setters:
		public static function set transitionTime(time:Number):void
		{
			CONFIG[TRANSITION_TIME] = time;
		}
		
		public static function get transitionTime():Number
		{
			return CONFIG[TRANSITION_TIME];
		}

		/**
		 * Set the global volume level used for sounds
		 * 
		 * @param vol the volume level of the global volume. Must be between 0 and 1.
		 * 
		 */
		public static function set globalVolume( vol:Number ):void
		{
			if ( vol > 1 || vol < 0 )
				throw Error("Volume must be between 0 and 1");
			CONFIG[GLOBAL_VOLUME] =  vol;
		}
		
		/**
		 * @return the global volume level for sounds
		 */
		public static function get globalVolume():Number
		{
			return CONFIG[GLOBAL_VOLUME];
		}
		
		/**
		 * Set the UI Volume offset that is used to get the uiVolume as a product of uiVolumeOffset and globalVolume
		 * @param volOffset the number to multiply the global volume by return the uiVolume. Must be between 0 and 1.
		 * 
		 */
		public static function set uiVolumeOffset( volOffset:Number ):void
		{
			if ( volOffset > 1 || volOffset < 0 )
				throw Error("Volume Offset must be between 0 and 1");
			CONFIG[UI_VOLUME_OFFSET] = volOffset;
		}
		
		/**
		 * @return the volume offset coefficent, used to calculate the uiVolume
		 * 
		 */
		public static function get uiVolumeOffset():Number
		{
			return CONFIG[UI_VOLUME_OFFSET] as Number;
		}
		
		public static function set musicVolumeOffset( vol:Number ):void
		{
			CONFIG[MUSIC_VOLUME_OFFSET] = vol;	
		}
		
		public static function get musicVolumeOffset():Number
		{
			return CONFIG[MUSIC_VOLUME_OFFSET] as Number;
		}
		
		public static function set ambientVolumeOffset( vol:Number ):void
		{
			CONFIG[AMBIENT_VOLUME_OFFSET] = vol;
		}
		
		public static function get ambientVolumeOffset():Number
		{
			return CONFIG[AMBIENT_VOLUME_OFFSET] as Number;
		}
		
		public static function set muted( mute:Boolean ):void
		{
			CONFIG[MUTED] = mute;
		}
		
		public static function get muted():Boolean
		{
			return CONFIG[MUTED];
		}
		
		public static function set fullScreen( fullScreen:Boolean ):void
		{
			CONFIG[FULLSCREEN] = fullScreen;
		}
		
		public static function get fullScreen():Boolean
		{
			return CONFIG[FULLSCREEN];
		}
		
		public static function set sceneOrder( so:Array ):void
		{
			CONFIG[SCENE_ORDER] = so;
		}
		
		public static function get sceneOrder():Array
		{
			return CONFIG[SCENE_ORDER] as Array;
		}
		
		public static function get isTutorial():Boolean
		{
			return CONFIG[TUTORIAL];
		}
		
		public static function set isTutorial(value:Boolean):void
		{
			CONFIG[TUTORIAL] = value;
		}
		
		public static function get hasMap():Boolean
		{
			return CONFIG[HAS_MAP];
		}
		
		public static function set hasMap( value:Boolean ):void
		{
			CONFIG[HAS_MAP] = value;
		}
		
		public static function get doorReset():Boolean
		{
			return CONFIG[DOOR_RESET];
		}
		
		public static function set doorReset( value:Boolean ):void
		{
			CONFIG[DOOR_RESET] = value;
		}
		
		public static function get activeMapCircleLocations():Dictionary
		{
			return CONFIG[ACTIVE_MAP_CIRCLE_LOCATIONS] as Dictionary;
		}
		
		public static function set activeMapCircleLocations( value:Dictionary ):void
		{
			CONFIG[ACTIVE_MAP_CIRCLE_LOCATIONS] = value;
		}
		
		public static function get currentMapArrowLocation():String
		{
			return CONFIG[CURRENT_MAP_ARROW_LOCATION] as String;
		}
		
		public static function set currentMapArrowLocation( value:String ):void
		{
			CONFIG[CURRENT_MAP_ARROW_LOCATION] = value;
		}
		
		public static function get currentArrowDegrees():Number
		{
			return CONFIG[CURRENT_ARROW_DEGREES] as Number;
		}
		
		public static function set currentArrowDegrees( value:Number ):void
		{
			CONFIG[CURRENT_ARROW_DEGREES] = value;
		}
		
		// public methods:
	}
}