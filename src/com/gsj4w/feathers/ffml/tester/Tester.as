package com.gsj4w.feathers.ffml.tester {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import lib.Preloader;
	import starling.core.Starling;
	
	[SWF(width='720',height='1280',backgroundColor='#f5f4f2',frameRate='60')]
	
	/**
	 * Native main.
	 * @author Jakub Wagner, J4W
	 */
	public class Tester extends Sprite {
		
		public var preloader:DisplayObject;
		private var frameCounter:uint = 0;
		
		private var _starling:Starling;
		
		public function Tester() {
			preloader = new Preloader();
			preloader.visible = false;
			addChild(preloader);
			onStageResizeHandler(null);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			addEventListener(Event.ENTER_FRAME, onFirstFrame);
			stage.addEventListener(Event.RESIZE, onStageResizeHandler, false, int.MAX_VALUE, true);
			onStageResizeHandler(null);
		}
		
		private function initStarling():void {
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			
			_starling = new Starling(TesterStarling, stage);
			_starling.enableErrorChecking = false;
			_starling.simulateMultitouch = true;
			_starling.start();
		}
		
		private function onStageDeactivateHandler(event:Event):void {
			_starling.stop();
			stage.addEventListener(Event.ACTIVATE, onStageActivateHandler, false, 0, true);
		}
		
		private function onStageActivateHandler(event:Event):void {
			stage.removeEventListener(Event.ACTIVATE, onStageActivateHandler);
			_starling.start();
		}
		
		private function onStageResizeHandler(e:Event):void {
			if (preloader && preloader.parent) {
				preloader.x = stage.stageWidth / 2 - preloader.width / 2;
				preloader.y = stage.stageHeight / 2 - preloader.height / 2;
				preloader.visible = true;
			}
			
			if (!_starling)
				return;
			
			_starling.stage.stageWidth = stage.stageWidth;
			_starling.stage.stageHeight = stage.stageHeight;
			
			const viewPort:Rectangle = _starling.viewPort;
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			try {
				_starling.viewPort = viewPort;
			}
			catch (err:Error) {
				trace("Tester::onStageResizeHandler() ERROR #" + err.errorID + " - " + err.message);
				trace(err.getStackTrace());
			}
		}
		
		private function onFirstFrame(e:Event):void {
			if (frameCounter == 3) {
				initStarling();
			}
			if (frameCounter++ == 4) {
				removeEventListener(Event.ENTER_FRAME, onFirstFrame);
				removeChild(preloader);
				onStageResizeHandler(null);
			}
		}
	
	}

}