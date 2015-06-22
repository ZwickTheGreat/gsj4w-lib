package com.gsj4w.feathers.utils {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.utils.getTimer;
	import starling.core.Starling;
	import starling.events.EnterFrameEvent;
	
	/**
	 * FrameRate controller that handles user's inactivity and lowers stage's fps if detected.
	 * @author Jakub Wagner, J4W
	 */
	public class FrameRateController {
		static private var userActivityTime:int = 3000;
		static private var fpsNormal:int = 60;
		static private var fpsIdle:int = 3;
		
		static private var stage:Stage;
		static private var current:Starling;
		
		static private var stayActiveLock:uint = 0;
		
		public function FrameRateController() {
		}
		
		/**
		 * True, if controller is inicialized.
		 * @see init()
		 */
		static public function isInicialized():Boolean {
			return stage != null;
		}
		
		static public function init(current:Starling, userActivityTime:int = 3000, fpsNormal:int = 60, fpsIdle:int = 3):void {
			FrameRateController.current = current;
			FrameRateController.stage = current.nativeStage;
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onNativeStageTouchEvent);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onNativeStageTouchEvent);
			stage.addEventListener(TouchEvent.TOUCH_END, onNativeStageTouchEvent);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onNativeStageMouseEvent);
			stage.addEventListener(MouseEvent.MOUSE_UP, onNativeStageMouseEvent);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onNativeStageMouseEvent);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onNativeStageMouseEvent);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			current.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, onStageEnterFrame);
		}
		
		static public function setIdleFrameRate():void {
			if (!stage)
				throw new Error("FrameRateController must be inicialized first!");
			if (stage.frameRate != fpsIdle) {
				stage.frameRate = fpsIdle;
			}
		}
		
		static public function setNormalFrameRate():void {
			if (!stage)
				throw new Error("FrameRateController must be inicialized first!");
			if (stage.frameRate == fpsIdle) {
				stage.frameRate = fpsNormal;
			}
		}
		
		/**
		 * Po zadany cas se nesnizi framerate.
		 * @param	time	cas v ms
		 */
		static public function stayActive(miliseconds:Number):void {
			if (!stage)
				throw new Error("FrameRateController must be inicialized first!");
			
			if (stayActiveLock < getTimer() + miliseconds) {
				stayActiveLock = getTimer() + miliseconds;
				setNormalFrameRate();
			}
		}
		
		/**
		 * Pri klavesovym vstupu zvysuju framerate (aktivita)
		 */
		static private function onStageKeyDown(e:KeyboardEvent):void {
			stayActive(userActivityTime);
		}
		
		/**
		 * Pri dotyku zvysuju framerate (aktivita)
		 */
		static private function onNativeStageTouchEvent(e:TouchEvent):void {
			stayActive(userActivityTime);
		}
		
		/**
		 * Pri vstupu z mysi zvysuju framerate (aktivita)
		 */
		static private function onNativeStageMouseEvent(e:MouseEvent):void {
			stayActive(userActivityTime);
		}
		
		/**
		 * Pokud za dobu timeru neni zadna aktivita, snizuji framerate.
		 */
		private static function onTimerTimer(e:TimerEvent):void {
			setIdleFrameRate();
		}
		
		static private function onStageEnterFrame(e:EnterFrameEvent):void {
			if (getTimer() < stayActiveLock) {
				if (stage.frameRate == fpsIdle) {
					stage.frameRate = fpsNormal;
				}
			} else {
				if (stage.frameRate != fpsIdle) {
					stage.frameRate = fpsIdle;
				}
			}
		}
	
	}

}