package net.strangerdreams.app.screens.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class Chapter1Screen_Script_Data implements IXMLObject
	{
		private var _xml:XML;

		public function Chapter1Screen_Script_Data()
		{
			_xml=
				<script>
					<captions>
						<caption key="title">Chapter 1: The Watch</caption>
						<caption key="q1text">There is one stirring hour unknown to those who dwell in houses, when a wakeful influence goes abroad over the sleeping hemisphere, and all the outdoor world are on their feet.</caption>
						<caption key="q1auth">-Robert Louis Stevenson</caption>
						<caption key="q2text">The cave you fear to enter holds the treasure you seek.</caption>
						<caption key="q2auth">-Joseph Campbell</caption>.
					</captions>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}