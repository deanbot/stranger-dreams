package development.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class Playground_Script_Data implements IXMLObject
	{
		private var _xml:XML;
		public function Playground_Script_Data()
		{
			_xml = 	
				<script>
					<captions>
						<node id="3">
							<caption objectKey="tree">
								<version priority="2">This is an old tree.</version>
								<version priority="1" flagRequirement="doorOpened" alternate="true">
									<screen order="1">This is an old tree. Go look at it!</screen>
									<screen order="2">Like this tree do you?</screen>
								</version>
							</caption>
							<caption objectKey="door" alternate="true">The town gate stands between you and a life of adventure.</caption>
						</node>
						<node id="4">
							<caption objectKey="appears">A wild Buneary has appeared!</caption>
							<caption objectKey="bunny"><screen order="1">Cute Buneary!</screen><screen order="2">Use your pokeball!</screen></caption>
							<caption objectKey="caughtMessage">You have captured Buneary!</caption>
							<caption objectKey="sign">Sign reads: "No more pokemans here. You've caughts 'em all bub!"</caption>
						</node>
					</captions>
					<dialogs>
						<node id="3">
							<dialog objectKey="oak">
								<version priority="3">
									<screen order="1">
										He Ho ho! Hello, well if it isn't Ash Carpenter. Whippersnapper you!
									</screen>
									<screen order="2">
										<text>Have you been studying your pokemon books closely?</text>
										<option id="sceen2A">Uh huh!</option>
										<option id="screen2B">Nooo... I've been really busy man.</option>
									</screen>
									<screen order="3">
										<text optionID="screen2A">Wuh-hu-hunnnderful haha! Yeah!</text>
										<text optionID="screen2B">Uh.... okay. You.... err... well... shoulda \n *mumble* *mumble*</text>
									</screen>
									<screen order="4">
										<text>I know you're ready! HA YESSSSSSSSS! Want me to open the town gate?</text>
										<option id="ready">Yes</option>
										<option id="notReady">No</option>
									</screen>
									<screen order="5">
										<text optionID="ready" givesPrimaryFlag="true">That's wonderful. Get there and catch us pokemon!</text>
										<text optionID="notReady" givesFlag="oaksSpeal">That's okay, come back and talk to me when you're ready</text>
									</screen>
								</version>
								<version priority="2" flagRequired="oaksSpeal">
									<screen order="1">
										<text>I can smell your readyness to explore and catch pokemon. Is my nose deceiving me?</text>
										<option givesPrimaryFlag="true">Nope! Open the gate!</option>
										<option>Yes....I should leave.</option>
									</screen>
								</version>
								<version priority="1" flagRequired="doorOpened">
									Go get em Gary!
								</version>
							</dialog>
							<dialog objectKey="bub">
								<version priority="2" alternate="true">
									<screen order="1">Leaving town is too risky. Sounds like too much work too. You aughten't uh do it.</screen>
									<screen order="2">My boy. No use adventuring when you can just stick your dollar in the slot and like magic out comes a bag of munchos.</screen>
								</version>
								<version priority="1" flagRequirement="doorOpen">No! Ruined! It's not safe *cough* *cough*</version>
							</dialog>
						</node>
					</dialogs>
					<items>
						<item key="testItem1" title="Journal" description="This is my journal. It is one of my shields."/>
						<item key="testItem2" title="Briefcase" description="This is my briefcase. It holds my shields."/>
					</items>
					<goals>
						<goal goalKey="inspectTree" title="Find the Ancestor"><![CDATA[People have been talking about some non-human relatives outside of our town.<br/><br/>Try and find out for yourself what they're talking about.]]></goal>
						<goal goalKey="catchBunny" title="Catch a PokeMon">Professor Oak would be really happy if you could catch a PokeMon. He loves those PokeMon!</goal>
					</goals>
					<notes>
						<note noteKey="momsNote" title="Mom's Note"/>
					</notes>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}