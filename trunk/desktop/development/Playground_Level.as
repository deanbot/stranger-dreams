package development
{	
	
	import development.scene.PlaygroundSceneOrder;
	import development.scene.Playground_Scene_Data;
	import development.scene.locationnodes.Node1;
	import development.scene.locationnodes.Node2;
	import development.scene.locationnodes.Node3;
	import development.scene.locationnodes.Node4;
	import development.script.PlaygroundScriptLanguageConfig;
	import development.script.en.Playground_Script_Data;
	import development.sound.PlaygroundSoundObjects;
	
	import flash.display.MovieClip;
	import flash.display.Screen;
	import flash.display.Sprite;
	
	import net.deanverleger.core.IDestroyable;
	import net.deanverleger.utils.AssetUtils;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.app.gui.UI;
	import net.strangerdreams.app.gui.ViewPort;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.location.LocationNodeManager;
	import net.strangerdreams.engine.scene.SceneOrder;
	import net.strangerdreams.engine.scene.data.CompassArrowDirection;
	
	import org.osflash.signals.Signal;
	
	public class Playground_Level extends Sprite
	{
		// constants:
		// private properties:
		private var se:StoryEngine;
		private var appSceneOrder:PlaygroundSceneOrder;
		private var appScriptLanguageConfig:PlaygroundScriptLanguageConfig;
		private var ui:UI;
		private var viewPort:ViewPort;
		private var moveTo:uint;
		private var miniGame:MovieClip;
		private var miniGameActive:Boolean;
		private var isFirstNode:Boolean;
		private var miniGameReturn:Boolean = false;
		private var movementDirection:String;
		//enumeration
		private var pgSoundObjects:PlaygroundSoundObjects;
		private var pgScene:Playground_Scene_Data;
		private var pgScript:Playground_Script_Data;
		private var node1:Node1;
		private var node2:Node2;
		private var node3:Node3;
		private var node4:Node4;
		
		// public properties:
		// constructor:
		public function Playground_Level( testing:Boolean = false )
		{
			SEConfig.transitionTime = .3;
			SEConfig.globalVolume = .85;
			SEConfig.uiVolumeOffset = .85;
			SEConfig.musicVolumeOffset = .5;
			SEConfig.ambientVolumeOffset = .85;
			addChild( viewPort = new ViewPort(true) );
			viewPort.load();
			ui = new UI();
			
			se = new StoryEngine( appSceneOrder = new PlaygroundSceneOrder(), appScriptLanguageConfig = new PlaygroundScriptLanguageConfig );
			se.sceneLoaded.addOnce( onSceneLoaded );
			se.loadCurrentScene();
		}
		
		// public getter/setters:
		// public methods:
		// private methods:
		/**
		 * Load UI and set up the viewports movieclip
		 * 
		 */
		private function onSceneLoaded():void
		{	
			se.sceneFinished.addOnce( onSceneFinished );
			if ( se.sceneUsesHUD ) {
				viewPort.setUI( ui );
				
				SESignalBroadcaster.calculateCompassCommand.add(updateCompassArrows);
				SESignalBroadcaster.miniGameEnter.add( onMiniGameCommand );
				ui.compassArrowClicked.add( onCompassArrowClicked );
				ui.forcedMove.add( onForcedMove );
				
				ui.load();
			} else {
				MouseIconHandler.init();
			}
			isFirstNode = true;
			updateViewPort();
		}
		
		private function onSceneFinished():void
		{
			viewPort.fadeAction.addOnce( unloadScene );
			viewPort.fadeOut();
		}
		
		private function unloadScene():void
		{
			se.unloadCurrentScene();
			viewPort.unsetUI();
			ui.unload();
			se.progressScene();
			se.loadCurrentScene();
		}
		
		private function updateCompassArrows():void
		{
			ui.setUpArrowControls( se.activeCompassDirections );
		}
		
		private function updateViewPort():void
		{
			if ( miniGameActive ) {
				viewPort.setActiveFrame( miniGame );
			} else {
				viewPort.setActiveFrame( se.getLocationNodeAsset( StoryEngine.currentNode ) );
				if ( se.sceneUsesHUD ) {
					//ui.setUpArrowControls( se.activeCompassDirections );
					ui.setCompassNeedleDegrees( se.getCurrentLocationNodeDegrees() );
				}
			}
			// because it's dark to begin with
			if ( !isFirstNode )
				viewPort.fadeAction.addOnce( onViewPortFadeAction );
			else
				isFirstNode = false;
			viewPort.fadeIn();
		}
		
		private function onViewPortFadeAction( frameVisible:Boolean ):void
		{
			if ( frameVisible ) {
				if ( se.sceneUsesHUD ) {
					working=false;
					ui.working = false;
					ui.checkRollOver();
				}
			} else {
				if ( se.sceneUsesHUD )
					ui.resetHud();
				if ( miniGameActive )
					ui.hideHUD();
				viewPort.frameRemoved.addOnce( onFrameRemoved );
				viewPort.unsetFrame();
			}
		}
		
		private var working:Boolean = false;
		private function onCompassArrowClicked( arrowDirection:String ):void
		{
			if ( se.getIsValidMovement(arrowDirection) && !working) 
			{
				working=true;
				movementDirection = arrowDirection;
				StoryEngine.destinationNode = se.getMovementDirectionNode(movementDirection);
				if (se.sceneUsesHUD)
					ui.working = true;
				LocationNodeManager.getLocationNode(StoryEngine.currentNode).manageSoundTransitions();
				viewPort.fadeAction.addOnce( onViewPortFadeAction );
				viewPort.fadeOut();
			}
		}
		
		private function onForcedMove( nodeID:uint ):void
		{
			if ( se.getIsValidNode( nodeID ) ) 
			{
				moveTo = nodeID;
				StoryEngine.destinationNode = int(nodeID);
				if (se.sceneUsesHUD)
					ui.working = true;
				LocationNodeManager.getLocationNode(StoryEngine.currentNode).manageSoundTransitions();
				viewPort.fadeAction.addOnce( onViewPortFadeAction );
				viewPort.fadeOut();
			}
		}
		
		private function onMiniGameCommand( miniGameClass:String ):void
		{
			//trace( miniGameClass );
			if( !miniGameActive) 
			{
				miniGame = AssetUtils.getAssetInstance( miniGameClass ) as MovieClip;
				if (miniGame != null ) 
				{
					StoryEngine.destinationNode = -1;
					miniGameActive = true;
					SESignalBroadcaster.miniGameExit.addOnce(onMiniGameExit);
					if (se.sceneUsesHUD)
						ui.working = true;
					viewPort.fadeAction.addOnce( onViewPortFadeAction );
					viewPort.fadeOut();
				}
			}
		}
		
		private function onMiniGameExit():void
		{
			if ( miniGameActive )
			{
				miniGameActive = false;
				if (se.sceneUsesHUD) {
					ui.working = true;
					ui.setUpArrowControls( se.activeCompassDirections);
				}
				viewPort.fadeAction.addOnce( onViewPortFadeAction );
				viewPort.fadeOut();
			}
		}
		
		private function onFrameRemoved():void
		{
			if ( !miniGameActive && miniGame != null) {
				IDestroyable(miniGame).destroy();
				miniGame = null;
				if (se.sceneUsesHUD)
					ui.revealHUD();
			} else if (!miniGameActive)
				se.unloadCurrentFrame();
				
			if (!miniGameActive) 
			{
				if ( movementDirection != null ) {
					se.moveInDirection( movementDirection );
					movementDirection = null;
				} else if ( moveTo != 0 ) {
					se.moveTo( moveTo);
					moveTo = 0;
				}
			}
			updateViewPort();
		}
	}
}