package com.gsj4w.feathers.screens.navigators.history {
	import com.gsj4w.feathers.screens.data.SharedData;
	import com.gsj4w.feathers.screens.navigators.AbstractScreenNavigator;
	import starling.events.Event;
	
	/**
	 * History manager, ktery si pamatuje k jednotlivym HistoryItem ScreenInput.
	 * @author Jakub Wagner, J4W
	 */
	public class ScreenInputCacheHistoryManager extends HistoryManager {
		private var sharedData:SharedData;
		
		public function ScreenInputCacheHistoryManager(abstractScreenNavigator:AbstractScreenNavigator, sharedData:SharedData) {
			this.sharedData = sharedData;
			super(abstractScreenNavigator);
		}
		
		override public function pushHistory(id:String):HistoryItem {
			var historyItem:HistoryItem = super.pushHistory(id);
			
			historyItem.screenInput = sharedData.getAndClearLastScreenInput();
			
			return historyItem;
		}
		
		override public function handleBackAuto(event:Event = null):HistoryItem {
			if (screenIdsStack.length < 2)
				return null;
			
			var historyItem:HistoryItem = popHistory();
			
			if (historyItem.screenInput)
				sharedData.processInput(historyItem.screenInput);
			
			var ease:Function;
			if (event && event.data && event.data.transition)
				ease = event.data.transition;
			else
				ease = defaultBackTransition
			
			abstractScreenNavigator.showScreen(historyItem.screenId, ease);
			
			return historyItem;
		}
	}

}