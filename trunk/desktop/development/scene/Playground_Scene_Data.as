package development.scene
{
	import net.deanverleger.data.IXMLObject
	
	public class Playground_Scene_Data implements IXMLObject
	{
		private var _xml:XML;
		
		public function Playground_Scene_Data()
		{
			_xml = 	
				<scene>
					<useHUD>true</useHUD>
					<scriptID>Playground</scriptID>
					<defaultNode>1</defaultNode>
					<implementationPackage>development.scene.locationnodes</implementationPackage>
					<soundInstructions>
						<soundInstruction key="peace">
							<music soundObjectKey="A" volume=".4" loop="true"/>
						</soundInstruction>
						<soundInstruction key="peaceOffice">
							<music soundObjectKey="A" loop="true" volume=".4"/>
							<ambient soundObjectKey="A" loop="false" />
						</soundInstruction>
						<soundInstruction key="war">
							<music soundObjectKey="B" loop="true" volume=".3"/>
						</soundInstruction>
						<soundInstruction key="briefcases">
							<ambient soundObjectKey="open" loop="false" nextSoundObjectKey="close"/>
							<ambient soundObjectKey="close" loop="false" play="false" nextSoundObjectKey="open"/>
						</soundInstruction>
					</soundInstructions>	
					<soundObjects enumerationPackage="development.sound" enumerationClassName="PlaygroundSoundObjects">
						<music>
							<soundObject key="A" className="NormalTownMusic"/>
							<soundObject key="B" className="BattleMusic"/>
						</music>
						<ambient>
							<soundObject key="A" className="PoliceDepartment"/>
							<soundObject key="open" className="OpenBriefcase"/>
							<soundObject key="close" className="CloseBriefcase"/>
						</ambient>
					</soundObjects>
					<goals>
						<goal key="inspectTree" type="inspect"/>
						<goal key="catchBunny" type="interact"/>
					</goals>
					<items>
						<item key="testItem1" assetClass="ItemJournal"/>
						<item key="testItem2" assetClass="ItemInventory"/>
					</items>
					<notes>
						<note key="momsNote" assetClass="MomsNote"/>
					</notes>
					<playerStart>
						<item key="testItem1"/>
						<item key="testItem2"/>
						<goal key="inspectTree"/>
						<note key="momsNote"/>
						<keyItem/>
					</playerStart>
					<nodes>
						<node assetClass="Yurt_Front_Door" implementationClass="Node1" id="1" compassDegree="240">
							<adjacents>
								<adjacent id="3" movementDirection="N"/>
								<adjacent id="2" movementDirection="E"/>
							</adjacents>
							<states defaultState="Default" soundInstructionKey="peace">
								<state key="Default">
									<object name="typewriter" type="save" hoverType="interact"/>
									<object name="door" hoverType="interact" type="link" linkedNode="3"/>
								</state>
							</states>
						</node>
						<node assetClass="Yurt_Rock" implementationClass="Node2" id="2" compassDegree="32">
							<adjacents>
								<adjacent id="1" movementDirection="W"/>
							</adjacents>
							<states defaultState="Default" soundInstructionKey="peaceOffice">
								<state key="Default">
									<object name="rock" type="minigame" hoverType="interact" miniGameClass="development.minigames.RockGameTime"/>
								</state>
							</states>
						</node>
						<node assetClass="Town_Gate" implementationClass="Node3" id="3" compassDegree="163">
							<adjacents>
								<adjacent id="1" movementDirection="S" />
								<adjacent id="4" movementDirection="N" flagRequired="doorOpened" />
							</adjacents>
							<states defaultState="GateClosed" soundInstructionKey="peace">
								<state key="GateClosed" startFrame="Gate Closed" priority="2">
									<object name="Oak1" type="speak" hoverType="speak" givesFlag="talkedWithOak" tempState="OakCloseup"/>
									<object name="bub_standing" hoverType="speak" type="speak"/>
									<object name="tree" type="caption" hoverType="inspect"/>
									<object name="door" type="interact" hoverType="inspect" flagRequirement="talkedWithOak" givesFlag="doorOpened" calculateAfter="true" />
								</state>
								<state key="OakCloseup" loopStart="Oak Talk Start" loopEnd="Oak Talk End"/>
								<state key="GateOpen" startFrame="Gate Open" priority="1" flagRequirement="talkedWithOak">
									<object name="tree" type="caption" hoverType="inspect"/>
									<object name="oak2" type="speak"/>
									<object name="bub_laying" type="speak"/>
								</state>
							</states>
						</node>
						<node assetClass="Grasslands" implementationClass="Node4" id="4" compassDegree="157">
							<adjacents>
								<adjacent id="3" movementDirection="S" />
							</adjacents>
							<states defaultState="Bunny">
								<state key="Bunny" startFrame="Bunny" soundInstructionKey="war" priority="4" triggeredObjectAtStart="appears">
									<object name="appears" type="caption" />
									<object name="bunny" type="caption" hoverType="inspect" acceptsItem="pokeball" calculateAfter="true"/>
								</state>
								<state key="PokeballOpen" startFrame="pokeball open" stopFrame="pokeball closed" soundInstructionKey="war" priority="3" haltControls="true" nextState="PokeballClosed"/>
								<state key="PokeballClosed" startFrame="pokeball closed" triggeredObjectAtStart="causeMessage" soundInstructionKey="peace">
									<object name="caughtMessage" type="caption" givesFlag="caughtBunny" />
								</state>
								<state key="Empty" startFrame="sign" soundInstructionKey="peace"/>
								<state key="WithSign" startFrame="sign" flagRequirement="caughtBunny" musicGroup="A" priority="1">
									<object key="sign" type="caption" hoverType="inspect"/>
								</state>
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