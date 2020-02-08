package net.strangerdreams.app.scenes.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class Scene4ScriptData implements IXMLObject
	{
		private var _xml:XML;
		public function Scene4ScriptData()
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
						<caption key="answerPhone">I should answer the phone.</caption>
					</captions>
					<dialogs></dialogs>
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
					</notes>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}