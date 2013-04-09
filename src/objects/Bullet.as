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
	
	// these are my bodies created for shooting
	public class Bullet extends Box2DPhysicsObject
	{
		public var speed:b2Vec2 = new b2Vec2(30, 0);
		private var ws:int = 30;	
		
		public function Bullet(name:String, params:Object=null)
		{			
			super(name, params);
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
		}
		
		override public function update(timeDelta:Number):void
		{
			_body.SetLinearVelocity(speed);
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
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			var affectedBody:b2Body = Box2DUtils.CollisionGetOther(this, contact).body;
			if (!(affectedBody.GetUserData() is PopupSensor) && !(affectedBody.GetUserData() is Sensor) && !(affectedBody.GetUserData() is Coin)) 
			{
				_ce.state.remove(this);
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

