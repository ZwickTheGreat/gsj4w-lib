package com.gsj4w.feathers.orientation.events {
	import flash.events.Event;
	
	/**
	 * Zmena pomeru stran.
	 * @author Jakub Wagner, J4W
	 */
	public class AspectRatioEvent extends Event {
		static public const ASPECT_CHANGE:String = "aspectChange";
		
		public var beforeChange:String;
		public var afterChange:String;
		
		public function AspectRatioEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "[AspectRatioEvent beforeChange=" + beforeChange + " afterChange=" + afterChange + "]";
		}
	
	}

}