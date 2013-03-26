package levels{
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import characters.HeroSnowman;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	import citrus.objects.complex.box2dstarling.Pool;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.MovingPlatform;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.objects.platformer.box2d.Teleporter;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2D;
	import citrus.ui.starling.LifeBar;
	import citrus.utils.objectmakers.ObjectMaker2D;
	import citrus.view.starlingview.StarlingCamera;
	
	import dragonBones.Armature;
	import dragonBones.animation.Animation;
	import dragonBones.events.AnimationEvent;
	import dragonBones.factorys.StarlingFactory;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.XMLDataParser;
	
	import effects.Particles;
	
	import objects.Bullet;
	import objects.PopupSensor;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	public class SnowmanBasicLevel extends StarlingState {
		
		[Embed(source = "/../embeds/skeleton.xml",mimeType = "application/octet-stream")]
		private const SkeletonDataXML:Class;
		
		protected var _factory:StarlingFactory;
		protected var _armature:Armature;
		protected var _armatureShark:Armature;
		protected var arm:Animation;
		
		protected var particles:Particles;
		
		protected var snowman:HeroSnowman;
		
		private var timeout:uint;
		
		private var box2D:Box2D;
		
		private var p:Point;
		
		public var camera:StarlingCamera;
		
		protected var _level:MovieClip;
		
		private var bulletTimer:Timer;
		
		protected var skeletonData:SkeletonData;
		
		public var lvlEnded:Signal;
		public var restartLevel:Signal;
		
		public var lifebar:LifeBar;
		public var filterDataNone:b2FilterData;
		
		protected var checkPointIndex:int = 0;
		protected var checkPoints:Vector.<b2Vec2>;
		
		public function SnowmanBasicLevel(level:MovieClip = null) 
		{
			super();
			
			_ce = CitrusEngine.getInstance();
			
			_level = level;
			
			lvlEnded = new Signal();
			restartLevel = new Signal();
			
			var objectsUsed:Array = [Platform, Enemy, Sensor, CitrusSprite, MovingPlatform, Teleporter, Pool, PopupSensor];
		}
		
		override public function initialize():void {
			super.initialize();
			stage.color = 0x0000ff;
			
			filterDataNone = new b2FilterData();
			filterDataNone.maskBits = PhysicsCollisionCategories.GetNone();
			
			box2D = new Box2D("box2D");
//						box2D.visible = true;
			box2D.gravity.y = 10;
			add(box2D);
			
			bulletTimer = new Timer(500);
			bulletTimer.addEventListener(TimerEvent.TIMER, onBulletTimer);
			
			lifebar = new LifeBar(Assets.getAtlas().getTexture("lifebar"));
			lifebar.x = 840;
			lifebar.y = 10;
			lifebar.name = "lifebar";
			addChild(lifebar);
			
			// the skeleton data for DragonBones, the body parts are included in my level spritesheet
			skeletonData = XMLDataParser.parseSkeletonData(XML(new SkeletonDataXML()));
			_factory = new StarlingFactory();
			_factory.addSkeletonData(skeletonData);
			_factory.addTextureAtlas(Assets.getAtlas(), "snowman2small");

			createHero();
		}
		
		private function createHero():void
		{
			_armature = _factory.buildArmature("snowman");
			
			// the arm animation is altered for weapon change, so i assign a variable to it
			arm = _armature.getBone("frontDownArm").childArmature.animation;
			arm.gotoAndPlay("gun");
			(_armature.display as Sprite).scaleY = 0.35;
			(_armature.display as Sprite).scaleX = 0.35;
			
			snowman = new HeroSnowman("snowman", {group:3, x:1000, y: 120, width:(_armature.display as Sprite).width/2+5, height:(_armature.display as Sprite).height/2+20, 
				offsetX:0,	offsetY:0, view:_armature, registration:"topLeft"});
			snowman.maxVelocity = 3.5;
			snowman.jumpAcceleration = 0.2;
			snowman.jumpHeight = 7;
			snowman.canDuck = true;			
			add(snowman);
			
			snowman.onShoot.add(startShooting);
			snowman.onShootEnd.add(stopShooting);
			snowman.onWeaponChange.add(changeWeapon);
			snowman.onTakeDamage.add(takeDamage);
			
			camera = view.camera as StarlingCamera;
			camera.setUp(snowman, new MathVector(stage.stageWidth/2, stage.stageHeight/2 + 150), new Rectangle(0, -1328, 4096, 2048), new MathVector(0.8, 0.6));
			camera.allowZoom = true;
			camera.setZoom(1.4);
			
			ObjectMaker2D.FromMovieClip(_level);
		}
		
		private function takeDamage():void
		{
			lifebar.ratio -= 1/3;
			if (lifebar.ratio < 0.1) die();
		}
		
		protected function die():void
		{
			snowman.isDead = true;
			arm.gotoAndPlay("noWepaon");
			_armature.addEventListener(AnimationEvent.COMPLETE, resetToLastCheckpoint);
			_armature.animation.gotoAndPlay("die");
		}
		
		private function resetToLastCheckpoint(e:Event):void
		{ 
			arm.gotoAndPlay("gun");
			snowman.body.SetType(0); 
			snowman.visible=false; 
			snowman.isDead = false; 
			_armature.removeEventListener(AnimationEvent.COMPLETE, resetToLastCheckpoint);
			
			TweenLite.to(snowman, 1.5, {delay:0.2, x:checkPoints[checkPointIndex].x, y:checkPoints[checkPointIndex].y,
							onComplete:function():void{
								snowman.body.SetType(2); 
								snowman.visible=true; 
								lifebar.ratio = 1}
			});
		}
		
		private function updateParticles():void
		{
			switch(arm.movementID)
			{
				case "gun":	
					if (snowman.inverted)
					{
						p = new Point(snowman.x + 10*0.35 - Math.cos(_armature.getBone("frontUpArm").node.rotation) * 55 * 0.35, 
							snowman.y -32*0.35 + Math.sin(_armature.getBone("frontUpArm").node.rotation) * 70 * 0.35);
						particles.particlesBullet.emitterX = p.x;
						particles.particlesBullet.emitterY= p.y;
						particles.particlesBullet.emitAngle =  rad2deg(32) - _armature.getBone("frontUpArm").node.rotation ;
						particles.particlesBullet.startRotation = _armature.getBone("frontUpArm").node.rotation;
						
						p = new Point(snowman.x - 32*0.35 - Math.cos(_armature.getBone("frontUpArm").node.rotation) * 55 * 0.35, 
							snowman.y -35*0.35 + Math.sin(_armature.getBone("frontUpArm").node.rotation) * 118 * 0.35);
						particles.particlesSmoke.emitterX = p.x;
						particles.particlesSmoke.emitterY = p.y;
						particles.particlesSmoke.emitAngle = -_armature.getBone("frontUpArm").node.rotation;
						particles.particlesSmoke.speed = -60;
					}
					else
					{
						p = new Point(snowman.x - 10*0.35 + Math.cos(_armature.getBone("frontUpArm").node.rotation) * 55 * 0.35, 
							snowman.y -32*0.35 + Math.sin(_armature.getBone("frontUpArm").node.rotation) * 70 * 0.35);
						particles.particlesBullet.emitterX = p.x;
						particles.particlesBullet.emitterY = p.y;
						particles.particlesBullet.emitAngle = _armature.getBone("frontUpArm").node.rotation - rad2deg(238);
						particles.particlesBullet.startRotation = _armature.getBone("frontUpArm").node.rotation;
						
						p = new Point(snowman.x + 32*0.35 + Math.cos(_armature.getBone("frontUpArm").node.rotation) * 55 * 0.35, 
							snowman.y -35*0.35 + Math.sin(_armature.getBone("frontUpArm").node.rotation) * 118 * 0.35);
						particles.particlesSmoke.emitterX = p.x;
						particles.particlesSmoke.emitterY = p.y;
						particles.particlesSmoke.emitAngle = _armature.getBone("frontUpArm").node.rotation;
						particles.particlesSmoke.speed = 60;
					}
					break;
				
				case "flameThrower":	
					if (snowman.inverted)
					{
						p = new Point(snowman.x - 130*0.35, snowman.y - 35*0.35);
						particles.particlesFire.emitterX = p.x;
						particles.particlesFire.emitterY = p.y;
						particles.particlesFire.emitAngle = -_armature.getBone("frontUpArm").node.rotation - deg2rad(180);
					}
					else
					{
						p = new Point(snowman.x + 130*0.35, snowman.y -35*0.35);
						particles.particlesFire.emitterX = p.x;
						particles.particlesFire.emitterY = p.y;
						particles.particlesFire.emitAngle = _armature.getBone("frontUpArm").node.rotation;
					}
					break;
			}
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (snowman && snowman.isAiming)
			{
				updateParticles();
			}
		}
		
		private function onBulletTimer(e:TimerEvent=null):void
		{
			var pre:int = (snowman.inverted) ? -1 : 1;
			p = new Point(snowman.x + pre*32*0.35 + pre*Math.cos(_armature.getBone("frontUpArm").node.rotation) * 60 * 0.35, 
				snowman.y -35*0.35 + Math.sin(_armature.getBone("frontUpArm").node.rotation) * 138 * 0.35);
			
			var bullet:Bullet = new Bullet("bullet", {x:p.x, y:p.y, speed:new b2Vec2(20 * pre*Math.cos(_armature.getBone("frontUpArm").node.rotation), 20 * Math.sin(_armature.getBone("frontUpArm").node.rotation))});
			add(bullet);
		}
		
		protected function startShooting():void
		{
			updateParticles();
			
			switch(arm.movementID)
			{
				case "gun":	
					if (snowman.inverted)
					{
						particles.particlesSmoke.emitAngle = Math.PI;
						particles.particlesBullet.emitAngle = deg2rad(302);
					}
					else 
					{
						particles.particlesSmoke.emitAngle = Math.PI*2;
						particles.particlesBullet.emitAngle = deg2rad(238);
					}
					particles.particlesBullet.start()
					particles.particlesSmoke.start(); 
					onBulletTimer();
					bulletTimer.start();
					
					break;
				
				case "flameThrower":	
					if (snowman.inverted)
					{
						particles.particlesFire.emitAngle = deg2rad(182);
					}
					else 
					{
						particles.particlesFire.emitAngle = deg2rad(358);
					}
					timeout = setTimeout(function():void{particles.particlesFire.start();}, 180);
					break;
			}
		}
		protected function stopShooting():void
		{
			bulletTimer.reset();
			particles.particlesBullet.pause();
			particles.particlesSmoke.pause();
			particles.particlesFire.pause();
		}
		protected function changeWeapon():void
		{
			if (arm.movementID == "gun")
			{
				arm.gotoAndPlay("flameThrower");
				snowman.weapon = "flameThrower";
			}
			else if (arm.movementID == "flameThrower")
			{
				arm.gotoAndPlay("gun");
				snowman.weapon = "gun";
			}
			if (snowman.isShooting) 
			{
				stopShooting();
				startShooting();
			}
		}
		
		// functions are used for the PopupSensor, maybe they should be moved there
		protected function createTextField(text:String, x:Number, y:Number):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.addChild(new Quad(200, 100,0x555555));
			sprite.visible = false;
			var tf:TextField = new TextField(200, 100, text, "ArialMT");
			tf.fontSize = BitmapFont.NATIVE_SIZE;
			tf.color = 0xffffff;
			tf.autoScale = true;
			sprite.addChild(tf);
			var ts:CitrusSprite = new CitrusSprite("ts", {x:x-100, y:y-150, group:6, view:sprite});
			tf.fontSize = 12;
			add(ts);
			tf.visible = true;
			return sprite;
		}
		
		protected function showPopUp(contact:b2Contact, sprite:Sprite):void {
			
			if (contact.GetFixtureA().GetBody().GetUserData() is HeroSnowman || contact.GetFixtureB().GetBody().GetUserData() is HeroSnowman) {
				sprite.visible = true;
			}
		}
		
		protected function hidePopUp(contact:b2Contact, sprite:Sprite):void {
			
			if (contact.GetFixtureA().GetBody().GetUserData() is HeroSnowman || contact.GetFixtureB().GetBody().GetUserData() is HeroSnowman) {
				sprite.visible = false;
			}
		}
	}
}
