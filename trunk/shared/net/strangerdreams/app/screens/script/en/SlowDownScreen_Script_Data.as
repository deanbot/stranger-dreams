package net.strangerdreams.app.screens.script.en
{
	import net.deanverleger.data.IXMLObject;

	public class SlowDownScreen_Script_Data implements IXMLObject
	{
		private var _xml:XML
		public function SlowDownScreen_Script_Data() 
		{
			_xml = <script>
					<captions>
						<caption key="slow" comment="not used, it's a graphic">
				When playing Stranger Dreams, we ask that you slow down, sit
				back, and enjoy the experience of the game. There are many
				clues and secrets to be found, and we want you to get as much
				enjoyment out of unfolding the story as we had creating it. 
						</caption>
					</captions>
				</script>;
		}

		public function get xml():XML
		{
			return _xml;
		}

	}
}