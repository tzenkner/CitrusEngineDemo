package
{
	import citrus.core.SoundManager;
	
	public class Sounds
	{
//		private static var jumpSound:Sound = new Sound(new URLRequest("../sounds/jump.mp3"));
//		private static var swimSound:Sound = new Sound(new URLRequest("../sounds/swim.mp3"));
//		private static var coinSound:Sound = new Sound(new URLRequest("../sounds/coin.mp3"));
//		private static var shootSound:Sound = new Sound(new URLRequest("../sounds/shoot.mp3"));
		
		public static function addSoundFiles():void
		{
			SoundManager.getInstance().addSound("jump", "../sounds/jump.mp3");
			SoundManager.getInstance().addSound("shoot", "../sounds/shoot_real.mp3");
			SoundManager.getInstance().addSound("coin", "../sounds/coin.mp3");
			SoundManager.getInstance().addSound("swim", "../sounds/swim.mp3");
			SoundManager.getInstance().addSound("iceBlockHit", "../sounds/bullet_iceblock_hit.mp3");
			SoundManager.getInstance().addSound("wallHit", "../sounds/bullet_wall_hit.mp3");
			SoundManager.getInstance().addSound("blockExplode", "../sounds/exploding_block.mp3");
			SoundManager.getInstance().addSound("bgMusic", "../sounds/Level1bg-DST-Eretria.mp3");
			SoundManager.getInstance().addSound("waterBoil", "../sounds/boiling_water.mp3");
			SoundManager.getInstance().addSound("heroEnterPool", "../sounds/hero_hits_water.mp3");
			SoundManager.getInstance().addSound("iceEnterPool", "../sounds/ice_hits_water.mp3");
			SoundManager.getInstance().addSound("hurt", "../sounds/hurt.mp3");
			SoundManager.getInstance().addSound("die", "../sounds/die.mp3");
			SoundManager.getInstance().addSound("popup", "../sounds/popup.mp3");
			
			SoundManager.getInstance().preLoadSounds();
		}
	}
}