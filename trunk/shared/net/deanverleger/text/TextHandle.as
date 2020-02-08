package net.deanverleger.text
{
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class TextHandle extends TextField
	{
		private var _format:TextFormat;
		
		public function TextHandle(_label:String, _size:uint = 11, _color:uint = 0xFFFFFF, _bold:Boolean = false, _align:String = TextFormatAlign.LEFT, _width:Number=0, _height:Number=0, _font:String="", _dropshadow:Boolean =false, _multiLine:Boolean=false, lineHeight:uint=0, html:Boolean = false) {
			_format = new TextFormat();
			if(_font!="")
				_format.font = _font;
			else
				_format.font = "Verdana";
			_format.color = _color;
			_format.size = _size;
			_format.align = _align;
			_format.bold = _bold;
			
			this.embedFonts = false;
			this.antiAliasType = AntiAliasType.ADVANCED;
			if(_width!=0)
				this.width=_width;
			else
				this.autoSize = TextFieldAutoSize.LEFT;
			if(_height!=0)
				this.height=_height;
			this.text = _label;
			this.multiline = _multiLine;
			if(_multiLine) {
				this.wordWrap=true;
				this.condenseWhite=true;
				if(lineHeight==0)
					this.height=this.textHeight;
				else
					this.height=lineHeight+(lineHeight*.25)+lineHeight;
			}
			this.selectable = false;
			this.defaultTextFormat = _format;
			this.setTextFormat(_format);
			if(_dropshadow)
			{
				var shadow:DropShadowFilter = new DropShadowFilter();
				shadow.distance = 5;
				shadow.angle = 25;
				shadow.alpha = 0.5;
				shadow.blurX = 8;
				shadow.blurY = 8;
				this.filters=[shadow];
			}
			this.mouseEnabled=false;
			this.cacheAsBitmap = true;
		}
		
		public function get format():TextFormat{
			return _format;
		}
		
		public function refresh():void{
			this.setTextFormat(_format);
		}
	}
}