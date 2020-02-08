package net.strangerdreams.app.tutorial.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class IntroScriptData implements IXMLObject
	{
		private var _xml:XML;
		public function IntroScriptData()
		{
			_xml = 
				<script>
					<captions>
						<node id="1">
							<caption objectKey="letter">
<screen order="1"><![CDATA[Chief Benson,<br/><br><br/>
Please consider this as my resignation from the Castor City<br/>
Police Bureau. It is with a deep sense of sadness and frustration<br/>
that I am submitting this letter.<br/><br/>

I can no longer continue my time on the force after the recent<br/>
string of horrific incidents have gone by ignored and denied of<br/>
any further investigation.<br/><br/>

I am growing increasingly conflicted with knowledge that there<br/>
is something that needs to be done, that there is something terrible<br/>
happening that we are doing little - truthfully nothing at all - to rectify.]]></screen>
								<screen order="2"><![CDATA[There are things I have uncovered about the recent murder<br/>
					cases that in my heart and mind I can not look away from.<br/><br/>
					I now realize that the extended arm of the law is nothing<br/>
					more than a puppet being manipulated by a master that has<br/>
					concealed itself behind a smokescreen of deception. It has<br/>
					reached it’s way down into the minds of the peers I consider<br/>
					upstanding officers, and has blinded them from realizing the<br/>
					truth and instead turn their heads convinced that nothing<br/>
					strange is happening.<br/><br/>
					Though I may not have the law on my side, endless nightmares<br/>
					tell me that I must pursue this case with what little power I<br/>
					have left. It is with a heavy but firm heart that I resign from<br/>
					my position as a law defender.<br/>]]></screen>
								<screen order="3">
				<![CDATA[I will truly miss the camaraderie of the force, in particular<br/>
					the dedication of my former partner Bernard. Knowing what I do,<br/>
					I could not walk with justice, with virtue, if sworn to protect<br/>
					yet powerless to. I couldn’t even face my dreams with that knowledge.<br/><br/>
					I expect that my search for the real answers won’t end here...<br/><br/><br/>
					Regards,]]></screen>
							</caption>
						</node>
					</captions>
				</script>;
				
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}