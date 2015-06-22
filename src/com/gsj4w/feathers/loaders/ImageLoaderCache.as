package com.gsj4w.feathers.loaders {
	import feathers.controls.ImageLoader;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ImageLoader with cache.
	 * @author Jakub Wagner
	 */
	public class ImageLoaderCache extends ImageLoader {
		public static var MAX_ITEMS:uint = 40;
		
		private static var cacheList:Array = new Array();
		private static var cacheDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * If true, animates loader after image change (fadeIn alpha 0-1)
		 */
		public var fadeInOnLoaded:Boolean = true;
		
		public function ImageLoaderCache() {
			super();
		}
		
		/**
		 * Clears whole cache.
		 */
		public static function cacheClear():void {
			for each (var item:CacheItem in cacheList) {
				item.texture.dispose();
				item.bitmapData.dispose();
			}
			cacheList.length = 0;
		}
		
		/**
		 * Push item in cache.
		 */
		public static function cachePush(source:String, texture:Texture, bitmapData:BitmapData):CacheItem {
			var cacheItem:CacheItem = new CacheItem();
			cacheItem.source = source;
			cacheItem.texture = texture;
			cacheItem.bitmapData = bitmapData;
			
			cacheList.push(cacheItem);
			cacheDictionary[source] = cacheItem;
			
			if (cacheList.length > MAX_ITEMS) {
				cacheItem = cacheList.shift();
				cacheItem.texture.dispose();
				cacheItem.bitmapData.dispose();
				cacheDictionary[cacheItem.source] = null;
			}
			
			return cacheItem;
		}
		
		/**
		 * Gets item from cache by its source.
		 */
		public static function cacheGet(source:String):CacheItem {
			return cacheDictionary[source];
		}
		
		override protected function commitData():void {
			if (!(source is String))
				super.commitData();
			else {
				var c:CacheItem = cacheGet(String(source));
				if (c && c.bitmapData) {
					this._lastURL = c.source;
					replaceBitmapDataTexture(c.bitmapData);
				} else {
					super.commitData();
				}
			}
		}
		
		override protected function replaceBitmapDataTexture(bitmapData:BitmapData):void {
			if (!(source is String))
				super.replaceBitmapDataTexture(bitmapData);
			
			var c:CacheItem = cacheGet(String(source));
			if (!c || !c.texture) {
				super.replaceBitmapDataTexture(bitmapData);
				this._isTextureOwner = false;
				cachePush(String(source), _texture, _textureBitmapData);
				return;
			}
			
			this._texture = c.texture;
			if (Starling.handleLostContext) {
				this._textureBitmapData = c.bitmapData;
			} else {
				bitmapData.dispose();
			}
			this._isTextureOwner = false;
			this._isLoaded = true;
			refreshCurrentTexture();
			animateFadeIn();
			
			invalidate(INVALIDATION_FLAG_LAYOUT);
			
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
		
		override public function set source(value:Object):void {
			if (fadeInOnLoaded)
				alpha = 1;
			super.source = value;
		}
		
		override protected function loader_completeHandler(event:flash.events.Event):void {
			super.loader_completeHandler(event);
			
			if (!delayTextureCreation) {
				animateFadeIn();
			}
		}
		
		private function animateFadeIn():void {
			if (!fadeInOnLoaded)
				return;
			alpha = 0;
			Starling.juggler.tween(this, .5, {alpha: 1});
		}
		
		override public function set delayTextureCreation(value:Boolean):void {
			if (!value && _pendingBitmapDataTexture) {
				animateFadeIn();
			}
			
			super.delayTextureCreation = value;
		}
	}
}

internal class CacheItem {
	public var source:String;
	public var bitmapData:flash.display.BitmapData;
	public var texture:starling.textures.Texture;
	
	public function toString():String {
		return "[CacheItem source=" + source + "]";
	}
}