package characters
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.physics.PhysicsCollisionCategories;
	
	public class RoundFish extends Enemy
	{
		[Inspectable(defaultValue="1.3")]
		public var speedY:Number = 0.7;
		
		[Inspectable(defaultValue="up",enumeration="up, down")]
		public var startingVerticalDirection:String = "up";
		
		[Inspectable(defaultValue="1000")]
		public var topBound:Number = -100000;
		
		[Inspectable(defaultValue="0")]
		public var bottomBound:Number = 100000;		
		
		[Inspectable(defaultValue="300")]
		public var radiusVertical:Number=0;
		
		protected var _topSensorShape:b2PolygonShape;
		protected var _bottomSensorShape:b2PolygonShape;
		protected var _topSensorFixture:b2Fixture;
		protected var _bottomSensorFixture:b2Fixture;
		
		public function RoundFish(name:String, params:Object=null)
		{
			super(name, params);
			_beginContactCallEnabled = false;
		}
		
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			speed = 0;
			if (radiusVertical != 0)
			{
				topBound = _y*30 - radiusVertical;
				bottomBound = _y*30 + radiusVertical;
			}
			if (startingVerticalDirection == "down") speedY = -speedY;
		}
		
		override public function update(timeDelta:Number):void
		{
			var position:b2Vec2 = _body.GetPosition();
			if ((position.y * _box2D.scale < topBound) || (position.y * _box2D.scale > bottomBound)) speedY = -speedY;
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			velocity.y = speedY;
		}
		override protected function createShape():void
		{
			_shape = new b2CircleShape();
			b2CircleShape(_shape).SetRadius(_width / 2);
			
			var sensorWidth:Number = wallSensorWidth / _box2D.scale;
			var sensorHeight:Number = wallSensorHeight / _box2D.scale;
			var sensorOffset:b2Vec2 = new b2Vec2( -_width / 2 - (sensorWidth / 2), _height / 2 - (wallSensorOffset / _box2D.scale));
			
			_leftSensorShape = new b2PolygonShape();
			_leftSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = -sensorOffset.x;
			_rightSensorShape = new b2PolygonShape();
			_rightSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
		}
		
		override protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_kinematicBody;
			_bodyDef.position = new b2Vec2(_x, _y);
			_bodyDef.angle = _rotation;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.Get("GoodGuys");
		}
	}
}