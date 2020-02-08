package net.strangerdreams.app.scenes.enum
{
	import net.strangerdreams.app.scenes.imp.scene2.MabelOutsidePostOfficeImp;
	import net.strangerdreams.app.scenes.imp.scene2.PostOfficeDoorImp;
	import net.strangerdreams.app.scenes.imp.scene2.PostOfficeLobbyImp;
	import net.strangerdreams.app.scenes.imp.scene2.SparkAndOatsDoorImp;
	import net.strangerdreams.app.scenes.imp.scene2.SparkAndOatsHallwayImp;
	import net.strangerdreams.app.scenes.imp.scene2.SparkAndOatsLobbyImp;
	import net.strangerdreams.app.scenes.imp.scene2.SparkAndOatsOutsideImp;
	import net.strangerdreams.app.scenes.imp.scene2.YourDoorImp;
	import net.strangerdreams.app.scenes.imp.scene2.YourRoomImp;
	import net.strangerdreams.app.scenes.note.BernardCarePackageLetterImp;
	import net.strangerdreams.app.scenes.note.NotePhotoStrangeManImp;
	import net.strangerdreams.app.scenes.note.NoteTrainTicketImp;
	import net.strangerdreams.app.scenes.scene.Scene2;
	import net.strangerdreams.app.scenes.script.en.Scene2ScriptData;

	public class Scene2Enumeration
	{
		//scene
		private var scene2Scene:Scene2;
		//script
		private var scene2Script:Scene2ScriptData;
		//nodes
		private var nodes:Array = new Array( YourRoomImp, YourDoorImp, SparkAndOatsHallwayImp, SparkAndOatsLobbyImp, SparkAndOatsDoorImp, SparkAndOatsOutsideImp, MabelOutsidePostOfficeImp, PostOfficeDoorImp, PostOfficeLobbyImp );
		//items
		private var items:Array = new Array( /*ItemRoomKey, */ItemFlashlight, KeyItemTicket );
		//characters 
		private var chars:Array = new Array( /*Char_ArtDefault, */Char_DoreenDefault, Char_JaneDefault, Char_ValerieDefault );
		//notes
		private var notes:Array = new Array( /*BernardLetterImp, */BernardCarePackageLetterImp, NotePhotoStrangeManImp, NoteTrainTicketImp );
		//sounds
		private var amb_sounds:Array = new Array( /*HotelDoorClose, HotelDoorOpen, HotelRoomDoorClose, */PostOfficeDoorOpen, PostOfficeDoorClose, Birds, PostOfficeAmbient, PostOfficePassOut);
		private var mus_sounds:Array = new Array( DayTheme );
	}
}