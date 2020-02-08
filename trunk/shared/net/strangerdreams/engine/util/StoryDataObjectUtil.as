package net.strangerdreams.engine.util
{
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.scene.data.Node;
	import net.strangerdreams.engine.sound.SoundObjectType;
	import net.strangerdreams.engine.sound.data.SoundInstruction;
	import net.strangerdreams.engine.sound.data.SoundObject;

	public class StoryDataObjectUtil
	{		
		/**
		 * Processes xml data, creating scene data objects
		 * 
		 * @param sceneData XML - the scene data to process
		 * @return Object - Story Scene Processed Data Object
		 */
		public static function processStoryScene( sceneData:XML ):Object
		{
			var nodes:Dictionary = new Dictionary(true);
			var numNodes:uint = 0;
			for each( var node:XML in sceneData.nodes.node )
			{
				var nodeObject:Node = new Node();
				nodeObject.setData( node );
				nodes[uint(node.@id)] = nodeObject;
				numNodes++;
			}
			//trace( "Story Scene Util says, \"Processed " + numNodes + " nodes.\"" );
			var storyScene:Object = new Object();
			storyScene["config"] = String(sceneData.config.text());
			storyScene["nodes"] = nodes;
			storyScene["scriptPackage"] = String(sceneData.scriptPackage.text());
			storyScene["scriptID"] = String(sceneData.scriptID.text()); 
			storyScene["implementationPackage"] = String(sceneData.implementationPackage.text());
			storyScene["defaultNode"] = uint(sceneData.defaultNode.text());
			storyScene["useHUD"] = ( String(sceneData.useHUD.text()) == "true" ) ? true : false;
			storyScene["numElements"] = numNodes;
			storyScene["soundInstructions"] = sceneData.soundInstructions;
			storyScene["soundObjects"] = sceneData.soundObjects;
			storyScene["items"] = sceneData.items;
			storyScene["goals"] = sceneData.goals;
			storyScene["events"] = sceneData.events;
			storyScene["notes"] = sceneData.notes;
			storyScene["characters"] = sceneData.characters;
			//trace( "Story Scene Util says, \"Start with node: " + storyScene["defaultNode"] + ".\"" );
			return storyScene;
		}
		
		public static function procesStoryScript( scriptData:XML ):Object
		{
			var storyScript:Object = new Object();
			
			return storyScript;
		}
	}
}