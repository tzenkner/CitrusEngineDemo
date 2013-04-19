package objects {
	
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	
	import characters.HeroSnowman;
	
	import citrus.core.SoundManager;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.box2d.Box2DUtils;
	
	import flash.display.Bitmap;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	public class PopupSensor extends Box2DPhysicsObject
	{
		public var onBeginContact:Signal;
		public var onEndContact:Signal;
		
		public var tf:TextField;
		public var sprite:Sprite;
		public var oneTime:Boolean = false;
		
		public function PopupSensor(name:String, params:Object=null)
		{
			super(name, params);
			onBeginContact = new Signal(b2Contact);
			onEndContact = new Signal(b2Contact);
			
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
		}
		
		override public function destroy():void
		{
			onBeginContact.removeAll();
			onEndContact.removeAll();
			
			super.destroy();
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.isSensor = true;
		}
		
		override public function handleBeginContact(contact:b2Contact):void 
		{
			onBeginContact.dispatch(contact);
			
			if (Box2DUtils.CollisionGetOther(this, contact) is HeroSnowman)
			{
				SoundManager.getInstance().playSound("popup", 0.6, 0);
				showPopUp();
			}
		}
		
		override public function handleEndContact(contact:b2Contact):void 
		{
			onEndContact.dispatch(contact);
			
			
			if (Box2DUtils.CollisionGetOther(this, contact) is HeroSnowman)
			{
				hidePopUp();
				if (oneTime) _ce.state.remove(this);
			}
		}
		
		public function createTextField(text:String, x:Number, y:Number):void
		{
			sprite = new Sprite()
			sprite.addChild(new Quad(200, 100,0x555555));
			sprite.visible = false;
			
			tf = new TextField(200, 100, text, "Atari");
			tf.fontSize = BitmapFont.NATIVE_SIZE;
			tf.color = Color.WHITE;
			tf.autoScale = true;
			sprite.addChild(tf);
			var ts:CitrusSprite = new CitrusSprite("ts", {x:x-100, y:y-150, group:6, view:sprite});
			tf.fontSize = 12;
			_ce.state.add(ts);
			tf.visible = true;
		}
		
		private function showPopUp():void 
		{
			sprite.visible = true;
		}
		
		private function hidePopUp():void 
		{
			sprite.visible = false;
		}
	}
}

