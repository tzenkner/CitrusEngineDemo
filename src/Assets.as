package {
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	public class Assets
	{
		[Embed(source="/../embeds/mySpritesheet.png")]
		public static const MySpriteSheet:Class;
		
		[Embed(source="/../embeds/mySpritesheet.xml", mimeType="application/octet-stream")]
		public static const MySpriteSheetXML:Class;
		
		private static var gameTextures:Dictionary = new Dictionary();
		private static var gameTextureAtlas:TextureAtlas;
		public static function getAtlas():TextureAtlas
		{
			if (gameTextureAtlas == null)
			{
				var texture:Texture = getTexture("MySpriteSheet");
				var xml:XML = XML(new MySpriteSheetXML());
				gameTextureAtlas=new TextureAtlas(texture, xml);
			}
			
			return gameTextureAtlas;
		}
		
		public static function getTexture(name:String):Texture
		{
			if (gameTextures[name] == undefined)
			{
				var bitmap:Bitmap = new Assets[name]();
				gameTextures[name]=Texture.fromBitmap(bitmap);
			}
			
			return gameTextures[name];
		}
	}
}

