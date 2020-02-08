package net.strangerdreams.app.tutorial.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class IntroSceneData implements IXMLObject
	{
		private var _xml:XML;
		public function IntroSceneData()
		{
			_xml = 
			<scene>
				<useHUD>false</useHUD>
				<scriptPackage>tutorial.script</scriptPackage>
				<scriptID>Intro</scriptID>
				<defaultNode>1</defaultNode>
				<implementationPackage>net.strangerdreams.app.tutorial.imp.intro</implementationPackage>
				<soundInstructions>
					<soundInstruction key="IntroAmbience">
						<ambient soundObjectKey="LetterReadAmbience" volume=".85" loop="false"/>
					</soundInstruction>
					<soundInstruction key="CaveAmbience">
						<ambient soundObjectKey="CaveAmbience" volume=".45" loop="true"/>
					</soundInstruction>
				</soundInstructions>
				<soundObjects>
					<ambient>
						<soundObject key="LetterReadAmbience" className="PoliceDepartment"/>
						<soundObject key="CaveAmbience" className="CaveAmbience"/>
					</ambient>
				</soundObjects>
				<nodes>
					<node assetClass="IntroFrame" implementationClass="IntroLetter" id="1">
						<states soundInstructionKey="IntroAmbience" >
							<state key="Default" priority="2"/>
							<state key="Read" flagRequirement="read" priority="1"/>
						</states>
					</node>
					<node assetClass="DreamSequence1" implementationClass="DreamSequence01" id="2">
						<states soundInstructionKey="" >
							<state key="Default" hideMouse="true" soundInstructionKey=""/>
						</states>
					</node>
					<node assetClass="DreamCaveScene" implementationClass="IntroCaveScene" id="3">
						<states soundInstructionKey="CaveAmbience" >
							<state key="Default" hideMouse="true"/>
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