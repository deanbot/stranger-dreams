package net.strangerdreams.app.scenes.scene
{
	import net.deanverleger.data.IXMLObject;

	public class Scene2 implements IXMLObject
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

		public function Scene2()
		{
			_xml =
				<scene>
					<useHUD>true</useHUD>
					<scriptPackage>scenes.script</scriptPackage>
					<scriptID>Scene2</scriptID>
					<defaultNode>1</defaultNode>
					<implementationPackage>net.strangerdreams.app.scenes.imp.scene2</implementationPackage>
					<soundInstructions>
						<soundInstruction key="theme">
							<music soundObjectKey="dayTheme" volume=".7" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelDoorClosed">
							<music soundObjectKey="dayTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="hotelDoorClose" volume="1" loop="false"/>
						</soundInstruction>
						<soundInstruction key="hotelLobby">
							<music soundObjectKey="dayTheme" volume=".5" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelRoomDoorClosed">
							<music soundObjectKey="dayTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="hotelRoomDoorClose" volume="1" loop="false"/>
						</soundInstruction>
						<soundInstruction key="birds">
							<music soundObjectKey="dayTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="birds" volume=".8" loop="true"/>
						</soundInstruction>
						<soundInstruction key="birdsQuiet">
							<music soundObjectKey="dayTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="birds" volume=".4" loop="true"/>
						</soundInstruction>
						<soundInstruction key="birdsRealQuiet">
							<music soundObjectKey="dayTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="birds" volume=".2" loop="true"/>
						</soundInstruction>
						<soundInstruction key="postOffice">
							<music soundObjectKey="dayTheme" volume=".4" loop="true"/>
							<ambient soundObjectKey="postOfficeAmbient" volume=".35" loop="true"/>
						</soundInstruction>
						<soundInstruction key="postOfficeCounter">
							<music soundObjectKey="dayTheme" volume=".3" loop="true"/>
							<ambient soundObjectKey="postOfficeAmbient" volume=".35" loop="true"/>
						</soundInstruction>
						<soundInstruction key="postOfficePassOut">
							<music soundObjectKey="dayTheme" volume=".1" loop="true"/>
							<ambient soundObjectKey="postOfficePassOut" volume=".3" loop="false"/>
						</soundInstruction>
						<soundInstruction key="postOfficeDoorClosed">
							<music soundObjectKey="dayTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="postOfficeDoorClose" volume=".8" loop="false"/>
							<ambient soundObjectKey="postOfficeAmbient" volume=".35" loop="true"/>
						</soundInstruction>
					</soundInstructions>
					<soundObjects>
						<music>
							<soundObject key="dayTheme" className="DayTheme"/>
						</music>
						<ambient>
							<soundObject key="hotelDoorClose" className="HotelDoorClose"/>
							<soundObject key="hotelRoomDoorClose" className="HotelRoomDoorClose"/>
							<soundObject key="hotelDoorOpen" className="HotelDoorOpen"/>
							<soundObject key="postOfficeDoorOpen" className="PostOfficeDoorOpen"/>
							<soundObject key="postOfficeDoorClose" className="PostOfficeDoorClose"/>
							<soundObject key="birds" className="Birds"/>
							<soundObject key="postOfficeAmbient" className="PostOfficeAmbient"/>
							<soundObject key="postOfficePassOut" className="PostOfficePassOut"/>
						</ambient>
					</soundObjects>
					<nodes>
						<node assetClass="SparkAndOatsRoom" implementationClass="YourRoomImp" id="1" compassDegree="121" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="3" movementDirection="S"/>
							</adjacents>
							<states>
								<state key="Default" priority="2" triggeredObjectAtStart="frameCaption" soundInstructionKey="theme">
									<object name="frameCaption" type="caption" antiFlagRequirement="node1FrameCaption" givesFlag="node1FrameCaption"/>
									<object name="bed" type="caption" hoverType="inspect"/>
									<object name="phone" type="caption" hoverType="inspect"/>
									<object name="recorder" type="save" hoverType="grab"/>
									<object name="painting" type="caption" hoverType="inspect"/>
								</state>
								<state key="LeftRoom" priority="1" flagRequirement="node1FrameCaption" soundInstructionKey="hotelRoomDoorClosed">
									<object name="bed" type="caption" hoverType="inspect"/>
									<object name="phone" type="caption" hoverType="inspect"/>
									<object name="recorder" type="save" hoverType="grab"/>
									<object name="painting" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsDoors" implementationClass="YourDoorImp" id="2" compassDegree="118" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="3" movementDirection="S"/>
								<adjacent id="1" movementDirection="N"/>
							</adjacents>
							<states>
								<state key="Default" stopFrame="door1" priority="1" soundInstructionKey="theme">
									<object name="handle" type="link" hoverType="grab" linkedNode="1" />
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsHallway" implementationClass="SparkAndOatsHallwayImp" id="3" compassDegree="200" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="4" movementDirection="S"/>
							</adjacents>
							<states>
								<state key="Default" priority="1" startFrame="singleDoors" soundInstructionKey="theme">
									<object name="door1" type="link" hoverType="grab" linkedNode="2"/>
									<object name="door2" type="caption" hoverType="inspect" />
									<object name="door3" type="caption" hoverType="inspect" />
									<object name="door4" type="caption" hoverType="inspect" />
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsLobby" implementationClass="SparkAndOatsLobbyImp" id="4" compassDegree="113" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="6" movementDirection="E"/>
								<adjacent id="3" movementDirection="W"/>
							</adjacents>
							<states soundInstructionKey="hotelLobby">
								<state key="ArtAuto" priority="3" startFrame="LobbyDoreen" triggeredObjectAtStart="artAuto">
									<object name="artAuto" dialogKey="artAuto" type="dialog" givesFlag="artAutoDialog" calculateAfterFinished="true" />
								</state>
								<state key="DoreenFull" priority="2" startFrame="LobbyDoreen" flagRequirement="artAutoDialog">
									<object name="doreen" type="dialog" dialogKey="doreenDialogFull" hoverType="speak" givesFlag="spokeToDoreen" calculateAfterFinished="true"/>
									<object name="coffee" type="dialog" dialogKey="myCoffee" hoverType="inspect"/>
									<object name="art" type="dialog" dialogKey="artDialogShort" hoverType="speak" givesFlag="artShortA"/>
								</state>
								<state key="DoreenShort" priority="1" startFrame="LobbyDoreen" flagRequirement="spokeToDoreen">
									<object name="doreen" type="dialog" dialogKey="doreenDialogShort" hoverType="speak" givesFlag="doreenShortA"/>
									<object name="coffee" type="dialog" dialogKey="myCoffee" hoverType="inspect" />
									<object name="art" type="dialog" dialogKey="artDialogShort" hoverType="speak" givesFlag="artShortA"/>
								</state>
							</states>
							<dialogs>
								<dialog key="artAuto" scriptKey="artAuto" character="ArtDefault" end="true"/>
								<dialog key="artDialogShort" scriptKey="artDialogShort" character="ArtDefault" end="true"/>
								<dialog key="myCoffee" scriptKey="myCoffee" character="ArtDefault" end="true"/>

								<dialog key="doreenDialogFull" scriptKey="whatDoYouWant" character="DoreenDefault">
									<option order="1" shortKey="doreenResponseShort" longKey="doreenResponseLong" nextKey="notYourBusiness" />
								</dialog>
								<dialog key="notYourBusiness" scriptKey="notYourBusiness" character="DoreenDefault" end="true"/>
								<dialog key="doreenDialogShort" scriptKey="doreenDialogShort" character="DoreenDefault" end="true"/>
							</dialogs>
						</node>
						<node assetClass="SparkAndOatsDoor" implementationClass="SparkAndOatsDoorImp" id="5" compassDegree="275" mapLocation="sparkAndOatsOut">
							<adjacents>
								<adjacent id="4" movementDirection="N" issueEvent="true"/>
								<adjacent id="6" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="birdsQuiet">
								<state key="Default" startFrame="day">
									<object name="craneNotice" type="caption" hoverType="inspect"/>
									<object name="doorHandle" type="interact" hoverType="grab"/>
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsOutside" implementationClass="SparkAndOatsOutsideImp" id="6" compassDegree="240" mapLocation="sparkAndOatsOut">
							<adjacents>
								<adjacent id="5" movementDirection="N"/>
								<adjacent id="7" movementDirection="E"/>
							</adjacents>
							<states>
								<state key="Default" startFrame="day" soundInstructionKey="birds">
									<object name="plaque" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="MabelOutsidePostOffice" implementationClass="MabelOutsidePostOfficeImp" id="7" compassDegree="60" mapLocation="mabelOutside">
							<adjacents>
								<adjacent id="6" movementDirection="S"/>
								<adjacent id="8" movementDirection="E"/>
							</adjacents>
							<states>
								<state key="Default" triggeredObjectAtStart="frameCaption" soundInstructionKey="birdsQuiet">
									<object name="frameCaption" type="caption" givesFlag="MabelFrameCaption" antiFlagRequirement="MabelFrameCaption"/>
									<object name="mountains" type="caption" hoverType="inspect"/>
									<object name="stuckys" type="caption" hoverType="inspect"/>
									<object name="post" type="caption" hoverType="inspect"/>
									<object name="flowers" type="caption" hoverType="inspect"/>
									<object name="postOffice" type="link" hoverType="grab" linkedNode="8"/>
								</state>
							</states>
						</node>
						<node assetClass="PostOfficeDoor" implementationClass="PostOfficeDoorImp" id="8" compassDegree="92" mapLocation="postOfficeDoor">
							<adjacents>
								<adjacent id="7" movementDirection="S"/>
								<adjacent id="9" movementDirection="N" issueEvent="true"/>
							</adjacents>
							<states>
								<state key="Default" soundInstructionKey="birdsRealQuiet">
									<object name="handle" type="interact" hoverType="grab"/>
								</state>
							</states>
						</node>
						<node assetClass="PostOfficeLobby" implementationClass="PostOfficeLobbyImp" id="9" compassDegree="54" mapLocation="postOfficeIn">
							<adjacents>
								<adjacent id="7" movementDirection="S" issueEvent="true"/>
							</adjacents>
							<states>
								<state soundInstructionKey="postOfficeDoorClosed" key="Default" startFrame="lobbyWithValerie" triggeredObjectAtStart="janeAuto" priority="3">
									<object name="janeAuto" dialogKey="janeAuto" type="dialog" antiFlagRequirement="janeAuto" givesFlag="janeAuto" />
									<object name="jane" type="interact" givesFlag="gotPackage" hoverType="speak" />
									<object name="valerie" type="dialog" dialogKey="valerieDialog" givesFlag="valerieDialogA" hoverType="speak" />
									<object name="stuff" type="caption" hoverType="inspect" />
								</state>
								<state key="FadeToCounter" priority="2" flagRequirement="gotPackage" nextState="Counter" startFrame="fadeLobbyToCounter" stopFrame="Counter" soundInstructionKey="postOfficeCounter" hideHUD="true"/>
								<state key="Counter" startFrame="Counter" soundInstructionKey="postOfficeCounter" hideHUD="true">
									<object name="carePackage" type="interact" hoverType="inspect" givesFlag="passOut"/>
								</state>
								<state key="PassOut" startFrame="Counter" stopFrame="passOut" hideHUD="true" priority="1" flagRequirement="passOut" soundInstructionKey="postOfficePassOut"/>
							</states>
							<dialogs>
								<dialog key="janeAuto" scriptKey="janeAuto" character="JaneDefault" end="true"/>
								<dialog key="valerieDialog" scriptKey="valerieDialog" character="ValerieDefault" end="true"/>
							</dialogs>
						</node>
					</nodes>
					<characters>
						<character key="ArtDefault" asset="Char_ArtDefault"/>
						<character key="DoreenDefault" asset="Char_DoreenDefault"/>
						<character key="ValerieDefault" asset="Char_ValerieDefault"/>
						<character key="JaneDefault" asset="Char_JaneDefault"/>
					</characters>
					<items>
						<item key="gun" assetClass="KeyItemGun" type="key" have="true"/>
						<item key="roomKey" assetClass="ItemRoomKey" type="inventory" have="true"/>
						<item key="ticket" assetClass="KeyItemTicket" type="key" />
						<item key="flashlight" assetClass="ItemFlashlight" type="inventory" />
						<item key="photo" assetClass="ItemStrangeManPhoto" type="inventory" />
					</items>
					<notes>
						<note key="bernardLetter" assetClass="BernardLetter" implementationClass="net.strangerdreams.app.tutorial.note.BernardLetterImp" have="true"/>
						<note key="noteTrainTicket" assetClass="NoteTrainTicket" implementationClass="net.strangerdreams.app.scenes.note.NoteTrainTicketImp"/>
						<note key="notePhotoStrangeMan" assetClass="NotePhotoStrangeMan" implementationClass="net.strangerdreams.app.scenes.note.NotePhotoStrangeManImp"/>
						<note key="carePackageLetter" assetClass="BernardCarePackageLetter" implementationClass="net.strangerdreams.app.scenes.note.BernardCarePackageLetterImp"/>
					</notes>
					<goals>
						<goal key="1" group="1" comment="go to post office" type="map"/>
						<goal key="2" group="2" comment="pick up care package" type="interact"/>
					</goals>
					<events>
						<event key="1" group="1" comment="">
							<condition type="location" locationNodeID="4"/>
							<condition type="flag" flagKey="artAutoDialog" />
							<result type="goal" subtype="add" key="1"/>
							<result type="map" subtype="addCircle" mapLocation="postOffice"/>
						</event>
						<event key="2" group="2" comment="">
							<condition type="location" locationNodeID="9"/>
							<result type="goal" subtype="complete" target="1"/>
							<result type="map" subtype="removeCircle" mapLocation="postOffice"/>
							<result type="goal" subtype="add" key="2"/>
						</event>
						<event key="3" group="3" comment="gain first goal">
							<condition type="flag" flagKey="gotPackage" />
							<result type="goal" subtype="complete" target="2"/>
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