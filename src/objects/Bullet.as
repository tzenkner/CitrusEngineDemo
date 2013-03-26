package objects{
	
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Coin;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2DUtils;
	
	import starling.display.Image;
	
	// this are my bodies created for shooting
	public class Bullet extends Box2DPhysicsObject
	{
		public var speed:b2Vec2 = new b2Vec2(30, 0);
		
		private var ws:int = 30;	
		private var destroy:Boolean = false;
		
		private var image:CitrusSprite;
		
		public function Bullet(name:String, params:Object=null)
		{			
			super(name, params);
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
		}
		
		override public function update(timeDelta:Number):void
		{
			_body.SetLinearVelocity(speed);
			if (image)
			{
				image.x = _body.GetPosition().x*ws;
				image.y = _body.GetPosition().y*ws;
			}
		}
		
		override protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
			_bodyDef.position.Set(x/ws, y/ws);
		}
		
		override protected function createBody():void
		{
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
		}
		
		override protected function createShape():void
		{
			_shape = new b2CircleShape;
			b2CircleShape(_shape).SetRadius(2/ws);
		}
		
		override protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0.5;
			_fixtureDef.restitution = 0.4;
		}
		
		override protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
			
			image = new CitrusSprite("b", {x:_body.GetPosition().x * ws, y:_body.GetPosition().y * ws,group:3,
				view:new Image(Assets.getAtlas().getTexture("shoot")), registration:"center"});
			_ce.state.add(image);
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			var affectedBody:b2Body = Box2DUtils.CollisionGetOther(this, contact).body;
			if (!(affectedBody.GetUserData() is PopupSensor) && !(affectedBody.GetUserData() is Sensor) && !(affectedBody.GetUserData() is Coin)) 
			{
				_ce.state.remove(this);
				_ce.state.remove(this.image);
			}
			if (contact.GetFixtureA().GetBody().GetUserData().hasOwnProperty("name") &&  contact.GetFixtureA().GetBody().GetUserData().name == "ice") 
			{
				contact.GetFixtureA().GetBody().SetType(2);
				contact.GetFixtureA().GetBody().ApplyImpulse(new b2Vec2(speed.x/2, speed.y), contact.GetFixtureA().GetBody().GetWorldCenter());
				contact.GetFixtureA().GetBody().ApplyTorque(50);
			}
		}
	}
}

