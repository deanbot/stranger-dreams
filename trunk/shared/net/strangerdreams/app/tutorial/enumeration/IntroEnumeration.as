package net.strangerdreams.app.tutorial.enumeration
{
	import net.strangerdreams.app.tutorial.imp.intro.DreamSequence01;
	import net.strangerdreams.app.tutorial.imp.intro.IntroCaveScene;
	import net.strangerdreams.app.tutorial.imp.intro.IntroLetter;
	import net.strangerdreams.app.tutorial.scene.IntroSceneData;
	import net.strangerdreams.app.tutorial.script.en.IntroScriptData;

	public class IntroEnumeration
	{
		//scene
		private var introScene:IntroSceneData;
		//script
		private var introScript:IntroScriptData;
		//location implementation nodes
		private var introLetter:IntroLetter;
		private var cinematic:DreamSequence01;
		private var introCave:IntroCaveScene;
		//sounds
		private var policeDepartment:PoliceDepartment;
		private var caveAmbience:CaveAmbience;
	}
}