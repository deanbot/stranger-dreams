package net.strangerdreams.app.scenes.enum
{
	import net.strangerdreams.app.scenes.imp.scene4.YourRoomImp;
	import net.strangerdreams.app.scenes.scene.Scene4;
	import net.strangerdreams.app.scenes.script.en.Scene4ScriptData;

	public class Scene4Enumeration
	{
		//scene
		private var scene:Scene4;
		//script
		private var script:Scene4ScriptData;
		//nodes
		private var nodes:Array = new Array( YourRoomImp );
		//items
		private var items:Array = new Array( /*ItemRoomKey, ItemFlashlight,ItemStrangeManPhoto */ );
		//characters 
		private var chars:Array = new Array( );
		//notes
		private var notes:Array = new Array( /*BernardLetterImp, BernardCarePackageLetterImp, */ );
		//sounds
		private var amb_sounds:Array = new Array( /*HotelDoorClose, HotelDoorOpen, HotelRoomDoorClose, */ Ringing);
		private var mus_sounds:Array = new Array( /*DayTheme */);
	}
}