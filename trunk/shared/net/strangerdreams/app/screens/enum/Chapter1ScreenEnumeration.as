package net.strangerdreams.app.screens.enum
{
	import net.strangerdreams.app.screens.imp.Screen01;
	import net.strangerdreams.app.screens.scene.ChapterStart;
	import net.strangerdreams.app.screens.script.en.Chapter1Screen_Script_Data;

	public class Chapter1ScreenEnumeration
	{
		//scene
		private var scene:ChapterStart;
		//script
		private var script:Chapter1Screen_Script_Data;
		//location implementation nodes
		private var screen1:Screen01;
		//sounds
		//private var policeDepartment:PoliceDepartment;
		//private var caveAmbience:CaveAmbience;
		private var ambSounds:Array = new Array( TrainChapterScreen );
	}
}