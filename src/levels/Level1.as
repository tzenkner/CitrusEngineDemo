package levels {
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import characters.HeroSnowman;
	import characters.RoundFish;
	import characters.Shark;
	
	import citrus.core.CitrusObject;
	import citrus.core.SoundManager;
	import citrus.objects.CitrusSprite;
	import citrus.objects.complex.box2dstarling.Bridge;
	import citrus.objects.platformer.box2d.Coin;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.objects.platformer.box2d.Teleporter;
	
	import com.greensock.TweenLite;
	
	import dragonBones.Armature;
	
	import effects.Particles;
	
	import flash.display.MovieClip;
	
	import objects.IceBlock;
	import objects.PopupSensor;
	import objects.SwimmingPlatform;
	import objects.customized.Pool;
	import objects.customized.Rope;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	/**
	 * @author Thomas Zenkner
	 */
	public class Level1 extends SnowmanBasicLevel 
	{
		private var vecCoins:Vector.<CitrusObject>;
		
		public function Level1(level:MovieClip = null) {
			
			super(level);
		}
		
		override public function initialize():void {
			
			super.initialize();
			
			Sounds.addSoundFiles();
			
			createObjects();
		}
		
		private function createObjects():void
		{
			vecCoins = getObjectsByType(Coin);
			for (i = 0; i<vecCoins.length; i++)
			{
				(vecCoins[i] as Coin).setParams(vecCoins[i] as Coin, {view:new Image(Assets.getAtlas().getTexture("coin")), collectorClass:HeroSnowman});
				(vecCoins[i] as Coin).onBeginContact.add(coinCollected);
			}
			checkPoints = new Vector.<b2Vec2>();
			checkPoints.push(new b2Vec2(1120, -460), new b2Vec2(288, 410), new b2Vec2(1180, 470), new b2Vec2(1800, 520));
			
			Sensor(getObjectByName("check1")).onBeginContact.add(function():void{remove(getObjectByName("check1"))});
			Sensor(getObjectByName("check2")).onBeginContact.add(function():void{checkPointIndex = 1; remove(getObjectByName("check2"))});
			Sensor(getObjectByName("check3")).onBeginContact.add(function():void{checkPointIndex = 2; remove(getObjectByName("check3"))});
			Sensor(getObjectByName("check4")).onBeginContact.add(function():void{checkPointIndex = 3; remove(getObjectByName("check4"))});
			
			Sensor(getObjectByName("tooDeep")).onBeginContact.add(function():void{lifebar.ratio = 0; die()});
			
			var bridge2:Bridge = new Bridge("bridge2", {group:2, leftAnchor:getObjectByName("left"), rightAnchor:getObjectByName("right"),
				numSegments:10, segmentTexture:Assets.getAtlas().getTexture("bridge1"), useTexture:true, heightSegment:5});
			add(bridge2);
			
			(getObjectByName("four") as Platform).body.GetFixtureList().SetFilterData(filterDataNone);
			
			var rope:Rope = new Rope("rope", {group:2, anchor:getObjectByName("one"), ropeLength:110, widthSegment:1,
				numSegments:11, segmentTexture:Assets.getAtlas().getTexture("rope"), useTexture:true, heroAnchorOffset:new b2Vec2(0, -((snowman.height+36)/2))});
			add(rope);
			var rope2:Rope = new Rope("rope1", {group:2, anchor:getObjectByName("two"), ropeLength:100, widthSegment:1,
				numSegments:10, segmentTexture:Assets.getAtlas().getTexture("rope"), useTexture:true, heroAnchorOffset:new b2Vec2(0, -((snowman.height+36)/2))});
			add(rope2);
			var rope4:Rope = new Rope("rope4", {group:2, anchor:getObjectByName("four"), ropeLength:100, widthSegment:1,
				numSegments:10, segmentTexture:Assets.getAtlas().getTexture("rope"), useTexture:true, heroAnchorOffset:new b2Vec2(0, -((snowman.height+36)/2))});
			add(rope4);
			var ropeCaveTop:Rope = new Rope("ropeCaveTop", {group:2, anchor:getObjectByName("caveTop"), ropeLength:160, widthSegment:1,
				numSegments:12, segmentTexture:Assets.getAtlas().getTexture("rope"), useTexture:true, heroAnchorOffset:new b2Vec2(0, -((snowman.height+36)/2))});
			add(ropeCaveTop);
			var ropeTreeOne:Rope = new Rope("ropeTreeOne", {group:2, anchor:getObjectByName("ropeTreeOne"), ropeLength:150, widthSegment:1,
				numSegments:12, segmentTexture:Assets.getAtlas().getTexture("rope"), useTexture:true, heroAnchorOffset:new b2Vec2(0, -((snowman.height+36)/2))});
			add(ropeTreeOne);
			var ropeTreeTwo:Rope = new Rope("ropeTreeTwo", {group:2, anchor:getObjectByName("ropeTreeTwo"), ropeLength:150, widthSegment:1,
				numSegments:12, segmentTexture:Assets.getAtlas().getTexture("rope"), useTexture:true, heroAnchorOffset:new b2Vec2(0, -((snowman.height+36)/2))});
			add(ropeTreeTwo);
			
			var pool:Pool = new Pool("pool",{x:460, y: -77, poolWidth:370, poolHeight:145, waterHeight:145, createBottom:false, hot:true, useSound:true});
			add(pool);
			var pool1:Pool = new Pool("pool1",{x:1530, y: 750, poolWidth:1520, poolHeight:325, createBottom:false, waterHeight:265});
			add(pool1);
			
			var iceblock:IceBlock = new IceBlock("ice",{x:222, y:-900});
			add(iceblock);
			
			particles = new Particles();
			particles.particlesBubble.emitterX = pool.x+5;
			particles.particlesBubble.emitterY= pool.y-15;
			particles.particlesBubble.start();
			
			var spLeft:SwimmingPlatform = new SwimmingPlatform("spLeft", {x:300, y: -600, texture:Assets.getAtlas().getTexture("swimmingPlatform")});
			add(spLeft);
			add(spLeft.display);
			var spRight:SwimmingPlatform = new SwimmingPlatform("spRight", {x:610, y: -600, texture:Assets.getAtlas().getTexture("swimmingPlatform")});
			add(spRight);
			add(spRight.display);
			
			(getObjectByName("teleporter") as Teleporter).object = snowman;
			(getObjectByName("teleporter") as Teleporter).onBeginContact.add(function():void{snowman.isSwimming = false;});
			(getObjectByName("no2") as Platform).oneWay = true;
			(getObjectByName("fg") as CitrusSprite).view = new Image(Assets.getAtlas().getTexture("fgWater"));
			(getObjectByName("fg1") as CitrusSprite).view = new Image(Assets.getAtlas().getTexture("fgWater2"));
			(getObjectByName("mp") as Platform).view = new Image(Assets.getAtlas().getTexture("movingPlatform"));
			
			var vecSharks:Vector.<CitrusObject> = getObjectsByType(Shark);
			for (var i:int = 0; i<vecSharks.length; i++)
			{
				var _shark:Armature = _factory.buildArmature("shark");
				(_shark.display as Sprite).scaleY = 0.5;
				(_shark.display as Sprite).scaleX = -0.5;
				(vecSharks[i] as Shark).setParams(vecSharks[i] as Shark, {view:_shark, group:3, offsetX:80, offsetY:60});
				if (!(vecSharks[i] as Shark).kinematic) pool1.addBodyToPool((vecSharks[i] as Shark).getBody())
				_shark.animation.play();
			}
			
			var vecFish:Vector.<CitrusObject> = getObjectsByType(RoundFish);
			for (i = 0; i<vecFish.length; i++)
			{
				var _fish:Armature = _factory.buildArmature("RoundFish");
				(_fish.display as Sprite).scaleY = 0.45;
				(_fish.display as Sprite).scaleX = -0.45;
				(vecFish[i] as RoundFish).setParams(vecFish[i] as RoundFish, {view:_fish, group:3, offsetX:45, offsetY:45});
				_fish.animation.play();
			}
			
			var moveHint:PopupSensor = PopupSensor(getObjectByName("moveHint"));
			moveHint.createTextField("What's going on? It's damn cold\n out here!\nControl me with the arrow keys, press space to jump!", moveHint.x, moveHint.y);
			
			var startHint:PopupSensor = PopupSensor(getObjectByName("startHint"));
			startHint.createTextField("How did I become a snowman?!\nStrange s***!", startHint.x, startHint.y);
			
			var storyHint:PopupSensor = PopupSensor(getObjectByName("storyHint"));
			storyHint.createTextField("Oooh I have weapons?!\nHope I don't need to kill someone...", storyHint.x, storyHint.y);
			
			var firingHint:PopupSensor = PopupSensor(getObjectByName("firingHint"));
			firingHint.createTextField("Press Ctrl or Y to enter aiming mode\nUp/Down to change angle,\n Ctrl or Y to fire\nX changes the weapon", firingHint.x, firingHint.y);
			
			var ropeHint:PopupSensor = PopupSensor(getObjectByName("ropeHint"));
			ropeHint.createTextField("Jump against a rope and hang to it\nLeft/Right to swing\nUp/Down to climb\nSpace to get off", ropeHint.x, ropeHint.y);
			
			var slideHint:PopupSensor = PopupSensor(getObjectByName("slideHint"));
			slideHint.createTextField("I am my own sledge!\nDuck (key down) while walking\nand slide. Try it downwards!", slideHint.x, slideHint.y);
			
			var swimmingHint:PopupSensor = PopupSensor(getObjectByName("swimmingHint"));
			swimmingHint.createTextField("If under water press Space to move up.\nAnd don't touch the fish\nor dive too deep!\nI'm not made for hot water!", swimmingHint.x+100, swimmingHint.y);
			
			var hotWaterHint:PopupSensor = PopupSensor(getObjectByName("hotWaterHint"));
			hotWaterHint.oneTime = true;
			hotWaterHint.createTextField("This water looks hot, better not jump in there!\n Maybe I can cool it down..", hotWaterHint.x, hotWaterHint.y);
			hotWaterHint.onBeginContact.add(zoomIn);
			
			var endHint:PopupSensor = PopupSensor(getObjectByName("endHint"));
			endHint.createTextField("", endHint.x, endHint.y);
			endHint.onBeginContact.add(function():void{endHint.tf.text = "Level End!\nYou have collected "
				+_ce.gameData.coins+" out of "+vecCoins.length+" coins\nNext Level coming soon..."});
			
			SoundManager.getInstance().playSound("bgMusic");
			SoundManager.getInstance().playSound("boil", 0.2);
		}

		// function i use for tweening the camera, quick and dirty..
		private function zoomIn(contact:b2Contact):void {
			
			if (contact.GetFixtureA().GetBody().GetUserData() is HeroSnowman || contact.GetFixtureB().GetBody().GetUserData() is HeroSnowman) {
				SoundManager.getInstance().setVolume("boil", 0.9)
				var ob:Object = {x:snowman.x, y:snowman.y};
				camera.target = ob;
				snowman.controlsEnabled = false;
				TweenLite.to(ob, 2,{delay:1, x:(getObjectByName("ice") as IceBlock).x, y:(getObjectByName("ice") as IceBlock).y+150,
					onComplete:function():void{
						TweenLite.to(ob, 3,{ x:snowman.x, y:snowman.y, 
							onComplete:function():void{
								snowman.controlsEnabled = true; camera.target = snowman;}
						})
					}
				});
			}
		}
	}
}
