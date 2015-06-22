package com.gsj4w.feathers.ffml {
	import com.gsj4w.feathers.groups.AbstractGroup;
	import com.gsj4w.feathers.groups.HGroup;
	import com.gsj4w.feathers.groups.TabHGroup;
	import com.gsj4w.feathers.groups.TabVGroup;
	import com.gsj4w.feathers.groups.VGroup;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.core.FeathersControl;
	import feathers.core.ITextRenderer;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.HAlign;
	
	/**
	 * FFML Parser.
	 *
	 * Parses XML data to display objects.
	 *
	 * @author Jakub Wagner, J4W
	 */
	public class FFMLParser {
		static public const HGROUP:String = "hgroup";
		static public const TABHGROUP:String = "tabhgroup";
		static public const VGROUP:String = "vgroup";
		static public const TABVGROUP:String = "tabvgroup";
		static public const TEXT:String = "text";
		static public const IMAGE:String = "image";
		static public const BUTTON:String = "button";
		
		/**
		 * If item.@scaleValues is true, all attribute values are scaled with defaultScale,
		 */
		public static var defaultScale:Number = 1;
		
		/**
		 * Text renderer factory.
		 * Factory method that should return ITextRenderer instance.
		 *
		 * <p>The function is expected to have the following signature:</p>
		 * <pre>function(style:String == "", item:XML = null):ITextRenderer</pre>
		 * Where style is an attribute from XML - ie. "myStyle" from <text style="myStyle">
		 * and 'item' is XML node for creating item.
		 */
		public static var textRendererFactory:Function;
		
		/**
		 * Custom item renderer factory.
		 * Factory method that should return DisplayObject instance.
		 *
		 * <p>The function is expected to have the following signature:</p>
		 * <pre>function(id:String, item:XML):DisplayObject</pre>
		 * Where 'id' is an attribute from XML - ie. "myButton" from <text id="myButton">
		 * and 'item' is XML node for creating item.
		 */
		public static var customItemRendererFactory:Function;
		
		/**
		 * Image factory.
		 * Factory method that should return Starling's Image instance.
		 *
		 * <p>The function is expected to have the following signature:</p>
		 * <pre>function(texture:String):Image</pre>
		 * Where texture is an attribute from XML - ie. "circle" from <image texture="circle">
		 */
		public static var imageFactory:Function;
		
		/**
		 * ImageLoader factory.
		 * Factory method that should return ImageLoader instance.
		 *
		 * <p>The function is expected to have the following signature:</p>
		 * <pre>function():ImageLoader</pre>
		 */
		public static var imageLoaderFactory:Function = function():ImageLoader {
			return new ImageLoader();
		};
		
		private var _data:XML;
		private var _root:DisplayObject;
		private var items:Dictionary;
		
		public function FFMLParser() {
		}
		
		/**
		 * Returns item with specified id.
		 * @param	id	items id from XML
		 * @return	DisplayObject or null if item with specified id does not exist
		 */
		public function getItemById(id:String):DisplayObject {
			return items[id];
		}
		
		/**
		 * Creates new FFMLParser instance, set data and parse them.
		 * @param	xml		FFML to parse.
		 * @return	FFMLParser instance
		 */
		public static function fromXML(xml:XML):FFMLParser {
			var fFMLParser:FFMLParser = new FFMLParser();
			fFMLParser.data = xml;
			fFMLParser.parse();
			return fFMLParser;
		}
		
		/**
		 * Parses data and disposes old content.
		 */
		public function parse():void {
			if (_root) {
				_root.dispose();
				_root = null;
			}
			items = new Dictionary(true);
			processItem(_data, null);
		}
		
		private function processItem(item:XML, parent:AbstractGroup):void {
			var displayObject:DisplayObject = getItemRenderer(item, parent);
			
			if (!_root)
				_root = displayObject;
			if (parent)
				appendChild(displayObject, parent, item);
			
			var abstractGroup:AbstractGroup = displayObject as AbstractGroup;
			if (abstractGroup) {
				var children:XMLList = item.children();
				for each (var child:XML in children) {
					processItem(child, abstractGroup);
				}
			}
		}
		
		private function getItemRenderer(item:XML, parent:AbstractGroup):DisplayObject {
			var displayObject:DisplayObject;
			
			if (equals(item.name(), HGROUP)) {
				displayObject = new HGroup();
			} else if (equals(item.name(), VGROUP)) {
				displayObject = new VGroup();
			} else if (equals(item.name(), TABVGROUP)) {
				displayObject = getTabVGroup(item);
			} else if (equals(item.name(), TABHGROUP)) {
				displayObject = getTabHGroup(item);
			} else if (equals(item.name(), TEXT)) {
				displayObject = getTextRenderer(item) as DisplayObject;
			} else if (equals(item.name(), IMAGE)) {
				displayObject = getImage(item);
			} else if (equals(item.name(), BUTTON)) {
				displayObject = getButton(item);
			} else {
				displayObject = getCustom(item);
			}
			
			if (!displayObject)
				throw new Error("Parse error: '" + item.name() + "' is not supported tag.");
			
			configureObject(displayObject, parent, item);
			
			var id:String = item.@id.toString();
			if (id) {
				items[id] = displayObject;
			}
			
			return displayObject;
		}
		
		private function appendChild(displayObject:DisplayObject, parent:AbstractGroup, item:XML):void {
			var space:Number = Number(item.@space.toString());
			var size:Number = Number(item.@size.toString());
			var index:Number = Number(item.@index.toString());
			var align:String = item.@align.toString();
			
			parent.appendChild( //
				displayObject, //
				space ? space : 0, align ? align : HAlign.LEFT, //
				size ? size : -1, //
				index ? index : -1 //
				);
		}
		
		//*************************************************************//
		//********************   Item Renderers  **********************//
		//*************************************************************//
		
		private function getTextRenderer(item:XML):ITextRenderer {
			var tr:ITextRenderer;
			
			if (textRendererFactory != null) {
				if (textRendererFactory.length == 2) {
					tr = textRendererFactory(item.@style.toString(), item);
				} else if (textRendererFactory.length == 1) {
					tr = textRendererFactory(item.@style.toString());
				} else {
					tr = textRendererFactory();
				}
			} else {
				tr = FeathersControl.defaultTextRendererFactory();
			}
			
			tr.text = item.text();
			return tr;
		}
		
		private function getTabVGroup(item:XML):TabVGroup {
			var gapsString:String = item.@gaps.toString();
			var alignsString:String = item.@aligns.toString();
			var gaps:Array = gapsString ? gapsString.split(",") : null;
			var aligns:Array = alignsString ? alignsString.split(",") : null;
			return new TabVGroup(gaps, aligns);
		}
		
		private function getTabHGroup(item:XML):TabHGroup {
			var gapsString:String = item.@gaps.toString();
			var alignsString:String = item.@aligns.toString();
			var gaps:Array = gapsString ? gapsString.split(",") : null;
			var aligns:Array = alignsString ? alignsString.split(",") : null;
			return new TabHGroup(gaps, aligns);
		}
		
		private function getImage(item:XML):DisplayObject {
			var texture:String = item.@textureId.toString();
			if (texture) {
				var image:Image = imageFactory(texture);
				return image;
			} else {
				var imageLoader:ImageLoader = imageLoaderFactory();
				return imageLoader;
			}
		}
		
		private function getButton(item:XML):DisplayObject {
			var button:Button = new Button();
			
			var childrenCount:int = item.children().length();
			if (childrenCount > 0) {
				if (childrenCount != 1) {
					throw new Error("Button container should have only one XML child.");
				}
				button.defaultSkin = FFMLParser.fromXML(item.children()[0]).root;
				
				var createDownSkin:Boolean = item.@createDownSkin.toString() == "true";
				if (createDownSkin) {
					button.downSkin = FFMLParser.fromXML(item.children()[0]).root;
					button.downSkin.alpha = .7;
				}
			}
			
			var url:String = item.@url.toString();
			if (url) {
				button.addEventListener(Event.TRIGGERED, function(e:Event):void {
						navigateToURL(new URLRequest(item.@url.toString()));
					});
			}
			
			return button;
		}
		
		private function getCustom(item:XML):DisplayObject {
			var clazzString:String = item.@classIdentifier.toString();
			var id:String = item.@customId.toString() || item.name().toString();
			if (clazzString) {
				var c:ApplicationDomain = ApplicationDomain.currentDomain;
				if (c.hasDefinition(clazzString)) {
					var clazz:Object = c.getDefinition(clazzString);
					return new clazz();
				} else {
					throw new Error(clazzString + " has not definition in ApplicationDomain.");
				}
			} else if (id) {
				if (customItemRendererFactory != null) {
					var displayObject:DisplayObject = customItemRendererFactory(id, item);
					if (displayObject) {
						return displayObject;
					} else {
						throw new Error("customItemRendererFactory has not returned displayObject instance for " + id);
					}
				} else {
					throw new Error("customItemRendererFactory is not set");
				}
			} else {
				throw new Error("Custom renderer should be specified with @id or @classIdentifier attribute.");
			}
		}
		
		private function configureObject(displayObject:DisplayObject, parent:AbstractGroup, item:XML):void {
			var attributes:XMLList = item.attributes();
			try {
				for each (var attribute:XML in attributes) {
					var n:String = attribute.name();
					if (n in displayObject) {
						var value:Object = attribute.toString();
						if (value === "true") {
							value = true;
						} else if (value === "false") {
							value = false;
						} else if (isFinite(Number(value))) {
							value = Number(value);
						} else if (parent && value.indexOf("%") == value.length - 1) { // percents - from parent!
							value = Number(value.split("%")[0]) * parent.width;
						}
						
						if (isFinite(Number(value)) && item.@scaleValues.toString() == "true") {
							if (attribute.toString().length != 8) {
								// if finite number, scaling enabled and is not a color (ie. "0xFFFFFF".length == 8)
								value = Number(value) * defaultScale;
							}
						}
						
						displayObject[n] = value;
					}
				}
			}
			catch (err:Error) {
				throw new Error("Error while configuring " + displayObject + " with " + item + ". Error caused by " + n + " attribute.");
			}
		}
		
		//*************************************************************//
		//*****************   Item Renderers END   ********************//
		//*************************************************************//
		
		public function get data():XML {
			return _data;
		}
		
		public function set data(value:XML):void {
			_data = value;
		}
		
		public function get root():DisplayObject {
			return _root;
		}
		
		private function equals(s1:String, s2:String):Boolean {
			return s1 == s2 || s1.toLowerCase() == s2.toLowerCase();
		}
	
	}

}