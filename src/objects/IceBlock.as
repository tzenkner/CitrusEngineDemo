package objects 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2FixtureDef;
	
	import citrus.core.SoundManager;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.PhysicsCollisionCategories;
	
	import com.greensock.TweenLite;
	
	import objects.customized.Pool;
	
	import starling.display.Image;
	import starling.extensions.particles.PDParticleSystem;
	import starling.utils.rad2deg;
	
	/**
	 * @author Thomas Zenkner
	 */
	public class IceBlock extends Box2DPhysicsObject
	{
		private var ws:int = 30;
		
		private var images:Vector.<CitrusSprite>;
		private var bodies:Vector.<b2Body>;
		private var poolIceCount:int = 0;
		
		public function IceBlock(name:String, params:Object=null)
		{
			super(name, params);
			updateCallEnabled = true;
		}
		
		override public function destroy():void
		{
			super.destroy();
			for (var i:int = 0; i<images.length; i++)
			{
				_ce.state.remove(images[i]);
			}
			for (i = 0; i<bodies.length; i++)
			{
				_box2D.world.DestroyBody(bodies[i]);
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			if (bodies[0])
			{
				for (var i:int = 0; i<images.length; i++)
				{
					images[i].x = bodies[i].GetPosition().x*ws;
					images[i].y = bodies[i].GetPosition().y*ws;
					images[i].rotation = rad2deg(bodies[i].GetAngle());
				}
			}
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
		}
		
		override protected function createShape():void
		{
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsBox(33/ws, 38/ws);
		}
		
		override protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0.5;
			_fixtureDef.restitution = 0.4;
			_fixtureDef.userData = {index:0};
		}
		
		// setting up the blocks, could be shortened ;)
		override protected function createFixture():void
		{
			images=new Vector.<CitrusSprite>();
			bodies = new Vector.<b2Body>();
			_fixture = _body.CreateFixture(_fixtureDef);
			var display:CitrusSprite = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis1")), registration:"center", group:2});
			_ce.state.add(display);
			images.push(display);
			bodies.push(_body);
			
			_bodyDef.position.Set(x/ws + 66.5/ws, y/ws + 8/ws);
			b2PolygonShape(_shape).SetAsBox(30.5/ws, 46/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:1};
			var body:b2Body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis2")), registration:"center", group:2});
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 147/ws, y/ws - 7/ws);
			b2PolygonShape(_shape).SetAsBox(40/ws, 31/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:2};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis3")), registration:"center", group:2});
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 213.5/ws, y/ws - 7/ws);
			b2PolygonShape(_shape).SetAsBox(15.5/ws, 31/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:3};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis4")), registration:"center", group:2});
			display.x = x+213.5;
			display.y = y-7;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 266/ws, y/ws + 16.5/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 54.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:4};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis5")), registration:"center", group:2});
			display.x = x+266;
			display.y = y+16.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 332/ws, y/ws + 12.5/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 50.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:5};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis6")), registration:"center", group:2});
			display.x = x+332;
			display.y = y+12.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 398/ws, y/ws + 20.5/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 58.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:6};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis7")), registration:"center", group:2});
			display.x = x+398;
			display.y = y+20.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 476.5/ws, y/ws + 16.5/ws);
			b2PolygonShape(_shape).SetAsBox(40/ws, 54.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:7};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis8")), registration:"center", group:2});
			display.x = x+476.5;
			display.y = y+16.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws, y/ws + 82.5/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 44.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:8};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis9")), registration:"center", group:2});
			display.x = x+0;
			display.y = y+82.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 66.5/ws, y/ws + 105.5/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 52.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:9};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis10")), registration:"center", group:2});
			display.x = x+66.5;
			display.y = y+105.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 147/ws, y/ws + 84/ws);
			b2PolygonShape(_shape).SetAsBox(43/ws, 60/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:10};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis11")), registration:"center", group:2});
			display.x = x+147;
			display.y = y+84;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 213.5/ws, y/ws + 79.5/ws);
			b2PolygonShape(_shape).SetAsBox(16/ws, 55.5/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:11};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis12")), registration:"center", group:2});
			display.x = x+213.5;
			display.y = y+79.5;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 266/ws, y/ws + 120/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 49/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:12};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis13")), registration:"center", group:2});
			display.x = x+266;
			display.y = y+120;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
			
			_bodyDef.position.Set(x/ws + 332/ws, y/ws + 112/ws);
			b2PolygonShape(_shape).SetAsBox(30/ws, 49/ws);
			_fixtureDef.shape = _shape;
			_fixtureDef.userData = {index:13};
			body = _box2D.world.CreateBody(_bodyDef);
			body.SetUserData(this);
			body.CreateFixture(_fixtureDef);
			display = new CitrusSprite("d", {view:new Image(Assets.getAtlas().getTexture("eis14")), registration:"center", group:2});
			display.x = x+332;
			display.y = y+112;
			_ce.state.add(display);
			images.push(display);
			bodies.push(body);
		}
		
		public function melt(index:int):void
		{
			var filter:b2FilterData = new b2FilterData();
			filter.maskBits = PhysicsCollisionCategories.GetNone();
			bodies[index].GetFixtureList().SetFilterData(filter);
			TweenLite.to(images[index].view, 2, {scaleX:0.3, scaleY:0.3, x:"20", y:"50", onComplete:onFinishTween, onCompleteParams:[index]});
			poolIceCount++;
			if (((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).maxNumParticles > 10) 
			{
				((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).maxNumParticles -= 15;
				((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).speed -= 7;
				((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).speedVariance -= 0.3;
				SoundManager.getInstance().setVolume("boil", SoundManager.getInstance().getSoundVolume("boil") - 0.03)
				if (poolIceCount < 7) ((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).lifespan += 0.13;
				else if (poolIceCount < 11) ((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).lifespan += 0.19;
				else if (poolIceCount < 13) ((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).lifespan += 0.4;
				else 
				{
					((_ce.state.getObjectByName("bubbles") as CitrusSprite).view as PDParticleSystem).pause();
					(_ce.state.getObjectByName("pool") as Pool).hot = false;
					_ce.state.remove(this);
					SoundManager.getInstance().stopSound("boil");
				}
			}
		}
		private function onFinishTween(index:int):void {
			_box2D.world.DestroyBody(bodies[index]);
			_ce.state.remove(images[index]);
		}
	}
}
