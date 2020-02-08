package net.strangerdreams.engine.map
{
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;

	public class MapObjectManager
	{	
		public static const LOCATION:String = "MapObjectManager";
		public static function addMapCircleLocation( mapLocation:String ):void
		{
			var activeMapLocations:Dictionary = SEConfig.activeMapCircleLocations;
			if(activeMapLocations == null)
				activeMapLocations = new Dictionary(true);
			if(activeMapLocations[mapLocation]==null)
				activeMapLocations[mapLocation]=mapLocation;
			//LoggingUtils.msgTrace("Adding Map Circle : " + mapLocation, LOCATION);
			SESignalBroadcaster.singleNotification.dispatch( "Map Marker Added." );
			SEConfig.activeMapCircleLocations = activeMapLocations;
		}
		
		public static function removeRemoveCircleLocation( mapLocation:String ):void
		{
			var activeMapLocations:Dictionary = SEConfig.activeMapCircleLocations;
			if(activeMapLocations == null)
			{
				activeMapLocations = new Dictionary(true);
				return;
			}
			if(activeMapLocations[mapLocation]!=null)
			{
				//LoggingUtils.msgTrace("Removing Map Circle : " + mapLocation, LOCATION);
				SESignalBroadcaster.singleNotification.dispatch( "Map Marker Removed." );
				activeMapLocations[mapLocation]=null;
				delete activeMapLocations[mapLocation];
			}
			SEConfig.activeMapCircleLocations = activeMapLocations;
		}
		
		public static function clearMapCircles():void
		{
			var activeMapLocations:Dictionary = SEConfig.activeMapCircleLocations;
			if(activeMapLocations != null)
				DictionaryUtils.emptyDictionary(activeMapLocations);
			activeMapLocations = new Dictionary(true);
			SEConfig.activeMapCircleLocations = activeMapLocations;
		}
		
		public static function setMapCircleLocations( ... rest ):void
		{
			for(var i:uint = 0; i<rest.length; i++)
				addMapCircleLocation( String(rest[i]) );
		}
	}
}