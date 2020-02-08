package net.deanverleger.gui
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import net.deanverleger.utils.LoggingUtils;
	
	import org.osflash.signals.Signal;
	
	/**
	 * InteractiveSurfaceScroller
	 * Currently breaks if you change the size, scale, or positon of surfaceSprite, maskRect, thumbnail, or thumbnailScroller after initializing.
	 * 
	 */	
	public class InteractiveSurfaceScroller extends Sprite
	{
		private var a1:Sprite;
		private var b1:Shape;
		private var a2:Sprite;
		private var b2:Sprite;
		private var rect:Rectangle; // scroll rect
		private var left:Number;
		private var top:Number;
		private var offsetX:Number;
		private var offsetY:Number;
		
		private var mouseOffStage:Boolean;
		private var drag:Boolean;
		private var _stage:Stage;
		private var _mouseOut:Signal;
		private var _mouseOver:Signal;
		private var _mouseDown:Signal;
		
		public function get mouseDown():Signal
		{
			return _mouseDown;
		}

		public function get mouseOver():Signal
		{
			return _mouseOver;
		}
		
		public function get mouseOut():Signal
		{
			return _mouseOut;
		}
		
		/**
		 * 
		 * @param surfaceSprite full size surface to scroll
		 * @param maskRect shape that is masking surface
		 * @param thumbnail smaller surface to scroll (controller background)
		 * @param thumbnailScroller viewport sprite to act as a handle (controller)
		 * 
		 */
		public function InteractiveSurfaceScroller()
		{
			super();
			init();
		}
		
		public function setData(surfaceSprite:Sprite, maskRect:Shape, thumbnail:Sprite, thumbnailScroller:Sprite, xOffset:Number = 0, yOffset:Number = 0, stage:Stage = null):void
		{
			_stage = stage;
			a1 = surfaceSprite;
			a2 = thumbnail;
			b1 = maskRect;
			b2 = thumbnailScroller;
			offsetX = xOffset;
			offsetY = yOffset;

			rect = new Rectangle( thumbnail.x, thumbnailScroller.y, thumbnail.width - thumbnailScroller.width, thumbnail.height - thumbnailScroller.height);
			
			left = surfaceSprite.x;
			top = surfaceSprite.y;
			a1w = a1.width - offsetX;
			a1h = a1.height - offsetY;
			a2w = a2.width;
			a2h = a2.height;
			b1w = b1.width;
			b1h = b1.height;
			b2w = b2.width;
			b2h = b2.height;
		}
		
		public function activate():void
		{
			b2.addEventListener(MouseEvent.MOUSE_DOWN, initDrag, false, 0, true);
			b2.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverScrubber, false, 0, true);
			b2.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutScrubber, false, 0, true);
		}
		
		public function deactivate():void
		{
			endDrag();
			b2.removeEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			b2.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverScrubber);
			b2.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutScrubber);
		}
		
		public function destroy():void
		{
			deactivate();

			if(_stage!=null)
			{
				if(_stage.hasEventListener(MouseEvent.MOUSE_UP))
				{
					_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
					_stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
					_stage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
				}
			}
			
			_mouseOut.removeAll();
			_mouseOver.removeAll();
			_mouseOut = _mouseOver = null;
			mouseOffStage = false;
			
			_stage = null;
			a1 = a2 = b2 = null;
			rect = null
			b1 = null;
			offsetX = offsetY = left = top = a1w = a1h = a2w = a2h = b1w = b1h = b2w = b2h = 0;
		}
		
		private function init():void
		{
			_mouseOut = new Signal();
			_mouseOver = new Signal();
			_mouseDown = new Signal();
		}
		
		/**
		 * Start the dragging and scrolling.
		 * 
		 * @param e MouseEvent MOUSE_DOWN
		 * 
		 */
		private function initDrag(e:MouseEvent):void
		{
			mouseOffStage = false;
			mouseDown.dispatch();
			drag = true;
			
			this.addEventListener( Event.ENTER_FRAME, scrollSurface, false, 0, true );
			this.b2.startDrag( false, rect );
			
			if(_stage!=null)
			{
				_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				_stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false, 0, true);
				_stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
				_stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			}	
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			//trace("Mouse Up On Stage")
			endDrag();
		}
		
		private function onMouseLeave(e:Event):void
		{
			if(mouseOffStage){
				//trace("mouse up and off stage");
				endDrag();
			}else{
				//trace("mouse has left the stage");
				//no reason to stop drag here as the user hasn't released the mouse yet
			}
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			mouseOffStage = true;
			//trace("mouse has left the stage");
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			mouseOffStage = false;
			//trace("mouse has come back on stage");
		}
		
		private var overScrubber:Boolean;
		private function onMouseOverScrubber(e:MouseEvent):void
		{
			overScrubber = true;
			this.mouseOver.dispatch();
		}
		
		private function onMouseOutScrubber(e:MouseEvent):void
		{
			overScrubber = false;
			if(!drag)
				this.mouseOut.dispatch();
		}
		
		/**
		 * Stop the dragging and scrolling.
		 * 
		 * @param e MouseEvent MOUSE_UP
		 * 
		 */
		private function endDrag():void
		{
			drag = false;
			
			this.b2.stopDrag();
			this.removeEventListener(Event.ENTER_FRAME, scrollSurface);
			if(!overScrubber)
			{
				this.mouseOut.dispatch();
			}
		}
		
		/**
		 * Scroll the surface.
		 * Calculate the distance or x value of the thumbnail scroller assuming it's point of origin is at (0,0) of the thumbnail
		 * Calculate the percentage of the total width (x values) or height (y values) to the left or the top of the thumbnail scroller
		 * 
		 * @param e Envent Enter_Frame
		 */
		private var relX:Number; 
		private var relY:Number;
		private var perX:Number;
		private var perY:Number;
		private var a1w:Number;
		private var a1h:Number;
		private var a2w:Number;
		private var a2h:Number;
		private var b1w:Number;
		private var b1h:Number;
		private var b2w:Number;
		private var b2h:Number;
		private function scrollSurface(e:Event):void 
		{
			//get relative x of scroller
			relX = b2.x - a2.x;
			relY = b2.y - a2.y;
			//get percentage of total x or y
			perX = relX / (a2w - b2w);
			perY = relY / (a2h - b2h);
			//set the surface
			a1.x = left - (perX * (a1w - b1w));
			a1.y = top - (perY * (a1h - b1h));
		}
	}
}