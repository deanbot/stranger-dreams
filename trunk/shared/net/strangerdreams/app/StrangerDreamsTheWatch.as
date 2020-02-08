package net.strangerdreams.app
{
	import com.greensock.TweenLite;
	import com.gskinner.utils.FrameScriptManager;
	
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.deanverleger.core.IDestroyable;
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.app.gui.NotificationDisplay;
	import net.strangerdreams.app.gui.UI;
	import net.strangerdreams.app.gui.ViewPort;
	import net.strangerdreams.app.keyboard.SEAuxKeyboardListener;
	import net.strangerdreams.app.keyboard.SEHotkeyListener;
	import net.strangerdreams.app.master.MasterEnumeration;
	import net.strangerdreams.app.master.MasterSceneOrder;
	import net.strangerdreams.app.master.MasterScriptLanguageConfig;
	import net.strangerdreams.app.tutorial.config.TutorialScriptLanguageConfig;
	import net.strangerdreams.app.tutorial.enumeration.SceneEnumeration;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.location.LocationNodeManager;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	public class StrangerDreamsTheWatch extends Sprite
	{
		// constants:
		public static const LOCATION:String = "StrangerDreamsTheWatch";
		private static const TUTORIAL_SCRIPT_ID:String = "BensApartment";
		
		// private properties:
		private var sceneOrder:MasterSceneOrder;
		private var addedToStage:NativeSignal;
		private var se:StoryEngine;
		private var ui:UI;
		private var viewPort:ViewPort;
		private var moveTo:uint;
		private var miniGame:MovieClip;
		private var miniGameActive:Boolean;
		private var isFirstNode:Boolean;
		private var noTransition:Boolean;
		private var miniGameReturn:Boolean = false;
		private var movementDirection:String;
		private var moving:Boolean = false;
		private var sceneUnloadDelay:Timer;
		private var onSceneUnloadDelayed:NativeSignal;
		private var _quitToMainMenu:Signal;
		private var _quitGame:Signal;
		private var _destroyed:Signal;
		private var _destroy:Boolean;
		
		//enumeration
		private var masterEnumeration:MasterEnumeration;
		
		public function StrangerDreamsTheWatch()
		{
			addedToStage = new NativeSignal(this,Event.ADDED_TO_STAGE, Event);
			addedToStage.addOnce(onStage);
			_quitToMainMenu = new Signal();
			_destroyed = new Signal();
			_quitGame = new Signal();
			_destroy = false;
			SESignalBroadcaster.quitToMain.addOnce(onQuitToMain);
			SESignalBroadcaster.quitGame.addOnce(onQuitGame);
			SEBetaBroadcaster.betaEndReached.addOnce(onBetaEndreached);
		}
		
		public function get quitGame():Signal
		{
			return _quitGame;
		}

		public function get quitToMainMenu():Signal
		{
			return _quitToMainMenu;
		}

		public function get destroyed():Signal
		{
			return _destroyed;
		}

		public function destroy():void
		{
			if(!_destroy)
			{
				_destroy = true;
				sceneOrder = null;
				if(addedToStage!=null)
					addedToStage.removeAll();
				addedToStage = null;
				if(ui!=null)
					ui.destroy();
				ui = null;
				if(viewPort!=null)
					viewPort.destroy();
				viewPort = null;
				moveTo = 0;
				miniGame = null;
				miniGameActive = isFirstNode = noTransition = miniGameReturn = moving = false;
				movementDirection = "";
				SEHotkeyListener.deactivate();
				if(onSceneUnloadDelayed!=null)
					onSceneUnloadDelayed.removeAll();
				onSceneUnloadDelayed = null;
				sceneUnloadDelay = null
				if(_quitToMainMenu !=null)
					_quitToMainMenu.removeAll();
				_quitToMainMenu = null;
				_destroyed.dispatch();
				se.destroyed.addOnce(onStoryEngineDestroyed);
				se.destroy();
			}
		}

		private function onStage(e:Event):void
		{
			SEConfig.transitionTime = .3;
			SEConfig.globalVolume = 1;
			//SEConfig.globalVolume = 0;
			SEConfig.uiVolumeOffset = 1;
			//SEConfig.musicVolumeOffset = .35;
			SEConfig.musicVolumeOffset = .5;
			SEConfig.ambientVolumeOffset = .8;
			//SEConfig.muted=true;
			addChild( viewPort = new ViewPort() );
			viewPort.load();
			ui = new UI();
			SEHotkeyListener.stageRef = this.stage;
			SEAuxKeyboardListener.stageRef = this.stage;
			
			se = new StoryEngine( sceneOrder = new MasterSceneOrder(), new MasterScriptLanguageConfig() );
			se.sceneLoaded.addOnce( onSceneLoaded );
			
			se.loadCurrentScene();
		}
		
		private var thanksForPlaying:ThanksForPlayingBeta;
		private var fsm:FrameScriptManager;
		private function onBetaEndreached():void
		{
			addChild( thanksForPlaying = new ThanksForPlayingBeta() );
			fsm = new FrameScriptManager(thanksForPlaying);
			fsm.setFrameScript(thanksForPlaying.totalFrames,onThanksFinished);
			fsm.setFrameScript(15,startFading);
		}
		
		private function startFading():void
		{
			viewPort.fadeOut(8);
		}
		
		private var thanksTimer:Timer;
		private var onThanksTimer:NativeSignal;
		private function onThanksFinished():void
		{
			thanksForPlaying.stop();
			fsm = null;
			thanksTimer = new Timer(2000);
			onThanksTimer = new NativeSignal(thanksTimer,TimerEvent.TIMER,TimerEvent);
			onThanksTimer.addOnce(onThanksTimerFinished);
			thanksTimer.start();
		}
		
		private function onThanksTimerFinished(e:TimerEvent):void
		{
			onThanksTimer = null;
			thanksTimer = null;
			thanksForPlaying.cacheAsBitmap = true;
			TweenLite.to(thanksForPlaying,5, {alpha: 0, onComplete:onThanksFaded});
		}
		
		private function onThanksFaded():void
		{
			removeChild(thanksForPlaying);
			thanksForPlaying = null;
			onQuitGame();
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
			//LoggingUtils.msgTrace("",LOCATION+".onSceneLoaded()");
			if(se.scriptID==TUTORIAL_SCRIPT_ID)
			{
				SEConfig.isTutorial=true;
				SEConfig.hasMap=false;
				SEHotkeyListener.haltInventory();
				SEHotkeyListener.haltJournal();
				SETutorialBroadcaster.briefcasePickedUp.addOnce(SEHotkeyListener.resumeInventory);
				SETutorialBroadcaster.journalPickedUp.addOnce(SEHotkeyListener.resumeJournal);
			}

			activateHotkeys();
			
			SESignalBroadcaster.sceneEndReached.addOnce(onSceneFinished);
			SESignalBroadcaster.noTransition.addOnce(onNoTransition);
			SESignalBroadcaster.changeNode.add(onForcedMove);
			if ( se.sceneUsesHUD ) {
				viewPort.setUI( ui );
				
				SESignalBroadcaster.calculateCompassCommand.add(updateCompass);
				SESignalBroadcaster.miniGameEnter.add( onMiniGameCommand );
				SEHotkeyListener.moveLeftKeyPressed.add( function():void { onKeyMove("W"); } );
				SEHotkeyListener.moveUpKeyPressed.add( function():void { onKeyMove("N"); } );
				SEHotkeyListener.moveRightKeyPressed.add( function():void { onKeyMove("E"); } );
				SEHotkeyListener.moveDownKeyPressed.add( function():void { onKeyMove("S"); } );
				ui.compassArrowClicked.add( onCompassArrowClicked );
				ui.forcedMove.add( onForcedMove );
				ui.load();
				SEConfig.currentArrowDegrees = 0;
				SEConfig.currentMapArrowLocation = "";
			} else {
				MouseIconHandler.init();
				SESignalBroadcaster.calculateCompassCommand.add(updateCompass);
			}
			isFirstNode = true;
			noTransition = false;
			updateViewPort();
		}
		
		private function onSceneFinished():void
		{
			if(!noTransition)
			{
				viewPort.fadeAction.addOnce( function(b:Boolean):void{ unloadScene(); } );
				viewPort.fadeOut();
			} else
				unloadScene();
		}
		
		
		private function unloadScene():void
		{
			if(se.scriptID==TUTORIAL_SCRIPT_ID)
				SEConfig.isTutorial=false;
			
			if ( se.sceneUsesHUD ) {
				SESignalBroadcaster.calculateCompassCommand.remove(updateCompass);
				viewPort.unsetUI();
				ui.unload();
			} else
				SESignalBroadcaster.calculateCompassCommand.remove(updateCompass);
			StoryEngine.unload = true;
			viewPort.unsetFrame();
			
			if(sceneUnloadDelay == null)
				sceneUnloadDelay = new Timer(2500);
			if(onSceneUnloadDelayed == null)
				onSceneUnloadDelayed = new NativeSignal(sceneUnloadDelay,TimerEvent.TIMER,TimerEvent);
			onSceneUnloadDelayed.addOnce( function(e:TimerEvent):void
			{
				sceneUnloadDelay.stop();
				se.unloadCurrentScene();
				se.progressScene();
				if(se.currentScene >= sceneOrder.sceneOrder.length)
				{
					onQuitGame();
					return;
				}
				se.sceneLoaded.addOnce( onSceneLoaded );
				se.loadCurrentScene();
			});
			sceneUnloadDelay.start();
		}
		
		/*
		private function updateCompassArrows():void
		{
			ui.setUpArrowControls( se.activeCompassDirections );
		}*/
		
		private function updateViewPort():void
		{
			//LoggingUtils.msgTrace("",LOCATION+".updateViewPort()");
			if ( miniGameActive ) {
				viewPort.setActiveFrame( miniGame );
			} else {
				viewPort.setActiveFrame( se.getLocationNodeAsset( StoryEngine.currentNode ) );
			}
			
			if(!noTransition)
			{
				// because it's dark to begin with
				if ( !isFirstNode )
					viewPort.fadeAction.addOnce( onViewPortFadeAction );
				else
					isFirstNode = false;
				viewPort.fadeIn();
			} else
			{
				viewPort.skipFadeIn();
				noTransition = false;
			}
			/*if (se.sceneUsesHUD)
				ui.notificationDisplay.resume();*/
		}

		private function onViewPortFadeAction( frameVisible:Boolean ):void
		{
			if ( frameVisible ) {
				activateHotkeys();
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
		
		private function onFrameRemoved():void
		{
			//LoggingUtils.msgTrace("Frame was Removed",LOCATION);
			if ( !miniGameActive && miniGame != null) {
				IDestroyable(miniGame).destroy();
				miniGame = null;
				if (se.sceneUsesHUD)
					ui.revealHUD();
			} else if (!miniGameActive)
				//se.unloadCurrentFrame();
			
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
		
		private function onCompassArrowClicked( arrowDirection:String ):void
		{
			if ( se.getIsValidMovement(arrowDirection) && !moving) 
			{
				if( se.getEventInsteadOfMovement(arrowDirection) )
				{
					SESignalBroadcaster.compassDirectionClicked.dispatch(arrowDirection);
				} else
				{
					moving=true;
					movementDirection = arrowDirection;
					StoryEngine.destinationNode = se.getMovementDirectionNode(movementDirection);
					if (se.sceneUsesHUD)
					{
						ui.working = true;
						//ui.notificationDisplay.pause();
					}
					pauseHotkeys();
					viewPort.fadeAction.addOnce( onViewPortFadeAction );
					if(!noTransition)
						viewPort.fadeOut();
					else
						viewPort.skipFadeOut();
				}
			}
		}
		
		private function onKeyMove( movementDirection:String ):void
		{
			onCompassArrowClicked( movementDirection );
		}
		
		private function onForcedMove( nodeID:uint ):void
		{
			if ( se.getIsValidNode( nodeID ) ) 
			{
				moving=true;
				moveTo = nodeID;
				StoryEngine.destinationNode = int(nodeID);
				if (se.sceneUsesHUD)
				{
					ui.working = true;
					//ui.notificationDisplay.pause();
				}
				//LocationNodeManager.getLocationNode(StoryEngine.currentNode).manageSoundTransitions();
				pauseHotkeys();
				viewPort.fadeAction.addOnce( onViewPortFadeAction );
				if(!noTransition)
					viewPort.fadeOut();
				else
					viewPort.skipFadeOut();
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
					{
						ui.working = true;
						ui.notificationDisplay.pause();
					}
					pauseHotkeys();
					viewPort.fadeAction.addOnce( onViewPortFadeAction );
					if (!noTransition)
						viewPort.fadeOut();
					else
						viewPort.skipFadeOut();
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
					//ui.notificationDisplay.pause();
					ui.setUpArrowControls( se.activeCompassDirections);
				} 
				viewPort.fadeAction.addOnce( onViewPortFadeAction );
				if(!noTransition)
					viewPort.fadeOut();
				else
					viewPort.skipFadeOut();
			}
		}
		
		private function updateCompass():void
		{
			SEConfig.currentArrowDegrees = se.getCurrentLocationNodeDegrees();
			SEConfig.currentMapArrowLocation = se.getCurrentLocationNodeMapLocation();
			ui.setCompassNeedleDegrees( se.getCurrentLocationNodeDegrees() );
			ui.setUpArrowControls( se.activeCompassDirections );
		}
		
		private function pauseHotkeys():void
		{
			//LoggingUtils.msgTrace("pauseHotkeys()",LOCATION);
			if(SEHotkeyListener.status == SEHotkeyListener.STATUS_ACTIVE)
				SEHotkeyListener.halt();
		}
		
		private function activateHotkeys():void
		{
			//LoggingUtils.msgTrace("activateHotkeys()",LOCATION);
			if(SEHotkeyListener.status == SEHotkeyListener.STATUS_INACTIVE)
				if(!SEHotkeyListener.ready)
					SEHotkeyListener.activate();
				else
					SEHotkeyListener.resume();
		}
		
		private function onQuitToMain():void
		{
			if(!noTransition)
			{
				viewPort.fadeAction.addOnce( function(b:Boolean):void{ unloadToMain(); } );
				viewPort.fadeOut();
			} else
				unloadToMain();
		}
		
		private function onQuitGame():void
		{
			exit();
		}
		
		private function onNoTransition():void
		{
			noTransition = true;	
		}

		private function unloadToMain():void
		{
			if(se.scriptID==TUTORIAL_SCRIPT_ID)
				SEConfig.isTutorial=false;
			
			if ( se.sceneUsesHUD ) {
				SESignalBroadcaster.calculateCompassCommand.remove(updateCompass);
				viewPort.unsetUI();
				ui.unload();
			}
			StoryEngine.unload = true;
			viewPort.unsetFrame();
			
			if(sceneUnloadDelay == null)
				sceneUnloadDelay = new Timer(2500);
			if(onSceneUnloadDelayed == null)
				onSceneUnloadDelayed = new NativeSignal(sceneUnloadDelay,TimerEvent.TIMER,TimerEvent);
			onSceneUnloadDelayed.addOnce( function(e:TimerEvent):void
			{
				sceneUnloadDelay.stop();
				se.unloadCurrentScene();
				_quitToMainMenu.dispatch();
			});
			sceneUnloadDelay.start();
		}
		
		private function exit():void
		{
			if( se == null)
				return;
			if ( se.sceneUsesHUD ) {
				SESignalBroadcaster.calculateCompassCommand.remove(updateCompass);
				viewPort.unsetUI();
				ui.unload();
			}
			StoryEngine.unload = true;
			viewPort.unsetFrame();
			se.unloadCurrentScene();
			_quitGame.dispatch();
			_quitGame.removeAll();
			_quitGame = null;
		}
		
		private function onStoryEngineDestroyed():void
		{
			se = null;
			_destroyed.dispatch();
			_destroyed.removeAll();
			_destroyed = null;
		}
		
	}
}