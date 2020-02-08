package net.strangerdreams.app.tutorial.enumeration
{
	import net.strangerdreams.app.tutorial.imp.apartment.Bathroom;
	import net.strangerdreams.app.tutorial.imp.apartment.Ceiling;
	import net.strangerdreams.app.tutorial.imp.apartment.Closet;
	import net.strangerdreams.app.tutorial.imp.apartment.ClosetBox;
	import net.strangerdreams.app.tutorial.imp.apartment.DeskDrawer;
	import net.strangerdreams.app.tutorial.imp.apartment.DiningRoom;
	import net.strangerdreams.app.tutorial.imp.apartment.Exit;
	import net.strangerdreams.app.tutorial.imp.apartment.LivingRoom;
	import net.strangerdreams.app.tutorial.imp.apartment.OutsideWindow;
	import net.strangerdreams.app.tutorial.imp.apartment.Window;
	import net.strangerdreams.app.tutorial.note.BernardLetterImp;
	import net.strangerdreams.app.tutorial.note.MabelBrochureImp;
	import net.strangerdreams.app.tutorial.scene.BensApartmentSceneData;
	import net.strangerdreams.app.tutorial.script.en.BensApartmentScriptData;
	import net.strangerdreams.engine.item.data.Item;

	public class TutorialEnumeration
	{
		//scene
		private var bensApartmentScene:BensApartmentSceneData;
		//script
		private var bensApartmentScript:BensApartmentScriptData;
		//location implementation nodes
		private var nodes:Array = new Array( Ceiling, Bathroom, Closet, ClosetBox, DeskDrawer, DiningRoom, Exit, LivingRoom, OutsideWindow, Window);
		//sounds
		private var sounds:Array = new Array( BensApartmentTheme, AptFanLoop, AptNeonLight, AptOutsideThunderA, AptOutsideThunderB, AptSinkLoop, AptWeatherLoop, AptWindowHowl, AptWindowThunder );
		//items
		private var items:Array = new Array( KeyItemGun, ItemApartmentTicket );
		//notes
		private var notes:Array = new Array( BernardLetterImp, MabelBrochureImp );
	}
}