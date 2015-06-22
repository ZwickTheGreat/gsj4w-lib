package com.gsj4w.feathers.components {
	import feathers.core.FeathersControl;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * Strankovaci komponenta.
	 * @author Jakub Wagner, J4W
	 */
	public class PagingComponent extends FeathersControl {
		private var pages:Array = new Array();
		private var _pagesCount:int;
		
		private var currentPage:Sprite
		private var currentPageIndex:int = -1;
		
		private var _onPageInitNeeded:ISignal = new Signal(uint);
		private var _onPageChanged:ISignal = new Signal(uint);
		
		public function PagingComponent(_pagesCount:uint = 10) {
			this._pagesCount = _pagesCount;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Inicializuje stranku.
		 * @param	pageSprite	Sprite stranky
		 * @param	page		Cislo stranky.
		 */
		public function initPage(pageSprite:Sprite, page:uint):void {
			var sprite:Sprite = new Sprite();
			sprite.addChild(pageSprite);
			sprite.touchable = false;
			sprite.visible = false;
			
			pages[page] = sprite;
			addChildAt(sprite, 0);
		}
		
		public function showPage(index:uint):void {
			if (currentPageIndex == index || index >= pagesCount)
				return;
			
			askForInit(index);
			
			if (!pages[index])
				return;
			
			currentPageIndex = index;
			
			if (currentPage) {
				var c:Sprite = currentPage;
				Starling.juggler.tween(currentPage, .3, {alpha: 0, onComplete: function() {
						if (c != currentPage) // pokud rychle preklikavam mezi strankama, neni uz tohle nahodou zase currentPage?
							c.visible = false;
					}});
			}
			
			var page:Sprite = pages[index];
			currentPage = page;
			currentPage.visible = true; // uz byl pridan, ale neni videt, tak zviditelnim
			currentPage.touchable = true;
			currentPage.alpha = 0;
			Starling.juggler.tween(currentPage, .3, {alpha: 1});
			
			onPageChanged.dispatch(index);
		}
		
		public function nextPage():void {
			showPage(currentPageIndex + 1);
		}
		
		public function prevPage():void {
			showPage(currentPageIndex - 1);
		}
		
		/**
		 * Vysle signal pro inicializaci stranek.
		 * @param	page
		 */
		private function askForInit(index:uint):void {
			if (!pages[index])
				onPageInitNeeded.dispatch(index);
			
			//prosit o dalsi by mel az po chvili
			Starling.juggler.delayCall(function() {
					if (!pages[index + 1] && index + 1 < pagesCount)
						onPageInitNeeded.dispatch(index + 1);
					if (!pages[index - 1] && index - 1 > 0)
						onPageInitNeeded.dispatch(index - 1);
				}, .4);
		}
		
		/**
		 * Signal, ktery si rika o potrebu inicializace stranky.
		 * Jako parametr predava ID stranky, ktere je potreba.
		 * Tzn. callback je ve tvaru function(page:uint):void
		 */
		public function get onPageInitNeeded():ISignal {
			return _onPageInitNeeded;
		}
		
		/**
		 * Signal, ktery informuje o zmene stranky.
		 * Tzn. callback je ve tvaru function(page:uint):void
		 */
		public function get onPageChanged():ISignal {
			return _onPageChanged;
		}
		
		public function get pagesCount():int {
			return _pagesCount;
		}
		
		//*************************************************************//
		//********************  Event Listeners  **********************//
		//*************************************************************//
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			showPage(0);
		}
	
	}

}