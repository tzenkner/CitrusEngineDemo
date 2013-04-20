package characters
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.core.SoundManager;
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.complex.box2dstarling.Bridge;
	import citrus.objects.platformer.box2d.Crate;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.ui.starling.LifeBar;
	
	import com.greensock.TweenLite;
	
	import dragonBones.Armature;
	import dragonBones.events.AnimationEvent;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import objects.SwimmingPlatform;
	import objects.customized.Pool;
	import objects.customized.Rope;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Sprite;
	import objects.UI.IngameDisplay;
	
	public class HeroSnowman extends Hero
	{
		public var isAiming:Boolean = false;
		public var isShooting:Boolean = false;
		public var isHanging:Boolean = false;
		public var isSwimming:Boolean = false;
		public var onSwimmingPlatform:Boolean = false;
		public var markForDamage:Boolean = false;
		public var isDead:Boolean = false;
		
		public var onShoot:Signal;
		public var onShootEnd:Signal;
		public var onWeaponChange:Signal;
		public var weapon:String = "gun";
		
		public var currentRope:String;
		
		private var off:Number;
		private var armRotation:Number = 0;
		private var autoAnimation:Boolean = true;
		private var idleCount:int = 0;
		private var idleCountMax:int = 0;
		
		private var sounds:SoundManager = SoundManager.getInstance();
		
		public function HeroSnowman(name:String, params:Object=null)
		{
			super(name, params);	
			onShoot = new Signal();
			onShootEnd = new Signal();
			onWeaponChange = new Signal();
			off = this.offsetY;
		
		}
		
		override protected function updateAnimation():void {
			
			var prevAnimation:String = _animation;
			
			var walkingSpeed:Number = getWalkingSpeed();
			
			if (_hurt)
				_animation = "hurt";
				
			else if (isShooting && isAiming && !isHanging){
				
				switch (weapon)
				{
					case "gun":
						_animation = "fire";
						break;
					case "flameThrower":
						_animation = "flame";
						break;
				}
			}
				
			else if (isAiming && !isHanging && !isShooting){
				_animation = "flame";
			}
				
			else if (!_onGround && !_ducking && !isHanging) {
				
				_animation = "jump";
				
				if (walkingSpeed < -acceleration)
					_inverted = true;
				else if (walkingSpeed > acceleration)
					_inverted = false;
				
			} 
			else if (_ducking && !isHanging){
				_animation = "duck";
			}
			else if (isHanging){
				_animation = "hang";
			}
			else if (isSwimming){
				if (walkingSpeed < -1) {
					_inverted = true;
					_animation = "swim";
					
				} else if (walkingSpeed > 1) {
					
					_inverted = false;
					_animation = "swim";
					
				} else
					_animation = "swim";
			}
			else {
				if (walkingSpeed < -acceleration) {
					_inverted = true;
					_animation = "walk";
					
				} else if (walkingSpeed > acceleration) {
					
					_inverted = false;
					_animation = "walk";
					
				} else{
					if (idleCountMax > 0)
					{
						idleCount++
					}
					if (idleCount <= idleCountMax) _animation = "stand";
					else _animation = "standBalance";
				}
			}
			
			if (prevAnimation != _animation)
			{
				if(_animation == "stand")
				{
					idleCountMax = int(90 + Math.random()*150);
				}
				else if (prevAnimation == "standBalance")
				{
					idleCountMax = 0;
					idleCount = 0;
				}
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDoing("duck", inputChannel) && canDuck);
				
				if (!isAiming && !isSwimming && !isHanging)
				{
					canDuck = true;
					
					if (_ce.input.isDoing("right", inputChannel) && !_ducking)
					{
						velocity.Add(getSlopeBasedMoveAngle());
						moveKeyPressed = true;
					}
					else if (_ce.input.isDoing("left", inputChannel) && !_ducking)
					{
						velocity.Subtract(getSlopeBasedMoveAngle());
						moveKeyPressed = true;
					}
					if (_ce.input.isDoing("duck", inputChannel) && _ducking)
					{
						_fixture.SetFriction(0.01);
						maxVelocity = 10;
					}
					else if (_ce.input.hasDone("duck", inputChannel))
					{
						_fixture.SetFriction(_friction);
						maxVelocity = 3.5;
					}
					if (_ce.input.justDid("shoot", inputChannel))
					{
						isAiming = true;
						(this.view as Armature).getBone("frontUpArm").node.rotation = armRotation;
						(this.view as Armature).getBone("backUpArm").node.rotation = armRotation;
					}
					else if (_ce.input.justDid("changeWeapon", inputChannel))
					{
						onWeaponChange.dispatch();					
					}
					if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ducking)
					{
						_onGround = false;
						velocity.y = -jumpHeight;
						onJump.dispatch();
						sounds.playSound("jump", 0.4, 0);
					}
					if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0)
					{
						velocity.y -= jumpAcceleration;
					}
				}
					
				else if (isSwimming) 
				{
					_onGround = true;
					canDuck = false;
					
					if (_ce.input.isDoing("right", inputChannel))
					{
						this.body.ApplyImpulse(new b2Vec2(0.8, 0), this.body.GetLocalCenter());
						moveKeyPressed = true;
					}
					else if (_ce.input.isDoing("left", inputChannel))
					{
						this.body.ApplyImpulse(new b2Vec2(-0.8, 0), this.body.GetLocalCenter());
						moveKeyPressed = true;
					}
					if (_ce.input.isDoing("down", inputChannel))
					{
						this.body.ApplyImpulse(new b2Vec2(0, 0.5), this.body.GetLocalCenter());
						moveKeyPressed = true;
					}
					
					if (_ce.input.justDid("jump", inputChannel))
					{
						sounds.playSound("swim", 1, 0);
						if (this.y < -350) 
						{
							_onGround = false;
							velocity.y = -jumpHeight;
						}
						else this.body.ApplyImpulse(new b2Vec2(0, -4), this.body.GetLocalCenter());
						moveKeyPressed = true;
					}
				}
					
				else if (isHanging) 
				{
					canDuck = false;
					
					if (_ce.input.isDoing("right", inputChannel))
					{
						velocity.Add(new b2Vec2(0.2, 0));
						moveKeyPressed = true;
					}
					else if (_ce.input.isDoing("left", inputChannel))
					{
						velocity.Subtract(new b2Vec2(0.2, 0));
						moveKeyPressed = true;
					}
					if (_ce.input.justDid("jump", inputChannel))
					{
						(_ce.state.getObjectByName(currentRope) as Rope).stopClimbing();
						(_ce.state.getObjectByName(currentRope) as Rope).removeJoint();
						sounds.playSound("jump", 0.4, 0);
					}
					if (_ce.input.hasDone("up", inputChannel))
					{
						(_ce.state.getObjectByName(currentRope) as Rope).stopClimbing();
					}
					else if (_ce.input.hasDone("down", inputChannel))
					{
						(_ce.state.getObjectByName(currentRope) as Rope).stopClimbing();
					}
					if (_ce.input.justDid("up", inputChannel))
					{
						(_ce.state.getObjectByName(currentRope) as Rope).startClimbing(true);
					}
					else if (_ce.input.justDid("down", inputChannel))
					{
						(_ce.state.getObjectByName(currentRope) as Rope).startClimbing(false);
					}
				}
					
				else if (isAiming)
				{
					canDuck = false;
					
					if ((_ce.input.justDid("left", inputChannel) || _ce.input.justDid("right", inputChannel)) && !isShooting)
					{
						isAiming = false;
						armRotation = (this.view as Armature).getBone("frontUpArm").node.rotation;
						(this.view as Armature).getBone("frontUpArm").node.rotation = 0;
						(this.view as Armature).getBone("backUpArm").node.rotation = 0;
					}
					if (_ce.input.justDid("jump", inputChannel) && !isShooting)
					{
						isAiming = false;
						sounds.playSound("jump", 0.4, 0);
						armRotation = (this.view as Armature).getBone("frontUpArm").node.rotation;
						(this.view as Armature).getBone("frontUpArm").node.rotation = 0;
						(this.view as Armature).getBone("backUpArm").node.rotation = 0;
						_onGround = false;
						velocity.y = -jumpHeight;
					}
					else if (_ce.input.hasDone("shoot", inputChannel) && isShooting) 
					{
						isShooting = false;
						onShootEnd.dispatch();
					}
					else if (_ce.input.justDid("shoot", inputChannel) && !isShooting)
					{
						isShooting = true;
						onShoot.dispatch();	
					}
					else if (_ce.input.justDid("changeWeapon", inputChannel))
					{
						onWeaponChange.dispatch();					
					}
					else if (_ce.input.isDoing("up", inputChannel))
					{
						if ((this.view as Armature).getBone("frontUpArm").node.rotation > -1.4)
						{
							(this.view as Armature).getBone("frontUpArm").node.rotation -= 0.04;
							(this.view as Armature).getBone("backUpArm").node.rotation -= 0.04;
						}
					}
						
					else if (_ce.input.isDoing("down", inputChannel))
					{
						if ((this.view as Armature).getBone("frontUpArm").node.rotation < 0.9)
						{
							(this.view as Armature).getBone("frontUpArm").node.rotation += 0.04;
							(this.view as Armature).getBone("backUpArm").node.rotation += 0.04;
						}
					}
				}
				
				if (_springOffEnemy != -1)
				{
					if (_ce.input.isDoing("jump", inputChannel))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); 
				}
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction);
				}
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				if (velocity.y > (10))
					velocity.y = 10;
				else if (velocity.y < (-10))
					velocity.y = -10;
			}
			if (autoAnimation) updateAnimation();
		}
		
		private function takeDamage():void
		{
			IngameDisplay((_ce.state as Sprite).getChildByName("display")).lifebar.ratio -= 1/3;
			if (IngameDisplay((_ce.state as Sprite).getChildByName("display")).lifebar.ratio < 0.1) 
			{
				die();
			}
			else 
			{
				SoundManager.getInstance().playSound("hurt", 1, 0);
			}
		}
		
		public function die():void
		{
			SoundManager.getInstance().playSound("die", 1, 0);
			isDead = true;
			Armature(this.view).getBone("frontDownArm").childArmature.animation.gotoAndPlay("noWepaon");
			Armature(this.view).addEventListener(AnimationEvent.COMPLETE, resetToLastCheckpoint);
			Armature(this.view).animation.gotoAndPlay("die");
			_ce.gameData.lives--;
			IngameDisplay((_ce.state as Sprite).getChildByName("display")).lifeValueText = _ce.gameData.lives;
		}
		
		private function resetToLastCheckpoint(e:Event):void
		{ 
			Armature(this.view).getBone("frontDownArm").childArmature.animation.gotoAndPlay("gun");
			_body.SetType(0); 
			visible = false; 
			isDead = false; 
			Armature(this.view).removeEventListener(AnimationEvent.COMPLETE, resetToLastCheckpoint);
			
			TweenLite.to(this, 1.5, {delay:0.2, x:_ce.gameData.checkPoints[_ce.gameData.checkPointIndex].x, y:_ce.gameData.checkPoints[_ce.gameData.checkPointIndex].y,
				onComplete:function():void{
					_body.SetType(2); 
					visible = true; 
					IngameDisplay((_ce.state as Sprite).getChildByName("display")).lifebar.ratio = 1}
			});
		}
		
		
		public function playAnimation(animation:String, duration:Number = 0):void
		{
			this.autoAnimation = false;
			Armature(this.view).addEventListener(AnimationEvent.COMPLETE, animationComplete);
			Armature(this.view).animation.gotoAndPlay(animation);
		}
		
		private function animationComplete(e:AnimationEvent = null):void
		{
			Armature(this.view).removeEventListener(AnimationEvent.COMPLETE, animationComplete);
			this.autoAnimation = true;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.density = 2;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			
			if (!_ducking)
				return;
			
			var other:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			if (!((other as Box2DPhysicsObject).name.substr(0, 3) == "bri"))
			{
				var heroTop:Number = y;
				var objectBottom:Number = other.y + (other.height / 2);
				
				if (objectBottom < heroTop)
					contact.SetEnabled(false);
			}
		}
		
		override public function hurt():void
		{
			if (!_hurt)
			{
				_hurt = true;
				_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
				takeDamage();
				onTakeDamage.dispatch();
				
				if (_playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction);
				}
			}
		}
		
		
		override protected function endHurtState():void 
		{
			if (isSwimming)
			{
				_hurt = false;
			}
			else
			{
				_hurt = false;
				controlsEnabled = true;
			}
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			if (_enemyClass && collider is _enemyClass)
			{
				if (_body.GetLinearVelocity().y < killVelocity && !_hurt)
				{
					hurt();
					
					//fling the hero
					var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
					if (isSwimming)
					{
						hurtVelocity.y = -hurtVelocityY/10;
						hurtVelocity.x = hurtVelocityX/5;
						if (collider.x > x)
							hurtVelocity.x = -hurtVelocityX;
					}
					else
					{
						hurtVelocity.y = -hurtVelocityY;
						hurtVelocity.x = hurtVelocityX;
						if (collider.x > x)
							hurtVelocity.x = -hurtVelocityX;
					}
				}
				else
				{
					_springOffEnemy = collider.y - height;
					onGiveDamage.dispatch();
				}
			}
			
			//Collision angle if we don't touch a Sensor.
			if (contact.GetManifold().m_localPoint && !(collider is Sensor)) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{				
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				var collName:String = collider.body.GetDefinition().userData.name;
				
				if ((collisionAngle > 45 && collisionAngle < 135) || (collisionAngle > -30 && collisionAngle < 10 && collisionAngle != 0) || collisionAngle == -90 || collider is Crate ||  collider is Bridge || collider is SwimmingPlatform || (collName == "vertical" && collisionAngle == 180))
				{
					//we don't want the Hero to be set up as onGround if it touches a cloud.
					//					if (collider is Platform && (collider as Platform).oneWay && collisionAngle == -90)
					if (collider is Platform && (collider as Platform).oneWay && collider.y < y)
						return;
					if (collider is SwimmingPlatform) onSwimmingPlatform = true;
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		override public function handleEndContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			if (collider is SwimmingPlatform) 
			{
				onSwimmingPlatform = false;
				
				if (markForDamage && !(_ce.state.getObjectByName("pool") as Pool).hot)
				{
					this.isSwimming = true;
					(this.view as Armature).getBone("frontDownArm").childArmature.animation.gotoAndPlay("noWepaon");
					this.body.GetFixtureList().SetFriction(0.01);
					var swimShape:b2Shape = Box2DShapeMaker.BeveledRect((this.height+10)/30, this.width/30, 0.1);
					this.body.GetFixtureList().GetShape().Set(swimShape);
					this.offsetY = -18;
					this.body.GetFixtureList().SetDensity(2.1);
					this.body.ResetMassData();
					this.hurtDuration = 1500;
					markForDamage = false;
				}
				else if (markForDamage && (_ce.state.getObjectByName("pool") as Pool).hot && !_hurt)
				{
					this.body.ApplyImpulse(new b2Vec2(0, -30), this.body.GetLocalCenter());
					hurt();
					markForDamage = false;
				}
			}
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body.GetFixtureList());
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
		}
	}
}