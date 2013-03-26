package objects.customized 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2BuoyancyController;
	import Box2D.Dynamics.Controllers.b2ControllerEdge;
	
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	
	import dragonBones.Armature;
	import objects.IceBlock;
	import characters.HeroSnowman;
	
	public class Pool extends Box2DPhysicsObject
	{
		public var poolWidth:Number = 700;
		public var poolHeight:Number = 200;
		public var poolThickness:Number = 15;
		public var waterHeight:Number = 170;
		public var ws:int = 30;
		public var createBottom:Boolean = true;
		public var hot:Boolean = false;
		
		private var pool:b2Body;
		private var poolFixtureDef:b2FixtureDef;
		private var poolFixture:b2Fixture;
		
		private var hero:HeroSnowman;
		
		private var originalSize:b2Vec2;
		
		private var buoyancyController:b2BuoyancyController = new b2BuoyancyController();
		
		public function Pool(name:String, params:Object=null)
		{
			super(name, params);
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
		}
		
		override public function destroy():void
		{
			_box2D.world.DestroyController(buoyancyController);
			_box2D.world.DestroyBody(pool);
			super.destroy();
		}
		
		override protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_staticBody;
			_bodyDef.position.Set(x/ws, y/ws);
		}
		
		override protected function createBody():void
		{
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
			pool = _box2D.world.CreateBody(_bodyDef);
			pool.SetUserData(this);
		}
		
		override protected function createShape():void
		{
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(poolWidth/_box2D.scale, (waterHeight-poolThickness)/_box2D.scale, 
				new b2Vec2(0, -waterHeight/_box2D.scale));
		}
		
		override protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.isSensor = true;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0.5;
			_fixtureDef.restitution = 0.4;
			_fixtureDef.userData = {name:"water"};
		}
		
		override protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
			
			poolFixtureDef = new b2FixtureDef();
			poolFixtureDef.isSensor = false;
			poolFixtureDef.density = 1;
			poolFixtureDef.friction = 0.6;
			poolFixtureDef.restitution = 0.3;
			poolFixtureDef.userData = {name:"pool"};
			
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(poolThickness/_box2D.scale, poolHeight/_box2D.scale, 
				new b2Vec2((-poolWidth-poolThickness)/_box2D.scale, (-poolHeight+poolThickness)/_box2D.scale));
			poolFixtureDef.shape = _shape;
			pool.CreateFixture(poolFixtureDef);
			b2PolygonShape(_shape).SetAsOrientedBox(poolThickness/_box2D.scale, poolHeight/_box2D.scale, 
				new b2Vec2((poolWidth+poolThickness)/_box2D.scale, (-poolHeight+poolThickness)/_box2D.scale));
			poolFixtureDef.shape = _shape;
			pool.CreateFixture(poolFixtureDef);
			if (createBottom) {
				b2PolygonShape(_shape).SetAsBox(poolWidth/_box2D.scale, poolThickness/_box2D.scale);
				poolFixtureDef.shape = _shape;
				pool.CreateFixture(poolFixtureDef);
			}
			
			buoyancyController.normal.Set(0,-1);
			//			buoyancyController.offset=-670/ws;
			buoyancyController.offset=-(_bodyDef.position.y - 2*waterHeight/ws + poolThickness/ws);
			buoyancyController.useDensity=true;
			buoyancyController.density=1.8;
			buoyancyController.linearDrag=3;
			buoyancyController.angularDrag=2;
			_box2D.world.AddController(buoyancyController);
		}
		
		public function addBodyToPool(b:b2Body):void
		{
			buoyancyController.AddBody(b);
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
//			if(contact && contact.GetFixtureB().GetUserData() && contact.GetFixtureB().GetUserData().name == "water")
//			{
			if(contact.GetFixtureA() == _fixture || contact.GetFixtureB() == _fixture)
			{
				var bodyA:b2Body= Box2DUtils.CollisionGetOther(this, contact).body;
				hero = (_ce.state.getObjectByName("snowman") as HeroSnowman);
				if (bodyA.GetUserData().name == "snowman") {
					originalSize = new b2Vec2(hero.width/ws, hero.height/ws);
					if (hot && !hero.onSwimmingPlatform)
					{
						hero.body.ApplyImpulse(new b2Vec2(0, -30), hero.body.GetLocalCenter());
						hero.hurt();
					}
					else if (hot && hero.onSwimmingPlatform)
					{
						hero.markForDamage = true;
					}
					else if(!hero.onSwimmingPlatform)
					{
						hero.isSwimming = true;
						(hero.view as Armature).getBone("frontDownArm").childArmature.animation.gotoAndPlay("noWepaon");
						hero.body.GetFixtureList().SetFriction(0.01);
						var swimShape:b2Shape = Box2DShapeMaker.BeveledRect((hero.height+10)/ws, hero.width/ws, 0.1);
						hero.body.GetFixtureList().GetShape().Set(swimShape);
						hero.offsetY = -18;
						hero.body.GetFixtureList().SetDensity(2.1);
						hero.body.ResetMassData();
						hero.hurtDuration = 1500;
					}
					else if(hero.onSwimmingPlatform)
					{
						hero.markForDamage = true;
					}
				}
				else if (bodyA.GetUserData().name == "ice") {
					(_ce.state.getObjectByName("ice") as IceBlock).melt(contact.GetFixtureA().GetUserData().index);
					
				}
				var bodyAControllers:b2ControllerEdge=bodyA.GetControllerList();
				if (bodyAControllers==null) {
					buoyancyController.AddBody(bodyA);
				}
				
			}
		}
		override public function handleEndContact(contact:b2Contact):void
		{
			if(contact.GetFixtureA() == _fixture || contact.GetFixtureB() == _fixture)
			{
				var currentBodyControllers:b2ControllerEdge=contact.GetFixtureA().GetBody().GetControllerList();
				if (currentBodyControllers!=null) {
					buoyancyController.RemoveBody(contact.GetFixtureA().GetBody());
				}
				if (Box2DUtils.CollisionGetOther(this, contact).body.GetUserData().name == "snowman") {
					hero.isSwimming = false;
					hero.markForDamage = false;
					if (!hero.isDead) (hero.view as Armature).getBone("frontDownArm").childArmature.animation.gotoAndPlay("gun");
					var swimShape:b2Shape = Box2DShapeMaker.BeveledRect(originalSize.x, originalSize.y, 0.1);
					hero.body.GetFixtureList().GetShape().Set(swimShape);
					hero.offsetY = 0;
					hero.hurtDuration = 1000;
					hero.body.GetFixtureList().SetDensity(2);
					hero.body.ResetMassData();
					
					(_ce.state.getObjectByName("snowman") as HeroSnowman).body.GetFixtureList().SetFriction(0.75);
				}
			}
		}
	}
}
