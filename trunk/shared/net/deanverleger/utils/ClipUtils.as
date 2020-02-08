package net.deanverleger.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	import net.strangerdreams.engine.scene.data.HoverType;
	import net.strangerdreams.engine.scene.data.NodeObject;
	
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	public class ClipUtils
	{
		public static function stopClips(... rest):void
		{
			for(var i:uint = 0; i < rest.length; i++)
				MovieClip(rest[i]).stop();
		}
		
		public static function buttonRollSets( rollOverHandler:Function, rollOutHandler:Function, ... buttons):Dictionary
		{
			var sets:Dictionary = new Dictionary(true);
			if ( sets == null )
				sets = new Dictionary(true);
			var button:DisplayObjectContainer;
			for(var i:uint = 0; i < buttons.length; i++)
			{
				button = DisplayObjectContainer(buttons[i]);
				var set:InteractiveObjectSignalSet = new InteractiveObjectSignalSet( button );
				sets[ button ] = set;
				set.mouseOver.add(rollOverHandler);
				set.mouseOut.add(rollOutHandler);
			}
			
			return sets;
		}
		
		public static function nodeObjectRollSets( rollOverFunct:Function, rollOutFunct:Function, nodeObjects:Dictionary, asset:MovieClip ):Dictionary
		{
			var sets:Dictionary = new Dictionary(true);	
			if ( sets == null )
				sets = new Dictionary(true);
			for ( var k:Object in nodeObjects )
			{
				var nObject:NodeObject = nodeObjects[k];
				if (nObject.hoverType != HoverType.NONE) {
					var dispObject:DisplayObjectContainer = asset[k] as DisplayObjectContainer;
					var set:InteractiveObjectSignalSet = new InteractiveObjectSignalSet(dispObject);
					set.mouseOver.add(rollOverFunct);
					set.mouseOut.add(rollOutFunct);
					sets[dispObject] = set;
				}
			}
			
			return sets;
		}
		
		public static function addNodeObjectSetsClickCallback( callback:Function, nodeObjectSets:Dictionary):void
		{
			for ( var k:Object in nodeObjectSets )
			{
				var objectSet:InteractiveObjectSignalSet = nodeObjectSets[k];
				objectSet.click.add( callback );
			}
		}
		
		public static function emptyNodeObjectSets( nodeObjectSets:Dictionary ):void
		{
			for ( var k:Object in nodeObjectSets )
			{
				InteractiveObjectSignalSet(nodeObjectSets[k]).removeAll();
				nodeObjectSets[k] = null;
				delete nodeObjectSets[k];
			}
			nodeObjectSets = null;
		}
		
		public static function addNativeSignalCallback( callback:Function, ... signals):void
		{
			for(var i:uint = 0; i < signals.length; i++)
				NativeSignal(signals[i]).add(callback);
		}
		
		public static function makeVisible( ... dispObjects ):void
		{
			for(var i:uint = 0; i < dispObjects.length; i++)
			{
				DisplayObject(dispObjects[i]).alpha = 1;
				DisplayObject(dispObjects[i]).visible = true;
			}
		}
		
		public static function makeInvisible( ... dispObjects ):void
		{
			for(var i:uint = 0; i < dispObjects.length; i++)
			{
				DisplayObject(dispObjects[i]).alpha = 0;
				DisplayObject(dispObjects[i]).visible = false;
			}
		}
		
		public static function hide( ... dispObjects ):void
		{
			for(var i:uint = 0; i < dispObjects.length; i++)
			{
				DisplayObject(dispObjects[i]).alpha = 0;
				DisplayObject(dispObjects[i]).visible = true;
			}
		}
		
		public static function hideChildren( container:DisplayObjectContainer, setInvisible:Boolean = true ):void
		{
			var disp:DisplayObject;
			for(var i:uint = 0; i < container.numChildren; i++)
			{
				disp = DisplayObject(container.getChildAt(i));
				disp.visible = setInvisible;
				disp.alpha = 0;
			}
		}
	}
}