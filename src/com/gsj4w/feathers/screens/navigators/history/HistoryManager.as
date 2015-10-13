package com.gsj4w.feathers.screens.navigators.history {
	import com.gsj4w.feathers.screens.navigators.AbstractScreenNavigator;
	import com.imageworks.debug.Debugger;
	import feathers.motion.Slide;
	import starling.events.Event;
	
	/**
	 * History manager
	 * @author Jakub Wagner, J4W
	 */
	public class HistoryManager {
		public static const BACK_BEHAVIOUR_AUTO:String = "backAuto";
		
		/**
		 * Blacklist idček screenu, ktere budou preskoceny pri volani handleBack. Resp. na tyto screeny se nedá vrátit po návratu zpět.
		 */
		public var screenIdsStackBlackList:Array = [];
		
		public var defaultBackTransition:Function = Slide.createSlideRightTransition();
		
		protected var screenIdsStack:Vector.<HistoryItem> = new Vector.<HistoryItem>();
		
		protected var abstractScreenNavigator:AbstractScreenNavigator;
		
		public function HistoryManager(abstractScreenNavigator:AbstractScreenNavigator) {
			this.abstractScreenNavigator = abstractScreenNavigator;
		}
		
		/**
		 * Prejde na screen vzad podle aktualniho zasobniku.
		 * @return HistoryItem, na ktery navigator prejde
		 */
		public function handleBackAuto(event:Event = null):HistoryItem {
			if (screenIdsStack.length < 2)
				return null;
			
			var historyItem:HistoryItem = popHistory();
			
			var ease:Function;
			if (event && event.data && event.data.transition)
				ease = event.data.transition;
			else
				ease = defaultBackTransition;
			
			abstractScreenNavigator.showScreen(historyItem.screenId, ease);
			
			return historyItem;
		}
		
		/**
		 * Obslouzi krok zpet.
		 */
		public function handleBack(event:Event = null):void {
			if (screenIdsStack.length < 2)
				return;
			
			Debugger.log("HistoryManager::handleBack() event.data.screenId = " + (event && event.data ? event.data.screenId : "null") + " screenIdsStack = " + screenIdsStack);
			if (!event || !event.data || !event.data.screenId || event.data.screenId == HistoryManager.BACK_BEHAVIOUR_AUTO) {
				handleBackAuto(event);
			} else {
				for (var index:int = 0; index < screenIdsStack.length; index++) { // hledam posledni vyskyt screenu, na ktery jdu (vynuceny backId)
					var historyItem:HistoryItem = screenIdsStack[index];
					if (historyItem.screenId == event.data.screenId) {
						break;
					}
				}
				screenIdsStack = screenIdsStack.slice(0, index);
				
				var ease:Function = event.data.transition || defaultBackTransition;
				
				abstractScreenNavigator.showScreen(event.data.screenId, ease);
			}
		}
		
		/**
		 * Prida krok do historie.
		 * @param	id		id screenu
		 */
		public function pushHistory(id:String):HistoryItem {
			if (screenIdsStack.length) {
				var lastHistoryItem:HistoryItem = screenIdsStack[screenIdsStack.length - 1];
				if (lastHistoryItem.screenId == id)
					return lastHistoryItem; // pokud to je posledni screen ve zasobniku, nepridam ho
			}
			
			var historyItem:HistoryItem = new HistoryItem();
			historyItem.screenId = id;
			screenIdsStack.push(historyItem); // pridam do zasobniku idcek
			return historyItem;
		}
		
		public function popHistory():HistoryItem {
			screenIdsStack.pop();
			
			var lastHistoryItem:HistoryItem = screenIdsStack[screenIdsStack.length - 1];
			var id:String = lastHistoryItem.screenId;
			
			while (screenIdsStackBlackList.indexOf(id) >= 0) { // je na blacklistu?
				screenIdsStack.pop(); // preskocim ho
				lastHistoryItem = screenIdsStack[screenIdsStack.length - 1];
				id = lastHistoryItem.screenId;
			}
			
			return lastHistoryItem;
		}
	
	}

}