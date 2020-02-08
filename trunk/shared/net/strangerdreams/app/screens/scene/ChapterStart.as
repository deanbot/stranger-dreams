package net.strangerdreams.app.screens.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class ChapterStart implements IXMLObject
	{
		private var _xml:XML;
		
		/*
		<soundInstruction key="IntroAmbience">
		<ambient soundObjectKey="LetterReadAmbience" volume=".85" loop="false"/>
		</soundInstruction>
		<ambient>
		<soundObject key="LetterReadAmbience" className="PoliceDepartment"/>
		<soundObject key="CaveAmbience" className="CaveAmbience"/>
		</ambient>
		*/
		
		public function ChapterStart()
		{
			_xml = 
				<scene>
					<useHUD>false</useHUD>
					<scriptPackage>screens.script</scriptPackage>
					<scriptID>Chapter1Screen</scriptID>
					<defaultNode>1</defaultNode>
					<config>net.strangerdreams.app.screens.config.ScreensScriptLanguageConfig</config>
					<implementationPackage>net.strangerdreams.app.screens.imp</implementationPackage>
					<soundInstructions><soundInstruction key="train"><ambient soundObjectKey="trainSounds" volume="1" loop="false"/></soundInstruction></soundInstructions>
					<soundObjects><ambient><soundObject key="trainSounds" className="TrainChapterScreen"/></ambient></soundObjects>
					<nodes>
						<node assetClass="Chapter1Screen" implementationClass="Screen01" id="1" compassDegree="240">
							<states soundInstructionKey="train">
								<state key="Default" priority="1"/>
							</states>
						</node>
					</nodes>
				</scene>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}