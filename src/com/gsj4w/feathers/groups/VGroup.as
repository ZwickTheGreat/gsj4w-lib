package com.gsj4w.feathers.groups {
	import starling.display.DisplayObject;
	import starling.utils.HAlign;
	
	/**
	 * Vertikální grupa prvků. Automaticky má šířku stageWidth.
	 * @author Jakub Wagner, J4W
	 */
	public class VGroup extends AbstractGroup {
		public function VGroup() {
		}
		
		override public function layoutItems():void {
			scaledActualHeight = actualHeight = 0;
			
			if (!isNaN(explicitWidth)) {
				scaledActualWidth = actualWidth = explicitWidth;
			}
			
			var totalSize:Number = 0;
			for each (var groupItem:GroupItem in groupItems) {
				var size:Number = groupItem.size;
				var space:Number = groupItem.space;
				var align:String = groupItem.align;
				var displayObject:DisplayObject = groupItem.displayObject;
				
				if (size == -1) {
					size = getItemHeight(groupItem.displayObject);
				} else {
					size *= AbstractGroup.defaultScale;
				}
				
				var itemWidth:Number = getItemWidth(groupItem.displayObject);
				if (align == HAlign.LEFT) {
					displayObject.x = paddingLeft;
				} else if (align == HAlign.CENTER) {
					displayObject.x = scaledActualWidth / 2 - itemWidth / 2;
				} else if (align == HAlign.RIGHT) {
					displayObject.x = scaledActualWidth - itemWidth - paddingRight;
				}
				displayObject.y = paddingTop + totalSize + space * AbstractGroup.defaultScale;
				
				totalSize += size + space * AbstractGroup.defaultScale;
				
				if (snapToPixels) {
					displayObject.x = Math.floor(displayObject.x);
					displayObject.y = Math.floor(displayObject.y);
				}
			}
			
			scaledActualHeight = actualHeight = paddingTop + totalSize + paddingBottom;
		}
		
		override public function measureItems():void {
			if (isNaN(explicitWidth) || explicitWidth == 0) { // pokud neni nastavena sirka explicitne
				// grupa je siroka jako nejsirsi prvek v ni				
				scaledActualWidth = actualWidth = 0;
				
				for each (var groupItem:GroupItem in groupItems) { // zjistuji nejsirsi prvek ze vsech
					var displayObject:DisplayObject = groupItem.displayObject;
					
					var itemWidth:Number = getItemWidth(displayObject);
					
					if (scaledActualWidth < itemWidth) {
						scaledActualWidth = actualWidth = itemWidth;
					}
				}
			}
		}
		
		public function toString():String {
			return "[VGroup name=" + name + "]";
		}
	
	}
}