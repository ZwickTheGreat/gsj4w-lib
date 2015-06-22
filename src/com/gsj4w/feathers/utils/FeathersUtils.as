package com.gsj4w.feathers.utils {
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	/**
	 * Utils pro Feathers.
	 * @author Jakub Wagner, J4W
	 */
	public class FeathersUtils {
		
		public function FeathersUtils() {
		
		}
		
		/**
		 * Zvaliduje FeathersControl. Pokud neni na stage, prida ho.
		 * Pozor, muze vyvolavat eventy ADDED_TO_STAGE, REMOVED_FROM_STAGE
		 * @param	feathersControl
		 */
		static public function politeValidate(feathersControl:FeathersControl):void {
			if (feathersControl.stage) {
				feathersControl.validate();
			} else {
				var p:DisplayObjectContainer = feathersControl.parent;
				var childIndex:int;
				if (p) {
					childIndex = p.getChildIndex(feathersControl);
				}
				
				Starling.current.stage.addChild(feathersControl);
				feathersControl.validate();
				
				if (p) {
					p.addChildAt(feathersControl, childIndex);
				} else {
					feathersControl.removeFromParent();
				}
			}
		}
		
		/**
		 * Prohleda vsechy rodice a pokud je to ScrollContainer, zavola na nej stopScrolling()
		 * @param	parent
		 */
		static public function stopParentScroll(parent:DisplayObjectContainer):void {
			var p:DisplayObjectContainer = parent;
			while (p) { // projedu parenty a jestli je to scrollcontainer, vypnu scroll
				if (p is Scroller) {
					(p as Scroller).stopScrolling();
				}
				p = p.parent;
			}
		}
		
		/**
		 * Na vsechny rodice zavola invalidate(), pokud jsou FeathersControl.
		 * @param	displayObject		parent
		 * @param	flag				flag ktery se ma invalidovat
		 * @param	clazz				Classy, ktere se maji invalidovat
		 * 								pokud null, tak vsechny FeathersControl
		 * @param	validate			pokud true, po invalidaci ihned volano validate
		 */
		static public function invalideParents(displayObject:DisplayObject, flag:String = "all", clazz:Class = null, validate:Boolean = true):void {
			var p:DisplayObjectContainer = displayObject.parent;
			while (p && p != p.stage) {
				var feathersControl:FeathersControl = p as FeathersControl;
				if (feathersControl && (clazz == null || feathersControl is clazz)) {
					feathersControl.invalidate(flag);
					if (validate)
						feathersControl.validate();
				}
				p = p.parent;
			}
		
		}
	
	}

}