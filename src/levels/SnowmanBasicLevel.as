package levels{
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2FilterData;
	
	import characters.HeroSnowman;
	
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.SoundManager;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
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
	
	import com.greensock.TweenLite;
	
	import dragonBones.Armature;
	import dragonBones.animation.Animation;
	import dragonBones.events.AnimationEvent;
	import dragonBones.factorys.StarlingFactory;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.XMLDataParser;
	
	import effects.Particles;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import objects.Bullet;
	import objects.PopupSensor;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	/**
	 * @author Thomas Zenkner
	 */
	public class SnowmanBasicLevel extends StarlingState {
		
		[Embed(source = "/../embeds/skeleton.xml",mimeType = "application/octet-stream")]
		private const SkeletonDataXML:Class;
		
		[Embed(source="/../embeds/AtariFont.fnt", mimeType="application/octet-stream")]
		private var _fontConfig:Class;
		[Embed(source="/../embeds/AtariFont.png")]
		private var _fontPng:Class;
		
		[Embed(source="/../embeds/AtariBig.fnt", mimeType="application/octet-stream")]
		private var _snowConfig:Class;
		[Embed(source="/../embeds/AtariBig_0.png")]
		private var _snowPng:Class;
		
		[Embed(source="/../embeds/Bitwise.fnt", mimeType="application/octet-stream")]
		private var _bitwiseConfig:Class;
		[Embed(source="/../embeds/Bitwise_0.png")]
		private var _bitwisePng:Class;
		
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
		
		public var display:IngameDisplay;
		public var filterDataNone:b2FilterData;
		
		protected var _maskDuringLoading:Quad;
		protected var _percentTF:TextField;
		protected var _titleTF:TextField;
		protected var _levelTF:TextField;
		
		private var loading:Boolean = true;
		
		protected var gamedata:MyGameData;
		
		public function SnowmanBasicLevel(level:MovieClip = null) 
		{
			super();
			
			_ce = CitrusEngine.getInstance();
			gamedata = _ce.gameData as MyGameData;
			
			_level = level;
			
			lvlEnded = new Signal();
			restartLevel = new Signal();
			
			var objectsUsed:Array = [Platform, Enemy, Sensor, CitrusSprite, MovingPlatform, Teleporter, Pool, PopupSensor];
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			stage.color = 0x0000ff;
			
			filterDataNone = new b2FilterData();
			filterDataNone.maskBits = PhysicsCollisionCategories.GetNone();
			
			box2D = new Box2D("box2D");
			//						box2D.visible = true;
			box2D.gravity.y = 10;
			add(box2D);
			
			ObjectMaker2D.FromMovieClip(_level);
			
			_ce.input.keyboard.addKeyAction("jump", Keyboard.SPACE);
			_ce.input.keyboard.addKeyAction("shoot", Keyboard.Y);
			_ce.input.keyboard.addKeyAction("shoot", Keyboard.CTRL);
			_ce.input.keyboard.addKeyAction("changeWeapon", Keyboard.X);

			registerFonts();
			
			bulletTimer = new Timer(500);
			bulletTimer.addEventListener(TimerEvent.TIMER, onBulletTimer);
			
			// the skeleton data for DragonBones, the body parts are included in my level spritesheet
			skeletonData = XMLDataParser.parseSkeletonData(XML(new SkeletonDataXML()));
			_factory = new StarlingFactory();
			_factory.addSkeletonData(skeletonData);
			_factory.addTextureAtlas(Assets.getAtlas(), "snowman2small");
		}
		
		private function registerFonts():void
		{
			var bitmap:Bitmap = new _fontPng();
			var ftTexture:Texture = Texture.fromBitmap(bitmap);
			var ftXML:XML = XML(new _fontConfig());
			TextField.registerBitmapFont(new BitmapFont(ftTexture, ftXML), "Atari");
			
			bitmap = new _snowPng();
			ftTexture = Texture.fromBitmap(bitmap);
			ftXML = XML(new _snowConfig());
			TextField.registerBitmapFont(new BitmapFont(ftTexture, ftXML), "AtariBig");
			
			bitmap = new _bitwisePng();
			ftTexture = Texture.fromBitmap(bitmap);
			ftXML = XML(new _bitwiseConfig());
			TextField.registerBitmapFont(new BitmapFont(ftTexture, ftXML), "Bitwise");
		}
		
		protected function addLoadingScreen(text:String):void
		{
			view.loadManager.onLoadComplete.addOnce(function():void{});
			
			_maskDuringLoading = new Quad(stage.stageWidth, stage.stageHeight);
			_maskDuringLoading.color = 0x000000;
			_maskDuringLoading.x = (stage.stageWidth - _maskDuringLoading.width) / 2;
			_maskDuringLoading.y = (stage.stageHeight - _maskDuringLoading.height) / 2;
			addChild(_maskDuringLoading);
			
			_titleTF = new TextField(600, 200, "", "AtariBig");
			_titleTF.fontSize = BitmapFont.NATIVE_SIZE;
			_titleTF.color = Color.WHITE;
			_titleTF.text = "Snowman Land";
			_titleTF.width = _titleTF.textBounds.width;
			_titleTF.x = (stage.stageWidth - _titleTF.width) / 2;
			_titleTF.y = (stage.stageHeight - _titleTF.height) / 2 - 200;
			addChild(_titleTF);
			
			_percentTF = new TextField(400, 200, "", "Atari");
			_percentTF.fontSize = BitmapFont.NATIVE_SIZE;
			_percentTF.color = Color.WHITE;
			_percentTF.x = (stage.stageWidth - _percentTF.width) / 2;
			_percentTF.y = (stage.stageHeight - _percentTF.height) / 2 + 100;
			addChild(_percentTF);
			
			_levelTF = new TextField(600, 200, "", "Bitwise");
			_levelTF.fontSize = BitmapFont.NATIVE_SIZE;
			_levelTF.color = 0x5E2605;
			_levelTF.text = text;
			_levelTF.width = _levelTF.textBounds.width;
			_levelTF.x = (stage.stageWidth - _levelTF.width) / 2;
			_levelTF.y = (stage.stageHeight - _levelTF.height) / 2;
			addChild(_levelTF);
		}
		
		protected function createHero():void
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
			
			camera = view.camera as StarlingCamera;
			camera.setUp(snowman, new MathVector(stage.stageWidth/2, stage.stageHeight/2 + 150), new Rectangle(0, -1328, 4096, 2048), new MathVector(0.8, 0.6));
			camera.allowZoom = true;
			camera.setZoom(1.4);
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
			if (loading)
			{
				if (view.camera.camPos.x < 649)
				{
					var percent:uint = (view.loadManager.bytesLoaded + (view.camera.camPos.x *1000)) / (view.loadManager.bytesTotal+ 649000) * 100;
					_percentTF.text = "Loading "+percent.toString() + "%";
				}
				else 
				{
					addChild(display.lifebar);
					removeChild(_percentTF, true);
					
					removeChild(_titleTF, true);
					removeChild(_levelTF, true);
					removeChild(_maskDuringLoading, true);
					loading = false;
				}
			}
			
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
			
			var bullet:Bullet = new Bullet("bullet", {x:p.x, y:p.y, view:Assets.getAtlas().getTexture("shoot"), group:3,
				speed:new b2Vec2(20 * pre*Math.cos(_armature.getBone("frontUpArm").node.rotation), 20 * Math.sin(_armature.getBone("frontUpArm").node.rotation))});
			SoundManager.getInstance().playSound("shoot", 0.7, 0);
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
		
		protected function coinCollected(contact:b2Contact):void
		{
			if (contact.GetFixtureA().GetBody().GetUserData() is HeroSnowman || contact.GetFixtureB().GetBody().GetUserData() is HeroSnowman)
			{
				SoundManager.getInstance().playSound("coin", 1, 0);
				gamedata.coins++;
			}
		}
	}
}
