package net.strangerdreams.app.scenes.scene
{
	import net.deanverleger.data.IXMLObject;

	public class Scene1 implements IXMLObject
	{
		private var _xml:XML;

		/*

		*/
		public function Scene1()
		{
			_xml =
				<scene>
					<config>net.strangerdreams.app.scenes.config.SceneScriptLanguageConfig</config>
					<useHUD>true</useHUD>
					<scriptPackage>scenes.script</scriptPackage>
					<scriptID>Scene1</scriptID>
					<defaultNode>1</defaultNode>
					<implementationPackage>net.strangerdreams.app.scenes.imp.scene1</implementationPackage>
					<soundInstructions>
						<soundInstruction key="outside">
							<music soundObjectKey="nightTheme" volume=".8" loop="true"/>
						</soundInstruction>
						<soundInstruction key="theme">
							<music soundObjectKey="nightTheme" volume=".7" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelDoorClosed">
							<music soundObjectKey="nightTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="hotelDoorClose" volume=".9" loop="false"/>
							<ambient soundObjectKey="hotelFireplace" volume=".35" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelLobby">
							<music soundObjectKey="nightTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="hotelFireplace" volume=".35" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelHallway">
							<music soundObjectKey="nightTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="hotelFireplace" volume=".2" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelDoor">
							<music soundObjectKey="nightTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="hotelFireplace" volume=".1" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelRoomDoorClosed">
							<music soundObjectKey="nightTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="hotelRoomDoorClose" volume="1" loop="false"/>
						</soundInstruction>
					</soundInstructions>
					<soundObjects>
						<music>
							<soundObject key="nightTheme" className="NightTheme"/>
						</music>
						<ambient>
							<soundObject key="hotelDoorClose" className="HotelDoorClose"/>
							<soundObject key="hotelRoomDoorClose" className="HotelRoomDoorClose"/>
							<soundObject key="hotelRoomDoorUnlocked" className="HotelRoomDoorUnlock"/>
							<soundObject key="pickUpMap" className="PickUpMap"/>
							<soundObject key="pickUpRoomKey" className="PickUpRoomKey"/>
							<soundObject key="hotelDoorOpen" className="HotelDoorOpen"/>
							<soundObject key="hotelFireplace" className="HotelFireplace"/>
							<soundObject key="hotelRoomDoorJiggleA" className="HotelRoomDoorJiggleA"/>
							<soundObject key="hotelRoomDoorJiggleB" className="HotelRoomDoorJiggleB"/>
						</ambient>
					</soundObjects>
					<nodes>
						<node assetClass="SparkAndOatsOutside" implementationClass="SparkAndOatsOutsideImp" id="1" compassDegree="240" mapLocation="sparkAndOatsOut">
							<adjacents>
								<adjacent id="2" movementDirection="N"/>
							</adjacents>
							<states soundInstructionKey="outside">
								<state key="Default" startFrame="night">
									<object name="plaque" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsDoor" implementationClass="SparkAndOatsDoorImp" id="2" compassDegree="275" mapLocation="sparkAndOatsOut">
							<adjacents>
								<adjacent id="1" movementDirection="S"/>
								<adjacent id="3" movementDirection="N" issueEvent="true"/>
							</adjacents>
							<states soundInstructionKey="outside">
								<state key="Default" startFrame="night">
									<object name="craneNotice" type="caption" hoverType="inspect"/>
									<object name="doorHandle" type="interact" hoverType="grab"/>
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsLobby" implementationClass="SparkAndOatsLobbyImp" id="3" compassDegree="113" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="2" movementDirection="E" issueEvent="true"/>
								<adjacent id="4" movementDirection="W"/>
							</adjacents>
							<states>
								<state key="ArtIntro" priority="4" startFrame="LobbyNightArt" triggeredObjectAtStart="artIntro" soundInstructionKey="hotelDoorClosed">
									<object name="artIntro" dialogKey="artIntro" type="dialog" givesFlag="showItems" calculateAfterFinished="true" />
								</state>
								<state key="Items" priority="3" hideHUD="true" startFrame="Items" flagRequirement="showItems" soundInstructionKey="hotelLobby" comment="give flag haveKey when pick up key" />
								<state key="ArtDialogContinued" priority="2" startFrame="LobbyNightArt" flagRequirement="haveKey" triggeredObjectAtStart="anythingElse" soundInstructionKey="hotelLobby">
									<object name="anythingElse" type="dialog" dialogKey="anythingElse" hoverType="none" givesFlag="artDialogFull" calculateAfterFinished="true" soundInstructionKey="hotelLobby" />
								</state>
								<state key="DialogFinished" priority="1" flagRequirement="artDialogFull" soundInstructionKey="hotelLobby">
									<object name="donuts" type="caption" hoverType="inspect"/>
									<object name="flyer" type="caption" hoverType="inspect"/>
									<object name="registry" type="dialog" dialogKey="dontTouch" hoverType="inspect"/>
									<object name="art" type="dialog" dialogKey="haveAGood" hoverType="speak"/>
								</state>
							</states>
							<dialogs>
								<dialog key="dontTouch" scriptKey="dontTouch" character="ArtDefault" end="true"/>
								<dialog key="artIntro" scriptKey="artIntro" character="ArtDefault">
									<option order="1" shortKey="aRoomShort" longKey="aRoomLong" nextKey="yourKey" />
									<option order="2" shortKey="askAboutNameLong" longKey="askAboutNameLong" nextKey="aboutName" />
								</dialog>
								<dialog key="yourKey" scriptKey="yourKey" character="ArtDefault" end="true" />
								<dialog key="anythingElse" scriptKey="anythingElse" character="ArtDefault">
									<option order="1" shortKey="askAboutNameShort" longKey="askAboutNameLong" nextKey="aboutName" antiFlagRequirement="askedAboutName" />
									<option order="2" shortKey="noThanksShort" longKey="noThanksLong" nextKey="goodnight" />
								</dialog>
								<dialog key="aboutName" scriptKey="aboutName" givesFlag="askedAboutName" character="ArtDefault">
									<option order="1" shortKey="noThanksShort" longKey="noThanksLong" nextKey="goodnight" flagRequirement="haveKey" />
									<option order="2" shortKey="aRoomShort" longKey="aRoomLong" nextKey="yourKey" antiFlagRequirement="haveKey" />
								</dialog>
								<dialog key="goodnight" scriptKey="goodnight" character="ArtDefault" end="true"/>
								<dialog key="haveAGood" scriptKey="haveAGood" character="ArtDefault" end="true"/>
							</dialogs>
						</node>
						<node assetClass="SparkAndOatsHallway" implementationClass="SparkAndOatsHallwayImp" id="4" compassDegree="200" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="3" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="hotelHallway">
								<state key="Default" stopFrame="doorsGrouped">
									<object name="door1" type="link" hoverType="grab" linkedNode="5"/>
									<object name="doors" type="caption" hoverType="inspect" />
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsDoors" implementationClass="YourDoorImp" id="5" compassDegree="118" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="4" movementDirection="S"/>
								<adjacent id="6" issueEvent="true" movementDirection="N"/>
							</adjacents>
							<states soundInstructionKey="hotelDoor">
								<state key="Locked" stopFrame="door1" priority="2" >
									<object name="handle" type="interact" hoverType="grab" givesFlag="unlocked" flagRequirement="unlocked" acceptsItem="roomKey" itemRemoved="false" itemUsedNotificationKey="unlocked" calculateAfterFinished="true"/>
									<object name="frameCaption" type="caption" />
								</state>
								<state key="Unlocked" stopFrame="door1" priority="1" flagRequirement="unlocked" >
									<object name="handle" type="link" hoverType="grab" linkedNode="6" />
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsRoom" implementationClass="YourRoomImp" id="6" compassDegree="121" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="5" movementDirection="S" issueEvent="true"/>
							</adjacents>
							<states>
								<state key="Default" priority="2" soundInstructionKey="hotelRoomDoorClosed">
									<object name="bed" type="interact" hoverType="grab"/>
									<object name="phone" type="caption" hoverType="inspect"/>
									<object name="recorder" type="caption" hoverType="grab" givesFlag="saveDialog" calculateAfterFinished="true"/>
									<object name="painting" type="caption" hoverType="inspect"/>
								</state>
								<state key="StreamlinedSave" priority="1" flagRequirement="saveDialog" triggeredObjectAtStart="recorder" soundInstructionKey="theme">
									<object name="bed" type="interact" hoverType="grab"/>
									<object name="phone" type="caption" hoverType="inspect"/>
									<object name="recorder" type="save" hoverType="grab"/>
									<object name="painting" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
					</nodes>
					<characters>
						<character key="ArtDefault" asset="Char_ArtDefault"/>
					</characters>
					<items>
						<item key="gun" assetClass="KeyItemGun" type="key" have="true"/>
						<item key="roomKey" assetClass="ItemRoomKey" type="inventory" />
					</items>
					<notes>
						<note key="bernardLetter" assetClass="BernardLetter" implementationClass="net.strangerdreams.app.tutorial.note.BernardLetterImp" have="true"/>
					</notes>
					<goals>
						<goal key="1" group="1" comment="Get some sleep" type="map"/>
					</goals>
					<events>
						<event key="1" group="1" comment="gain first goal">
							<condition type="location" locationNodeID="1"/>
							<result type="caption" key="firstGoal"/>
							<result type="goal" subtype="add" key="1"/>
						</event>
					</events>
				</scene>;
		}

		public function get xml():XML
		{
			return _xml;
		}
	}
}