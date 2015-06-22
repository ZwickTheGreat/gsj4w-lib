package com.gsj4w.feathers.motion.transitions {
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	
	/**
	 * SlideOver transition.
	 * @author Jakub Wagner, J4W
	 */
	public class SlideOver {
		/**
		 * @private
		 */
		protected static const SCREEN_REQUIRED_ERROR:String = "Cannot transition if both old screen and new screen are null.";
		
		public static function createSlideFromBottom(duration:Number = 0.7, ease:Object = Transitions.EASE_IN_OUT):Function {
			return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function):void {
				if (!oldScreen && !newScreen) {
					throw new ArgumentError(SCREEN_REQUIRED_ERROR);
				}
				if (oldScreen) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				if (newScreen) {
					newScreen.x = 0;
					newScreen.y = oldScreen.height;
					
					tween(newScreen, duration, ease, onComplete);
				}
			}
		}
		
		public static function createSlideFromUp(duration:Number = 0.7, ease:Object = Transitions.EASE_IN_OUT):Function {
			return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function):void {
				if (!oldScreen && !newScreen) {
					throw new ArgumentError(SCREEN_REQUIRED_ERROR);
				}
				if (oldScreen) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				if (newScreen) {
					newScreen.x = 0;
					newScreen.y = -oldScreen.height;
					
					tween(newScreen, duration, ease, onComplete);
				}
			}
		}
		
		public static function createSlideFromRight(duration:Number = 0.7, ease:Object = Transitions.EASE_IN_OUT):Function {
			return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function):void {
				if (!oldScreen && !newScreen) {
					throw new ArgumentError(SCREEN_REQUIRED_ERROR);
				}
				if (oldScreen) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				if (newScreen) {
					newScreen.x = oldScreen.width;
					newScreen.y = 0;
					
					tween(newScreen, duration, ease, onComplete);
				}
			}
		}
		
		public static function createSlideFromLeft(duration:Number = 0.7, ease:Object = Transitions.EASE_IN_OUT):Function {
			return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function):void {
				if (!oldScreen && !newScreen) {
					throw new ArgumentError(SCREEN_REQUIRED_ERROR);
				}
				if (oldScreen) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				if (newScreen) {
					newScreen.x = -oldScreen.width;
					newScreen.y = 0;
					
					tween(newScreen, duration, ease, onComplete);
				}
			}
		}
		
		static private function tween(newScreen:DisplayObject, duration:Number, ease:Object, onComplete:Function):void {
			Starling.juggler.tween(newScreen, duration, {x: 0, y: 0, transition: ease, onComplete: onComplete});
		}
	
	}

}