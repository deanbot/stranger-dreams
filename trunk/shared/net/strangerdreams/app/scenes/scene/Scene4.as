package net.strangerdreams.app.scenes.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class Scene4 implements IXMLObject
	{
		private var _xml:XML;
		
		public function Scene4()
		{
			_xml = 
				<scene>
					<useHUD>true</useHUD>
					<scriptPackage>scenes.script</scriptPackage>
					<scriptID>Scene4</scriptID>
					<defaultNode>1</defaultNode>
					<implementationPackage>net.strangerdreams.app.scenes.imp.scene4</implementationPackage>
					<soundInstructions>
						<soundInstruction key="ringing">
							<music soundObjectKey="dayTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="ringing" volume=".9" loop="true"/>
						</soundInstruction>
					</soundInstructions>
					<soundObjects>
						<music>
							<soundObject key="dayTheme" className="DayTheme"/>
						</music>
						<ambient>
							<soundObject key="ringing" className="Ringing"/>
						</ambient>
					</soundObjects>
					<nodes>
						<node assetClass="SparkAndOatsRoom" implementationClass="YourRoomImp" id="1" compassDegree="121" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="3" movementDirection="S" issueEvent="true"/>
							</adjacents>
							<states defaultState="Ringing">
								<state key="Ringing" startFrame="room" soundInstructionKey="ringing" priority="2">
									<object name="phone" type="interact" hoverType="grab" givesFlag="answerPhone" comment="later dont use a flag since it's internal"/>
									<object name="recorder" type="save" hoverType="grab"/>
								</state>
								<state key="Phone" soundInstructionKey="ringing" type="internal" priority="1" flagRequirement="answerPhone" startFrame="fadeRoomToPhone" stopFrame="phone"/>
							</states>
						</node>
					</nodes>
					<characters></characters>
					<items>
						<item key="gun" assetClass="KeyItemGun" type="key" have="true"/>
						<item key="roomKey" assetClass="ItemRoomKey" type="inventory" have="true"/>
						<item key="ticket" assetClass="ItemNewhavenTicket" type="key" have="true"/>
						<item key="flashlight" assetClass="ItemFlashlight" type="inventory" have="true"/>
						<item key="photo" assetClass="ItemStrangeManPhoto" type="inventory" have="true"/>
					</items>
					<notes>
						<note key="bernardLetter" assetClass="BernardLetter" implementationClass="net.strangerdreams.app.tutorial.note.BernardLetterImp" have="true"/>
						<note key="carePackageLetter" assetClass="BernardCarePackageLetter" implementationClass="net.strangerdreams.app.scenes.note.BernardCarePackageLetterImp" have="true"/>					
					</notes>
					<goals>
					</goals>
					<events>
					</events>
				</scene>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}