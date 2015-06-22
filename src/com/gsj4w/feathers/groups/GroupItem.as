package com.gsj4w.feathers.groups {
	import starling.display.DisplayObject;
	
	/**
	 * Item v groupe.
	 * @author Jakub Wagner, J4W
	 */
	public class GroupItem {
		public var size:Number;
		public var align:String;
		public var space:Number;
		public var displayObject:DisplayObject;
		
		public function GroupItem(displayObject:DisplayObject, space:Number, align:String, size:Number) {
			this.size = size;
			this.align = align;
			this.space = space;
			this.displayObject = displayObject;
		}
	
	}

}