package{

	import citrus.utils.AGameData;
	
	import levels.Level1;

	public class MyGameData extends AGameData {
		
		private var coinsCollected:int = 0;

		public function MyGameData() {
			
			super();
			
			poolIceCount = 0
			
			_levels = [[Level1, "../levels/A1/LevelOne.swf"]];
		}
		
		public function get levelArray():Array {
			return _levels;
		}

		override public function destroy():void {
			
			super.destroy();
		}
		public function get coins():int {
			return coinsCollected;
		}
		
		public function set coins(coins:int):void {
			
			coinsCollected = coins;
		}
	}
}
