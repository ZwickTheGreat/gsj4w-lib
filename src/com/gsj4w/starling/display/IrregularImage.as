package com.gsj4w.starling.display {
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Jakub Wagner, J4W
	 */
	public class IrregularImage extends Image {
		
		public function IrregularImage(texture:Texture) {
			super(texture);
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