package net.strangerdreams.app.scenes.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class Scene3ScriptData implements IXMLObject
	{
		private var _xml:XML;
		public function Scene3ScriptData()
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
								couldn’t quit for many reasons. Maybe I just don't have <br/>
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
						<node id="1">
							<caption objectKey="frameCaption">
								<screen order="1">What happened? Did I black out? I hope I didn't miss the meeting with Bernard's contact.</screen>
								<screen order="2">I need to get to the diner. I think it's called Love's.</screen>
							</caption>
							<caption objectKey="bed" alternate="true">
								<screen order="1">How did I end up here?</screen>
								<screen order="2">Did someone bring me here?</screen>
							</caption>
						</node>
						<node id="3">
							<caption objectKey="doors" alternate="true">
							<screen order="1">Hmm... nothing.</screen><screen order="2">...</screen>
							</caption>
						</node>
						<node id="4">
							<caption objectKey="registry">No one is around, and all of the lights are off. I've got an uneasy feeling.</caption>
						</node>
						<node id="5">
							<caption objectKey="craneNotice">"Crand Ind. will be starting construction at the end of Main St."</caption>
						</node>
						<node id="7">
							<caption objectKey="frameCaption">
								<screen order="1">Am I slipping out of reality? I had hoped coming here would have grounded me, but it feels like falling into unknown territory.</screen>
								<screen order="2">It's like the beginning of a nightmare where everything seems familiar and friendly.</screen>
							</caption>
							<caption objectKey="stuckys">
								Stucky's gas station. It seems like they should be open.
							</caption>
							<caption objectKey="bar">
								Looks like a bar. The sign says "Lamb's Head". Conveniently placed across from Spark & Oats. If I loose my mind it's only steps away.
							</caption>
							<caption objectKey="church">
								I can barely make out a building through the thick fog. It looks like a large church. Not very comforting.
							</caption>
						</node>
						<node id="8">
							<caption objectKey="frameCaption">
								This is the only building on the block with any lights on. All I can hope is that Bernard's contact will still be there.
							</caption>
						</node>
						<node id="11">
							<caption objectKey="wrapUp">
								<screen order="1">
									Could he have meant everything he said?
								</screen>
								<screen order="2">
									If I'm not the only person looking for answers, I'm most likely the only one looking for them in dreams. That gives me an advantage, but...
								</screen>
								<screen order="3">
									I have no idea what this person knows... what advantages they have over me. Every answer I receive presents itself as another question.
								</screen>
								<screen order="4">
									What will happen if I trust my dreams completely and they lead me astray? 
								</screen>
								<screen order="5">
									I've never considered the possibility that my subsconcious is trying to do me in. Though I can't be sure that my visions come from me.
								</screen>
								<screen order="6">
									It could be argued that the dream world and the waking world are made of the same material. If so, what could that man have meant...
								</screen>
								<screen order="7">
									When we spoke of trusting dreams... 
								</screen>
							</caption>
						</node>
					</captions>
					<dialogs>
						<node id="10">
							<dialog key="atleeHale">
								Go ahead and have a seat.
							</dialog>
						</node>
						<node id="11">
							<dialog key="jeanniePie">
								Would you like anything? Pie's made fresh every day, and we have great coffee. No? Well I'll be in the back if you need anything.
							</dialog>
							<dialog key="atleeIntro">
								I've been waiting for you. I expected you earlier but I had no doubts that you'd show up. I suspect you had a good reason for keeping me waiting?
							</dialog>
							<dialog key="atleePie">
								<screen order="1">You could say I'm a friend. I love this pie, you should really try it before you no longer have the chance.</screen>
								<screen order="2">You have something to show me?</screen>
							</dialog>
							<dialog key="atleePromptPhoto">
								You have something to show me?
							</dialog>
							<dialog key="atleeNotReady">
								You're not ready to hear what this man has to say yet. And if you aren't ready, he will not allow himself to be found. It's not time.
									
							</dialog>
							<dialog key="atleeExplain">
								<screen order="1">
									You must walk your own path to find the truth. I would be doing you a disservice to tell you things you cannot yet comprehend.
								</screen>
								<screen order="2">
									It's better for me to point you in the right direction. Please listen. I'm going to ask you a question.
								</screen>
							</dialog>
							<dialog key="atleeQuestion">
								It may sound strange, but please answer truthfully. Do you trust the wisdom of your dreams?
							</dialog>
							<dialog key="atleeDreamResponseA">
								<screen order="1">
									It gives me hope to hear this. You can't hope to surivive this if you cannot accept the teachings of your dreams.
								</screen>
								<screen order="2">
									Understanding is but one tool at your disposal however. It may not always be the correct lens to look through.
								</screen>
								<screen order="3">
									In any situation, you must take the good with the bad. Efforts should be made to withold judgement towards these absolutes.
								</screen>
								<screen order="4">
									After all, good and bad are just words. And words have a funny way of fluttering away when you would most appreciate their assistance.
								</screen>
								<screen order="5">
									Once the words fly away the meaning is set loose. The words could never contain the meaning anyway.
								</screen>
								<screen order="6">
									Our time is up, but before I leave I'll tell you one last thing.
								</screen>
								<screen order="7">
									You're not the only one looking for answers in this town.
								</screen>
							</dialog>
							<dialog key="atleeDreamResponseB">
								<screen order="1">
									This is regrettable news to hear... It's not an easy burden to bear, but you mustn't let fear cloud your focus.
								</screen>
								<screen order="2">
									There is much to be learned if you can accept what frightens you.
								</screen>
								<screen order="3">
									In any situation, you must take the good with the bad. Efforts should be made to withold judgement towards these absolutes.
								</screen>
								<screen order="4">
									After all, good and bad are just words. And words have a funny way of fluttering away when you would most appreciate their assistance.
								</screen>
								<screen order="5">
									Once the words fly away the meaning is set loose. The words could never contain the meaning anyway.
								</screen>
								<screen order="6">
									Our time is up, but before I leave I'll tell you one last thing.
								</screen>
								<screen order="7">
									You're not the only one looking for answers in this town.
								</screen>
							</dialog>
							<dialog key="atleeDreamSummary">
								<screen order="1">
									In any situation, you must take the good with the bad. Efforts should be made to withold judgement towards these absolutes.
								</screen>
								<screen order="2">
									After all, good and bad are just words. And words have a funny way of fluttering away when you would most appreciate their assistance.
								</screen>
								<screen order="3">
									Once the words fly away the meaning is set loose. The words could never contain the meaining anyway.
								</screen>
							</dialog>
							<dialog key="atleeTimeUp">
								<screen order="1">
									Our time is up, but before I leave. I'll tell you one last thing.
								</screen>
								<screen order="2">
									You're not the only one looking for answers in this town.
								</screen>
							</dialog>
							
							<option key="atleeIntroAShort">I don't know what happened.</option>
							<option key="atleeIntroBShort">Who are you?</option>
							<option key="atleeIntroALong">I blacked out... I think. I'm not really sure what happened. So you're a friend of Bernard's?</option>
							<option key="atleeIntroBLong">I'm not sure what you mean? Are you a friend of Bernard's?</option>
							<option key="atleeNotReadyAShort">What do you mean?</option>
							<option key="atleeExplainAShort">I'm all ears.</option>
							<option key="atleeNotReadyALong">What do you mean?</option>
							<option key="atleeExplainALong">I'm all ears.</option>
							<option key="atleeQuestionAShort">I trust the wisdom of my dreams.</option>
							<option key="atleeQuestionBShort">My dreams frighten me.</option>
							<option key="atleeQuestionALong">I may not always understand them, but I trust them. I wouldn't be here if I didn't.</option>
							<option key="atleeQuestionBLong">My dreams frighten me. I've had too many sleepless nights. Whatever wisdom that's there is lost on me.</option>
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
					</notes>
					<goals>
						<goal key="1" title="Speak to contact" description="I was supposed to meet a contact that has some information for me. It's a long shot, but I have to check if he's still waiting for me. Any leads are a help right now, even unlikely ones."/>
					</goals>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}