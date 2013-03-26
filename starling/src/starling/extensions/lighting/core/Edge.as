package starling.extensions.lighting.core
{
	/**
	 * ...
	 * @author UG
	 */
	public class Edge 
	{
		public var startX:Number;
		public var startY:Number;
		public var endX:Number;
		public var endY:Number;
		
		/**
		 * simple class to hold the start and end points of an edge used for shadow casting
		 */
		public function Edge(_startX:Number = 0, _startY:Number = 0, _endX:Number = 0, _endY:Number = 0)
		{
			startX = _startX;
			startY = _startY;
			endX = _endX;
			endY = _endY;
		}
		
		public function toString():String
		{
			return "start (" + startX + ", " + startY + ") end (" + endX + ", " + endY + ")";
		}
	}
}