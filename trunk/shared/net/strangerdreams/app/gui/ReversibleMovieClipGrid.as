package net.strangerdreams.app.gui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.LoggingUtils;
	import net.strangerdreams.engine.SESignalBroadcaster;
	import net.strangerdreams.engine.StoryEngine;
	import net.strangerdreams.engine.flag.FlagManager;
	import net.strangerdreams.engine.location.LocationNode;
	import net.strangerdreams.engine.location.LocationNodeManager;
	import net.strangerdreams.engine.scene.data.NodeObject;
	import net.strangerdreams.engine.scene.data.NodeState;
	
	import org.casalib.display.ReversibleMovieClip;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;
	
	public class ReversibleMovieClipGrid extends Sprite
	{
		public var tweenTime : Number = 0.2;
		public var itemAlphaOff : Number = 0.7;
		
		public function get itemUsed():Signal
		{
			return _itemUsed;
		}

		public function set permit(value:Boolean):void
		{
			_permit = value;
		}

		public function get permit():Boolean
		{
			return _permit;
		}

		public function get numCells() : int
		{
			return _rows * _cols;
		}
		
		private var _rows : int;
		private var _cols : int;
		private var _padd : int;
		private var _rowSize : int;
		private var _colSize : int;
		private var _index : Array;
		private var _items : Array;
		private var _numItems : int;
		private var _dictionary : Dictionary;
		private var _currentItem : ReversibleMovieClipWrapper;
		private var _itemSets : Dictionary;
		private var _stageMove:NativeSignal;
		//inventory hacks
		private var _briefcase : Boolean;
		private var _quickslots : Boolean;
		private static const INVENTORY_MENU:String = "inventory";
		public var removedFromInventory:Signal = new Signal( ReversibleMovieClipWrapper, Boolean );
		public var removedFromHud:Signal = new Signal( ReversibleMovieClipWrapper,Boolean );
		private var briefcaseColOffset:Number = 5;
		private var briefcaseColOffset2:Number = 5;
		private var briefcaseRowOffset:Number = 13;
		private var tempX:int;
		private var tempY:int;
		private var _permit:Boolean;
		private var _itemUsed:Signal;
				
		public function ReversibleMovieClipGrid(rows : int, cols : int, rowSize : int, colSize : int, padding : Number = 0, briefcase:Boolean=false, quickslots:Boolean=false)
		{
			_rows = rows;
			_cols = cols;
			_padd = padding;
			_rowSize = rowSize;
			_colSize = colSize;
			_numItems = 0;
			_briefcase = briefcase;
			_quickslots = quickslots;
			_itemUsed = new Signal( ReversibleMovieClipWrapper, String, String ); // item & acceptsItemKey & node object key
			
			initIndex();
		}
		
		public function addItem(item : ReversibleMovieClipWrapper) : ReversibleMovieClipWrapper
		{
			var col : int = _numItems % _cols;
			var row : int = Math.floor(_numItems / _cols);
			var itemVO : ShuffleGridItemVO = new ShuffleGridItemVO();
			var position : Point = getPosition(row, col);
			var itemSet : InteractiveObjectSignalSet = new InteractiveObjectSignalSet(item);
			
			itemVO.row = row;
			itemVO.col = col;
			itemVO.item = item;
			
			item.x = position.x;
			item.y = position.y;
			
			item.mouseEnabled = true;
			item.buttonMode = true;
			
			_itemSets[item]=itemSet;
			itemSet.mouseDown.add(onItemPress);
			itemSet.mouseUp.add(onItemRelease);
			
			addChild(item);
			
			_items.push(item);
			_index[row][col] = itemVO;
			_dictionary[item] = itemVO;
			_numItems++;
			
			return item;
		}
		
		public function addItemAt(item : ReversibleMovieClipWrapper, row:int, col:int, callback:Function=null,_position:Point=null) : ReversibleMovieClipWrapper
		{
			var col : int = col;
			var row : int = row;
			var itemVO : ShuffleGridItemVO = new ShuffleGridItemVO();
			var position : Point = getPosition(row, col);
			
			itemVO.row = row;
			itemVO.col = col;
			itemVO.item = item;
			
			if(callback==null&&_position==null)
			{
				item.x = position.x;
				item.y = position.y;
			} else if (_position!=null)
			{
				item.x = _position.x;
				item.y = _position.y;
			}
			
			if(item.name!="empty")
			{
				var itemSet : InteractiveObjectSignalSet = new InteractiveObjectSignalSet(item);
				item.mouseEnabled = true;
				item.buttonMode = true;
				
				_itemSets[item]=itemSet;
				itemSet.mouseDown.add(onItemPress);
				itemSet.mouseUp.add(onItemRelease);
			}
			
			addChild(item);
			
			_items.push(item);
			_index[row][col] = itemVO;
			_dictionary[item] = itemVO;
			_numItems++;
			
			if(callback!=null)
			{
				snapToGrid(itemVO,callback);
			}
			
			return item;
		}
		
		public function getItemAt(index : int) : ReversibleMovieClipWrapper
		{
			return _items[index];
		}
		
		public function getItemAtPosition(row : int, col : int) : ReversibleMovieClipWrapper
		{
			return ShuffleGridItemVO(_index[row][col]).item;
		}
		
		public function getItemVO(icon : ReversibleMovieClipWrapper) : ShuffleGridItemVO
		{
			return ShuffleGridItemVO(_dictionary[icon]);
		}
		
		public function destroy():void
		{
			var item: ReversibleMovieClipWrapper;
			while(item=_items.pop())
			{
				removeChild(item);
				if(item.name!="empty")
				{
					InteractiveObjectSignalSet(_itemSets[item]).removeAll();
					_itemSets[item]=null;
					delete _itemSets[item]
				}
				_dictionary[item]=null;
				delete _dictionary[item];
				item=null;
			}
			for ( var row:int = 0; row < _index.length; row++ )
			{
				for ( var column:int = 0; column < _index[row].length; column++ )
				{
					_index[row][column]=null;
				} 
			}
			if(_dictionary[INVENTORY_MENU] !=null)
				delete _dictionary[INVENTORY_MENU];
			_dictionary=_itemSets=null;
			_index=null;
			_numItems=0;
		}
		
		public function setInventoryRef(ref:Inventory_Menu):void
		{
			if(_dictionary[INVENTORY_MENU]==null)
				_dictionary[INVENTORY_MENU]=ref;
		}
		
		private function get invRef():Inventory_Menu
		{
			return Inventory_Menu(_dictionary[INVENTORY_MENU]);
		}
		
		private function initIndex() : void
		{
			_dictionary = new Dictionary();
			_itemSets = new Dictionary(true);
			_index = new Array(_rows);
			_items = [];
			
			for (var i : int = 0;i < _rows; i++)
			{
				_index[i] = new Array(_cols);
			}
		}
		
		private function shuffleItems() : void
		{
			if(_currentItem==null)
				return;
			var itemVO : ShuffleGridItemVO = _dictionary[_currentItem];
			if(itemVO==null)
				return;
			var cell : Point = getCell(_currentItem.x, _currentItem.y);
			
			var col : int = cell.x;
			var row : int = cell.y;
			
			if(col == itemVO.col && row == itemVO.row)
			{
				return;
			}
			
			var hMove : int = col - itemVO.col;
			var vMove : int = row - itemVO.row;
			
			var i : int;
			var item : ShuffleGridItemVO;
			var move : Array = [];
			
			// set drop darget item new item VO
			item = _index[row][col];
			item.row = itemVO.row;
			item.col = itemVO.col;
			_index[item.row][item.col]=item;
			move.push(item);
			
			// set current item new itemVO
			itemVO.row=row;
			itemVO.col=col;
			_index[itemVO.row][itemVO.col]=itemVO;
			
			for (i = 0;i < move.length; i++)
			{
				snapToGrid(move[i]);
			}
		}
		
		private function snapToGrid(item : ShuffleGridItemVO, callback:Function=null) : void
		{
			var pos : Point = getPosition(item.row, item.col);
			if(callback!=null)
				TweenLite.to(item.item, tweenTime, {x:pos.x, y:pos.y, ease:Expo.easeInOut, onComplete:callback});
			else
				TweenLite.to(item.item, tweenTime, {x:pos.x, y:pos.y, ease:Expo.easeInOut});
		}
		
		private function getPosition(row : int, col : int) : Point
		{
			//inventory hack
			var point:Point;
			if(_briefcase)
				point = new Point( (col * (_colSize + _padd) - ((col>1)?briefcaseColOffset:0) - ((col>2)?briefcaseColOffset2:0)), (row * (_rowSize + _padd) - ((row>0)?briefcaseRowOffset:0)) );
			else if (_quickslots)
				point = new Point(col * (_colSize + _padd), row * (_rowSize + _padd));
			else
				point = new Point(col * (_colSize + _padd), row * (_rowSize + _padd));
				
			return point;
		}
		
		public function getCell(x : Number, y : Number) : Point
		{
			var cell : Point = new Point();
			
			if(_briefcase)
			{
				cell.x = Math.max(0, Math.min(_cols - 1, Math.round(x / (_colSize + _padd))));
				cell.y = Math.max(0, Math.min(_rows - 1, Math.round(y / (_rowSize + _padd))));
			} else if (_quickslots)
			{
				cell.x = Math.max(0, Math.min(_cols - 1, Math.round(x / (_colSize + _padd))));
				cell.y = Math.max(0, Math.min(_rows - 1, Math.round((y-10) / (_rowSize + _padd))));
			} else 
			{
				cell.x = Math.max(0, Math.min(_cols - 1, Math.round(x / (_colSize + _padd))));
				cell.y = Math.max(0, Math.min(_rows - 1, Math.round(y / (_rowSize + _padd))));
			}
			
			return cell;
		}
		
		private function onItemMove(event : MouseEvent) : void
		{
			//shuffleItems();
		}
		
		private function onHUDItemMove(event : MouseEvent) : void
		{
			if(this.invRef.active)
			{
				if(this.invRef.hitTestPoint(invRef.mouseX-_currentItem.mouseX,invRef.mouseY))
				{
					if(_stageMove!=null)
						_stageMove.remove(onHUDItemMove);
					_stageMove=null;
					sendIcon();
				}
			}
		}
		
		private function onItemReleaseFromInventory(event : MouseEvent):void
		{
			var stagePoint:Point; 
			var spritePoint:Point;
			var icon:ReversibleMovieClipWrapper;
			var item:ShuffleGridItemVO;
			var set:InteractiveObjectSignalSet;
			if(this.invRef.padding.hitTestPoint(this.invRef.mouseX,this.invRef.mouseY))
			{
				//trace("overPadding");
				//find slot
				icon = _currentItem;
				icon.alpha = 1.0;
				icon.stopDrag();
				item = ShuffleGridItemVO(_dictionary[_currentItem]);
				set = InteractiveObjectSignalSet(_itemSets[icon]);
				set.mouseUp.remove(onItemReleaseFromInventory);
				var itemGrid:ReversibleMovieClipGrid = this.invRef.itemGrid;
				stagePoint = this.invRef.localToGlobal(new Point(this.invRef.mouseX, this.invRef.mouseY));
				spritePoint = itemGrid.globalToLocal(stagePoint);
				var hudCell:Point = itemGrid.getCell(spritePoint.x, spritePoint.y);
				spritePoint.x-=icon.mouseX;
				spritePoint.y-=icon.mouseY;
				
				var dropIcon:ReversibleMovieClipWrapper=itemGrid.getItemAtPosition(hudCell.y,hudCell.x);
				var itemVO:ShuffleGridItemVO = ShuffleGridItemVO(_dictionary[_currentItem]);
				var row:int = itemVO.row;
				var col:int = itemVO.col;
				
				stagePoint = itemGrid.localToGlobal(new Point(icon.x,icon.y));
				var invIconPoint:Point = this.globalToLocal(stagePoint);
				var invCallback:Function = function():void {
					itemGrid.removeIconRefs( hudCell.y,hudCell.x );
					itemGrid.removedFromInventory.dispatch( dropIcon, true);
				};
				var hudCallback:Function = function():void {
					removeIconRefs(itemVO.row, itemVO.col);
					removedFromHud.dispatch( icon, true );
				};
				if(dropIcon.name=="empty")
				{
					itemGrid.removeItemAt(hudCell.y,hudCell.x);
					itemGrid.addItemAt(icon,hudCell.y,hudCell.x,function():void{},spritePoint);
					hudCallback();
					var blank:ReversibleMovieClipWrapper=new ReversibleMovieClipWrapper( new MovieClip() );
					blank.name = "empty";
					addItemAt(blank,row,col);
				} else 
				{
					invCallback();
					hudCallback();
					
					itemGrid.addItemAt(icon,hudCell.y,hudCell.x,function():void{},spritePoint);
					
					stagePoint = this.invRef.hud.itemGrid.localToGlobal(new Point(tempX,tempY));
					spritePoint = this.invRef.itemGrid.globalToLocal(stagePoint);
					tempIcon=dropIcon;
					_tempItem=item;
					TweenLite.to(dropIcon,tweenTime,{x:spritePoint.x,y:spritePoint.y,onComplete:onDroppedTweenFinished});
				}
				_currentItem=null;
			} else {
				//send back
				icon = _currentItem;
				icon.alpha = 1.0;
				icon.stopDrag();
				set = InteractiveObjectSignalSet(_itemSets[icon]);
				set.mouseUp.remove(onItemReleaseFromInventory);
				stagePoint = this.invRef.hud.itemGrid.localToGlobal(new Point(tempX,tempY));
				spritePoint = this.invRef.globalToLocal(stagePoint);
				TweenLite.to(icon,tweenTime,{x:spritePoint.x,y:spritePoint.y,onComplete:onTweenToHudFinished});
			}
		}
		
		private static const TEMP_ICON:String="tempIcon";
		private var _tempItem:ShuffleGridItemVO;
		
		private function get tempIcon():ReversibleMovieClipWrapper 
		{ 
			return ReversibleMovieClipWrapper(_dictionary[TEMP_ICON]);
		}
		
		private function set tempIcon(value:ReversibleMovieClipWrapper):void	
		{
			_dictionary[TEMP_ICON]=value;
		}
		
		private function onDroppedTweenFinished():void
		{
			this.addItemAt(tempIcon,_tempItem.row,_tempItem.col,function():void{},new Point(tempX,tempY));
			delete _dictionary[TEMP_ICON];
			_tempItem=null;
			tempX=tempY=0;
		}
		
		private function onTweenToHudFinished():void
		{
			var stagePoint:Point; 
			var spritePoint:Point;
			var icon:ReversibleMovieClipWrapper;
			var item:ShuffleGridItemVO;
			var set:InteractiveObjectSignalSet;
			icon = _currentItem;
			set = InteractiveObjectSignalSet(_itemSets[icon]);
			set.mouseDown.add(onItemPress);
			set.mouseUp.add(onItemRelease);
			this.addChild(icon);
			icon.x=tempX;
			icon.y=tempY;
			tempX=tempY=0;
		}
		
		private function sendIcon():void
		{
			var hudMOIcon:ReversibleMovieClipWrapper = _currentItem;
			var stagePointHMO:Point = this.localToGlobal(new Point(hudMOIcon.x,hudMOIcon.y));
			var invIconPointHMO:Point = this.invRef.globalToLocal(stagePointHMO);
			hudMOIcon.x=invIconPointHMO.x;
			hudMOIcon.y=invIconPointHMO.y;
			this.invRef.addChild(hudMOIcon);
			var hudMOSet:InteractiveObjectSignalSet = InteractiveObjectSignalSet(_itemSets[_currentItem]); 
			hudMOSet.mouseOut.remove(onItemRelease);
			hudMOSet.mouseUp.remove(onItemRelease);
			hudMOSet.mouseUp.add(onItemReleaseFromInventory);
		}
		
		private function onItemRelease(event : MouseEvent) : void
		{
			if(_currentItem==null)
				return;
			if(this.invRef.active)
			{
				if(event.type==MouseEvent.MOUSE_OUT)
					if(_quickslots)
						if(this.invRef.hitTestPoint(invRef.mouseX-_currentItem.mouseX,invRef.mouseY))
						{
							return;
						}
			}
				
			var outBound:Boolean=false;
			if(_briefcase) // if inventory
			{
				if(this.invRef.hud.hitTestPoint(invRef.mouseX,invRef.mouseY))
				{
					//trace("over hud");
					if(this.invRef.hud.quick_slots_briefcase.hitTestPoint(invRef.mouseX,invRef.mouseY))
					{
						_currentItem.stopDrag();
						_currentItem.alpha = 1.0;
						InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.remove(onItemRelease);
						outBound=true;
						//trace("over quickslots");
						var itemGrid:ReversibleMovieClipGrid = this.invRef.hud.itemGrid;
						var stagePoint:Point = this.invRef.localToGlobal(new Point(this.invRef.mouseX, this.invRef.mouseY));
						var hudGridPoint:Point = itemGrid.globalToLocal(stagePoint);
						var hudCell:Point = itemGrid.getCell(hudGridPoint.x, hudGridPoint.y);
						hudGridPoint.x-=_currentItem.mouseX;
						hudGridPoint.y-=_currentItem.mouseY;
						
						var quickslotRow:int = hudCell.y;
						var icon:ReversibleMovieClipWrapper=itemGrid.getItemAtPosition(quickslotRow,0);
						var itemVO:ShuffleGridItemVO = ShuffleGridItemVO(_dictionary[_currentItem]);
						var row:int = itemVO.row;
						var col:int = itemVO.col;

						stagePoint = itemGrid.localToGlobal(new Point(icon.x,icon.y));
						var invIconPoint:Point = this.globalToLocal(stagePoint);
						var invCallback:Function = function():void {
							removeIconRefs( itemVO.row, itemVO.col );
							removedFromInventory.dispatch( itemVO.item, true);
						};
						var hudCallback:Function = function():void {
							itemGrid.removeIconRefs( quickslotRow,0 );
							itemGrid.removedFromHud.dispatch( icon, true );
						};
						if(icon.name=="empty")
						{
							itemGrid.removeItemAt(quickslotRow,0);
							itemGrid.addItemAt(_currentItem,quickslotRow,0,function():void{},hudGridPoint);
							invCallback();
							var blank:ReversibleMovieClipWrapper=new ReversibleMovieClipWrapper( new MovieClip() );
							blank.name = "empty";
							addItemAt(blank,row,col);
						} else 
						{
							invCallback();
							hudCallback();
							
							itemGrid.addItemAt(_currentItem,quickslotRow,0,function():void{},hudGridPoint);
							
							this.addItemAt(icon,itemVO.row,itemVO.col,function():void{},invIconPoint);
						}
						_currentItem=null;
					}
				}
				if(!outBound)
				{
					shuffleItems();
					_currentItem.alpha = 1.0;
					_currentItem.stopDrag();
					if(_itemSets[_currentItem]!=null)
						InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.remove(onItemRelease);
					snapToGrid(_dictionary[_currentItem]);
				}
			} else if (_quickslots)
			{
				shuffleItems();
				if(_itemSets[_currentItem]!=null)
					InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.remove(onItemRelease);
				_currentItem.alpha = 1.0;
				_currentItem.stopDrag();
				if(_stageMove!=null)
					_stageMove.remove(onHUDItemMove);
				_stageMove=null;
				snapToGrid(_dictionary[_currentItem]);
			} else {
				shuffleItems();
				if(_itemSets[_currentItem]!=null)
					InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.remove(onItemRelease);
				_currentItem.alpha = 1.0;
				_currentItem.stopDrag();
				snapToGrid(_dictionary[_currentItem]);
			}
		}
		
		private function onItemPress(event : MouseEvent) : void
		{
			if(!_permit)
				return;
			_currentItem = event.currentTarget as ReversibleMovieClipWrapper;
			if (_quickslots)
			{
				if(this.invRef.active)
				{
					tempX=_currentItem.x;
					tempY=_currentItem.y;
					_stageMove = new NativeSignal(stage, MouseEvent.MOUSE_MOVE, MouseEvent);
					_stageMove.add(onHUDItemMove);
					InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.add(onItemRelease);
				} else
				{
					node = StoryEngine.currentLocationNodeImp;
					
					if(node!=null)
					{
						asset = node.asset;
						var state:NodeState = node.currentState;
						if(state!=null)
						{
							var stateObjects:Dictionary = state.nodeObjects;
							objects = new Dictionary(true);
							for(var objKey:String in stateObjects)
							{
								if(NodeObject(stateObjects[objKey]).acceptsItem!="")
								{
									nodeHasItemObject=true;
									objects[objKey] = NodeObject(stateObjects[objKey]);
								}
							}
						}
					}
					if(nodeHasItemObject)
					{
						_stageMove = new NativeSignal(stage, MouseEvent.MOUSE_MOVE, MouseEvent);
						_stageMove.add(itemMoveStage);
						InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseUp.remove(onItemRelease);
						InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseUp.add(itemReleasedStage);
						InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.add(itemReleasedStage);
						mouseOverItem = "";
					} else {
						node = null;
						asset = null;
						objects = null;
						mouseOverItem = "";
						InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.add(onItemRelease);
					}
				}
			} else
			{
				InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.add(onItemRelease);
			}
			_currentItem.alpha = itemAlphaOff;
			_currentItem.startDrag();
			addChild(_currentItem);
		}
		
		public function itemReleasedStage(e:MouseEvent):void
		{
			var stagePoint:Point; 
			var spritePoint:Point;
			var item:ShuffleGridItemVO;
			var set:InteractiveObjectSignalSet;
			var itemRemoved:Boolean = false;
			if(mouseOverItem!="")
			{
				LoggingUtils.msgTrace( "mouse over item: " + mouseOverItem, "Item Grid");
				var nodeObject:NodeObject = NodeObject(objects[mouseOverItem]);
				_itemUsed.dispatch( ReversibleMovieClipWrapper( e.currentTarget ), nodeObject.acceptsItem, mouseOverItem );
				itemRemoved = nodeObject.itemRemoved;
			}
			if(!itemRemoved)
			{
				shuffleItems();
				if(_itemSets[_currentItem]!=null)
				{
					InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseOut.remove(itemReleasedStage);
					InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseUp.remove(itemReleasedStage);
					InteractiveObjectSignalSet(_itemSets[_currentItem]).mouseUp.add(onItemRelease);
				}
				if(_stageMove!=null)
					_stageMove.remove(itemMoveStage);
				_stageMove=null;
				_currentItem.alpha = 1.0;
				_currentItem.stopDrag();
				snapToGrid(_dictionary[_currentItem]);
			} else {
				_currentItem.stopDrag();
				item = ShuffleGridItemVO(_dictionary[_currentItem]);
				
				var itemVO:ShuffleGridItemVO = ShuffleGridItemVO(_dictionary[_currentItem]);
				var row:int = itemVO.row;
				var col:int = itemVO.col;
				
				removeItemAt(itemVO.row, itemVO.col);
				removedFromHud.dispatch( _currentItem, false );
				removeIconRefs(itemVO.row, itemVO.col);
				
				var blank:ReversibleMovieClipWrapper=new ReversibleMovieClipWrapper( new MovieClip() );
				blank.name = "empty";
				addItemAt(blank,row,col);
			}
			node = null;
			asset = null;
			if(objects!=null)
				DictionaryUtils.emptyDictionary(objects);
			objects = null;
			mouseOverItem = "";
		}
		
		private var node:LocationNode;
		private var asset:MovieClip;
		private var objects:Dictionary;
		private var nodeHasItemObject:Boolean;
		private var mouseOverItem:String;
		public function itemMoveStage(e:MouseEvent):void
		{
			var stageObject:MovieClip;
			if(node!=null)
			{
				if(objects!=null)
				{
					for(var objKey:String in objects)
					{
						stageObject = asset[objKey] as MovieClip;
						if(stageObject!=null)
						{
							if(stageObject.hitTestPoint(asset.mouseX,asset.mouseY))
							{
								mouseOverItem = objKey;
								
							} else if(mouseOverItem!=null)
							{
								if(mouseOverItem == objKey)
									mouseOverItem = "";
							}
							
						}
					}
				}
			}
			
			if(mouseOverItem != "")
				_currentItem.alpha = 1.0;
			else
				_currentItem.alpha = itemAlphaOff;
		}
		
		public function removeIconRefs(row:int, col:int):void
		{
			var item: ShuffleGridItemVO = ShuffleGridItemVO(_index[row][col]);
			var index:int = _items.indexOf( item.item );
			var icon : ReversibleMovieClipWrapper;
			if( index != -1)
			{
				icon = _items[index];
				_items.splice( index, 1 );
				if( icon!=null )
				{
					if(icon.name!="empty")
					{
						InteractiveObjectSignalSet(_itemSets[icon]).removeAll();
						_itemSets[icon]=null;
						delete _itemSets[icon]
					}
					_dictionary[icon]=null;
					delete _dictionary[icon];
					icon=null;
				}
			}
			_numItems--;
		}
		
		public function removeItemAt(row:int, col:int):void
		{
			var item: ShuffleGridItemVO = ShuffleGridItemVO(_index[row][col]);
			var index:int = _items.indexOf( item.item );
			var icon : ReversibleMovieClipWrapper;
			if( index != -1)
			{
				icon = _items[index];
				_items.splice( index, 1 );
				if( icon!=null )
				{
					if(this.contains(icon))
						removeChild(icon);
					if(icon.name!="empty")
					{
						InteractiveObjectSignalSet(_itemSets[icon]).removeAll();
						_itemSets[icon]=null;
						delete _itemSets[icon]
					}
					_dictionary[icon]=null;
					delete _dictionary[icon];
					icon=null;	
				}
			}
			_index[row][col] = null;
			_numItems--;
		}
	}
}

import net.strangerdreams.app.gui.ReversibleMovieClipWrapper;

internal class ShuffleGridItemVO
{
	public var row : int;
	public var col : int;
	public var item : ReversibleMovieClipWrapper;
}
