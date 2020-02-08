package net.strangerdreams.app.scenes.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class Scene1ScriptData implements IXMLObject
	{
		private var _xml:XML;
		public function Scene1ScriptData()
		{
			_xml=
				<script>
					<captions>
						<caption key="bernardApologyletter" comment="note from tutorial">
								<screen order="1"><![CDATA[Ben,<br/><br><br/>
								Hey buddy! I hope you've been getting some sleep lately. Not to<br/>
								get all serious on you, but I hope you know what a loss it<br/>
								is to me personally to have you leave the force. I know we'll<br/>
								still see each other, but this new guy just isn't the same. Don't<br/>
								worry, I'll go easy on him.]]></screen>
								<screen order="2"><![CDATA[I know how dedicated you are to this investigation, and<br/>
								I'm right there with you...you know, in spirit. I just <br/>
								couldn't quit for many reasons. Maybe I just don't have <br/>
								your adventerous spirit. HA! Well, I'm starting you off<br/>
								on the right food. I heard the next ‘mystery' murder<br/>
								happened in a little town called Mabel. I took it upon<br/>
								myself to buy you a train ticket to the place. It<br/>
								includes a whole lodging package and everything.]]></screen>
								<screen order="3"><![CDATA[Ben, for me, go and make peace with these nightmares <br/>
								you've been having, but PLEASE relax a little. I'm almost<br/>
								jealous...kind of looks like a peaceful place. Maybe you'd<br/>
								even have a little of that thing us normal humans call fun?<br/><br/>
								
								I'll be checking in on you to make sure you're not dying <br/>
								or anything. Catch me some fish!]]></screen>
						</caption>
						<caption key="noMap">I don't have a map for this area.</caption>
						<caption key="noKeyItems" comment="no key items at this point">
							I don't have any key items yet.
						</caption>
						<caption key="mapAdded">Mabel Map added. You may access the map page in your journal.</caption>
						<caption key="wheresRoomKey">Where did I put that room key?</caption>
						<caption key="unlocked">Unlocked door.</caption>
						<caption key="noLeave">... It was a long journey. I should get some sleep.</caption>
						<caption key="sleep">Time to get some rest?</caption>
						<caption key="saveGame">Save Game?</caption>
						<caption key="yes">Yes</caption>
						<caption key="no">No</caption>
						<caption key="firstGoal">Spark & Oats, huh? I guess this is where I'll be staying while I'm here. Looks nice enough.</caption>
						<node id="1">
							<caption objectKey="plaque" alternate="true">
								<screen order="1">
									<screen order="1">There's a plaque here at the bottom of the totem pole. It reads: "To honor those who lived here before us whose spirits still live on in these forests."</screen>
									<screen order="2">"Local tribes made totem poles out of solid cuts of cedar before this land was settled."</screen>
									<screen order="3">For more information on the indigenous cultures of Mable, please visit the Mabel Historical Society."</screen>
								</screen>
								<screen order="2">... I wonder what the ancient inhabitants of Mabel called this place.</screen>
							</caption>
						</node>
						<node id="2">
							<caption objectKey="craneNotice">"Crand Ind. will be starting construction at the end of Main St."</caption>
						</node>
						<node id="3">
							<caption objectKey="donuts">I hope they replace these donuts every morning...they must be as stale as cardboard.</caption>
							<caption objectKey="flyer">A flyer for the Mabel Apple Butter Festival? Where am I?</caption>
						</node>
						<node id="4">
							<caption objectKey="doors" alternate="true">
								<screen order="1">I'm just going to get some rest. I'm sure they're doing the same.</screen>
								<screen order="2">It's pretty late, I shouldn't bother anyone.</screen>
							</caption>
						</node>
						<node id="5">
							<caption objectKey="frameCaption">This must be my room.</caption>
							<caption objectKey="handle">I need to unlock the door first.</caption>
						</node>
						<node id="6">
							<caption objectKey="bed">A real bed. Who knows, I might actually get some sleep while I'm here. I'm not sure if that's a good or a bad thing.</caption>
							<caption objectKey="recorder">
								<screen order="1">Maybe I should track my progress occasionally with this tape recorder.</screen>
					 			<screen order="2">Who knows, if I go missing it may be the only evidence left.</screen>
							</caption>
							<caption objectKey="painting">"Scenic Sylvan Lake". Looks like a painting of somewhere in Mabel.</caption>
							<caption objectKey="phone">I can use this to contact Bernard if I need to. No real use right now.</caption>
						</node>
					</captions>	
					<dialogs>
						<node id="3">
							<dialog key="dontTouch">Sorry, Ben. Even though we're like family here the registry book is for employee eyes only.</dialog>
							<dialog key="artIntro">
								<screen order="1">Well, hello! The name's Art. You must be Ben, we've been expecting you. Had plenty of frantic phone calls from a 'Bernard' trying to make sure you got here okay.</screen>
								<screen order="2">How can I help you?</screen>
							</dialog>
							<dialog key="yourKey">Sure thing. Here's your room key and a complimentary map of Mabel.</dialog>
							<dialog key="anythingElse">You should really see the sights when you're not too busy! Anything else I can do for you, Ben?</dialog>
							<dialog key="aboutName">
								<screen order="1">Me and my wife had two horses of the name. We loved them so much, we decided to name the place after them when we opened it.</screen>
								<screen order="2">'Course, the horses and my wife have both passed. Now my grandson helps me here occasionally. Anything else?</screen>
							</dialog>
							<dialog key="goodnight">
								<screen order="1">If you need anything, just let me know! Oh! Where is my head. It's so late.</screen>
								<screen order="2">That fellow Bernard wanted me to let you know he's left a tape recorder for you.</screen>
								<screen order="3">I put it in your room. Have a good night.</screen>
							</dialog>
							<dialog key="haveAGood">Your room is right down the hall there on the left. Have a good night.</dialog>
							
							<option key="aRoomShort">I just need a room.</option>
							<option key="aRoomLong">I just need a room.</option>
							<option key="askAboutNameShort">Why is this place called Spark & Oats?</option>
							<option key="askAboutNameLong">Why is this place called Spark & Oats?</option>
							<option key="noThanksShort">No, thanks. That'll be all.</option>
							<option key="noThanksLong">No, thanks. That'll be all.</option>
						</node>
					</dialogs>
					<items>
						<item key="gun" title="Detective Special" description="Small and concealable, I don't plan on using this much. Just a precaution." />
						<item key="roomKey" title="Room Key" description="The key to get into my room at Spark & Oats. the tag reads '1'" />
					</items>
					<notes>
						<note key="bernardLetter" title="Bernard's Apology"/>
					</notes>
					<goals><goal key="1" title="Get some sleep." description="I just need to find my room. Hopefully the bed is comfortable and the tenants quiet."/></goals>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}