package characters
{
	import flash.geom.Point;
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.math.MathVector;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	
	import objects.SwimmingPlatform;
	import objects.customized.Pool;
	
	/**
	 * @author Thomas Zenkner
	 */
	public class Shark extends Enemy
	{
		protected var _topSensorShape:b2PolygonShape;
		protected var _bottomSensorShape:b2PolygonShape;
		protected var _topSensorFixture:b2Fixture;
		protected var _bottomSensorFixture:b2Fixture;
		private var targetY:Number;
		
		[Inspectable(defaultValue="30")]
		public var verticalRadius:Number = 30;
		
		[Inspectable(defaultValue="200")]
		public var horizontalRadius:Number = 200;
		
		[Inspectable(defaultValue="false")]
		public var kinematic:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		public var useSensor:Boolean = false;
		
		public function Shark(name:String, params:Object=null)
		{
			super(name, params);
			targetY = y;
			leftBound = _x*30 - horizontalRadius
			rightBound = _x*30 + horizontalRadius
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			var position:b2Vec2 = _body.GetPosition();
			if (position.y * _box2D.scale > targetY + verticalRadius)
			{
				_body.ApplyImpulse(new b2Vec2(0, -2), _body.GetWorldCenter());
			}
			if ((position.x * _box2D.scale < leftBound) || (position.x * _box2D.scale > rightBound)) speed = -speed;
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			velocity.x = speed;
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			if (kinematic) _bodyDef.type = b2Body.b2_kinematicBody;
			else _bodyDef.type = b2Body.b2_dynamicBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = 0;
			_fixtureDef.density = 1.9;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items");
			
			_sensorFixtureDef = new b2FixtureDef();
			_sensorFixtureDef.shape = _leftSensorShape;
			_sensorFixtureDef.isSensor = true;
			_sensorFixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_sensorFixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items");
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.2);
			
			var sensorWidth:Number = wallSensorWidth / _box2D.scale;
			var sensorHeight:Number = _height / 3;
			var sensorOffset:b2Vec2 = new b2Vec2( -_width / 2 - (sensorWidth * 2), 0);
			
			_leftSensorShape = new b2PolygonShape();
			_leftSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = -sensorOffset.x;
			_rightSensorShape = new b2PolygonShape();
			_rightSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = sensorOffset.x/2;
			sensorOffset.y = _height/2 + (wallSensorOffset / _box2D.scale);
			_topSensorShape = new b2PolygonShape();
			_topSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = sensorOffset.x/2;
			sensorOffset.y = -_height/2 - (wallSensorOffset / _box2D.scale);
			_bottomSensorShape = new b2PolygonShape();
			_bottomSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (collider is _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)
				hurt();
			
			if (_body.GetLinearVelocity().x < 0 && (contact.GetFixtureA() == _rightSensorFixture || contact.GetFixtureB() == _rightSensorFixture))
				return;
			
			if (_body.GetLinearVelocity().x > 0 && (contact.GetFixtureA() == _leftSensorFixture || contact.GetFixtureB() == _leftSensorFixture))
				return;
			
			if (contact.GetManifold().m_localPoint) {
				
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				
				if (collider is Platform || collider is Enemy || (collider is SwimmingPlatform && collisionAngle != -90)
					|| (collider is Pool))
					turnAround();
				//				trace(collider, collisionAngle);
			}
		}
	}
}