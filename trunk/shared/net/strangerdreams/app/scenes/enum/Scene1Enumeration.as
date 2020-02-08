package net.strangerdreams.app.scenes.enum
{
	import net.strangerdreams.app.scenes.config.SceneScriptLanguageConfig;
	import net.strangerdreams.app.scenes.imp.scene1.SparkAndOatsDoorImp;
	import net.strangerdreams.app.scenes.imp.scene1.SparkAndOatsHallwayImp;
	import net.strangerdreams.app.scenes.imp.scene1.SparkAndOatsLobbyImp;
	import net.strangerdreams.app.scenes.imp.scene1.SparkAndOatsOutsideImp;
	import net.strangerdreams.app.scenes.imp.scene1.YourDoorImp;
	import net.strangerdreams.app.scenes.imp.scene1.YourRoomImp;
	import net.strangerdreams.app.scenes.scene.Scene1;
	import net.strangerdreams.app.scenes.script.en.Scene1ScriptData;

	public class Scene1Enumeration
	{
		//config
		private var config:SceneScriptLanguageConfig;
		//scene
		private var scene:Scene1;
		//script
		private var script:Scene1ScriptData;
		//imp nodes
		private var nodes:Array = new Array( SparkAndOatsOutsideImp, SparkAndOatsDoorImp, SparkAndOatsLobbyImp, SparkAndOatsHallwayImp, YourDoorImp, YourRoomImp );
		//items
		private var items:Array = new Array( ItemRoomKey );
		//characters 
		private var chars:Array = new Array( Char_ArtDefault );
		//sounds
		private var amb_sounds:Array = new Array( HotelDoorClose, HotelDoorOpen, HotelRoomDoorClose, HotelRoomDoorJiggleA, HotelRoomDoorJiggleB, HotelRoomDoorUnlock, PickUpMap, PickUpRoomKey, HotelFireplace );
		private var mus_sounds:Array = new Array( NightTheme );
	}
}