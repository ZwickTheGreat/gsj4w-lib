package com.gsj4w.feathers.touch {
	import com.j4w.starling.nextFrame;
	import feathers.core.FeathersControl;
	import flash.geom.Point;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Swiper.
	 * @author Jakub Wagner, J4W
	 */
	public class Swiper {
		static public var defaultScale:Number = 1;
		
		private const MOVEMENT_LOCK_LIMIT:Number = 10 * defaultScale;
		
		private var movement:Point = new Point();
		
		/**
		 * Lock indicating, that we are dragging.
		 */
		private var dragLock:Boolean = false;
		
		/**
		 * If user swipes left the left content to show is requested.
		 *
		 * function():DisplayObject is expected
		 */
		public var contentLeftFactory:Function;
		
		/**
		 * If user swipes right the right content to show is requested.
		 *
		 * function():DisplayObject is expected
		 */
		public var contentRightFactory:Function;
		
		/**
		 * Content is not known until requested with contentFactory.
		 * In some cases we need to know the content width before.
		 */
		public var contentLeftWidth:Number = NaN;
		
		/**
		 * Content is not known until requested with contentFactory.
		 * In some cases we need to know the content width before.
		 */
		public var contentRightWidth:Number = NaN;
		
		/**
		 * Source display object user swipes with.
		 */
		private var source:DisplayObjectContainer;
		
		/**
		 * Created content after succesfull swipe to left.
		 */
		private var _contentLeft:DisplayObject;
		
		/**
		 * Created content after succesfull swipe to right.
		 */
		private var _contentRight:DisplayObject;
		
		/**
		 * If user swipes, it locks at content.
		 * Next touch will be ignored.
		 */
		private var _contentLock:Boolean = false;
		
		/**
		 * If true, source can be swiped otherwise it can't.
		 */
		private var _isEnabled:Boolean;
		
		public function Swiper(source:DisplayObjectContainer) {
			this.source = source;
			
			isEnabled = true;
		}
		
		/**
		 * Resets sources alpha and pivot and all locks.
		 */
		public function reset():void {
			source.alpha = 1;
			source.pivotX = 0;
			contentLock = dragLock = false;
		}
		
		/**
		 * Content created with createContent (contentFactory) will be disposed. New content will be created if needed.
		 */
		public function disposeContent():void {
			if (_contentLeft)
				_contentLeft.removeFromParent(true);
			_contentLeft = null;
			if (_contentRight)
				_contentRight.removeFromParent(true);
			_contentRight = null;
			reset();
		}
		
		private function onTouch(e:TouchEvent):void {
			var touch:Touch = e.getTouch(source);
			if (touch && touch.target != _contentLeft) {
				if (!dragLock && touch.phase == TouchPhase.MOVED) {
					touch.getMovement(source, movement);
					if (Math.abs(movement.y) > 2 * MOVEMENT_LOCK_LIMIT) {
						dragLock = true;
						animatePivotXTo(0);
						return;
					}
					if (Math.abs(source.pivotX) > MOVEMENT_LOCK_LIMIT || Math.abs(movement.x) > MOVEMENT_LOCK_LIMIT) {
						createContentLeft(); // create content now
						createContentRight();
						FeathersUtils.stopParentScroll(source.parent);
					}
					source.pivotX -= movement.x;
					if (contentRightFactory != null) {
						if (source.pivotX > contentRightWidth) {
							source.pivotX = contentRightWidth;
							dragLock = contentLock = true;
						} else if (contentLeftFactory == null && source.pivotX < 0) {
							source.pivotX = 0;
						}
					}
					if (contentLeftFactory != null) {
						if (source.pivotX < -contentLeftWidth) {
							source.pivotX = -contentLeftWidth;
							dragLock = contentLock = true;
						} else if (contentRightFactory == null && source.pivotX > 0) {
							source.pivotX = 0;
						}
					}
				} else if (touch.phase == TouchPhase.ENDED) {
					dragLock = false;
					if (!contentLock) // if we are not locked at content
						animatePivotXTo(0);
				} else if (touch.phase == TouchPhase.BEGAN) {
					if (contentLock) {
						// make contentLock if dragLock
						dragLock = true;
						nextFrame(function():void {
								contentLock = false;
							});
					}
				}
			}
		}
		
		/**
		 * Animates pivotX.
		 * @param	number
		 */
		private function animatePivotXTo(number:Number):void {
			
			Starling.juggler.tween(source, .2, {pivotX: number, transition: Transitions.EASE_IN_OUT});
		}
		
		/**
		 * Creates left content.
		 */
		private function createContentLeft():void {
			if (!_contentLeft && contentLeftFactory != null) {
				_contentLeft = contentLeftFactory();
				source.addChild(_contentLeft);
				
				// evaluate contentWidth
				if (isNaN(contentLeftWidth)) {
					var fc:FeathersControl = _contentLeft as FeathersControl;
					if (fc)
						fc.validate();
					contentLeftWidth = _contentLeft.width;
				}
				
				_contentLeft.x = -contentLeftWidth;
				
				// animate content from alpha 0
				_contentLeft.alpha = 0;
				Starling.juggler.tween(_contentLeft, .2, {alpha: 1});
			}
		}
		
		/**
		 * Creates right content.
		 */
		private function createContentRight():void {
			if (!_contentRight && contentRightFactory != null) {
				_contentRight = contentRightFactory();
				source.addChild(_contentRight);
				
				// evaluate contentWidth
				if (isNaN(contentRightWidth)) {
					var fc:FeathersControl = _contentRight as FeathersControl;
					if (fc)
						fc.validate();
					contentRightWidth = _contentRight.width;
				}
				
				// place at position
				_contentRight.x = source.width;
				
				// animate content from alpha 0
				_contentRight.alpha = 0;
				Starling.juggler.tween(_contentRight, .2, {alpha: 1});
			}
		}
		
		/**
		 * If true, is marks that user swipes to content and source is touch-locked.
		 */
		public function get contentLock():Boolean {
			return _contentLock;
		}
		
		public function set contentLock(value:Boolean):void {
			_contentLock = value;
			var feathersControl:FeathersControl = source as FeathersControl;
			if (feathersControl)
				if (_contentLock) {
					feathersControl.isQuickHitAreaEnabled = false;
					feathersControl.isEnabled = false;
					feathersControl.touchable = true;
				} else {
					feathersControl.isEnabled = true;
				}
		}
		
		/**
		 * If true, source can be swiped otherwise it can't.
		 */
		public function get isEnabled():Boolean {
			return _isEnabled;
		}
		
		public function set isEnabled(value:Boolean):void {
			_isEnabled = value;
			if (_isEnabled) {
				source.addEventListener(TouchEvent.TOUCH, onTouch);
			} else {
				reset();
				source.removeEventListener(TouchEvent.TOUCH, onTouch);
			}
		}
		
		/**
		 * Left content, null if not yet created.
		 */
		public function get contentLeft():DisplayObject {
			return _contentLeft;
		}
		
		/**
		 * Right content, null if not yet created.
		 */
		public function get contentRight():DisplayObject {
			return _contentRight;
		}
	
	}

}