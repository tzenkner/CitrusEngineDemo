package
{
	import citrus.core.IState;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.utils.LevelManager;
	
	import levels.SnowmanBasicLevel;
	
	[SWF(width="980", height="720", frameRate="30")]
	
	/**
	 * @author Thomas Zenkner
	 */
	public class Main extends StarlingCitrusEngine
	{
		public function Main()
		{
			setUpStarling(true);
			
			gameData = new MyGameData();
			
			levelManager = new LevelManager(SnowmanBasicLevel);
			levelManager.onLevelChanged.add(_onLevelChanged);
			levelManager.levels = gameData.levelArray;
			levelManager.gotoLevel();
		}
		
		private function _onLevelChanged(lvl:SnowmanBasicLevel):void {
			
			state = lvl;
			lvl.lvlEnded.add(_nextLevel);
			lvl.restartLevel.add(_restartLevel);
		}
		
		private function _nextLevel():void {
			
			levelManager.nextLevel();
		}
		
		private function _restartLevel():void {
			
			state = levelManager.currentLevel as IState;
		}
	}
}