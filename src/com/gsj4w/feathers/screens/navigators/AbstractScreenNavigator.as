package com.gsj4w.feathers.screens.navigators {
	import com.gsj4w.feathers.screens.AbstractScreen;
	import com.gsj4w.feathers.screens.navigators.history.HistoryManager;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.events.FeathersEventType;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	/**
	 * Abstraktni jednoduchy screen navigator, ktery umi pracovat s nasim AbstractScreenem.
	 * @author Jakub Wagner, J4W
	 */
	public class AbstractScreenNavigator extends ScreenNavigator {
		public static const BACK_BEHAVIOUR_AUTO:String = "backAuto";
		
		protected var transitionManager:ScreenSlidingStackTransitionManager;
		protected var historyManager:HistoryManager;
		
		public function AbstractScreenNavigator() {
			transitionManager = new ScreenSlidingStackTransitionManager(this);
			createHistoryManager();
			
			addEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		override public function addScreen(id:String, item:ScreenNavigatorItem):void {
			item.events.back = handleBack;
			super.addScreen(id, item);
		}
		
		override public function showScreen(id:String, transition:Function = null):DisplayObject {
			if (activeScreenID == id) {
				// pokud uzivatel uz je na tomto screenu, vytvorena kopii, aby se mohl zobrazit
				// napr. na z detailu subjektu lze prejit na dalsi detail subjektu a tak neustale dokola
				var screen:ScreenNavigatorItem = getScreen(id);
				id = id + "Copy";
				if (!getScreen(id)) // kopie neexistuje
					addScreen(id, screen); // zalozim ji
			}
			historyManager.pushHistory(id);
			return super.showScreen(id, transition);
		}
		
		protected function createHistoryManager():void {
			historyManager = new HistoryManager(this);
		}
		
		protected function onTransitionComplete(e:Event):void {
			var abstractScreen:AbstractScreen = activeScreen as AbstractScreen;
			if (abstractScreen) {
				abstractScreen.doDelayedInitialisation();
			}
		}
		
		protected function handleBack(event:Event):void {
			historyManager.handleBack(event);
		}
	
	}

}