package com.gsj4w.feathers.groups {
	import starling.display.DisplayObject;
	import starling.utils.VAlign;
	
	/**
	 * Horizontální grupa prvků.
	 * @author Jakub Wagner, J4W
	 */
	public class HGroup extends AbstractGroup {
		
		public function HGroup() {
		}
		
		override public function layoutItems():void {
			scaledActualWidth = actualWidth = 0;
			
			if (!isNaN(explicitHeight)) {
				actualHeight = explicitHeight;
				scaledActualHeight = actualHeight * scaleY;
			}
			
			var totalSize:Number = 0;
			for each (var groupItem:GroupItem in groupItems) {
				var size:Number = groupItem.size;
				var space:Number = groupItem.space;
				var align:String = groupItem.align;
				var displayObject:DisplayObject = groupItem.displayObject;
				
				if (size == -1) {
					size = getItemWidth(displayObject);
				} else {
					size *= AbstractGroup.defaultScale;
				}
				
				var itemHeight:Number = getItemHeight(groupItem.displayObject);
				if (align == VAlign.TOP) {
					displayObject.y = paddingTop;
				} else if (align == VAlign.CENTER) {
					displayObject.y = scaledActualHeight / 2 - itemHeight / 2 + paddingTop - paddingBottom;
				} else if (align == VAlign.BOTTOM) {
					displayObject.y = scaledActualHeight - itemHeight - paddingBottom;
				}
				displayObject.x = paddingLeft + totalSize + space * AbstractGroup.defaultScale;
				
				totalSize += size + (this is TabHGroup ? 0 : space * AbstractGroup.defaultScale);
				
				if (snapToPixels) {
					displayObject.x = Math.floor(displayObject.x);
					displayObject.y = Math.floor(displayObject.y);
				}
			}
			
			actualWidth = paddingLeft + totalSize + paddingRight;
			scaledActualWidth = actualWidth * scaleX;
		}
		
		override public function measureItems():void {
			if (isNaN(explicitHeight) || explicitHeight == 0) { // pokud neni nastavena vyska explicitne
				// grupa je vysoka jako nejvyssi prvek v ni				
				scaledActualHeight = actualHeight = 0;
				
				for each (var groupItem:GroupItem in groupItems) { // zjistuji nejvyssi prvek ze vsech	
					var displayObject:DisplayObject = groupItem.displayObject;
					
					var itemHeight:Number = getItemHeight(displayObject) + paddingTop + paddingBottom;
					
					if (actualHeight < itemHeight) {
						actualHeight = itemHeight;
						scaledActualHeight = actualHeight * scaleY;
					}
				}
			}
		}
	
	}
}