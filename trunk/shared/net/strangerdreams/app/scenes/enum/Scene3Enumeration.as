package net.strangerdreams.app.scenes.enum
{
	import net.strangerdreams.app.scenes.imp.scene3.LovesCounterImp;
	import net.strangerdreams.app.scenes.imp.scene3.LovesDoorImp;
	import net.strangerdreams.app.scenes.imp.scene3.LovesLobbyImp;
	import net.strangerdreams.app.scenes.imp.scene3.MabelOutsideLovesSpecialSceneImp;
	import net.strangerdreams.app.scenes.imp.scene3.MabelOutsideSpecialSceneImp;
	import net.strangerdreams.app.scenes.imp.scene3.SparkAndOatsDoorImp;
	import net.strangerdreams.app.scenes.imp.scene3.SparkAndOatsHallwayImp;
	import net.strangerdreams.app.scenes.imp.scene3.SparkAndOatsLobbyImp;
	import net.strangerdreams.app.scenes.imp.scene3.SparkAndOatsOutsideImp;
	import net.strangerdreams.app.scenes.imp.scene3.YourDoorImp;
	import net.strangerdreams.app.scenes.imp.scene3.YourRoomImp;
	import net.strangerdreams.app.scenes.scene.Scene3;
	import net.strangerdreams.app.scenes.script.en.Scene3ScriptData;

	public class Scene3Enumeration
	{
		//scene
		private var scene3Scene:Scene3;
		//script
		private var scene3Script:Scene3ScriptData;
		//nodes
		private var nodes:Array = new Array( YourRoomImp, YourDoorImp, SparkAndOatsHallwayImp, SparkAndOatsLobbyImp, SparkAndOatsDoorImp, SparkAndOatsOutsideImp, MabelOutsideSpecialSceneImp, MabelOutsideLovesSpecialSceneImp, LovesDoorImp, LovesLobbyImp, LovesCounterImp);
		//items
		private var items:Array = new Array( /*ItemRoomKey, ItemFlashlight,KeyItemTicket,*/ ItemStrangeManPhoto );
		//characters 
		private var chars:Array = new Array( Char_JeannieDefault, Char_StrangeManDefault );
		//notes
		private var notes:Array = new Array( /*BernardLetterImp, BernardCarePackageLetterImp, */ );
		//sounds
		private var amb_sounds:Array = new Array( /*HotelDoorClose, HotelDoorOpen, HotelRoomDoorClose, */ NightSound, BuzzSound, Owls, LovesOpen, LovesClose);
		private var mus_sounds:Array = new Array( /*DayTheme */ StrangeNightTheme, Solace, MustHaveBeenDreaming );
	}
}