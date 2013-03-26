package objects
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Controllers.b2BuoyancyController;
	
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	/**
	 * @author Thomas Zenkner
	 */
	public class SwimmingPlatform extends Box2DPhysicsObject
	{
		public var ws:int = 30;
		
		private var pool:b2Body;
		private var poolFixtureDef:b2FixtureDef;
		private var poolFixture:b2Fixture;
		
		public var display:CitrusSprite;
		public var texture:Texture;
		
		//to prevent them from floating anywhere this are values to control the position
		private var targetX:Number;
		private var targetY:Number;
		
		private var toleranceX:Number = 10;
		private var toleranceY:Number = 10;
		
		private var buoyancyController:b2BuoyancyController = new b2BuoyancyController();
		
		public function SwimmingPlatform(name:String, params:Object=null)
		{
			super(name, params);
			updateCallEnabled = true;
		}
		
		override public function update(timeDelta:Number):void 
		{
			super.update(timeDelta);
			
			if (_body.GetWorldCenter().x*ws < targetX-toleranceX) 
				_body.ApplyForce(new b2Vec2(10, 0), _body.GetWorldCenter());
			
			else if (_body.GetWorldCenter().x*ws > targetX+toleranceX) 
				_body.ApplyForce(new b2Vec2(-10, 0), _body.GetWorldCenter());
			
			if (_body.GetWorldCenter().y*ws < targetY+toleranceY) 
				_body.ApplyForce(new b2Vec2(0, -15), _body.GetWorldCenter());
			
			if (display)
			{
				this.display.x = _body.GetWorldCenter().x * _box2D.scale;
				this.display.y = _body.GetWorldCenter().y * _box2D.scale;
				this.display.rotation = rad2deg(_body.GetAngle());
			}
		}
		
		override protected function defineBody():void
		{
			targetX = x;
			targetY = -390;
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
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
			b2PolygonShape(_shape).SetAsBox(110/ws, 10/ws);
		}
		
		override protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 0.8;
			_fixtureDef.friction = 0.02;
			_fixtureDef.restitution = 0;
		}
		
		override protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
			
			poolFixtureDef = new b2FixtureDef();
			poolFixtureDef.friction = 0.3;
			poolFixtureDef.restitution = 0;
			
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(40/ws, 5/ws, new b2Vec2(-width/ws/2+30/ws, 35/ws), deg2rad(60));
			poolFixtureDef.density = 0.3;
			poolFixtureDef.shape = _shape;
			_body.CreateFixture(poolFixtureDef);	
			
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(40/ws, 5/ws, new b2Vec2(width/ws/2-30/ws, 35/ws), deg2rad(-60));
			poolFixtureDef.shape = _shape;
			poolFixtureDef.density = 0.3;
			_body.CreateFixture(poolFixtureDef);
			
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(65/ws, 5/ws, new b2Vec2(0, 33/ws));
			poolFixtureDef.shape = _shape;
			poolFixtureDef.density = 0.3;
			_body.CreateFixture(poolFixtureDef);		
			
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(16.5/ws, 16.5/ws, new b2Vec2(0, 63.5/ws));
			poolFixtureDef.shape = _shape;
			poolFixtureDef.density = 2.9;
			_body.CreateFixture(poolFixtureDef);	
			
			setDisplay();
		}
		
		private function setDisplay():void
		{
			display = new CitrusSprite("d", {view:new Image(texture), registration:"center", group:2});
			display.x = _body.GetLocalCenter().x * _box2D.scale +10/ws;
			display.y = _body.GetLocalCenter().y * _box2D.scale;
			display.rotation = rad2deg(_body.GetAngle());
		}
	}
}
