package com.gsj4w.feathers.screens {
	import com.gsj4w.feathers.groups.VGroup;
	import com.gsj4w.feathers.utils.FrameRateController;
	import com.imageworks.debug.Debugger;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.utils.HAlign;
	
	/**
	 * Abstraktní screen.
	 * @author Jakub Wagner, J4W
	 */
	public class AbstractScreen extends Screen {
		
		/**
		 * Scroll container. Defaulne je null, je vytvoren az teprve pri prvnim volani appendChild().
		 */
		protected var scrollContainer:ScrollContainer;
		
		/**
		 * Groupa drzici prvky.
		 */
		protected var vGroup:VGroup;
		
		/**
		 * Pokud true, je rozdělena inicializace do dvou fází - aby uživatel neviděl seknutí během příjíždění screenu,
		 * tak toho vykreslím méně. Zbytek vykreslím až později v delayedInitialize().
		 *
		 * Defaultně se v initialize() volá createPreloader(), která defaultně vytvoří nápis "Loading...".
		 */
		protected var useDelayedInit:Boolean = false;
		
		/**
		 * Urcuje, zda je dany screen navrzen jako landscape, ci nikoliv.
		 * Pokud ne (false):
		 * - vzdy se vyuzije jako stageWidth sirka displeje telefonu v portrait modu (stageWidth nebo fullscreenHeight)
		 */
		protected var isLandscapeScreen:Boolean = false;
		
		/**
		 * Vyska k pouziti timto screenem. Na tuto vysku se automaticky snazi zvetsit ScrollContainer.
		 * Pokud je -1, je pouzita stageHeight
		 */
		protected var _availableHeight:Number = -1;
		
		/**
		 * True nebo false, podle toho zda jiz probehla delayed initializace.
		 */
		protected var isDelayedInitialized:Boolean = false;
		
		public function AbstractScreen(useDelayedInit:Boolean = false) {
			this.useDelayedInit = useDelayedInit;
			Starling.current.nativeStage.addEventListener(Event.RESIZE, onNativeStageResize);
		}
		
		override protected function initialize():void {
			clipRect = new Rectangle(0, 0, stageWidth, stageHeight);
			if (useDelayedInit) {
				createPreloader();
			}
		}
		
		override public function dispose():void {
			destroyPreloader(); // aby mi ho nesezral dispose...
			super.dispose();
		}
		
		/**
		 * Volá se po dokončení animace screenu. (screen přijíždí zboku)
		 */
		protected function delayedInitialize():void {
		
		}
		
		/**
		 * Pokud true, je rozdělena inicializace do dvou fází - aby uživatel neviděl seknutí během příjíždění screenu,
		 * tak toho vykreslím méně. Zbytek vykreslím až později v delayedInitialize().
		 *
		 * Defaultně se v initialize() volá createPreloader(), která defaultně vytvoří nápis "Loading...".
		 */
		public function isUsingDelayedInitialisation():Boolean {
			return useDelayedInit;
		}
		
		/**
		 * Veřejná funkce, která umožňuje zvenčí zavolat delayed inicializaci.
		 * Hlavně pro využití AbstractNavigatorem.
		 */
		public function doDelayedInitialisation():void {
			if (useDelayedInit && !isDelayedInitialized) {
				destroyPreloader();
				try {
					delayedInitialize();
					FrameRateController.stayActive(500);
				}
				catch (err:Error) {
					Debugger.error("AbstractScreen::doDelayedInitialisation() ERROR #" + err.errorID + " - " + err.message);
					Debugger.error(err.getStackTrace());
				}
				isDelayedInitialized = true;
			}
		}
		
		/**
		 * Vraci vysku headeru. Pokud nema menu, vraci 0.
		 */
		public function getHeaderHeight():Number {
			return 0;
		}
		
		/**
		 * Vraci stageWidth nejen podle aktualni stageWidth, ale zahranuje do sebe predpoklad o jaky screen jde
		 * tzn. pokud je to landscapeScreen, tak pocita s landscape sirkou, tak mu nikdy (i kdyby jeste nebyl adobe air stage pretocenej) spatny udaje
		 */
		public function get stageWidth():Number {
			if (isLandscapeScreen) {
				return Math.max(Starling.current.stage.stageWidth, Starling.current.nativeStage.fullScreenHeight); // delsi z techto dvou
			} else {
				return Math.min(Starling.current.stage.stageWidth, Starling.current.nativeStage.fullScreenHeight); // kratsi s techto dvou
			}
		}
		
		/**
		 * Vraci stageHeight nejen podle aktualni stageHeight, ale zahranuje do sebe predpoklad o jaky screen jde
		 * tzn. pokud je to landscapeScreen, tak pocita s landscape sirkou, tak mu nikdy (i kdyby jeste nebyl adobe air stage pretocenej) spatny udaje
		 */
		public function get stageHeight():Number {
			if (isLandscapeScreen) {
				return Math.min(Starling.current.stage.stageHeight, Starling.current.nativeStage.fullScreenWidth); // kratsi z techto dvou
			} else {
				return Math.max(Starling.current.stage.stageHeight, Starling.current.nativeStage.fullScreenWidth); // delsi s techto dvou
			}
		}
		
		private var _backId:String;
		
		/**
		 * Nastaví ID screenum na které to má přejít po stisku tlačítka zpět.
		 * Automaticky nastavi handler zmacknuti na androidu na zpět.
		 *  + Přidá tlačítko do Headeru.
		 */
		public function get backId():String {
			return _backId;
		}
		
		public function set backId(value:String):void {
			backButtonHandler = defaultBackButtonHandler;
			_backId = value;
		}
		
		protected function defaultBackButtonHandler():void {
			dispatchEventWith("back", false, {screenId: backId});
			backButtonHandler = null;
		}
		
		/**
		 * Vyska k pouziti timto screenem. Na tuto vysku se automaticky snazi zvetsit napr. ScrollContainer.
		 * Pokud je -1, je pouzita stageHeight;
		 */
		public function get availableHeight():Number {
			return _availableHeight;
		}
		
		/**
		 * Vyska k pouziti timto screenem. Na tuto vysku se automaticky snazi zvetsit napr. ScrollContainer.
		 * Pokud je -1, je pouzita stageHeight;
		 */
		public function set availableHeight(value:Number):void {
			_availableHeight = value;
			
			if (scrollContainer) {
				scrollContainer.setSize(stageWidth, availableHeight);
			}
		}
		
		/**
		 * Pripne item na konec scroll containeru. Rozmery jsou prepocitany s Shiraz.scale.
		 * @param	displayObject
		 * @param	space			odskok od posledniho prvku
		 * @param	align			zarovnani prvku (viz HAlign)
		 * @param	size			sirka pridavaneho prvku.. pokud je -1, pokusi se ji ziskat z display object
		 * @return  vraci sam sebe (displayObject z parametru)
		 */
		protected function appendChild(displayObject:DisplayObject, space:Number = 0, align:String = HAlign.LEFT, size:Number = -1, index:int = -1):DisplayObject {
			if (!displayObject) {
				throw new Error("You cannot append null displayObject");
			}
			
			if (!scrollContainer) {
				createScrollContainer();
				createVGroup();
			}
			
			vGroup.appendChild(displayObject, space, align, size, index);
			return displayObject;
		}
		
		/**
		 * Pro všechny screeny stačí jedna instance.
		 */
		private static var preloader:DisplayObject;
		
		/**
		 * Vytvořím jen preloader - aby uživatel neviděl seknutí během příjíždění screenu,
		 * tak toho vykreslím méně. Zbytek vykreslím až později v delayedInitialize().
		 */
		protected function createPreloader():void {
			if (!preloader) { // pokud neexistuje, vytvorim
				preloader = preloaderFactory();
			}
			// pokud existuje, poze pridej do display listu
			preloader.x = stageWidth / 2 - preloader.width / 2;
			preloader.y = stageHeight / 2 - preloader.height / 2;
			addChild(preloader);
		}
		
		protected function destroyPreloader():void {
			if (preloader && preloader.parent == this) {
				preloader.removeFromParent();
			}
		}
		
		protected function preloaderFactory():DisplayObject {
			throw new Error("Preloader factory not implemented!");
			return null;
		}
		
		/**
		 * Vytvoří scroll container.
		 */
		protected function createScrollContainer():void {
			scrollContainer = new ScrollContainer();
			scrollContainer.setSize(stageWidth, availableHeight);
			scrollContainer.y = getHeaderHeight();
			addChildAt(scrollContainer, 0);
		}
		
		/**
		 * Vytvoří scroll container.
		 */
		protected function createVGroup():void {
			vGroup = new VGroup();
			vGroup.name = "AbstractScreenVGroup";
			vGroup.width = stageWidth;
			scrollContainer.addChild(vGroup);
		}
		
		/**
		 * Pokud se zmenil obsah, je potreba obnovit scrollcontainer. Ojebavka chyby v feathers.... Sam se proste neupdatne ani po invalidate().
		 */
		protected function updateScrollContainerSize():void {
			if (scrollContainer)
				scrollContainer.setSize(scrollContainer.width, scrollContainer.height + 0.0000001);
			// scroll container overuje pri volani setSize, zda ta vyska neni ta, ktera uz byla a pak nic neudela...
			// jelikoz nereaguje na invalidate a vubec nic, jedine co obslouzi je toto
		}
		
		private function onNativeStageResize(e:Event):void {
			clipRect = new Rectangle(0, 0, stageWidth, stageHeight);
			if (scrollContainer)
				scrollContainer.setSize(stageWidth, availableHeight);
		}
	
	}

}