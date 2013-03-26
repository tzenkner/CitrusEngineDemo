package effects
{
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.objects.CitrusSprite;
	
	import starling.core.Starling;
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	
	public class Particles
	{
		[Embed(source="/../embeds/particleSnow.pex", mimeType="application/octet-stream")]
		private var ParticleSnowXML:Class;
		public var particlesSnow:PDParticleSystem;
		
		[Embed(source="/../embeds/particleBullet.pex", mimeType="application/octet-stream")]
		private var ParticleBulletXML:Class;		
		public var particlesBullet:PDParticleSystem;
		
		[Embed(source="/../embeds/particleSmoke.pex", mimeType="application/octet-stream")]
		private var ParticleSmokeXML:Class;		
		public var particlesSmoke:PDParticleSystem;
		
		[Embed(source="/../embeds/particleFire.pex", mimeType="application/octet-stream")]
		private var ParticleFireXML:Class;		
		public var particlesFire:PDParticleSystem;
		
		[Embed(source="/../embeds/particleBubble.pex", mimeType="application/octet-stream")]
		private var ParticleBubbleXML:Class;		
		public var particlesBubble:PDParticleSystem;
		
		private var ce:CitrusEngine;
		
		public var snow:CitrusSprite;
		public var smoke:CitrusSprite;
		public var bullet:CitrusSprite;
		public var fire:CitrusSprite;
		public var bubbles:CitrusSprite;
		
		public function Particles()
		{
			ce = CitrusEngine.getInstance();
			
			particlesSnow = new PDParticleSystem(XML(new ParticleSnowXML()), Assets.getAtlas().getTexture("textureSnow"));
			particlesSnow.emitterX = 2048;
			particlesSnow.emitterY = -1424;
			Starling.juggler.add(particlesSnow);
			particlesSnow.start();
			snow = new CitrusSprite("snow", {group:7, view:particlesSnow});
			(ce as StarlingCitrusEngine).state.add(snow);
			
			var texture:Texture =  Assets.getAtlas().getTexture("textureFire");
			
			particlesSmoke = new PDParticleSystem(XML(new ParticleSmokeXML()), texture);
			(ce as StarlingCitrusEngine).starling.juggler.add(particlesSmoke);
			smoke = new CitrusSprite("smoke", {group:2, view:particlesSmoke});
			(ce as StarlingCitrusEngine).state.add(smoke);
			
			particlesBullet = new PDParticleSystem(XML(new ParticleBulletXML()), Assets.getAtlas().getTexture("textureBullet"));
			(ce as StarlingCitrusEngine).starling.juggler.add(particlesBullet);
			particlesBullet.emissionRate = 2;
			bullet = new CitrusSprite("bullet", {group:2, view:particlesBullet});
			(ce as StarlingCitrusEngine).state.add(bullet);
			
			particlesFire = new PDParticleSystem(XML(new ParticleFireXML()), texture);
			(ce as StarlingCitrusEngine).starling.juggler.add(particlesFire);
			fire = new CitrusSprite("fire", {group:2, view:particlesFire});
			(ce as StarlingCitrusEngine).state.add(fire);
			
			particlesBubble = new PDParticleSystem(XML(new ParticleBubbleXML()), Assets.getAtlas().getTexture("textureBubble"));
			(ce as StarlingCitrusEngine).starling.juggler.add(particlesBubble);
			bubbles = new CitrusSprite("bubbles", {group:7, view:particlesBubble});
			(ce as StarlingCitrusEngine).state.add(bubbles);
		}
	}
}