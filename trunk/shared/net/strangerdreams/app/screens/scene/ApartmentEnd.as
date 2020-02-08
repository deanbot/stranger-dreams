package net.strangerdreams.app.screens.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class ApartmentEnd implements IXMLObject
	{
		private var _xml:XML;
		
		public function ApartmentEnd()
		{
			_xml = <scene>
					<useHUD>false</useHUD>
					<scriptPackage>screens.script</scriptPackage>
					<scriptID>EndTutorialScreen</scriptID>
					<defaultNode>1</defaultNode>
					<config>net.strangerdreams.app.screens.config.ScreensScriptLanguageConfig</config>
					<implementationPackage>net.strangerdreams.app.screens.imp</implementationPackage>
					<soundInstructions>
						<soundInstruction key="TrainSounds">
							<music soundObjectKey="TrainSounds" volume=".7" loop="false"/>
						</soundInstruction>
					</soundInstructions>
					<soundObjects>
						<music>
							<soundObject key="TrainSounds" className="TutorialEndSoundScape"/>
						</music>
					</soundObjects>
					<nodes>
						<node assetClass="EndTutorialScreen" implementationClass="EndTutorial" id="1" compassDegree="240">
							<states soundInstructionKey="TrainSounds">
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