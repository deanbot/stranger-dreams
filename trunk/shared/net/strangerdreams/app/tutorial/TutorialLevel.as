package net.strangerdreams.app.tutorial
{
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Sprite;
	
	import net.deanverleger.core.IDestroyable;
	import net.deanverleger.utils.AssetUtils;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.app.gui.UI;
	import net.strangerdreams.app.gui.ViewPort;
	import net.strangerdreams.app.tutorial.config.TutorialScriptLanguageConfig;
	import net.strangerdreams.app.tutorial.enumeration.SceneEnumeration;
	import net.strangerdreams.app.tutorial.scene.TutorialSceneOrder;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.location.LocationNodeManager;
	
	public class TutorialLevel extends Sprite
	{
		// constants:
		private static const TUTORIAL_SCRIPT_ID:String = "BensApartment";
		
		// private properties:
		private var se:StoryEngine;
		private var ui:UI;
		private var viewPort:ViewPort
		private var moveTo:uint;
		private var miniGame:MovieClip;
		private var miniGameActive:Boolean;
		private var isFirstNode:Boolean;
		private var miniGameReturn:Boolean = false;
		private var movementDirection:String;
		private var moving:Boolean = false;
		//enumeration
		private var sceneEnumeration:SceneEnumeration;
		
		// public properties:
		// constructor:
		public function TutorialLevel()
		{
			SEConfig.transitionTime = .3;
			SEConfig.globalVolume = .85;
			//SEConfig.globalVolume = 0;
			SEConfig.uiVolumeOffset = .85;
			SEConfig.musicVolumeOffset = .85;
			SEConfig.ambientVolumeOffset = .85;
			addChild( viewPort = new ViewPort() );
			viewPort.load();
			ui = new UI();
			
			se = new StoryEngine( new TutorialSceneOrder(), new TutorialScriptLanguageConfig() );
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
			if(se.scriptID==TUTORIAL_SCRIPT_ID)
				SEConfig.isTutorial=true;
			
			SESignalBroadcaster.sceneEndReached.addOnce(onSceneFinished);
			if ( se.sceneUsesHUD ) {
				viewPort.setUI( ui );
				
				SESignalBroadcaster.calculateCompassCommand.add(updateCompassArrows);
				SESignalBroadcaster.miniGameEnter.add( onMiniGameCommand );
				SESignalBroadcaster.changeNode.add(onForcedMove);
				ui.compassArrowClicked.add( onCompassArrowClicked );
				ui.forcedMove.add( onForcedMove );		
				
				ui.load();
				
			} else {
				MouseIconHandler.init();
				SESignalBroadcaster.changeNode.add(onForcedMove);
			}
			isFirstNode = true;
			updateViewPort();
		}
		
		private function onSceneFinished():void
		{
			viewPort.fadeAction.addOnce( function(b:Boolean):void{ trace("hello"); unloadScene(); } );
			viewPort.fadeOut();
		}
		
		private function unloadScene():void
		{
			if(se.scriptID==TUTORIAL_SCRIPT_ID)
				SEConfig.isTutorial=false;
			
			se.unloadCurrentScene();
			if ( se.sceneUsesHUD ) {
				viewPort.unsetUI();
				ui.unload();
			}
			viewPort.unsetFrame();
			se.progressScene();
			se.sceneLoaded.addOnce( onSceneLoaded );
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
					moving=false;
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
		
		private function onCompassArrowClicked( arrowDirection:String ):void
		{
			if ( se.getIsValidMovement(arrowDirection) && !moving) 
			{
				moving=true;
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