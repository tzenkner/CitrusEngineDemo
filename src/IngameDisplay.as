package
{
	import citrus.core.CitrusEngine;
	import citrus.ui.starling.LifeBar;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	
	public class IngameDisplay extends Sprite
	{
		public var lifebar:LifeBar;
		
		private var _coinTF:TextField;
		private var _lifesTF:TextField;
		
		public function IngameDisplay()
		{
			super();
			
			lifebar = new LifeBar(Assets.getAtlas().getTexture("lifebar"));
			lifebar.x = 840;
			lifebar.y = 10;
			addChild(lifebar);
			
			var image:Image = new Image(Assets.getAtlas().getTexture("coinSymbol"));
			image.x = 705;
			image.y = 15;
			addChild(image);
			
			_coinTF = new TextField(100, 40, "x 0", "Bitwise");
			_coinTF.fontSize = 28;
			_coinTF.color = 0xffffff;
			_coinTF.x = 720;
			_coinTF.y = 10;
			addChild(_coinTF);
			
			image = new Image(Assets.getAtlas().getTexture("lifesSymbol"));
			image.x = 570;
			image.y = 10;
			addChild(image);
			
			_lifesTF = new TextField(100, 40, "x "+CitrusEngine.getInstance().gameData.lives.toString(), "Bitwise");
			_lifesTF.fontSize = 28;
			_lifesTF.color = 0xffffff;
			_lifesTF.x = 590;
			_lifesTF.y = 10;
			addChild(_lifesTF);
		}
		
		public function set coinValueText(count:int):void
		{
			_coinTF.text = "x "+count.toString();
		}

		public function set lifeValueText(count:int):void
		{
			_lifesTF.text = "x "+count.toString();
		}
	}
}