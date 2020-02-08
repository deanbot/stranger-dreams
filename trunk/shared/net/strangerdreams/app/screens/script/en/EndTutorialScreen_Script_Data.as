package net.strangerdreams.app.screens.script.en
{
	import net.deanverleger.data.IXMLObject;
	
	public class EndTutorialScreen_Script_Data implements IXMLObject
	{
		private var _xml:XML;
		
		public function EndTutorialScreen_Script_Data()
		{
			_xml = <script>
					<captions>
						<caption key="frameText">Crisp air, birds chirping, and a sparkling body of water surrounded by lush trees. These first impressions of Mabel as the train rolled into the station were all but overshadowed by the towering monoliths of an oppressive city miles away in the mountains above - growing not outward, but upward, reaching through the trees and the fog like an unwelcome sore upon the natural landscape.</caption>
					</captions>
				</script>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}