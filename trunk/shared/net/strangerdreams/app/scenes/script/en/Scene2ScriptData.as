package net.strangerdreams.app.scenes.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class Scene2ScriptData implements IXMLObject
	{
		private var _xml:XML;
		public function Scene2ScriptData()
		{
			_xml=
				<script>
					<captions>
						<caption key="bernardApologyletter" comment="note from tutorial">
								<screen order="1"><![CDATA[Ben,<br/><br><br/>
								Hey buddy! I hope you’ve been getting some sleep lately. Not to<br/>
								get all serious on you, but I hope you know what a loss it<br/>
								is to me personally to have you leave the force. I know we’ll<br/>
								still see each other, but this new guy just isn’t the same. Don’t<br/>
								worry, I’ll go easy on him.]]></screen>
								<screen order="2"><![CDATA[I know how dedicated you are to this investigation, and<br/>
								I’m right there with you...you know, in spirit. I just <br/>
								couldn’t quit for many reasons. Maybe I just don’t have <br/>
								your adventerous spirit. HA! Well, I’m starting you off<br/>
								on the right food. I heard the next ‘mystery’ murder<br/>
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
						<caption key="carePackageLetter" comment="bernards second letter">
								<screen order="1"><![CDATA[Ben,<br/><br/>
								I hope you made it safely and are adjusting<br/>
								to the town. I've been trying to get some leads,<br/>
								and I've arranged a meeting for you at Love's<br/>
								diner with someone who might have some info.<br/>
								It never hurts to talk to the locals too.<br/>
								They might know more than you think.]]></screen>
								<screen order="2"><![CDATA[
								I hear there's going to be a pretty bad snow storm soon, <br/>
								so you might be shacking up there for a bit. Don't <br/>
								worry, I've got you covered. I sent you some<br/>
								things that might come in handy.<br/>]]></screen>
								<screen order="3"><![CDATA[The contact you're meeting is a bit squeamish <br/>
								about his name getting tossed around. I'm sorry<br/>
								I can't tell you more. My guess is you can find<br/>
								him easily enough. show him the picture I've <br/>
								given you. Rumor has it that the blurry shape <br/>
								in the photo used to word for Crane.<br/>
								Will talk soon.]]></screen>
						</caption>
						<caption key="yes">Yes</caption>
						<caption key="no">No</caption>
						<caption key="saveGame">Log an entry?</caption>
						<node id="1">
							<caption objectKey="frameCaption">Well rested... two new words to add to my vocabulary.</caption>
							<caption objectKey="bed">It's a decent bed. Better than my chair.</caption>
							<caption objectKey="painting">"Scenic Sylvan Lake". I'll have to visit while I can.</caption>
							<caption objectKey="phone">I've given Bernard my number here. He'll call when he needs to get ahold of me.</caption>
						</node>
						<node id="3">
							<caption objectKey="door2">Sounds like someone is there, but they aren't answering.</caption>
							<caption objectKey="door3">Hmm... nothing.</caption>
							<caption objectKey="door4">Hmm... nothing.</caption>
						</node>
						<node id="5">
							<caption objectKey="craneNotice">"Crand Ind. will be starting construction at the end of Main St."</caption>
						</node>
						<node id="6">
							<caption objectKey="plaque">
								<screen order="1">
									<screen order="1">There's a plaque here at the bottom of the totem pole. It reads: "To honor those who lived here before us whose spirits still live on in these forests."</screen>
									<screen order="2">"Local tribes made totem poles out of solid cuts of cedar before this land was settled."</screen>
									<screen order="3">For more information on the indigenous cultures of Mable, please visit the Mabel Historical Society."</screen>
								</screen>
								<screen order="2">... I wonder what the ancient inhabitants of Mabel called this place.</screen>
							</caption>
						</node>
						<node id="7">
							<caption objectKey="frameCaption">I wonder if it's always this dreary outside. Surely it doesn't rain here every day.</caption>
							<caption objectKey="flowers">The flowers look well maintained. The preservation of nature is definitely a larger priority here than it ever was in Castor City.</caption>
							<caption objectKey="stuckys">Looks like a gas station called "Stuckys". Probably the only one in town.</caption>
							<caption objectKey="mountains">The mountains are a beautiful site... but they give me an ominous feel. I'm drawn to them.</caption>
							<caption objectKey="post">
								<screen order="1">There are some flyers here for businesses in town. "Come visit the Cherry Bowl Drive-In theater. Saturday is Couples Night. $1.00 off concessions."</screen>
								<screen order="2">There's another one here for Crane ind. It mentions some construction they're beginning in Mabel. There's a sturn looking man's face on it.</screen>
							</caption>
						</node>
						<node id="9">
							<caption objectKey="stuff">Customs forms, envelopes, etc...</caption>
						</node>
					</captions>
					<dialogs>
						<node id="4">
							<dialog key="artAuto">
								<screen order="1">Good morning Mr. Benjamin. Hope you slept well. I take a lot of pride in the comfort of these rooms.</screen>
								<screen order="2">Postman came by this morning, said you've got something waiting for you at the post office. Have a wonderful day!</screen>
							</dialog>
							<dialog key="artDialogShort">
								<version priority="2">Jim Baker is our postman. His wife Jane works over in the post office. What a riot those two.</version>
								<version priority="1" flagRequirement="artShortA">Have a wonderful day!</version>
							</dialog>
							<dialog key="myCoffee">
								<screen order="1">That's mine! Specially delivered from Love's every morning. You should go get some if you want a great cup of coffee.</screen>
								<screen order="2">You don't want to drink after these old lips have been on it.</screen>
							</dialog>
				
							<dialog key="whatDoYouWant">
								What do you want?
							</dialog>
							<dialog key="notYourBusiness">
								<screen order="1">Though it's none of your business, I'm not. I'm staying with my husband in room 2, but I'm not a huge fan of him. So I try not to stay there.</screen>
								<screen order="2">Too bad there's nothing else to do here. Maybe I'll see you around.</screen>
							</dialog>
							<dialog key="doreenDialogShort">
								<version priority="2">Who knows what he does in there all day.</version>
								<version priority="1" flagRequirement="doreenShortA">Maybe I'll see you around.</version>
							</dialog>
				
							<option key="doreenResponseShort">Who are you?</option>
							<option key="doreenResponseLong">You don't look like you're from around here.</option>
						</node>
						<node id="9">
							<dialog key="janeAuto">
				You don't look familiar. You Benjamin Carpenter? Must be. Got a package for you. Just talk to me when you're ready.
							</dialog>
							<dialog key="valerieDialog">	
								<version priority="2">
									<screen order="1">Hi, there. My name is Valerie, nice to meet you.</screen>
									<screen order="2">Hey, you aren't one of those goons from Crane Industries coming down here to poke your nose around are you?</screen>
									<screen order="3">I hear they want to change this town. I don't know what that means, but it scares me. I like my life here.</screen>
								</version>
								<version priority="1" flagRequirement="valerieDialogA">My dad is Doc Simmons. You can visit him if you get sick. His practice is across the street from Love's.</version>
							</dialog>
						</node>
					</dialogs>
					<items>
						<item key="gun" title="Detective Special" description="Small and concealable, I don't plan on using this much. Just a precaution." />
						<item key="roomKey" title="Room Key" description="The key to get into my room at Spark & Oats. the tag reads '1'" />
						<item key="ticket" title="Train Ticket" description="A train ticket to Newhaven. Crand Industries is there..." />
						<item key="flashlight" title="Flashlight" description="A heavy duty flashlight Bernard send to me. Wouldn't want to be exploring the woods without it." />
						<item key="photo" title="Photo" description="Bernard says he might have information for me." />
					</items>
					<notes>
						<note key="bernardLetter" title="Bernard's Apology"/>
						<note key="carePackageLetter" title="Care Package Letter"/>
						<note key="noteTrainTicket" title="n/a"/>
						<note key="notePhotoStrangeMan" title="n/a"/>
					</notes>
					<goals>
						<goal key="1" title="Get to the Post Office" description="Art told me I have a package waiting for me at the Post Office. Probably from Bernard. I think he cares too much."/>
						<goal key="2" title="Pick up Care Package" description="I just need to find my room. Hopefully the bed is comfortable and the tenants quiet."/>
					</goals>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}