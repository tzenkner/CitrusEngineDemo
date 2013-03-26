package objects {
	
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.objects.Box2DPhysicsObject;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	
	/**
	 * Sensors simply listen for when an object begins and ends contact with them. They dispatch a signal
	 * when contact is made or ended, and this signal can be used to perform custom game logic such as
	 * triggering a scripted event, ending a level, popping up a dialog box, and virtually anything else.
	 * 
	 * <p>Remember that signals dispatch events when ANY Box2D object collides with them, so you will want
	 * your collision handler to ignore collisions with objects that it is not interested in, or extend
	 * the sensor and use maskBits to ignore collisions altogether.</p>  
	 * 
	 * <ul>Events:
	 * <li>onBeginContact : Dispatches on first contact with the sensor.</li>
	 * <li>onEndContact : Dispatches when the object leaves the sensor.</li></ul>
	 */	
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
		
		override public function handleBeginContact(contact:b2Contact):void {
			onBeginContact.dispatch(contact, sprite);
		}
		
		override public function handleEndContact(contact:b2Contact):void {
			if (oneTime) _ce.state.remove(this);
			onEndContact.dispatch(contact, sprite);
		}
	}
}

