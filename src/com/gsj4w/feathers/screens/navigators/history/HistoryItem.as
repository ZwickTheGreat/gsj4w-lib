package com.gsj4w.feathers.screens.navigators.history {
	import com.gsj4w.feathers.screens.data.input.ScreenInput;
	
	/**
	 * History item
	 * @author Jakub Wagner, J4W
	 */
	public class HistoryItem {
		public var screenId:String;
		public var screenInput:ScreenInput;
		public var screenDataClones:Object = {};
		
		public function HistoryItem() {
		
		}
		
		public function toString():String {
			//return "[HistoryItem screenId=" + screenId + " screenDataClones=" + Inspector.dump(screenDataClones) + "]";
			return screenId;
		}
	
	}

}