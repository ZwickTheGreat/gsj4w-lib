package com.gsj4w.feathers.components {
	import feathers.core.FeathersControl;
	import starling.display.Quad;
	import starling.utils.Color;
	
	/**
	 * ...
	 * @author Jakub Wagner, J4W
	 */
	public class QuadWithLine extends FeathersControl {
		private var _quad:Quad;
		private var _quadLine:Quad;
		private var _quadLineTop:Quad;
		
		private var _twoLines:Boolean;
		private var _lineColor:uint;
		private var _lineAlpha:Number;
		private var _lineWidth:Number;
		private var _lineHeight:uint;
		private var _color:uint;
		
		public function QuadWithLine() {
			super();
			_quad = new Quad(10, 10, Color.WHITE);
			_quadLine = new Quad(10, 10, Color.WHITE);
			_quadLine.touchable = false;
			addChild(_quad);
			addChild(_quadLine);
		}
		
		override protected function draw():void {
			super.draw();
			
			_quad.color = color;
			_quad.width = _quad.width = width;
			_quad.height = height;
			
			_quadLine.width = isNaN(lineWidth) ? width : lineWidth;
			_quadLine.height = lineHeight;
			
			_quadLine.x = (width - _quadLine.width) / 2;
			_quadLine.y = height - lineHeight;
			
			_quadLine.color = lineColor;
			_quadLine.alpha = lineAlpha;
			
			if (twoLines) {
				if (!_quadLineTop) {
					_quadLineTop = new Quad(width, lineHeight, lineColor);
					_quadLineTop.touchable = false;
				}
				_quadLineTop.width = isNaN(lineWidth) ? width : lineWidth;
				_quadLineTop.height = lineHeight;
				
				_quadLineTop.x = (width - _quadLine.width) / 2;
				
				_quadLineTop.color = lineColor;
				_quadLineTop.alpha = lineAlpha;
				
				addChild(_quadLineTop);
			} else if (_quadLineTop) {
				removeChild(_quadLineTop);
			}
		}
		
		public function get color():uint {
			return _color;
		}
		
		public function set color(value:uint):void {
			if (_color != value) {
				_color = value;
				invalidate(INVALIDATION_FLAG_LAYOUT);
			}
		}
		
		public function get lineHeight():uint {
			return _lineHeight;
		}
		
		public function set lineHeight(value:uint):void {
			if (_lineHeight != value) {
				_lineHeight = value;
				invalidate(INVALIDATION_FLAG_LAYOUT);
			}
		}
		
		public function get lineWidth():Number {
			return _lineWidth;
		}
		
		public function set lineWidth(value:Number):void {
			if (_lineWidth != value) {
				_lineWidth = value;
				invalidate(INVALIDATION_FLAG_LAYOUT);
			}
		}
		
		public function get lineAlpha():Number {
			return _lineAlpha;
		}
		
		public function set lineAlpha(value:Number):void {
			if (_lineAlpha != value) {
				_lineAlpha = value;
				invalidate(INVALIDATION_FLAG_LAYOUT);
			}
		}
		
		public function get lineColor():uint {
			return _lineColor;
		}
		
		public function set lineColor(value:uint):void {
			if (_lineColor != value) {
				_lineColor = value;
				invalidate(INVALIDATION_FLAG_LAYOUT);
			}
		}
		
		public function get twoLines():Boolean {
			return _twoLines;
		}
		
		public function set twoLines(value:Boolean):void {
			if (_twoLines != value) {
				_twoLines = value;
				invalidate(INVALIDATION_FLAG_LAYOUT);
			}
		}
		
		public function get quad():Quad {
			return _quad;
		}
		
		public function get line():Quad {
			return _quadLine;
		}
		
		/**
		 * Bottom line. Same as line. Only if twoLines == true.
		 */
		public function get lineBottom():Quad {
			return _quadLine;
		}
		
		/**
		 * Top line.
		 */
		public function get lineTop():Quad {
			return _quadLineTop;
		}
	
	}

}