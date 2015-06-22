package com.gsj4w.utils {
	import flash.desktop.NativeApplication;
	
	/**
	 * Vytahuje info z app deskriptoru.
	 * @author Jakub Wagner, J4W
	 */
	public class ApplicationInfo {
		static private var appBundleId:String;
		static private var appVersion:String;
		
		public static function getVersion():String {
			if (!appVersion) {
				var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace = appXml.namespace();
				appVersion = appXml.ns::versionNumber[0] + (appXml.ns::versionLabel[0] ? (" " + appXml.ns::versionLabel[0]) : "");
			}
			return appVersion;
		}
		
		public static function getBundleId():String {
			if (!appBundleId) {
				var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace = appXml.namespace();
				appBundleId = appXml.ns::id[0];
			}
			return appBundleId;
		}
	
	}

}