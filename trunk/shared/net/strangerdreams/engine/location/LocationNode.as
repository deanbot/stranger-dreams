package net.strangerdreams.engine.location
{
	import com.gskinner.utils.FrameScriptManager;
	import com.meekgeek.statemachines.finite.events.StateManagerEvent;
	import com.meekgeek.statemachines.finite.manager.StateManager;
	import com.meekgeek.statemachines.finite.manager.StateManagerStatus;
	
	import development.StoryEngineConfig;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.AssetUtils;
	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.deanverleger.utils.VectorUtils;
	import net.strangerdreams.app.gui.MouseIconHandler;
	import net.strangerdreams.app.state.OutroState;
	import net.strangerdreams.engine.SEConfig;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.events.EventManager;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.scene.StorySceneManager;
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.scene.data.Node;
	import net.strangerdreams.engine.scene.data.NodeObject;
	import net.strangerdreams.engine.scene.data.NodeObjectType;
	import net.strangerdreams.engine.scene.data.NodeState;
	import net.strangerdreams.engine.script.StoryScriptManager;
	import net.strangerdreams.engine.script.data.Caption;
	import net.strangerdreams.engine.sound.SoundInstructionManager;
	import net.strangerdreams.engine.sound.SoundUtils;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class LocationNode implements ILocationNode
	{
		// constants:
		public static const LOCATION:String = "Location Node";
		// private properties:
		private var _nodeDataRef:Node;
		private var _asset:MovieClip;
		private var _sm:StateManager;
		private var _loaded:Boolean;
		private var assetAddedToStage:NativeSignal;
		private var assetRemovedFromStage:NativeSignal;
		private var stateIntroStart:NativeSignal;
		private var stateIntroComplete:NativeSignal;
		private var stateOutroStart:NativeSignal;
		private var stateAction:NativeSignal;
		private var _stopFrameReached:Signal;
		private var fsm:FrameScriptManager;
		private var _currentStateKey:String;
		private var nodeObjectSets:Dictionary;
		private var _freshNode:Boolean;
		private var _preparedForUnload:Boolean;
		private var _destroyed:Signal;
		private var _isDestroyed:Boolean = false;
		
		// public properties:
		// constructor:
		public function LocationNode()
		{
			
		}
		
		// public getter/setters:
		public function get destroyed():Signal
		{
			return _destroyed;
		}
		/*
		public function get preparedForUnload():Signal
		{
		return _preparedForUnload;
		}*/
		
		public function get soundInstructionKey():String
		{
			return this._nodeDataRef.soundInstructionKey;
		}
		
		public function get currentStateKey():String
		{
			return _currentStateKey;
		}
		
		public function get asset():MovieClip
		{
			return _asset;
		}
		
		public function get dialogTrees():Dictionary
		{
			return _nodeDataRef.dialogTrees;
		}
		
		public function get sm():StateManager
		{
			return _sm;
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get stopFrameReached():Signal 
		{ 
			return _stopFrameReached; 
		}
		
		public function get currentState():NodeState 
		{ 
			return this._nodeDataRef.nodeStates[currentStateKey] as NodeState; 
		}
		
		/**
		 * 
		 * @return the state destined to land on
		 * 
		 */
		public function get destinationState():NodeState
		{
			var theState:NodeState = null;
			var stateKey:String;
			if(!StoryEngine.unload)
			{
				if(_nodeDataRef.numNodeStates > 1)
				{
					var states:Vector.<NodeState> = new Vector.<NodeState>;
					for ( var k:Object in _nodeDataRef.nodeStates )
					{
						// add all states with priority
						if ( NodeState(_nodeDataRef.nodeStates[k]).priority != 0 )
							states.push( NodeState(_nodeDataRef.nodeStates[k]) );
					}
					var statesSorted:Vector.<NodeState>;
					// sort by priority
					if( states.length > 0 )
						statesSorted = Vector.<NodeState>(VectorUtils.sortOn(states, "priority", Array.NUMERIC));
					
					if (statesSorted != null) {
						var matchFound:Boolean = false;
						var counter:uint=0;
						while(!matchFound || counter < statesSorted.length)
						{
							if( statesSorted[counter].flagRequirement != "" )
							{
								if( FlagManager.getHasFlag(statesSorted[counter].flagRequirement) )
								{
									matchFound = true;
									break;
								}
							} else {
								matchFound = true;
								break;
							}
							counter++;
						}
						if(matchFound)
							theState = statesSorted[counter];
					}
				} else
				{
					for ( var key:Object in _nodeDataRef.nodeStates )
						theState = _nodeDataRef.nodeStates[key];
				}
			}
			return theState;
		}
		
		// public methods:
		/**
		 * Loads asset into memory and adds to stage. Wait for assetAdded Signal before referencing.
		 */
		public function load():void
		{
			if (_nodeDataRef == null)
				throw Error( 'Node data object not set' );
			if (!_loaded) {
				_destroyed = new Signal();
				if( _nodeDataRef.assetClass != "")
					_asset = AssetUtils.getAssetInstance( _nodeDataRef.assetClass ) as MovieClip;
				else 
					_asset = new MovieClip();
				assetAddedToStage = new NativeSignal( _asset, Event.ADDED_TO_STAGE, Event );
				assetRemovedFromStage = new NativeSignal( _asset, Event.REMOVED_FROM_STAGE, Event );
				assetAddedToStage.addOnce(  onAssetAddedToStage );
				assetRemovedFromStage.addOnce( onAssetRemoved );
				
				_sm = new StateManager( _asset );
				stateIntroStart = new NativeSignal( _sm, StateManagerEvent.ON_INTRO_START, StateManagerEvent );
				stateIntroComplete = new NativeSignal( _sm, StateManagerEvent.ON_INTRO_COMPLETE, StateManagerEvent );
				stateAction = new NativeSignal( _sm, StateManagerEvent.ON_ACTION, StateManagerEvent );
				stateOutroStart = new NativeSignal( _sm, StateManagerEvent.ON_OUTRO_START, StateManagerEvent );
				stateIntroStart.addOnce( onStateIntroStart );
				
				SESignalBroadcaster.updateState.add(onUpdateStateInitiated);
				
				_loaded = true;
				_isDestroyed = false;
			}
		}
		
		public function setData( node:Node ):void
		{
			_nodeDataRef = node;
		}
		
		/**
		 * Null all data. Prepping for garbage collection
		 */
		public function destroy(slow:Boolean = true):void
		{
			if(_isDestroyed == true)
				return;
			_isDestroyed=true;
			if(slow)
			{
				if(_sm !=null)
				{
					_sm.setState(OutroState.KEY);
					LoggingUtils.msgTrace("LOOK! ("+_sm.getState()+") you want to do the outro state now ",LOCATION);
				}
			}
			//LoggingUtils.msgTrace("Destroying",LOCATION + "-" + this._nodeDataRef.implementationClass);
			unload();
		}
		
		public function updateNodeObjects():void
		{
			detachNodeObjectSignals();
			attachNodeObjectSignals();
		}
		
		public function updateState():void
		{
			LoggingUtils.msgTrace("updateState: "+_nodeDataRef.implementationClass, LOCATION);
			if(_loaded == false)
			{ LoggingUtils.msgTrace("ERROR: Calling updateState when node is not loaded",LOCATION); return; }
			// check if has more than one state
			var stateKey:String;
			var theState:NodeState;
			if (this._nodeDataRef.numNodeStates > 1) 
			{
				theState = this.destinationState;
				if (theState != null) 
				{
					stateKey = theState.key;
					// queue changeState if statekey exists and is different than current state
					if (stateKey != null) 
					{
						if (stateKey != sm.getState()) 
						{
							if(sm.status!=null)
							{
								if(sm.status.code==2)
								{
									LoggingUtils.msgTrace("Change State to " + stateKey, LOCATION + ".updateState()");
									changeState(stateKey);
								} //else
								LoggingUtils.msgTrace("Statemanager not in standby, ignoring change state (" + stateKey + ")", LOCATION + ".updateState()");
							}
						} else
						{
							onStateIntroStart( new StateManagerEvent(StateManagerEvent.ON_INTRO_START) );
						}	
					} else 
						LoggingUtils.msgTrace("State key is null", LOCATION + ".updateState()");
				}
			} else {
				theState = this.destinationState;
				if (theState != null) 
				{
					stateKey = theState.key;
					// queue changeState if statekey exists and is different than current state
					if (stateKey != null) 
					{
						if (stateKey != sm.getState()) 
						{
							if(sm.status!=null)
							{
								if(sm.status.code==2)
								{
									LoggingUtils.msgTrace("Change State to " + stateKey, LOCATION + ".updateState()");
									changeState(stateKey);
								} //else
								LoggingUtils.msgTrace("Statemanager not in standby, ignoring change state (" + stateKey + ")", LOCATION + ".updateState()");
							}
						} else
						{
							onStateIntroStart( new StateManagerEvent(StateManagerEvent.ON_INTRO_START) );
						}	
					} else 
						LoggingUtils.msgTrace("State key is null", LOCATION + ".updateState()");
				}
			}
		}
		
		// private methods:
		private function onAssetAddedToStage( e:Event ):void
		{
			_freshNode=true;
			//figure out correct state based on flags using static class
			INodeImplementor(this).loadStates(this.destinationState.key);
			this.sm.addState(OutroState.KEY,new OutroState());
			calculateState();
		}
		
		private function calculateState():void
		{
			// check if has more than one state
			if (this._nodeDataRef.numNodeStates > 1) 
			{
				var theState:NodeState = this.destinationState;
				if (theState != null) 
				{
					var stateKey:String = theState.key;
					// queue changeState if statekey exists and is different than current state
					if (stateKey != null) 
						if (stateKey != sm.getState()) 
							stateAction.addOnce( function():void { changeState(stateKey); } );	
				}
			}
		}
		
		public function changeState( key:String ):void
		{
			if ( sm.getState() != key )
				if ( sm.hasState(key) )
				{
					stateIntroStart.addOnce( onStateIntroStart );
					/*stateIntroComplete.addOnce( onStateIntroComplete);
					//stateOutroStart.addOnce( onStateOutroStart );*/
					//if the state is internal queue leaveInternalState
					sm.setState( key );
				} //else 
			//throw new Error("Location Node has no state: " + key + " and can't change to state.");
		}
		
		private function configureFrameActions(theState:NodeState):void
		{
			_stopFrameReached = new Signal();
			fsm = new FrameScriptManager(_asset);
			
			var startFrame:String = theState.startFrame;
			var stopFrame:String = theState.stopFrame;
			var loopStart:String = theState.loopStart;
			var loopEnd:String = theState.loopEnd;
			
			//remove previous stopframe actions
			if( _stopFrameReached.numListeners > 0)
				stopFrameReached.removeAll();
			
			//if next state configured queue change state at stop frame marker
			if ( theState.nextState ) 
				_stopFrameReached.addOnce( function():void { changeState(theState.nextState); } );
			
			//can't have both a stopframe and a loopend, only one.
			if (stopFrame && loopEnd)
				trace(" Warning: Location Node [" + _nodeDataRef.id + "] state " + theState.key + " has both a stopFrame and loopEnd." );
			
			//set up stop frame marker actions
			if (stopFrame) {
				if (startFrame) {
					if ( fsm.getFrameNumber(startFrame) != fsm.getFrameNumber(stopFrame) )
						fsm.setFrameScript( stopFrame, function():void { _asset.stop(); _stopFrameReached.dispatch(); } );
					else
						fsm.setFrameScript( stopFrame, _asset.stop );
				} else { 
					// (assume that it's one)
					if ( fsm.getFrameNumber(stopFrame) != 1 )
						fsm.setFrameScript( stopFrame, function():void { _asset.stop(); _stopFrameReached.dispatch(); } );
					else
						fsm.setFrameScript( 1, _asset.stop )
				}
			}
			
			//set up loop marker to loop or stop at loopEnd marker
			if (loopEnd) {
				if (loopStart) {
					if ( fsm.getFrameNumber(loopEnd) != fsm.getFrameNumber(loopStart) )
						fsm.setFrameScript( loopEnd, function():void { _asset.gotoAndPlay(loopStart); } );
					else
						fsm.setFrameScript( loopEnd, _asset.stop );
					
				} else if (startFrame) {
					if ( fsm.getFrameNumber(loopEnd) != fsm.getFrameNumber(startFrame) )
						fsm.setFrameScript( loopEnd, function():void { _asset.gotoAndPlay(startFrame); } );
					else
						fsm.setFrameScript( loopEnd, _asset.stop );
				} else {
					// (assume that it should go back to one)
					if ( fsm.getFrameNumber(loopEnd) != 1 )
						fsm.setFrameScript( loopEnd, function():void { _asset.gotoAndPlay(1); } );
					else
						fsm.setFrameScript( 1,_asset.stop );
				}
			}
			
			//stop movieclip at it's start frame if it doesn't have a loop end or stop frame
			if (startFrame)
				if (!loopEnd && !stopFrame)
					fsm.setFrameScript( startFrame, _asset.stop );
			
			//send movieclip to appropriate start frame or stop if no start frame
			if (startFrame)
				_asset.gotoAndPlay( startFrame );
			else if (loopStart)
				_asset.gotoAndPlay( loopStart );
			else if (_asset.totalFrames<100)	
				_asset.stop();
		}
		
		/**
		 *  
		 */
		private function onStateIntroStart( e:StateManagerEvent ):void
		{
			if(e.key != null)
				_currentStateKey = e.key;
			var theState:NodeState = this.currentState;
			
			var frameReadyCommands:Function = function():void
			{
				//LoggingUtils.msgTrace(" the state: " + theState.key + ", dest state: " + StoryEngine.currentLocationNodeImp.destinationState.key, LOCATION);
				/*if(theState != StoryEngine.currentLocationNodeImp.destinationState)
				updateState();
				else { */
				//LoggingUtils.msgTrace("Issuing Frame Ready Commands",LOCATION);
				if( theState.hasTriggeredObjectAtStart ) 
				{
					var nodeObject:NodeObject = NodeObject(theState.nodeObjects[theState.triggeredObjectName]);
					var hasFlagRequirements:Boolean = true;
					var flagRequirements:Array = nodeObject.flagRequirements;
					if(flagRequirements.length>0)
						for (var i:uint=0; i<flagRequirements.length; i++)
							if (!FlagManager.getHasFlag(String(flagRequirements[i])) )
								hasFlagRequirements=false;
					
					if(nodeObject.antiFlagRequirement)
						if (FlagManager.getHasFlag(nodeObject.antiFlagRequirement) )
							hasFlagRequirements=false;
					
					
					if(hasFlagRequirements)
					{
						if(nodeObject.type==NodeObjectType.CAPTION)
						{
							//LoggingUtils.msgTrace("Triggering Node Object Caption",LOCATION);
							//SESignalBroadcaster.blockToggle.dispatch(false);
							SESignalBroadcaster.captionTriggered.dispatch(nodeObject,_freshNode);
						} else if(nodeObject.type==NodeObjectType.DIALOG)
						{
							//LoggingUtils.msgTrace("Triggering Node Object Dialog, freshnode:" + _freshNode,LOCATION);
							//SESignalBroadcaster.blockToggle.dispatch(false);
							SESignalBroadcaster.dialogTriggered.dispatch(_nodeDataRef.dialogTrees[String(nodeObject.dialogKey)],nodeObject,_freshNode);
						} else if(nodeObject.type==NodeObjectType.SAVE)
						{
							//SESignalBroadcaster.blockToggle.dispatch(false);
							var tempCaption:Caption = Caption(StoryScriptManager.getCaptionInstance("saveGame"));
							var saveText:String = (tempCaption != null)? tempCaption.text : "Save Game?";
							tempCaption = Caption(StoryScriptManager.getCaptionInstance("yes"));
							var yesText:String = (tempCaption != null)? tempCaption.text : "Yes";
							tempCaption = Caption(StoryScriptManager.getCaptionInstance("no"));
							var noText:String = (tempCaption != null)? tempCaption.text : "No";
							SESignalBroadcaster.saveTriggered.dispatch(saveText, yesText, noText);
						}
					}
				}
				
				if ( theState.numNodeObjects > 0 )
				{
					stateOutroStart.addOnce(function(e:StateManagerEvent):void { 
						//LoggingUtils.msgTrace("Removing Node Object Signals",LOCATION+".stateOutroStart()-via frameReadyCommands()");
						detachNodeObjectSignals();
						//preparedForUnload.dispatch();
					});
					attachNodeObjectSignals();
				}
				
				if(_freshNode)
					_freshNode=false;
				//}
			};
			
			var framePreparationCommands:Function = function():void {
				//LoggingUtils.msgTrace("Issuing Frame Preparation Commands",LOCATION);
				//show compass back if an 'internal' node state
				
				configureFrameActions(theState);
				
				// activate state level sound instructions or node level sound instrucitons
				if(_nodeDataRef.soundInstructionKey=="")
				{
					if(theState.soundInstructionKey!=null)
						SoundInstructionManager.activateSoundInstruction(theState.soundInstructionKey);
				} else 
					SoundInstructionManager.activateSoundInstruction(_nodeDataRef.soundInstructionKey);
				
				stateOutroStart.addOnce(function(e:StateManagerEvent):void {
					//LoggingUtils.msgTrace("Managing Sound Transitions",LOCATION+".stateOutroStart()-via framePreparationCommands()");
					manageSoundTransitions();
				} );
				
				//hide the mouse if necessary.
				if(theState.hideMouse)
					MouseIconHandler.hideMouse();
				else
					MouseIconHandler.showMouse();
				
				if(StorySceneManager.useHUD)
				{
					//hide ui if necessary.
					if(theState.hideHUD)
						SESignalBroadcaster.hideHUD.dispatch(false);
					else
						SESignalBroadcaster.showHUD.dispatch(false);
					
					//show the compass back if necessary.
					if ( theState.internalState ) {
						SESignalBroadcaster.enterInternalState.dispatch();
						stateOutroStart.addOnce(function(e:StateManagerEvent):void { 
							SESignalBroadcaster.leaveInternalState.dispatch(); 
						});
					}
				}
				//update compass needle and arrows
				SESignalBroadcaster.calculateCompassCommand.dispatch();
			}
			
			// if event manager has events do events 'before' frame commands 
			if(EventManager.hasEvents)
			{
				//trace(theState.key + " has events and freshness: " +_freshNode);
				LoggingUtils.msgTrace("Event manager has events for ("+theState.key+"), it will do transition commands or frame commands",LOCATION);
				SESignalBroadcaster.blockToggle.dispatch(true);
				//LoggingUtils.msgTrace("Issuing Events",LOCATION);
				EventManager.doEvents(framePreparationCommands,frameReadyCommands,_freshNode);
			} else 
			{
				//LoggingUtils.msgTrace("No events for ("+theState.key+"). Doing transition commands and then frame commands",LOCATION);
				
				framePreparationCommands();
				stateIntroComplete.addOnce(function(e:StateManagerEvent):void { 
					frameReadyCommands(); 
				});
			}
		}
		
		private function manageSoundTransitions():void
		{
			//if necessary (changing to a new node sound or music group) fade sound groups
			//temporarily fading out immediately for minigames
			if (StoryEngine.destinationNode != -1)
			{
				if (SoundUtils.playingMusic || SoundUtils.playingAmbient)
					SoundInstructionManager.manageSoundChannelRemoval(this, (StoryEngine.destinationNode != 0) ? LocationNodeManager.getLocationNode(StoryEngine.destinationNode) : null);
			} 
			else
			{
				if (SoundUtils.playingMusic)
				{
					//LoggingUtils.msgTrace("Playing Music.",LOCATION);
					SoundUtils.fadeMusicChannels(0,SEConfig.transitionTime*2,true);
				} //else
				//LoggingUtils.msgTrace("Not playing Music.",LOCATION);
				if (SoundUtils.playingAmbient)
				{
					//LoggingUtils.msgTrace("Playing Ambient.",LOCATION);
					SoundUtils.fadeAmbientChannels(0,SEConfig.transitionTime*2,true);
				} //else
				//LoggingUtils.msgTrace("Not playing Ambient.",LOCATION);
			}
		}
		
		private function onAssetRemoved(e:Event):void
		{
			//LoggingUtils.msgTrace("Asset Removed",LOCATION);
			stateAction.addOnce( function(e:StateManagerEvent):void {
				//LoggingUtils.msgTrace("stateAction from onAssetRemoved",LOCATION);
				unload();
			});
			sm.setState(OutroState.KEY);
		}
		
		/**
		 * Removes asset from stage and memory 
		 */
		private function unload():void
		{
			_isDestroyed=true;
			//LoggingUtils.msgTrace("",LOCATION+".unload()");
			SESignalBroadcaster.updateState.remove(onUpdateStateInitiated);
			detachNodeObjectSignals();
			_asset = null;
			if(_sm!=null)
				_sm.destroy();
			_sm = null;
			fsm = null;
			if(stateIntroStart!=null)
				stateIntroStart.removeAll();
			if(stateIntroComplete!=null)
				stateIntroComplete.removeAll();
			if(stateAction!=null)
				stateAction.removeAll();
			if(stateOutroStart!=null)
				stateOutroStart.removeAll();
			if(assetRemovedFromStage!=null)
				assetRemovedFromStage.removeAll();
			if(assetAddedToStage!=null)
				assetAddedToStage.removeAll();
			if(_stopFrameReached!=null)
				_stopFrameReached.removeAll();
			stateIntroStart = stateIntroComplete = stateAction = stateOutroStart = null;
			assetRemovedFromStage = assetAddedToStage = null;
			_stopFrameReached = null;
			_currentStateKey = null;
			_loaded = false;
			if(_destroyed!=null)
			{
				this.destroyed.dispatch();
				//_destroyed.removeAll();
				//_destroyed=null;
			}
		}
		
		private function attachNodeObjectSignals():void
		{
			var theState:NodeState = this.currentState;
			if ( theState.numNodeObjects > 0 ) {
				nodeObjectSets = ClipUtils.nodeObjectRollSets( onNodeObjectRollOver, onNodeObjectRollOut, theState.nodeObjects, _asset );
				ClipUtils.addNodeObjectSetsClickCallback( onNodeObjectClick, nodeObjectSets );
			}
		}
		
		private function detachNodeObjectSignals():void
		{
			if( nodeObjectSets!=null )
				ClipUtils.emptyNodeObjectSets(nodeObjectSets);
			nodeObjectSets = null;
		}
		
		private function onNodeObjectClick( e:MouseEvent ):void
		{
			if(sm.status==StateManagerStatus.STANDBY)
			{
				var theState:NodeState = this.currentState;
				var theObject:NodeObject = theState.nodeObjects[e.target.name] as NodeObject;
				SESignalBroadcaster.interactiveClick.dispatch( theObject );
			}
		}
		
		private function onNodeObjectRollOver( e:MouseEvent ):void
		{
			var i:uint;
			var theState:NodeState = this.currentState;
			// if object has flag and a hovertype of inspect, but the object type is interact then use interact hover
			var flagReqsMet:Boolean = true;
			var theObject:NodeObject = theState.nodeObjects[e.target.name] as NodeObject;
			if ( theObject.hoverType != theObject.type )
				if ( theObject.flagRequirements.length>0 )
					if(!FlagManager.getHasFlagRequirements(theObject.flagRequirements))
						flagReqsMet = false;
			
			if ( theObject.flagRequirements.length>0 )
				if (flagReqsMet)
					SESignalBroadcaster.interactiveRollOver.dispatch( theObject.type );
				else 
					SESignalBroadcaster.interactiveRollOver.dispatch( theObject.hoverType );
			else 
				SESignalBroadcaster.interactiveRollOver.dispatch( theObject.hoverType );
			
			theObject = null;
		}
		
		private function onNodeObjectRollOut( e:MouseEvent ):void
		{
			SESignalBroadcaster.interactiveRollOut.dispatch();
		}
		
		private function onUpdateStateInitiated():void
		{
			LoggingUtils.msgTrace("Update State Initiated",LOCATION);
			updateState();
		}
	}
}