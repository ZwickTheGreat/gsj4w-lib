package com.gsj4w.feathers.orientation {
	import com.gsj4w.feathers.orientation.events.AspectRatioEvent;
	import com.gsj4w.feathers.utils.FrameRateController;
	import com.imageworks.debug.Debugger;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	/**
	 * Event pri natoceni displeje
	 * @eventType com.goodshape.shirazcode.utils.orientation.events.AspectRatioEvent.ASPECT_CHANGE
	 */
	[Event(name="aspectChange",type="com.goodshape.shirazcode.utils.orientation.events.AspectRatioEvent")]
	
	/**
	 * Trida, ktera se stara o povolovani otaceni.
	 * @author Jakub Wagner, J4W
	 */
	public class OrientationController {
		static protected var loadingHolder:MovieClip;
		
		static private var stage:Stage;
		static private var _currentAspect:String;
		static private var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		static public function init(_stage:Stage, _loadingHolder:MovieClip):void {
			loadingHolder = _loadingHolder;
			stage = _stage;
			_currentAspect = stage.stageWidth > stage.stageHeight ? AspectRatio.LANDSCAPE : AspectRatio.PORTRAIT;
			_stage.addEventListener(Event.RESIZE, onStageResize);
			_stage.addEventListener("orientationChange", onStageOrientationChange); // TODO: nepouzivam schvalne konstanty z StageOrientationEvent, protoze to pak nefakci v prohlizeci
			_stage.addEventListener("orientationChanging", onStageOrientationChanging);
			
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onNativeStageKeyDown); // DEBUG - preklapi displej pri testovani na pc
		}
		
		static public function disableAutoOrientation():void {
			stage.autoOrients = false;
			stage.setOrientation(StageOrientation.DEFAULT);
			stage.setAspectRatio(StageAspectRatio.PORTRAIT);
			
			hideLoading();
		}
		
		static public function enableAutoOrientation():void {
			stage.autoOrients = true;
			stage.setAspectRatio(StageAspectRatio.ANY);
		}
		
		static protected function showLoading():void {
			stage.addChild(loadingHolder);
			
			centerLoading();
		}
		
		static protected function hideLoading():void {
			if (loadingHolder.parent == stage)
				stage.removeChild(loadingHolder);
		}
		
		static protected function centerLoading():void {
			loadingHolder.x = stage.stageWidth / 2 - loadingHolder.width / 2;
			loadingHolder.y = stage.stageHeight / 2 - loadingHolder.height / 2;
		}
		
		//*************************************************************//
		//********************  Event Listeners  **********************//
		//*************************************************************//
		
		private static function onNativeStageKeyDown(e:KeyboardEvent):void {
			// DEBUG - preklapi displej pri testovani na pc
			if (!stage.autoOrients)
				return;
			
			switch (e.keyCode) {
				case Keyboard.RIGHT: 
					stage.setOrientation(StageOrientation.ROTATED_RIGHT);
					break;
				case Keyboard.LEFT: 
					stage.setOrientation(StageOrientation.ROTATED_LEFT);
					break;
				case Keyboard.UP: 
					stage.setOrientation(StageOrientation.DEFAULT);
					break;
			}
		}
		
		private static function onStageOrientationChange(e:Object):void {
			Debugger.log("OrientationController:: orientation change from " + e.beforeOrientation + " to " + e.afterOrientation);
			showLoading();
			setTimeout(hideLoading, 3000); // NEJDELE po 3 vterinach ho schovam
		}
		
		private static function onStageOrientationChanging(e:Object):void {
			Debugger.log("OrientationController:: orientation changing from " + e.beforeOrientation + " to " + e.afterOrientation);
			showLoading();
			setTimeout(hideLoading, 3000); // NEJDELE po 3 vterinach ho schovam
		}
		
		static private function onStageResize(e:Event):void {
			var aspect:String = stage.fullScreenWidth > stage.fullScreenHeight ? AspectRatio.LANDSCAPE : AspectRatio.PORTRAIT;
			Debugger.log("OrientationController::onStageResize() from ", _currentAspect, " to ", aspect, " stage size: ", stage.fullScreenWidth, "x", stage.fullScreenHeight);
			if (aspect != _currentAspect) {
				var aspectRatioEvent:AspectRatioEvent = new AspectRatioEvent(AspectRatioEvent.ASPECT_CHANGE);
				aspectRatioEvent.beforeChange = _currentAspect
				aspectRatioEvent.afterChange = aspect;
				eventDispatcher.dispatchEvent(aspectRatioEvent);
			}
			_currentAspect = aspect;
			
			showLoading();
			setTimeout(hideLoading, 500); // shovam za 500ms
			
			if (FrameRateController.isInicialized())
				FrameRateController.stayActive(500);
		}
		
		/* DELEGATE flash.events.EventDispatcher */
		
		static public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		static public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}
		
		static public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Vraci aspect ratio (AspectRatio.PORTRAIT nebo AspectRation.LANDSCAPE)
		 */
		static public function get currentAspectRatio():String {
			return _currentAspect;
		}
	
	}

}