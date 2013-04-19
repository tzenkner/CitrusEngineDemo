package{

	import Box2D.Common.Math.b2Vec2;
	
	import citrus.utils.AGameData;
	
	import levels.Level1;

	public class MyGameData extends AGameData {
		
		public var coins:int = 0;
		
		public var checkPointIndex:int = 0;
		public var checkPoints:Vector.<b2Vec2>;

		public function MyGameData() {
			
			super();
		
			_levels = [[Level1, "../levels/A1/LevelOne.swf"]];
		}
		
		public function get levelArray():Array {
			return _levels;
		}

		override public function destroy():void {
			
			super.destroy();
		}
		
	}
}
