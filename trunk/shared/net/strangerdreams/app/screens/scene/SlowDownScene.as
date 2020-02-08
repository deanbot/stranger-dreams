package net.strangerdreams.app.screens.scene
{
	import net.deanverleger.data.IXMLObject;
	
	public class SlowDownScene implements IXMLObject
	{
		private var _xml:XML;
		
		public function SlowDownScene()
		{
			_xml = 
				<scene>
					<useHUD>false</useHUD>
					<scriptPackage>screens.script</scriptPackage>
					<scriptID>SlowDownScreen</scriptID>
					<config>net.strangerdreams.app.screens.config.ScreensScriptLanguageConfig</config>
					<defaultNode>1</defaultNode>
					<implementationPackage>net.strangerdreams.app.screens.imp</implementationPackage>
					<nodes>
						<node assetClass="SlowDownScreen" implementationClass="SlowDown" id="1">
							<states>
								<state key="Default" priority="1" hideMouse="true"/>
							</states>
						</node>
					</nodes>
				</scene>;
		}
		
		public function get xml():XML
		{
			return _xml;
		}
	}
}