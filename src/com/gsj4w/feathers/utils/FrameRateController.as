package com.gsj4w.feathers.utils {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import starling.core.Starling;
	
	/**
	 * Kontroler, ktery se stara o snizovani framerate pri necinnosti.
	 * @author Jakub Wagner, J4W
	 */
	public class FrameRateController {
		static private const FPS_TIMER_DELAY:Number = 5000;
		static private const FPS_NORMAL:Number = 60;
		static private const FPS_IDLE:Number = 3;
		
		static private var stage:Stage;
		static private var current:Starling;
		static private var fpsTimer:Timer;
		
		static private var stayActiveLock:uint = 0;
		
		public function FrameRateController() {
		}
		
		/**
		 * True, pokud je kontroller spravne inicializovan.
		 * @see init()
		 */
		static public function isInicialized():Boolean {
			return stage != null;
		}
		
		static public function init(current:Starling):void {
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
			
			fpsTimer = new Timer(FPS_TIMER_DELAY);
			fpsTimer.addEventListener(TimerEvent.TIMER, onTimerTimer);
			fpsTimer.start();
		}
		
		static public function setIdleFrameRate():void {
			if (!stage)
				throw new Error("FrameRateController must be inicialized first!");
			if (stage.frameRate != FPS_IDLE) {
				//Debugger.log("FrameRateController::setIdleFrameRate() FPS_IDLE = " + FPS_IDLE);
				/* Silence is golden */
				stage.frameRate = FPS_IDLE;
			}
		}
		
		static public function setNormalFrameRate():void {
			if (!stage)
				throw new Error("FrameRateController must be inicialized first!");
			fpsTimer.reset();
			fpsTimer.delay = FPS_TIMER_DELAY; // nastavim zpet cas timeru
			fpsTimer.start();
			if (stage.frameRate != FPS_NORMAL) {
				//Debugger.log("FrameRateController::setNormalFrameRate() FPS_NORMAL = " + FPS_NORMAL);
				/* Silence is golden */
				stage.frameRate = FPS_NORMAL;
			}
			
			stayActiveLock = getTimer() + FPS_TIMER_DELAY;
		}
		
		/**
		 * Po zadany cas se nesnizi framerate.
		 * @param	time	cas v ms
		 */
		static public function stayActive(miliseconds:Number):void {
			if (!stage)
				throw new Error("FrameRateController must be inicialized first!");
			
			if (stage.frameRate == FPS_IDLE || stayActiveLock < getTimer() + miliseconds) {
				setNormalFrameRate();
				fpsTimer.reset();
				fpsTimer.delay = miliseconds;
				fpsTimer.start();
				
				stayActiveLock = getTimer() + miliseconds;
			}
		}
		
		/**
		 * Pri klavesovym vstupu zvysuju framerate (aktivita)
		 */
		static private function onStageKeyDown(e:KeyboardEvent):void {
			setNormalFrameRate();
		}
		
		/**
		 * Pri dotyku zvysuju framerate (aktivita)
		 */
		static private function onNativeStageTouchEvent(e:TouchEvent):void {
			setNormalFrameRate();
		}
		
		/**
		 * Pri vstupu z mysi zvysuju framerate (aktivita)
		 */
		static private function onNativeStageMouseEvent(e:MouseEvent):void {
			setNormalFrameRate();
		}
		
		/**
		 * Pokud za dobu timeru neni zadna aktivita, snizuji framerate.
		 */
		private static function onTimerTimer(e:TimerEvent):void {
			setIdleFrameRate();
		}
	
	}

}