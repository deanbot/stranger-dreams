package net.strangerdreams.app.tutorial.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class BensApartmentSceneData implements IXMLObject
	{
		private var _xml:XML;
		public function BensApartmentSceneData()
		{
			/*<object name="radio" type="caption" hoverType="inspect"/>*/
			_xml = 
				<scene>
					<useHUD>true</useHUD>
					<scriptPackage>tutorial.script</scriptPackage>
					<scriptID>BensApartment</scriptID>
					<defaultNode>1</defaultNode>
					<implementationPackage>net.strangerdreams.app.tutorial.imp.apartment</implementationPackage>
					<soundInstructions>
						<soundInstruction key="CeilingFan">
							<music soundObjectKey="aptTheme" volume=".45" loop="true"/>
							<ambient soundObjectKey="AptFanLoop" volume=".65" loop="true"/>
							<ambient soundObjectKey="AptWeatherLoop" volume=".3" loop="true"/>
						</soundInstruction>
						<soundInstruction key="Livingroom">
							<music soundObjectKey="aptTheme" volume=".6" loop="true"/>
							<ambient soundObjectKey="AptWeatherLoop" volume="1" loop="true"/>
						</soundInstruction>
						<soundInstruction key="Window">
							<music soundObjectKey="aptTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="AptWeatherLoop" volume="1" loop="true"/>
							<ambient soundObjectKey="AptWindowThunder" volume="1" loop="false"/>
							<ambient soundObjectKey="AptNeonBuzz" volume=".9" loop="true"/>
						</soundInstruction>
						<soundInstruction key="Outside">
							<music soundObjectKey="aptTheme" volume=".45" loop="true"/>
							<ambient soundObjectKey="AptWeatherLoop" volume="1" loop="true"/>
							<ambient soundObjectKey="AptThunderA" volume="1" loop="false" nextSoundObjectKey="AptThunderB"/>
							<ambient soundObjectKey="AptThunderB" volume="1" loop="false" play="false" nextSoundObjectKey="AptThunderA"/>
						</soundInstruction>
						<soundInstruction key="Bathroom">
							<music soundObjectKey="aptTheme" volume=".6" loop="true"/>
							<ambient soundObjectKey="AptSinkLoop" volume="1" loop="true"/>
						</soundInstruction>
						<soundInstruction key="Exit">
							<music soundObjectKey="aptTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="AptWeatherLoop" volume=".5" loop="true"/>
						</soundInstruction>
						<soundInstruction key="JustTheme">
							<music soundObjectKey="aptTheme" volume=".7" loop="true"/>
						</soundInstruction>
					</soundInstructions>
					<soundObjects>
						<music>
							<soundObject key="aptTheme" className="BensApartmentTheme"/>
						</music>
						<ambient>
							<soundObject key="AptWindowThunder" className="AptWindowThunder"/>
							<soundObject key="AptHowl" className="AptWindowHowl"/>
							<soundObject key="AptThunderA" className="AptOutsideThunderA"/>
							<soundObject key="AptThunderB" className="AptOutsideThunderB"/>
							<soundObject key="AptNeonBuzz" className="AptNeonLight"/>
							<soundObject key="AptWeatherLoop" className="AptWeatherLoop"/>
							<soundObject key="AptSinkLoop" className="AptSinkLoop"/>
							<soundObject key="AptFanLoop" className="AptFanLoop"/>
						</ambient>
					</soundObjects>
					<nodes>
						<node assetClass="ApartmentCeilingFrame" implementationClass="Ceiling" id="1" compassDegree="235">
							<states soundInstructionKey="CeilingFan" >
								<state key="Default" hideHUD="true" hideMouse="true" priority="2" />
								<state key="CaptionClick" hideHUD="true" triggeredObjectAtStart="frameCaption" priority="1" flagRequirement="doCaption">
									<object name="frameCaption" type="caption" hoverType="none"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentLivingRoomFrame" implementationClass="LivingRoom" id="2" compassDegree="235">
							<adjacents>
								<adjacent id="4" movementDirection="E"/>
								<adjacent id="6" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="Livingroom">
								<state key="Default" priority="2" startFrame="default">
									<object name="books" type="caption" hoverType="inspect"/>
									<object name="books2" type="caption" hoverType="inspect"/>
									<object name="briefcase" type="pickUp" hoverType="grab" givesFlag="briefcaseTaken" calculateAfterFinished="true"/>
									<object name="hypnosPoem" type="interact" hoverType="inspect"/>
									<object name="hypnosStatue" type="caption" hoverType="inspect"/>
									<object name="tv" type="caption" hoverType="inspect"/>
									<object name="clippingsHit" type="interact" hoverType="inspect"/>
									<object name="deskDrawerHit" type="link" hoverType="inspect" linkedNode="3"/>
								</state>
								<state key="ReadClippings" triggeredObjectAtStart="clippingsCaption" type="internal">
									<object name="clippingsCaption" type="caption" givesFlag="sawClippings" antiFlagRequirement="sawClippings"/>
								</state>
								<state key="ReadHypnosPoem" type="internal"/>
								<state key="BriefcaseTaken" priority="1" startFrame="briefcaseTaken" flagRequirement="briefcaseTaken">
									<object name="books" type="caption" hoverType="inspect"/>
									<object name="books2" type="caption" hoverType="inspect"/>
									<object name="hypnosPoem" type="interact" hoverType="inspect"/>
									<object name="hypnosStatue" type="caption" hoverType="inspect"/>
									<object name="tv" type="caption" hoverType="inspect"/>
									<object name="clippingsHit" type="interact" hoverType="inspect"/>
									<object name="deskDrawerHit" type="link" hoverType="inspect" linkedNode="3"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentDeskDrawerFrame" implementationClass="DeskDrawer" id="3" compassDegree="235">
							<adjacents>
								<adjacent id="2" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="Livingroom">
								<state key="Default" priority="2" startFrame="default">
									<object name="journal" type="pickUp" hoverType="grab" givesFlag="journalTaken" calculateAfterFinished="true"/>
									<object name="matches" type="caption" hoverType="inspect"/>
								</state>
								<state key="JournalTaken" priority="1" flagRequirement="journalTaken" startFrame="journalTaken">
									<object name="matches" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentWindowFrame" implementationClass="Window" id="4" compassDegree="350">
							<adjacents>		
								<adjacent id="6" movementDirection="E"/>
								<adjacent id="2" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="Window">
								<state key="Default">
									<object name="window" type="link" hoverType="inspect" linkedNode="5"/>
									<object name="plant" type="caption" hoverType="inspect" />
								</state>
							</states>
						</node>
						<node assetClass="ApartmentOutsideWindowFrame" implementationClass="OutsideWindow" id="5" compassDegree="350">
							<adjacents></adjacents>
							<states soundInstructionKey="Outside">
								<state key="Default" hideHUD="true" triggeredObjectAtStart="frameCaption">
									<object name="frameCaption" type="caption" />
								</state>
							</states>
						</node>
						<node assetClass="ApartmentExitFrame" implementationClass="Exit" id="6" compassDegree="45">
							<adjacents>
								<adjacent id="4" movementDirection="W"/>
								<adjacent id="7" movementDirection="E"/>
								<adjacent id="2" movementDirection="S"/>
								<adjacent issueEvent="true" movementDirection="N" flagRequirement="exitNow"/>
							</adjacents>
							<states soundInstructionKey="Exit">
								<state key="Default">
									<object name="chair" type="caption" hoverType="inspect"/>
									<object name="pipesCloset" type="caption" hoverType="inspect"/>
									<object name="bathroom" type="link" hoverType="grab" linkedNode="10"/>
									<object name="coat" type="caption" hoverType="inspect"/>
									<object name="closet" type="link" hoverType="grab" linkedNode="8"/>
									<object name="door" type="interact" hoverType="inspect" flagRequirement="exitNow"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentDiningRoomFrame" implementationClass="DiningRoom" id="7" compassDegree="10">
							<adjacents>
								<adjacent id="6" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="JustTheme">
								<state key="Default" priority="2">
									<object name="clock" type="caption" hoverType="inspect"/>
									<object name="compass" type="caption" hoverType="inspect"/>
									<object name="picture" type="caption" hoverType="inspect"/>
									<object name="obituaryHit" type="interact" hoverType="inspect"/>
									<object name="brochureLetterHit" type="interact" hoverType="inspect" givesFlag="brochureLetterTaken">
										<flagRequirement key="briefcaseTaken"/>
										<flagRequirement key="journalTaken"/>
									</object>
									<object name="tool" type="caption" hoverType="inspect"/>
								</state>
								<state key="LetterBrochure" />
								<state key="ReadObiturary" type="internal" />
								<state key="BrochureLetterTaken" priority="1" flagRequirement="brochureLetterTaken">
									<object name="clock" type="caption" hoverType="inspect"/>
									<object name="compass" type="caption" hoverType="inspect"/>
									<object name="picture" type="caption" hoverType="inspect"/>
									<object name="obituaryHit" type="interact" hoverType="inspect"/>
									<object name="tool" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentClosetFrame" implementationClass="Closet" id="8" compassDegree="290">
							<adjacents>
								<adjacent id="6" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="JustTheme">
								<state key="Default">
									<object name="box" type="link" hoverType="grab" linkedNode="9"/>
									<object name="coat" type="caption" hoverType="inspect"/>
									<object name="files" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentClosetBoxFrame" implementationClass="ClosetBox" id="9" compassDegree="290">
							<adjacents>
								<adjacent id="8" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="JustTheme">
								<state key="Default" startFrame="default" priority="3">
									<object name="gun" type="pickUp" hoverType="inspect" itemKey="gun" givesFlag="gunTaken" flagRequirement="canPickupGun" calculateAfterFinished="true"/>
									<object name="bullets" type="caption" hoverType="inspect"/>
								</state>
								<state key="FadeGun" flagRequirement="gunTaken" priority="2" startFrame="FadeGun" stopFrame="gunTaken" nextState="ClosetBoxGunRemoved"/>
								<state key="ClosetBoxGunRemoved" startFrame="gunTaken" priority="1" flagRequirement="gunFaded" >
									<object name="bullets" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="ApartmentBathroomFrame" implementationClass="Bathroom" id="10" compassDegree="80">
							<adjacents>
								<adjacent id="6" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="Bathroom">
								<state key="Default" triggeredObjectAtStart="frameCaption">
									<object name="frameCaption" type="caption" givesFlag="lookedInBathroom" antiFlagRequirement="lookedInBathroom"/>
								</state>
							</states>
						</node>

					</nodes>
					<items>
						<item key="gun" assetClass="KeyItemGun" type="key" />
						<item key="ticket" assetClass="ItemApartmentTicket" type="inventory" />
					</items>
					<notes>
						<note key="bernardLetter" assetClass="BernardLetter" implementationClass="net.strangerdreams.app.tutorial.note.BernardLetterImp"/>
						<note key="mabelBrochure" assetClass="MabelBrochure" implementationClass="net.strangerdreams.app.tutorial.note.MabelBrochureImp"/>
					</notes>
					<goals>
						<goal key="1" group="1" comment="get journal and briefcase" type="interact"/>
						<goal key="1A" group="1" comment="get journal" type="interact"/>
						<goal key="1B" group="1" comment="get briefcase" type="interact"/>
						<goal key="2" group="2" comment="get train ticket" type="inspect"/>
						<goal key="3" group="3" comment="get gun" type="interact"/>
						<goal key="4" group="4" comment="leave" type="map"/>
					</goals>
					<events>
						<event key="1" group="1" comment="gain first goal">
							<condition type="location" locationNodeID="2"/>
							<result type="caption" key="tutorial02"/>
							<result type="goal" subtype="add" key="1"/>
						</event>
						<event key="1A" group="1" comment="after briefcase comes journal" remove="1B">
							<condition type="flag" flagKey="briefcaseTaken"/>
							<result type="goal" subtype="update" target="1" key="1A"/>
						</event>
						<event key="1A1" group="1" comment="do a complete here if journal was last">
							<condition type="flag" flagKey="briefcaseTaken"/>
							<condition type="flag" flagKey="journalTaken"/>
							<condition type="location" locationNodeID="3"/>
							<result type="goal" subtype="complete" target="1A"/>
						</event>
						<event key="1B" group="1" comment="after journal comes briefcase" remove="1A">
							<condition type="flag" flagKey="journalTaken"/>
							<result type="goal" subtype="update" target="1" key="1B"/>
						</event>
						<event key="1C" group="1" comment="dialog before new goals" remove="1A1">
							<condition type="flag" flagKey="briefcaseTaken"/>
							<condition type="flag" flagKey="journalTaken"/>
							<condition type="location" locationNodeID="2"/>
							<result type="caption" key="tutorial03"/>
							<result type="goal" subtype="complete" targetGroup="1"/>
							<result type="goal" subtype="add" key="2"/>
							<result type="goal" subtype="add" key="3"/>
							<result type="flag" subtype="add" givesFlag="canPickupGun"/>
						</event>
						<event key="2" group="2" comment="You've found the ticket">
							<condition type="item" itemKey="ticket"/>
							<result type="goal" subtype="complete" target="2"/>
						</event>
						<event key="3" group="3" comment="You've found the gun">
							<condition type="item" itemKey="gun"/>
							<result type="goal" subtype="complete" target="3"/>
						</event>
						<event key="4" group="4" comment="get goal to leave">
							<condition type="item" itemKey="gun"/>
							<condition type="item" itemKey="ticket" />
							<result type="flag" subtype="add" givesFlag="exitNow"/>
							<result type="goal" subtype="add" key="4"/>
						</event>
						<event key="5" group="5" comment="About to leave">
							<condition type="flag" flagKey="exitNow"/>
							<condition type="location" locationNodeID="6"/>
							<result type="caption" key="tutorial04"/>
						</event>
					</events>
				</scene>;
		}
		//if goal subtype == complete, make sure goal isn't already complete. fail quietly.
		public function get xml():XML
		{
			return _xml;
		}
	}
}