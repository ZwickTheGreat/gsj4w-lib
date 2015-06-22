package com.gsj4w.feathers.ffml.tester {
	import com.goodshape.dpp.praguetrips.assets.Assets;
	import com.goodshape.dpp.praguetrips.renderers.BrownButton;
	import com.goodshape.dpp.praguetrips.renderers.TripDetailImage;
	import com.goodshape.dpp.praguetrips.theme.Theme;
	import com.gsj4w.feathers.ffml.FFMLParser;
	import feathers.core.FeathersControl;
	import feathers.core.ITextRenderer;
	import starling.display.DisplayObject;
	import starling.display.Image;
	
	/**
	 * Starling main.
	 * @author Jakub Wagner, J4W
	 */
	public class TesterStarling extends FeathersControl {
		
		public function TesterStarling() {
			Assets.addEventListener(Assets.ASSETS_LOADED, onAssetsLoaded);
			Assets.loadAssets();
			
			new Theme(this);
			FFMLParser.textRendererFactory = function(style:String = ""):ITextRenderer {
				switch (style) {
					case "title": 
						return Theme.getTextFieldRenderer(Theme.getTextFormatMyriad(38, Theme.BLACK, true));
						break;
					default: 
						return Theme.getTextFieldRenderer(Theme.getTextFormatMyriad(30, Theme.BLACK));
						break;
				}
			}
			FFMLParser.customItemRendererFactory = function(id:String):DisplayObject {
				switch (id) {
					case "button": 
						var button:BrownButton = new BrownButton();
						button.width = 150;
						return button;
						break;
				}
				return null;
			}
			FFMLParser.imageFactory = function(texture:String):DisplayObject {
				var image:Image = new Image(Assets.getTextureFromAtlas(texture));
				Theme.scaleSkin(image);
				return image;
			}
			TripDetailImage;
		}
		
		public function createTest():void {
			var group1:XML =    
				<vgroup>
					<text>pekne</text>
					<hgroup>
						<text>pekne</text><text>pekne2</text><text>{"pekne3<br/>dajkasdsaddsadsadsa"}</text></hgroup>
					<text>pekne3</text>
				</vgroup>;
			
			var xml:XML = 
				<vgroup>
					<tabhgroup>
						<text style="title">lol</text><text>lol2</text><text>lol3</text>
					</tabhgroup>		
					<tabhgroup gaps="100,50,100" aligns="left,center,right" space="50">
						<image id="test" textureId="thumb10" align="center"/>
						<text align="center">lol</text>
						<image source="http://img.ihned.cz/attachment.php/170/52915170/LPkvjeB7Qs4dby2CmnTVNuSEGtc1AoH5/SPORT_OLYMPIJSKE_HOKEJ_CR_SVEDSKO_SOCI_22_326.jpg" width="100" height="100"/>
					</tabhgroup>
					<vgroup>	
						<text background="true" backgroundColor="0xFF0000">lol</text>
						<text space="30">lol2</text>
						<text>{"pekne3<br/>dajkasdsaddsadsadsa"}</text>
						<custom id="button" label="Pěknej label"/>
						<custom classIdentifier="com.goodshape.dpp.praguetrips.renderers.TripDetailImage" imgURL="http://i.min.us/jjoiIq.png" imgTitle="Moc hezkej obrázek"/>
					</vgroup>
				</vgroup>
			
			//var fFMLParser:FFMLParser = new FFMLParser();
			//fFMLParser.data = xml;
			//fFMLParser.parse();
			//addChild(fFMLParser.root);
			
			var f:FFMLParser = FFMLParser.fromXML(xml);
			addChild(f.root);
			
			trace(f.getItemById("test"));
		}
		
		private function onAssetsLoaded(e:*):void {
			createTest();
		}
	
	}

}