package
{
	import citrus.ui.starling.LifeBar;
	
	import starling.display.Sprite;
	
	public class IngameDisplay extends Sprite
	{
		public var lifebar:LifeBar;
		
		public function IngameDisplay()
		{
			super();
			
			lifebar = new LifeBar(Assets.getAtlas().getTexture("lifebar"));
			lifebar.x = 840;
			lifebar.y = 10;
		}
	}
}