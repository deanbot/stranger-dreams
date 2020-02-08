package net.strangerdreams.app.tutorial.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class BensApartmentScriptData implements IXMLObject
	{
		private var _xml:XML;
		public function BensApartmentScriptData()
		{
			/**/
			_xml=
				<script>
					<captions>
						<caption key="keyItemsHint">
							To view key items click the lock on your briefcase.
						</caption>
						<caption key="bernardApologyletter">
								<screen order="1"><![CDATA[Ben,<br/><br><br/>
								Hey buddy! I hope you’ve been getting some sleep lately. Not to<br/>
								get all serious on you, but I hope you know what a loss it<br/>
								is to me personally to have you leave the force. I know we'll<br/>
								still see each other, but this new guy just isn't the same. Don't<br/>
								worry, I'll go easy on him.]]></screen>
								<screen order="2"><![CDATA[I know how dedicated you are to this investigation, and<br/>
								I'm right there with you...you know, in spirit. I just <br/>
								couldn't quit for many reasons. Maybe I just don't have <br/>
								your adventurous spirit. HA! Well, I'm starting you off<br/>
								on the right foot. I heard the next ‘mystery' murder<br/>
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
						<caption key="tutorial02">
							<screen order="1">
				I don't remember much about the past couple of months.
							</screen>
							<screen order="2">
				Just the dreams. And my systematic investigation of every image there therin. I've followed all the leads.
							</screen>
							<screen order="3">
				I think I've gone as far as I can here in this city. In this apartment.
							</screen>
							<screen order="4">
				Some part of me knows that I won't get further in the dream if I stay here.
							</screen>
							<screen order="5">
				So it's time to leave. I need my briefcase and my journal. I wouldn't get far in any investigation without them.
							</screen>
						</caption>
						<caption key="tutorial03" comment="prompt before gaining goal to get ticket">
							<screen order="1">
				Mabel is the obvious place for me to go. Pine trees. A recent unexplained murder. A cover up by Crane. Paper Crane?
							</screen>
							<screen order="2">
				It's a good thing Bernard still owed me a favor or two. I couldn't have afforded the train ticket on my own.
							</screen>
							<screen order="3">
				We made a good team. In a city like this it's good to have a partner that watches your back.
							</screen>
							<screen order="4">
				... My sense of self-preservation tells me I should bring something to defend myself.
							</screen>
							<screen order="5">
				I've never done something quite like this so I don't know what I'll come up against.
							</screen>	
						</caption>
						<caption key="tutorial04">
							<screen order="1">
				I loved my job. Being a cop made me feel like what I did really mattered, like I made a difference.
							</screen>
							<screen order="2">
				I even like my apartment. It's not in the nicest area, but the rent's cheap and it was close to work.
							</screen>
							<screen order="3">
				Maybe when this is all over I can get my job back. Maybe.
							</screen>
						</caption>
						<caption key="noMap" comment="no map for tutorial level">
							I don't have a map for this area.
						</caption>
						<caption key="noKeyItems" comment="no key items at this point">
							I don't have any key items yet.
						</caption>
						<node id="1">
							<caption objectKey="frameCaption">
								<screen order="1">
				...
								</screen>
								<screen order="2">
				There's no use trying to go back to sleep.
								</screen>
								<screen order="3">
				If there's one thing I've learned it's that I can't see any more of the dream. I'm not allowed. That's all I get.
								</screen>
								<screen order="4">
				A woman screams in the night, a row of trees... The crane, the fire, the buzzing in the air like everything is alive... I know that's me in the cave. 
								</screen>
								<screen order="5">
				The dream is getting more familiar while my current surroundings are getting more distant. More blurry.
								</screen>
								<screen order="6">
				In a moment everything will come into focus though.
								</screen>
								<screen order="7">
				...Get up.
								</screen>
							</caption>
						</node>
						<node id="2">
							<caption objectKey="briefcasePickedUp">
				Briefcase picked up. You can now access the inventory.
							</caption>
							<caption objectKey="books" alternate="true">
								<screen order="1">
				The Art of Deduction.
								</screen>
								<screen order="2">
				The Return of Sherlock Holmes.
								</screen>
							</caption>
							<caption objectKey="books2">
				The Boyscout Handbook.
							</caption>
							<caption objectKey="hypnosStatue">
				A bust of Hypnos, the Greek god of dreams. Purchased from a street vendor.
							</caption>
							<caption objectKey="tv">
				All this thing gets these days is static. Not that I watched it that much in the first place.
							</caption>
							<caption objectKey="clippingsCaption">
								<screen order="1">
									It's all connected.
								</screen>
								<screen order="2">
									When I read about isolated events, murders with peculiar details, development plans from powerful, rich technologists... I sometimes get a feeling.
								</screen>
								<screen order="3">
									It's not that I logically deduce that something is connected to the case. It just feels connected.
								</screen>
								<screen order="4">
									This doesn't always fly on the books though. Now that I'm on my own I can run this investigation my own way.
								</screen>
								<screen order="5">
				It couldn't just be a coincidence that the latest mystery death happened so close to the town where Crane Ind. is located.
								</screen>
								<screen order="6">
									 I know they're involved... somehow.
								</screen>
							</caption>
							<caption objectKey="craneClean">
								<screen order="1"><![CDATA[Crane Clean,<br/><br/>
by: Daily Benson<br/><br/>
On behalf of the Castor City Examiner and<br/>
								all of its employees, we extend a sincere <br/>
								apology to Crane Industries in regards to <br/>
								previously printed material that may have set<br/>
								out to defame the company name. Issues with<br/>
								one of our previous journalists responsible for<br/>
								writing the article have been taken care of. <br/><br/>[...]]]></screen>
								<screen order="2"><![CDATA[After thorough investigation and <br/>
								cooperation from police, no link between Crane<br/>
								and the murders could be found. There is no <br/>
								solid evidence to prove any conviction, and the<br/>
								hysterics of conspiracy theorists should be <br/>
								pushed aside. As a sign of good faith, Crane <br/>
								Industries will be running a cleanup <br/>
								operation at the site of the most recent death<br/>
								in Mabel. The cause has been proven to be <br/>
								toxic gases from nearby Red Dog Mine.<br/>
								Crane will be funding the destruction and <br/>
								decommissioning of the mine to keep the locals safe <br/>
								from any further danger.]]></screen>
							</caption>
							<caption objectKey="craneDenies">
								<screen order="1"><![CDATA[Crane Ind. Denies Involvement<br/> In Unexplainable Deaths<br/><br/>
								By: Kirby Hale<br/><br/>
								Crane Industries, a multi-billion <br/>
								dollar genetic enhancements company, is <br/>
								suspected of bribing media and law <br/>
								enforcement agencies into suppressing <br/>
								details of a string of inexplicable <br/>
								murder cases behind closed doors. <br/>
								What Crane Ind. could gain from these <br/>
								actions is still unknown. CEO <br/>
								Warren Crane denied any public <br/>
								statement on the matter. If the <br/>
								accusations are proven true, it could be <br/>
								detrimental to the further growth of ]]></screen>
								<screen order="2"><![CDATA[ Crane Industries. <br/>
								The cases are currently being <br/>
								largely withheld from the public. <br/>
								Suspicions arose as to the cause of the<br/>
								deaths, and the nature of the secrecy <br/>
								revolving around them. Crane has <br/>
								bounced back from numerous scandals,<br/>
								but has his luck finally run out? <br/><br/>
								
								(Story continues on page 8)]]></screen>
							</caption>
						</node>
						<node id="3">
					<caption objectKey="journalPickedUp">
				Journal picked up. You can now access the journal.
							</caption>
							<caption objectKey="matches">
				A matchbook from the bar across the street. I don't think I'll need it.
							</caption>
						</node>
						<node id="4">
							<caption objectKey="plant" alternate="true">
								<screen order="1">
									<screen order="1">
					Damn... Sorry, guy. I guess I haven't watered you in a while. I haven't been treating myself well lately either.
									</screen>
									<screen order="2">
					I should get some food on the train. Looks like we've both got withering health.
									</screen>
								</screen>
								<screen order="2">
					Maybe I'll buy a new plant to bring home when I come back.
								</screen>
							</caption>
						</node>
						<node id="5">
							<caption objectKey="frameCaption" alternate="true">
				<screen order="1">
				I'm sick of seeing those same flashing lights...police tape...there's something missing here...
				</screen>
				<screen order="2">
				People talk about cities teeming with life, but folks here look more like zombies.
				</screen>
				<screen order="3">
					<screen order="1">
					What would those people do if I told them something was wrong? Would they believe me? Would they just go about their day?
					</screen>
					<screen order="2">
					What if it undermined everything?
					</screen>
					<screen order="3">
					What would it take for people to do something?
					</screen>
				</screen>
							</caption>
						</node>
						<node id="6">
							<caption objectKey="chair" alternate="true">
				<screen order="1">
				I haven't had a real bed for a while now.
				</screen>
				<screen order="2">
				After I quit my job I still had to pay rent. The bed was the first to go.
				</screen>
							</caption>
							<caption objectKey="coat">
				I'll grab my coat before I leave.
							</caption>
							<caption objectKey="pipesCloset">
				Nothing much in here. Just the water heater and some pipes.
							</caption>
							<caption objectKey="door">
				I still need to collect my things.
							</caption>
							<caption objectKey="doorQuestion">
				Are you ready to leave?
							</caption>
							<caption objectKey="doorYes">
				Yes
							</caption>
							<caption objectKey="doorYes">
				No
							</caption>
						</node>
						<node id="7">
							<caption objectKey="clock">
				<screen order="1">
				3 o'clock. I've gotten used to it by now, but I still don't get it.
				</screen>
				<screen order="2">
				Why is it that each time I wake up from the dream it's always around the same time?
				</screen>
				<screen order="3">
				Right between midnight and day... I haven't got a clue what it means - if anything.
				</screen>
							</caption>
							<caption objectKey="compass">
				<screen order="1">Ah... my Orienteering badge from boy scouts.</screen>
				<screen order="2">"Orienteering, the use of map and compass to find locations and plan a journey, has been a vital skill for humans for thousands of years."</screen>
				<screen order="3">...I can't remember the rest.</screen>
							</caption>
							<caption objectKey="picture">
				My old partner Bernard and I on a fishing trip.
							</caption>
							<caption objectKey="brochureLetterHit">
				If I'm going to pick this up I'll need something to put it in...
							</caption>
							<caption objectKey="tool">
								A compass, a tool for making maps.
							</caption>
						</node>
						<node id="8">
							<caption objectKey="coat">
				My old police jacket. I was promoted before it got much use.
							</caption>
							<caption objectKey="files">
				Full of old memories. I think I'd get along just fine without them.
							</caption>
						</node>
						<node id="9">
							<caption objectKey="bullets">
				I'll leave my extra ammo here. I don't want to be tempted to use my gun more than necessary.
							</caption>
							<caption objectKey="gun">
				I'm not going to just put this in my pocket. I'm not careless. I need something to put this in first.
							</caption>
						</node>
						<node id="10">
							<caption objectKey="frameCaption">
								<screen order="1">
				This is actually the cleanest room in the house. I can't stand a dirty bathroom. 
								</screen>
								<screen order="2">
				I wish the landlord would fix the leaking pipe.
								</screen>
							</caption>
						</node>
					</captions>
					<items>
						<item key="gun" title="Detective Special" description="Small and concealable, I don't plan on using this much. Just a precaution." />
						<item key="ticket" title="Train Ticket" description="A ticket for the one-way from Castor City to Mabel." />
					</items>
					<notes>
						<note key="bernardLetter" title="Bernard's Apology"/>
						<note key="mabelBrochure" title="Mabel Brochure"/>
						<note key="newsClippings" title="News Clippings"/>
					</notes>
					<goals>
						<goal key="1" title="Find my suitcase & journal." description="n/a"/>
						<goal key="1A" title="Find journal" description="n/a"/>
						<goal key="1B" title="Find suitcase" description="Essential to any investigation - if I find things of interest I can keep them in my suitcase."/>
						<goal key="2" title="Ticket out of here" description="Bernard's a real friend. He set up all the travel arrangements for me. I should inspect the Mabel Brochure. I need the ticket inside to take the train."/>
						<goal key="3" title="Always be prepared" description="Hopefully I won't have to use my gun, but it'd be a mistake to leave it behind. Using it is a last resort."/>
						<goal key="4" title="Head to the train station" description="Even though it's still dark I'd like to get going. I'm always antsy at the beginning of an investigation."/>
					</goals>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}