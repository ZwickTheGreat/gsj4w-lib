package com.gsj4w.feathers.components {
	import com.gsj4w.feathers.groups.TabHGroup;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.events.FeathersEventType;
	import flash.text.TextFormat;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Komponenta, ktera umi pobrat libovolnou komponentu a pridat k ni label.
	 * S vybranymi komponentami umi spolupracovat i tak, ze posloucha jejich focus a change eventy a chova s podle toho (meni pozadi, barvu pisma atp.)
	 * @author Jakub Wagner, J4W
	 */
	public class ItemWithLabel extends FeathersControl {
		public var labelFactory:Function = FeathersControl.defaultTextRendererFactory;
		
		public var backgroundSkin:DisplayObject;
		public var backgroundFocusedSkin:DisplayObject;
		
		private var tabHGroup:TabHGroup;
		
		private var tfLabel:TextFieldTextRenderer;
		private var _item:DisplayObject;
		
		private var _label:String = "";
		private var _labelColor:Number;
		private var _paddingLeft:Number = 0;
		private var _paddingRight:Number = 0;
		
		private var _itemWidth:Number;
		
		public function ItemWithLabel() {
		}
		
		override protected function initialize():void {
			tfLabel = labelFactory();
			tfLabel.wordWrap = true;
		}
		
		override protected function draw():void {
			if (isInvalid()) {
				if (isInvalid(INVALIDATION_FLAG_STYLES)) {
					var t:TextFormat = tfLabel.textFormat;
					if (t.color != labelColor) {
						t.color = labelColor;
						tfLabel.textFormat = t;
					}
				}
				if (isInvalid(INVALIDATION_FLAG_DATA)) {
					tfLabel.text = label;
				}
				if (isInvalid(INVALIDATION_FLAG_SIZE)) {
					tfLabel.width = explicitWidth - itemWidth - paddingLeft - paddingRight;
					if (backgroundSkin) {
						backgroundSkin.width = explicitWidth;
						backgroundSkin.height = explicitHeight;
					}
					if (backgroundFocusedSkin) {
						backgroundFocusedSkin.width = explicitWidth;
						backgroundFocusedSkin.height = explicitHeight;
					}
				}
				
				item.width = itemWidth;
				item.height = explicitHeight - 1;
				
				var oldHGroup:TabHGroup = tabHGroup;
				
				tabHGroup = new TabHGroup([(explicitWidth - itemWidth - paddingRight), itemWidth], [HAlign.LEFT, HAlign.RIGHT]);
				tabHGroup.background = backgroundSkin;
				tabHGroup.appendChild(tfLabel, paddingLeft, VAlign.CENTER);
				tabHGroup.appendChild(item);
				addChild(tabHGroup);
				tabHGroup.validate();
				
				if (oldHGroup) {
					oldHGroup.removeFromParent(true);
				}
			}
			scaledActualWidth = actualWidth = explicitWidth;
			scaledActualHeight = actualHeight = explicitHeight;
			super.draw();
		}
		
		/**
		 * Item width.
		 */
		public function get itemWidth():Number {
			return _itemWidth;
		}
		
		public function set itemWidth(value:Number):void {
			invalidate(INVALIDATION_FLAG_SIZE);
			_itemWidth = value;
		}
		
		/**
		 * Label.
		 */
		public function get label():String {
			return _label;
		}
		
		public function set label(value:String):void {
			invalidate(INVALIDATION_FLAG_DATA);
			_label = value;
		}
		
		/**
		 * Prvek.
		 */
		public function get item():DisplayObject {
			return _item;
		}
		
		public function set item(value:DisplayObject):void {
			invalidate(INVALIDATION_FLAG_DATA);
			_item = value;
			
			if (_item is FeathersControl) {
				var feathersControl:FeathersControl = _item as FeathersControl;
				feathersControl.addEventListener(FeathersEventType.FOCUS_IN, onFeathersControlFocusIn);
				feathersControl.addEventListener(FeathersEventType.FOCUS_OUT, onFeathersControlFocusOut);
			}
		}
		
		/**
		 * Left padding-
		 */
		public function get paddingLeft():Number {
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void {
			_paddingLeft = value;
		}
		
		/**
		 * Right padding.
		 */
		public function get paddingRight():Number {
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void {
			_paddingRight = value;
		}
		
		/**
		 * Label color.
		 */
		public function get labelColor():Number {
			return _labelColor;
		}
		
		public function set labelColor(value:Number):void {
			_labelColor = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		//*************************************************************//
		//********************  Event Listeners  **********************//
		//*************************************************************//
		
		private function onFeathersControlFocusIn(e:Event):void {
			tabHGroup.background = backgroundFocusedSkin || backgroundSkin;
		}
		
		private function onFeathersControlFocusOut(e:Event):void {
			tabHGroup.background = backgroundSkin;
		}
	
	}

}