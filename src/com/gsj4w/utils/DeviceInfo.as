package com.gsj4w.utils {
	import flash.system.Capabilities;
	
	/**
	 * Device info.
	 * @author Jakub Wagner, J4W
	 */
	public class DeviceInfo {
		static private var initialized:Boolean = false;
		
		static private var _isIOS7:Boolean = false;
		static private var _isIOS:Boolean;
		static private var _isAndroid:Boolean;
		
		public function DeviceInfo() {
		}
		
		/**
		 * @return true, pokud jsme na ios a je verze 7.
		 */
		static public function isIOS7():Boolean {
			init();
			return _isIOS7;
		}
		
		/**
		 * @return true, pokud jsme na ios
		 */
		static public function isIOS():Boolean {
			init();
			return _isIOS;
		}
		
		/**
		 * @return true, pokud jsme na androidu
		 */
		static public function isAndroid():Boolean {
			init();
			return _isAndroid;
		}
		
		/**
		 * Na nekterych zarizenich saha nativni status bar do stage.
		 * Napriklad na iOS 7 lista zabira 40 px.
		 * @return	Vysku status baru, resp. potrebny margin od vrsku stage.
		 */
		static public function getStatusBarHeight():Number {
			var statusBarHeight:Number = 0;
			if (isIOS7()) { // v iOS7 je statusbar pruhledny - prekryva nas header
				statusBarHeight = 40; // http://ivomynttinen.com/blog/the-ios-7-design-cheat-sheet/
			}
			return statusBarHeight;
		}
		
		static private function init():void {
			if (initialized)
				return;
			initialized = true;
			
			_isIOS = (Capabilities.manufacturer.indexOf("iOS") != -1);
			_isAndroid = (Capabilities.manufacturer.indexOf("Android") != -1);
			
			if (_isIOS) {
				var osInfo:Array = Capabilities.os.split(" ");
				if (osInfo[0] == "iPhone") {
					var versionNumber:Number = parseFloat(osInfo[2]);
					if (versionNumber >= 7) {
						_isIOS7 = true;
					}
				}
			}
		}
	
	}

}