package net.strangerdreams.app.scenes.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class Scene3 implements IXMLObject
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
		
		public function Scene3()
		{
			_xml = 
				<scene>
					<useHUD>true</useHUD>
					<scriptPackage>scenes.script</scriptPackage>
					<scriptID>Scene3</scriptID>
					<defaultNode>1</defaultNode>
					<implementationPackage>net.strangerdreams.app.scenes.imp.scene3</implementationPackage>
					<soundInstructions>
						<soundInstruction key="theme">
							<music soundObjectKey="strangeNightTheme" volume=".7" loop="true"/>	
							<ambient soundObjectKey="bugs" volume=".02" loop="true"/>
						</soundInstruction>
						<soundInstruction key="hotelDoorClosed">
							<music soundObjectKey="strangeNightTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="hotelDoorClose" volume="1" loop="false"/>
						</soundInstruction>
						<soundInstruction key="hotelRoomDoorClosed">
							<music soundObjectKey="strangeNightTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="hotelRoomDoorClose" volume="1" loop="false"/>
						</soundInstruction>
						<soundInstruction key="hotelLobby">
							<music soundObjectKey="strangeNightTheme" volume=".7" loop="true"/>
							<ambient soundObjectKey="bugs" volume=".03" loop="true"/>
							<ambient soundObjectKey="hoots" volume=".03" loop="true"/>
						</soundInstruction>
						<soundInstruction key="nightHoots">
							<music soundObjectKey="strangeNightTheme" volume=".7" loop="true"/>	
							<ambient soundObjectKey="hoots" volume=".5" loop="true"/>
							<ambient soundObjectKey="bugs" volume=".2" loop="true"/>
						</soundInstruction>
						<soundInstruction key="nightStreet">
							<music soundObjectKey="strangeNightTheme" volume=".5" loop="true"/>	
							<ambient soundObjectKey="bugs" volume=".06" loop="true"/>
							<ambient soundObjectKey="hoots" volume=".2" loop="true"/>
							<ambient soundObjectKey="buzz" volume=".25" loop="true"/>
						</soundInstruction>
						<soundInstruction key="lovesBuzz">
							<music soundObjectKey="strangeNightTheme" volume=".6" loop="true"/>	
							<ambient soundObjectKey="bugs" volume=".05" loop="true"/>
							<ambient soundObjectKey="buzz" volume=".4" loop="true"/>
						</soundInstruction>
						<soundInstruction key="lovesInside">
							<music soundObjectKey="strangeNightTheme" volume=".5" loop="true"/>	
							<ambient soundObjectKey="bugs" volume=".02" loop="true"/>
							<ambient soundObjectKey="buzz" volume=".1" loop="true"/>
						</soundInstruction>
						<soundInstruction key="lovesDoorClosed">
							<music soundObjectKey="strangeNightTheme" volume=".5" loop="true"/>
							<ambient soundObjectKey="bugs" volume=".02" loop="true"/>
							<ambient soundObjectKey="buzz" volume=".1" loop="true"/>
							<ambient soundObjectKey="lovesClose" volume="1" loop="false"/>
						</soundInstruction>
						<soundInstruction key="solace">
							<music soundObjectKey="strangeNightSolace" volume=".7" loop="true"/>
							<ambient soundObjectKey="bugs" volume=".02" loop="true"/>
							<ambient soundObjectKey="buzz" volume=".1" loop="true"/>
						</soundInstruction>
					</soundInstructions>
					<soundObjects>
						<music>
							<soundObject key="strangeNightTheme" className="StrangeNightTheme"/>
							<soundObject key="strangeNightSolace" className="Solace"/>
							<soundObject key="jukebox" className="MustHaveBeenDreaming"/>
						</music>
						<ambient>
							<soundObject key="hotelDoorClose" className="HotelDoorClose"/>
							<soundObject key="hotelRoomDoorClose" className="HotelRoomDoorClose"/>
							<soundObject key="hotelDoorOpen" className="HotelDoorOpen"/>
							<soundObject key="lovesOpen" className="LovesOpen"/>
							<soundObject key="lovesClose" className="LovesClose"/>
							<soundObject key="hoots" className="Owls"/>
							<soundObject key="bugs" className="NightSound"/>
							<soundObject key="buzz" className="BuzzSound"/>
						</ambient>
					</soundObjects>
					<nodes>
						<node assetClass="SparkAndOatsRoom" implementationClass="YourRoomImp" id="1" compassDegree="121" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="3" movementDirection="S"/>
							</adjacents>
							<states>
								<state key="Default" priority="2" soundInstructionKey="theme">
									<object name="bed" type="caption" hoverType="inspect"/>
									<object name="recorder" type="save" hoverType="grab"/>
								</state>
								<state key="LeftRoom" priority="1" flagRequirement="node1FrameCaption" soundInstructionKey="hotelRoomDoorClosed">
									<object name="bed" type="caption" hoverType="inspect"/>
									<object name="recorder" type="save" hoverType="grab"/>
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
								<state key="Default" priority="1" stopFrame="doorsGrouped" soundInstructionKey="theme">
									<object name="door1" type="link" hoverType="grab" linkedNode="2"/>
									<object name="doors" type="caption" hoverType="inspect" />
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsLobby" implementationClass="SparkAndOatsLobbyImp" id="4" compassDegree="113" mapLocation="sparkAndOatsIn">
							<adjacents>
								<adjacent id="6" movementDirection="E"/>
								<adjacent id="3" movementDirection="W"/>
							</adjacents>
							<states soundInstructionKey="hotelLobby">
								<state key="Default" priority="1" startFrame="NightSpecial" >
									<object name="registry" hoverType="inspect" type="caption" />
								</state>
							</states>
						</node>
						<node assetClass="SparkAndOatsDoor" implementationClass="SparkAndOatsDoorImp" id="5" compassDegree="275" mapLocation="sparkAndOatsOut">
							<adjacents>
								<adjacent id="4" movementDirection="N" issueEvent="true"/>
								<adjacent id="6" movementDirection="S"/>
							</adjacents>
							<states soundInstructionKey="nightHoots">
								<state key="Default" startFrame="night">
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
								<state key="Default" startFrame="night" soundInstructionKey="nightHoots">
									<object name="plaque" type="caption" hoverType="inspect"/>
								</state>
							</states>
						</node>
						<node assetClass="MabelOutsideSpecialScene" implementationClass="MabelOutsideSpecialSceneImp" id="7" compassDegree="50" mapLocation="specialSceneOutside">
							<adjacents>
								<adjacent id="6" movementDirection="S"/>
								<adjacent id="8" movementDirection="N"/>
							</adjacents>
							<states>
								<state key="Default" startFrame="red" triggeredObjectAtStart="frameCaption" soundInstructionKey="nightStreet">
									<object name="frameCaption" type="caption" givesFlag="OutsideCaption" antiFlagRequirement="OutsideCaption"/>
									<object name="stuckys" type="caption" hoverType="inspect"/>
									<object name="bar" type="caption" hoverType="inspect"/>
									<object name="church" type="caption" hoverType="inspect"/>
									<object name="loves" type="link" hoverType="inspect" linkedNode="8"/>
								</state>
							</states>
						</node>
						<node assetClass="MabelOutsideLovesSpecialScene" implementationClass="MabelOutsideLovesSpecialSceneImp" id="8" compassDegree="92" mapLocation="lovesOut">
							<adjacents>
								<adjacent id="7" movementDirection="S"/>
								<adjacent id="9" movementDirection="N"/>
							</adjacents>
							<states>
								<state key="Default" soundInstructionKey="lovesBuzz" triggeredObjectAtStart="frameCaption" >
									<object name="door" type="link" hoverType="grab" linkedNode="9"/>
									<object name="frameCaption" type="caption" givesFlag="OutsideLovesCaption" antiFlagRequirement="OutsideLovesCaption" />
								</state>
							</states>
						</node>
						<node assetClass="LovesDoor" implementationClass="LovesDoorImp" id="9" compassDegree="87" mapLocation="lovesDoor">
							<adjacents>
								<adjacent id="8" movementDirection="S"/>
								<adjacent id="9" movementDirection="N" issueEvent="true"/>
							</adjacents>
							<states>
								<state key="Default" soundInstructionKey="lovesBuzz" stopFrame="night" >
									<object name="door" type="interact" hoverType="grab" />
								</state>
							</states>
						</node>
						<node assetClass="LovesLobby" implementationClass="LovesLobbyImp" id="10" compassDegree="73" mapLocation="lovesLobby">
							
							<states>
								<state key="Default" soundInstructionKey="lovesDoorClosed" triggeredObjectAtStart="atleeHale">
									<object name="stool" type="link" hoverType="grab" linkedNode="11"/>
									<object name="jukebox" type="interact" hoverType="grab"/>
									<object name="atleeHale" type="dialog" dialogKey="atleeHale"/>
								</state>
							</states>
								
							<dialogs>
								<dialog key="atleeHale" scriptKey="atleeHale" character="StrangeManDefault" end="true"/>
							</dialogs>
						</node>
						<node assetClass="LovesCounter" implementationClass="LovesCounterImp" id="11" compassDegree="70" mapLocation="lovesCounter">
							<states>
								<state key="JeanniePie" startFrame="Jeanie" soundInstructionKey="lovesInside" triggeredObjectAtStart="jeanniePie" priority="5">
									<object name="jeanniePie" type="dialog" dialogKey="jeanniePie" givesFlag="jeanniePie" calculateAfterFinished="true"/>
								</state>
								<state key="AtleeIntro" startFrame="FadeJeanieToAtlee" stopFrame="Atlee" triggeredObjectAtStart="atleeIntro" priority="4" flagRequirement="jeanniePie" soundInstructionKey="lovesInside">
									<object name="atleeIntro" type="dialog" dialogKey="atleeIntro" givesFlag="atleeIntro"/>			
									<object name="atlee" type="dialog" dialogKey="atleePromptPhoto" hoverType="speak" acceptsItem="photo"/>			
								</state>
								<state key="AtleeNotReady" startFrame="Atlee" triggeredObjectAtStart="atleeNotReady" priority="3" flagRequirement="gaveAtleePhoto" soundInstructionKey="lovesInside">
									<object name="atleeNotReady" type="dialog" dialogKey="atleeNotReady" givesFlag="atleeDialog" calculateAfterFinished="true"/>					
								</state>
								<state key="FadeAtlee" startFrame="FadeAtleeToCounter" stopFrame="Counter" nextState="Counter" priority="2" flagRequirement="atleeDialog" soundInstructionKey="solace"/>
								<state key="Counter" startFrame="Counter" soundInstructionKey="solace" triggeredObjectAtStart="wrapUp">
									<object name="wrapUp" type="caption" givesFlag="wrapUp" calculateAfterFinished="true"/>
								</state>
								<state key="EndScene" startFrame="Counter" soundInstructionKey="solace" flagRequirement="wrapUp" priority="1"/>
							</states>
							<dialogs>
								<dialog key="jeanniePie" scriptKey="jeanniePie" character="JeannieDefault" end="true"/>
								<dialog key="atleeIntro" scriptKey="atleeIntro" character="StrangeManDefault">
									<option order="1" shortKey="atleeIntroAShort" longKey="atleeIntroALong" nextKey="atleePie" />
									<option order="2" shortKey="atleeIntroBShort" longKey="atleeIntroBLong" nextKey="atleePie" />
								</dialog>
								<dialog key="atleePie" scriptKey="atleePie" character="StrangeManDefault" end="true"/>
								<dialog key="atleePromptPhoto" scriptKey="atleePromptPhoto" character="StrangeManDefault" end="true"/>
								<dialog key="atleeNotReady" scriptKey="atleeNotReady" character="StrangeManDefault">
									<option order="1" shortKey="atleeNotReadyAShort" longKey="atleeNotReadyALong" nextKey="atleeExplain" />
								</dialog>
								<dialog key="atleeExplain" scriptKey="atleeExplain" character="StrangeManDefault">
									<option order="1" shortKey="atleeExplainAShort" longKey="atleeExplainALong" nextKey="atleeQuestion" />
								</dialog>
								<dialog key="atleeQuestion" scriptKey="atleeQuestion" character="StrangeManDefault">
									<option order="1" shortKey="atleeQuestionAShort" longKey="atleeQuestionALong" nextKey="atleeDreamResponseA" />
									<option order="2" shortKey="atleeQuestionBShort" longKey="atleeQuestionBLong" nextKey="atleeDreamResponseB" />
								</dialog>
								<dialog key="atleeDreamResponseA" scriptKey="atleeDreamResponseA" character="StrangeManDefault" end="true"/>
								<dialog key="atleeDreamResponseB" scriptKey="atleeDreamResponseB" character="StrangeManDefault" end="true"/>
							</dialogs>
						</node>
					</nodes>
					<characters>
						<character key="StrangeManDefault" asset="Char_StrangeManDefault"/>
						<character key="JeannieDefault" asset="Char_JeannieDefault"/>
					</characters>
					<items>
						<item key="gun" assetClass="KeyItemGun" type="key" have="true"/>
						<item key="roomKey" assetClass="ItemRoomKey" type="inventory" have="true"/>
						<item key="ticket" assetClass="KeyItemTicket" type="key" have="true"/>
						<item key="flashlight" assetClass="ItemFlashlight" type="inventory" have="true"/>
						<item key="photo" assetClass="ItemStrangeManPhoto" type="inventory" have="true"/>
					</items>
					<notes>
						<note key="bernardLetter" assetClass="BernardLetter" implementationClass="net.strangerdreams.app.tutorial.note.BernardLetterImp" have="true"/>
						<note key="carePackageLetter" assetClass="BernardCarePackageLetter" implementationClass="net.strangerdreams.app.scenes.note.BernardCarePackageLetterImp" have="true"/>					
					</notes>
					<goals>
						<goal key="1" group="1" comment="Speak to contact" type="map"/>
					</goals>
					<events>
						<event key="1" group="1" comment="">
							<condition type="location" locationNodeID="1"/>
							<result type="flag" subtype="add" givesFlag="node1FrameCaption"/>
							<result type="caption" key="n1frameCaption" comment="what happened?"/>
							<result type="goal" subtype="add" key="1"/>
							<result type="map" subtype="addCircle" mapLocation="loves"/>
						</event>
						<event key="2" group="2">
							<condition type="location" locationNodeID="9"/>
							<result type="map" subtype="removeCircle" mapLocation="loves"/>
						</event>
						<event key="3" group="3" comment="">
							<condition type="flag" flagKey="atleeIntro" />
							<result type="goal" subtype="complete" target="1"/>
							<result type="goal" subtype="add" key="2"/>
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