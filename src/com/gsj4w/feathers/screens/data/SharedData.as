package com.gsj4w.feathers.screens.data {
	import com.gsj4w.feathers.screens.data.input.ScreenInput;
	
	/**
	 * Sdilena data mezi screeny.
	 * @author Jakub Wagner, J4W
	 */
	public class SharedData extends Object {
		/**
		 * Obecná data ke sdílení.
		 */
		public var data:Object = {};
		
		private var _lastScreenInput:ScreenInput;
		
		public function SharedData() {
		}
		
		/**
		 * Zpracuje ScreenInput - vola screenInput.process(this)
		 */
		public function processInput(screenInput:ScreenInput):void {
			_lastScreenInput = screenInput;
			screenInput.process(this);
		}
		
		/**
		 * Vrati posledni pouzity ScreenInput skrze SharedData::processInput a smaze ho.
		 */
		public function getAndClearLastScreenInput():ScreenInput {
			var lastScreenInput:ScreenInput = _lastScreenInput;
			_lastScreenInput = null;
			return lastScreenInput;
		}
		
		/**
		 * Posledni pouzity ScreenInput skrze SharedData::processInput
		 */
		public function get lastScreenInput():ScreenInput {
			return _lastScreenInput;
		}
	
	}

}