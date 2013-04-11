package
{
	import citrus.core.SoundManager;
	
	public class Sounds
	{
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
			SoundManager.getInstance().addSound("boil", "../sounds/boiling_water.mp3");
		}
	}
}