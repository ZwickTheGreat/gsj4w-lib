package com.gsj4w.feathers.groups {
	import starling.display.DisplayObject;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Jedná se o horizonzální grupu, která má jasně definované minimální rozpaly mezi 2ma prvky.
	 * @author Jakub Wagner, J4W
	 */
	public class TabHGroup extends HGroup {
		protected var gaps:Array;
		protected var aligns:Array;
		
		/**
		 * HGroupa, ktera ma prednastaveny sirky mezi pridavanymi objekty.
		 * Ma parametr gaps a aligns.
		 * Napriklad gaps [300,200], bude donekoncna delat taby 300,200,300,200 atd...
		 * Napriklad aligns [HAlign.LEFT,HAlign.CENTER], bude donekoncna delat taby zarovnane vlevo, a uprostred ...
		 * @param	gaps		Pole tabu, jak maji jit za sebou v pixelech. Ty budou vynasobeny o scale.
		 * 						Defaultně je [300] (bude delat donekonecna taby 300)
		 * @param	aligns		Pole, jak ma byt zarovanyn obsah v tabu.
		 * 						Defaultně je [HAlign.LEFT] (všechny budou v tabu zarovnány na levo)
		 */
		public function TabHGroup(gaps:Array = null, aligns:Array = null) {
			if (!gaps) {
				gaps = [300];
			} else {
				for (var i:int = 0; i < gaps.length; i++) { // kontrola zda jsou gaps cisla
					if (isNaN(gaps[i]) && isFinite(gaps[i])) {
						throw new Error("Gap " + i + " i NaN or Infinite!! " + gaps);
					}
				}
			}
			if (!aligns) {
				aligns = [HAlign.LEFT];
			}
			
			this.aligns = aligns;
			this.gaps = gaps;
		}
		
		override public function appendChild(displayObject:DisplayObject, space:Number = 0, align:String = VAlign.TOP, size:Number = -1, index:int = -1):DisplayObject {
			return super.appendChild(displayObject, space, align, gaps[groupItems.length % gaps.length]);
		}
		
		override public function layoutItems():void {
			super.layoutItems();
			
			for each (var groupItem:GroupItem in groupItems) {
				var a:DisplayObject = groupItem.displayObject;
				
				var index:int = getGroupItemIndex(a);
				var gap:Number = gaps[index % gaps.length] * AbstractGroup.defaultScale;
				var align:String = aligns[index % aligns.length];
				
				switch (align) {
					case HAlign.CENTER: 
						a.x += gap / 2 - a.width / 2;
						break;
					case HAlign.RIGHT: 
						a.x += gap - a.width;
						break;
				}
				
				if (snapToPixels) {
					a.x = Math.floor(a.x);
					a.y = Math.floor(a.y);
				}
			}
		}
	}

}