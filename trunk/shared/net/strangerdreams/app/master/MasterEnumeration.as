package net.strangerdreams.app.master
{
	import net.strangerdreams.app.gui.UI;
	import net.strangerdreams.app.gui.UIEnumeration;
	import net.strangerdreams.app.scenes.enum.Scene1Enumeration;
	import net.strangerdreams.app.scenes.enum.Scene2Enumeration;
	import net.strangerdreams.app.scenes.enum.Scene3Enumeration;
	import net.strangerdreams.app.scenes.enum.Scene4Enumeration;
	import net.strangerdreams.app.screens.config.ScreensScriptLanguageConfig;
	import net.strangerdreams.app.screens.enum.Chapter1ScreenEnumeration;
	import net.strangerdreams.app.screens.enum.EndTutorialScreenEnumeration;
	import net.strangerdreams.app.screens.enum.SlowDownEnum;
	import net.strangerdreams.app.tutorial.enumeration.IntroEnumeration;
	import net.strangerdreams.app.tutorial.enumeration.TutorialEnumeration;

	public class MasterEnumeration
	{
		//ui enumeration
		private var uiEnumeration:UIEnumeration;
		//prologue scene enumeration
		private var introEnumeration:IntroEnumeration;
		private var tutorialEnumeration:TutorialEnumeration;
		//screen scene enumeration
		private var screenConfig:ScreensScriptLanguageConfig;
		private var slowDownSceneEnum:SlowDownEnum;
		private var endTutorialScreenEnumeration:EndTutorialScreenEnumeration;
		private var chapter1ScreenEnumeration:Chapter1ScreenEnumeration;
		//scene enumeration
		private var scene1Enumeration:Scene1Enumeration;
		private var scene2Enumeration:Scene2Enumeration;
		private var scene3Enumeration:Scene3Enumeration;
		private var scene4Enumeration:Scene4Enumeration;
	}
}