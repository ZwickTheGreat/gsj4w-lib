package com.gsj4w.feathers.interfaces {
	
	/**
	 * Interface.
	 * @see #realHeight
	 * @author Jakub Wagner, J4W
	 */
	public interface IDimensionDiscoverable {
		/**
		 * Vrací šířku některých komponent ještě dříve, než je opravdu jejich šířka nastavena.
		 * Jedná se například o problém nevalidních komponent...
		 * @see feathers.core.FeathersControl#invalidate
		 */
		function get realWidth():Number;
		
		/**
		 * Vrací výšku některých komponent ještě dříve, než je opravdu jejich výška nastavena.
		 * Jedná se například o problém nevalidních komponent...
		 * @see feathers.core.FeathersControl#invalidate
		 */
		function get realHeight():Number;
	}

}