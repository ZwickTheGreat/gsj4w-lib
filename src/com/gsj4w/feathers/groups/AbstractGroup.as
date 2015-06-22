package com.gsj4w.feathers.groups {
	import com.gsj4w.feathers.interfaces.IDimensionDiscoverable;
	import com.gsj4w.feathers.utils.FeathersUtils;
	import feathers.core.FeathersControl;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.HAlign;
	
	/**
	 * Groupa prvku.
	 * @author Jakub Wagner, J4W
	 */
	public class AbstractGroup extends FeathersControl {
		static public const INVALIDATION_FLAG_ITEMS_CHANGE:String = "invalidationFlagItemsChange";
		
		/**
		 * Scale, o ktere jsou zvetsovany vsechny rozmery.
		 */
		static public var defaultScale:Number = 1;
		
		public var paddingTop:Number = 0;
		public var paddingBottom:Number = 0;
		public var paddingLeft:Number = 0;
		public var paddingRight:Number = 0;
		
		/**
		 * Pokud true, jsou pozice objektu zaokrouhlovany na plne pixely.
		 */
		public var snapToPixels:Boolean = false;
		private var _manageVisibility:Boolean = false;
		private var _manageVisibilityRect:Rectangle = new Rectangle();
		private var RECTANGLE_HELPER:Rectangle = new Rectangle();
		
		protected var groupItems:Vector.<GroupItem> = new Vector.<GroupItem>()
		
		private var _background:DisplayObject;
		private var backgroundHolder:Sprite;
		private var _backgroundAutoSize:Boolean = false;
		
		public function AbstractGroup() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function layoutItems():void {
			throw new Error("Not implemented in abstract class.");
		}
		
		public function measureItems():void {
			throw new Error("Not implemented in abstract class.");
		}
		
		override protected function draw():void {
			measureItems();
			layoutItems();
			if (_background && _backgroundAutoSize) {
				_background.width = width;
				_background.height = height;
			}
			//Debugger.log(Inspector.getClassName(this, false) + "::draw() final size " + scaledActualWidth + "x" + scaledActualHeight);
		}
		
		override public function invalidate(flag:String = INVALIDATION_FLAG_ALL):void {
			super.invalidate(flag);
			scaledActualWidth = actualWidth = 0;
			scaledActualHeight = actualHeight = 0;
		}
		
		/**
		 * Pripne item na konec groupy. Rozmery jsou prepocitany s Shiraz.scale.
		 * @param	displayObject	pridavany prvek
		 * @param	space			odskok od posledniho prvku
		 * @param	align			zarovnani prvku (viz VAlign a HAlign)
		 * @param	size			sirka pridavaneho prvku.. pokud je -1, pokusi se ji ziskat z display object
		 * @param	index			na jaky index se ma prvek vlozit, pokud -1, vlozi se nakonec
		 * @return  vraci sam sebe (displayObject z parametru)
		 */
		public function appendChild(displayObject:DisplayObject, space:Number = 0, align:String = HAlign.LEFT, size:Number = -1, index:int = -1):DisplayObject {
			var groupItem:GroupItem = new GroupItem(displayObject, space, align, size);
			if (index != -1) {
				groupItems.splice(index, 0, groupItem);
				super.addChildAt(displayObject, index);
			} else {
				groupItems.push(groupItem);
				super.addChild(displayObject);
			}
			invalidate(INVALIDATION_FLAG_ITEMS_CHANGE);
			return displayObject;
		}
		
		/**
		 * Vrati prvek z groupy z urciteho indexu.
		 * @param	number
		 */
		public function getGroupItemAt(index:uint):DisplayObject {
			if (!groupItems[index])
				throw new RangeError(index + " is out of range");
			return groupItems[index].displayObject;
		}
		
		/**
		 * Vrati pocet prvku v groupe.
		 * @param	number
		 */
		public function getGroupNumChildren():uint {
			return groupItems.length;
		}
		
		/**
		 * Vrati kolikaty je prvek v dane groupe (opravdove poradi, ne z-index)
		 * -1 pokud neni nalezen
		 * @param	displayObject
		 * @return
		 */
		public function getGroupItemIndex(displayObject:DisplayObject):int {
			for each (var item:GroupItem in groupItems) {
				if (item.displayObject == displayObject) {
					return groupItems.indexOf(item);
				}
			}
			return -1;
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean = false):DisplayObject {
			for each (var item:GroupItem in groupItems) {
				if (item.displayObject == child) {
					var i:int = groupItems.indexOf(item);
					groupItems.splice(i, 1);
					invalidate(INVALIDATION_FLAG_ITEMS_CHANGE);
					return super.removeChild(child, dispose);
				}
			}
			throw new Error("You can't remove child from Group, which was not added with appendChild function.");
		}
		
		/**
		 * Removes all items from group.
		 */
		public function clear(dispose:Boolean = false):void {
			for each (var item:GroupItem in groupItems) {
				removeChild(item.displayObject, dispose);
			}
		}
		
		protected function getItemWidth(displayObject:DisplayObject):Number {
			var displayObjectWidth:Number = displayObject.width;
			var feathersControl:FeathersControl = displayObject as FeathersControl;
			if (feathersControl && feathersControl.isInvalid()) {
				FeathersUtils.politeValidate(feathersControl);
				displayObjectWidth = feathersControl.width;
			} else if (displayObject is IDimensionDiscoverable) {
				displayObjectWidth = (displayObject as IDimensionDiscoverable).realWidth;
			}
			return displayObjectWidth;
		}
		
		protected function getItemHeight(displayObject:DisplayObject):Number {
			var displayObjectHeight:Number = displayObject.height;
			var feathersControl:FeathersControl = displayObject as FeathersControl;
			if (feathersControl && feathersControl.isInvalid()) {
				FeathersUtils.politeValidate(feathersControl);
				displayObjectHeight = feathersControl.height;
			} else if (displayObject is IDimensionDiscoverable) {
				displayObjectHeight = (displayObject as IDimensionDiscoverable).realHeight;
			}
			return displayObjectHeight;
		}
		
		public function get background():DisplayObject {
			return _background;
		}
		
		public function set background(value:DisplayObject):void {
			if (_background)
				_background.removeFromParent();
			
			_background = value;
			
			if (!backgroundHolder) {
				backgroundHolder = new Sprite();
				super.addChildAt(backgroundHolder, 0);
			}
			
			backgroundHolder.addChild(_background);
		}
		
		/**
		 * Sets/gets the background color. Automatically sets backgroundAutoSize to true.
		 */
		public function get backgroundColor():uint {
			return (_background is Quad) ? (_background as Quad).color : 0x000000;
		}
		
		public function set backgroundColor(value:uint):void {
			if (_background is Quad)
				(_background as Quad).color = value;
			else {
				background = new Quad(10, 10, value);
				backgroundAutoSize = true;
			}
		}
		
		/**
		 * Pokud true, rozmery pozadi jsou automaticky nastaveny na rozmery group.
		 */
		public function get backgroundAutoSize():Boolean {
			return _backgroundAutoSize;
		}
		
		public function set backgroundAutoSize(value:Boolean):void {
			if (_backgroundAutoSize != value) {
				_backgroundAutoSize = value;
				invalidate(INVALIDATION_FLAG_SKIN);
			}
		}
		
		/**
		 * Pokud true, tak kazdy frame je zjistovano, zda jsou vsechny prvky groupy umistene v manageVisibilityRect.
		 * Pokud nejsou, je jim nastaveno visible na false.
		 */
		public function get manageVisibility():Boolean {
			return _manageVisibility;
		}
		
		public function set manageVisibility(value:Boolean):void {
			if (_manageVisibility == value)
				return;
			
			_manageVisibility = value;
			
			if (value)
				addEventListener(Event.ENTER_FRAME, onVisibilityCheckEnterFrame);
			else
				removeEventListener(Event.ENTER_FRAME, onVisibilityCheckEnterFrame);
		}
		
		/**
		 * Bounds ve kterych budou prvky groupy viditelne. Coords related to stage.
		 * Default: new Rectangle(0, 0, stageWidth, stageHeight);
		 */
		public function get manageVisibilityRect():Rectangle {
			return _manageVisibilityRect;
		}
		
		public function set manageVisibilityRect(value:Rectangle):void {
			_manageVisibilityRect = value;
		}
		
		/**
		 * Nastavi vsec¨hna padding. Getter vraci paddingTop.
		 */
		public function get padding():Number {
			return paddingTop;
		}
		
		public function set padding(value:Number):void {
			paddingLeft = paddingRight = paddingTop = paddingBottom = value;
		}
		
		//*************************************************************//
		//********************  Event Listeners  **********************//
		//*************************************************************//
		
		private function onVisibilityCheckEnterFrame(e:Event):void {
			if (!visible || !parent.visible)
				return;
			
			var l:int = groupItems.length;
			for (var i:int = 0; i < l; i++) {
				var displayObject:DisplayObject = groupItems[i].displayObject;
				displayObject.getBounds(stage, RECTANGLE_HELPER);
				displayObject.visible = RECTANGLE_HELPER.intersects(manageVisibilityRect);
			}
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if (_manageVisibilityRect.isEmpty())
				_manageVisibilityRect.setTo(0, 0, stage.stageWidth, stage.stageHeight);
		}
	
	}

}