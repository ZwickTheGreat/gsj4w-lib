package com.gsj4w.starling.display {
	import starling.display.Quad;
	
	public class IrregularQuad extends Quad {
		public function IrregularQuad(width:Number, height:Number, color:uint = 0xffffff, premultipliedAlpha:Boolean = true) {
			super(width, height, color, premultipliedAlpha);
		}
		
		public function setCornerPoints(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):void {
			mVertexData.setPosition(0, x1, y1);
			mVertexData.setPosition(1, x2, y2);
			mVertexData.setPosition(2, x3, y3);
			mVertexData.setPosition(3, x4, y4);
			onVertexDataChanged();
		}
	}
}