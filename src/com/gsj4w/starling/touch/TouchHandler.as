package com.gsj4w.starling.touch {
	import flash.geom.Point;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * Dispatched when the button is released while the touch is still
	 * within the button's bounds (a tap or click that should trigger the
	 * button).
	 *
	 * @eventType starling.events.Event.TRIGGERED
	 */
	[Event(name="triggered",type="starling.events.Event")]
	
	/**
	 * Classa ktera ze sprite udela tlacitko, ktere vyvolava po stisknuti Event.TRIGGERED.
	 * @author Jakub Wagner, J4W
	 */
	public class TouchHandler extends EventDispatcher {
		private var _sprite:Sprite;
		private var movement:Point = new Point();
		private var movementLock:Boolean;
		private var preventDefault:Boolean;
		
		/**
		 * @param	sprite
		 * @param	preventDefault		Pokud true, tak se po vyvolani Event.TRIGGERED ukonci TouchEvent.
		 */
		public function TouchHandler(sprite:Sprite, preventDefault:Boolean = false) {
			this.preventDefault = preventDefault;
			this._sprite = sprite;
			_sprite.addEventListener(TouchEvent.TOUCH, onSpriteTouch);
		}
		
		private function onSpriteTouch(e:TouchEvent):void {
			var touch:Touch = e.getTouch(sprite);
			if (touch) {
				if (touch.phase == TouchPhase.BEGAN) {
					movementLock = false;
				}
				if (movementLock)
					return;
				if (touch.phase == TouchPhase.ENDED) {
					dispatchEventWith(Event.TRIGGERED, false, sprite);
					if (preventDefault) {
						e.stopImmediatePropagation();
						e.stopPropagation();
					}
					return;
				}
				touch.getMovement(sprite, movement);
				if (Math.abs(movement.x) > 5 || Math.abs(movement.y) > 5) {
					movementLock = true;
					return;
				}
			}
		}
		
		public function get sprite():Sprite {
			return _sprite;
		}
	
	}

}