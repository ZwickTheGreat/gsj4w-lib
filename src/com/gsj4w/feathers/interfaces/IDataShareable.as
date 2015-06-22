package com.gsj4w.feathers.interfaces {
	import com.gsj4w.feathers.screens.data.SharedData;
	
	/**
	 * Screeny, ktere si mezi sebou potrebuji vymenovat data nech implementuji tento interface.
	 * @author Jakub Wagner, J4W
	 */
	public interface IDataShareable {
		function get sharedData():SharedData;
		function set sharedData(value:SharedData):void;
	}

}