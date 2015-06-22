package com.gsj4w.feathers.components {
	import com.gsj4w.feathers.utils.FeathersUtils;
	import feathers.controls.PageIndicator;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import feathers.core.FeathersControl;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Komponenta, která drží několik stránek, mezi kterýma se dá swipovat (doprava doleva).
	 * @author Jakub Wagner, J4W
	 */
	public class SwipingComponent extends FeathersControl {
		static public const INVALIDATION_FLAG_PAGE:String = "page";
		
		static public var defaultScale:Number = 1;
		
		/**
		 * Pokud true, bude se pri skrollovani pozice zaokrouhlavat na cele px.
		 */
		public var snapScrollPositionsToPixels:Boolean = false;
		/**
		 * Prvni stranka, na kterou to po vytvoreni skoci (nemusi byt vzdy 0).
		 */
		private var _initialPageIndex:uint = 0;
		
		private var pages:Array;
		private var pagesHolder:Sprite;
		private var currentPage:Sprite;
		private var currentPageIndex:int = -1;
		private var pagesCount:Number;
		
		private var autoDisableTouch:Boolean = false;
		
		private var _pageIndicator:PageIndicator;
		
		private var _onPageInitNeeded:ISignal = new Signal(uint);
		private var _onPageChanged:ISignal = new Signal(uint);
		
		/**
		 *
		 * @param	_pagesCount			Pocet stranek
		 * @param	autoDisableTouch	Pokud true, automaticky nastavuje neviditelnym strankam touchable = false
		 */
		public function SwipingComponent(_pagesCount:uint = 10, autoDisableTouch:Boolean = true) {
			this.autoDisableTouch = autoDisableTouch;
			pagesCount = _pagesCount;
			
			pages = new Array();
			pagesHolder = new Sprite();
			
			addChild(pagesHolder);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		override protected function initialize():void {
			pagesHolder.x = -initialPageIndex * width
			showPage(initialPageIndex);
		}
		
		override public function validate():void {
			if (!this.stage || !this._isInitialized || !this.isInvalid()) {
				return;
			}
			if (isInvalid(INVALIDATION_FLAG_SIZE)) {
				if (explicitWidth && explicitHeight)
					clipRect = new Rectangle(0, 0, explicitWidth, explicitHeight);
			}
			super.validate();
			if (explicitWidth) {
				actualWidth = scaledActualWidth = explicitWidth;
			} else {
				actualWidth = scaledActualWidth = currentPage ? currentPage.width : 0
			}
			if (explicitHeight) {
				actualHeight = scaledActualHeight = explicitHeight;
			} else {
				actualHeight = scaledActualHeight = currentPage ? currentPage.height : 0;
			}
		}
		
		/**
		 * Inicializuje stranku.
		 * @param	pageSprite		Sprite stranky
		 * @param	page		Cislo stranky.
		 */
		public function initPage(pageSprite:Sprite, page:uint):void {
			var sprite:Sprite = new Sprite();
			sprite.addChild(pageSprite);
			
			pages[page] = sprite;
			pagesHolder.addChild(sprite);
			sprite.x = page * width;
			sprite.visible = false;
			if (autoDisableTouch)
				sprite.touchable = false;
		}
		
		/**
		 * Zobrazi stranku.
		 * @param	number	c
		 */
		private function showPage(page:uint):void {
			animateBoundTo(page);
			
			if (currentPageIndex == page)
				return;
			
			currentPageIndex = page;
			
			askForInit(currentPageIndex);
			
			if (currentPage) { // minulou stranku zneaktivnim
				if (autoDisableTouch)
					currentPage.touchable = false;
			}
			currentPage = pages[page] as Sprite;
			currentPage.touchable = true;
			
			for (var i:int = 0; i < pagesCount; i++) {
				var p:Sprite = (pages[i] as Sprite);
				if (p) {
					p.visible = false;
				}
			}
			
			currentPage.unflatten();
			currentPage.visible = true;
			var prevPage:Sprite = (pages[currentPageIndex - 1] as Sprite);
			var nextPage:Sprite = (pages[currentPageIndex + 1] as Sprite);
			if (prevPage)
				prevPage.visible = true;
			if (nextPage)
				nextPage.visible = true;
			
			if (_pageIndicator) {
				_pageIndicator.selectedIndex = page;
			}
			
			invalidate(INVALIDATION_FLAG_PAGE);
			
			onPageChanged.dispatch(page);
		}
		
		private function animateBoundTo(page:uint):void {
			Starling.juggler.tween(pagesHolder, .3, {transition: Transitions.EASE_OUT, x: -page * width, roundToInt: snapScrollPositionsToPixels, onComplete: animateBoundToComplete});
		}
		
		/**
		 * Po doanimovani shovam vsechny krome currentPage.
		 */
		private function animateBoundToComplete():void {
			//TODO: shovat vsechny krome jedny, tak jako je to ted, pouze pri nejakem flagu (keepNeighboursVisible?)
			
			for (var i:int = 0; i < pagesCount; i++) {
				var p:Sprite = (pages[i] as Sprite);
				if (p && i != currentPageIndex) {
					p.visible = false;
					if (!p.isFlattened)
						p.flatten();
				}
			}
		}
		
		/**
		 * Vysle signal pro inicializaci stranek.
		 * @param	page
		 */
		private function askForInit(page:uint):void {
			if (!pages[page])
				onPageInitNeeded.dispatch(page);
			
			//prosit o dalsi by mel az po najeti aktualni stranky
			Starling.juggler.delayCall(function():void {
					if (!pages[page + 1] && page + 1 < pagesCount)
						onPageInitNeeded.dispatch(page + 1);
					if (!pages[page - 1] && page - 1 >= 0)
						onPageInitNeeded.dispatch(page - 1);
				}, .3);
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
		
		public function get initialPageIndex():uint {
			return _initialPageIndex;
		}
		
		public function set initialPageIndex(value:uint):void {
			value = Math.max(0, Math.min(value, pagesCount - 1));
			_initialPageIndex = value;
		}
		
		public function get pageIndicator():PageIndicator {
			return _pageIndicator;
		}
		
		public function set pageIndicator(value:PageIndicator):void {
			if (_pageIndicator) {
				_pageIndicator.removeFromParent();
			}
			_pageIndicator = value;
			_pageIndicator.pageCount = pagesCount;
			_pageIndicator.selectedIndex = currentPageIndex;
			addChild(pageIndicator);
		}
		
		//*************************************************************//
		//********************  Event Listeners  **********************//
		//*************************************************************//
		
		static private const MOVEMENT_LOCK_LIMIT:Number = 20;
		private var movement:Point = new Point();
		private var movementLock:Boolean = false;
		private var parentScrollDisabled:Boolean = false;
		
		private function onTouch(e:TouchEvent):void {
			var touch:Touch = e.getTouch(this);
			
			if (touch) {
				if (touch.target is Slider || touch.target.parent is Slider) { // pokud to je slider, nehybeme vubec (jinak by neslo sldier ovladat)
					e.stopImmediatePropagation();
					return;
				}
				if (touch.phase == TouchPhase.BEGAN) {
					movementLock = false;
					
					var prevPage:Sprite = (pages[currentPageIndex - 1] as Sprite);
					var nextPage:Sprite = (pages[currentPageIndex + 1] as Sprite);
					if (prevPage)
						prevPage.visible = true;
					if (nextPage)
						nextPage.visible = true;
				} else if (!movementLock && touch.phase == TouchPhase.MOVED) {
					touch.getMovement(this, movement);
					var absMovX:Number = Math.abs(movement.x);
					var absMovY:Number = Math.abs(movement.y);
					
					if (!parentScrollDisabled && absMovX > MOVEMENT_LOCK_LIMIT * defaultScale) {
						parentScrollDisabled = true;
						FeathersUtils.stopParentScroll(parent);
						disableChildrenScroll(currentPage);
					}
					
					if (absMovY > absMovX && absMovY > MOVEMENT_LOCK_LIMIT * defaultScale) {
						movementLock = true;
						animateBoundTo(currentPageIndex);
						currentPage.touchable = true;
						return;
					}
					pagesHolder.x += movement.x;
					
					if (snapScrollPositionsToPixels) {
						pagesHolder.x = Math.round(pagesHolder.x);
					}
					
					// (starling je nejakej divnej v kombinaci s tim, ze mu chybi moznost nastavit si u event listeneru prioritu)
					// ani kdyz nastavim listener na stage, tak se neustale jako prvni vyrizuji eventy deti na stage, takze
					// nemama sanci zavolat stopImmidiatePropagation, nebo cokoliv... sice tu nastavim touchable na false, ale
					// to uz je pozde, protoze onTouch byl obslouzen napriklad u buttonu...
					if (absMovX > MOVEMENT_LOCK_LIMIT * defaultScale) {
						currentPage.touchable = false; // stranka pri pohybu nereaguje na dotyk
						if (touch.target is FeathersControl) // pokud je to komponenta, radeji ji zamknu (viz koment)
							touch.target.touchable = false;
					}
				} else if (touch.phase == TouchPhase.ENDED) {
					var movementToLeft:Boolean = movement.x < 0;
					var boundTo:int = -Math.round((pagesHolder.x / width) - (movementToLeft ? 0.25 : -0.25));
					boundTo = boundTo < 0 ? 0 : boundTo;
					boundTo = boundTo >= pagesCount ? pagesCount - 1 : boundTo;
					
					movementLock = false;
					parentScrollDisabled = false;
					
					currentPage.touchable = true;
					if (touch.target is FeathersControl) // pokud je to komponenta, odemknu ji (v move ji zamykam)
						touch.target.touchable = true;
					showPage(boundTo);
				}
			}
		}
		
		private function onAddedToStage(e:Event):void {
			if (pagesCount > 1)
				addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onRemovedFromStage(e:Event):void {
			removeEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function disableChildrenScroll(displayObject:DisplayObject):void {
			var scrollContainer:ScrollContainer = displayObject as ScrollContainer; // pokud je to scroll container, vypni ho
			if (scrollContainer)
				scrollContainer.stopScrolling();
			
			var displayObjectContainer:DisplayObjectContainer = displayObject as DisplayObjectContainer;
			if (displayObjectContainer) // pokud je to kontejner, aplikuj to same na jeho deti (rekurze)
				for (var i:int = 0; i < displayObjectContainer.numChildren; i++) {
					disableChildrenScroll(displayObjectContainer.getChildAt(i));
				}
		}
	
	}

}