package starling.extensions.lighting.geometry
{
	import starling.display.Quad;
	import starling.extensions.lighting.core.Edge;
	import starling.extensions.lighting.core.ShadowGeometry;
	import starling.utils.VertexData;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * @author Szenia Zadvornykh
	 */
	public class QuadShadowGeometry extends ShadowGeometry
	{
		private const indices:Array = [0, 1, 1, 3, 3, 2, 2, 0];
		private const numEdges:int = 4;
		
		/**
		 * subclass of ShadowGeometry that creates shadow geometry matching the vertex data (bounding box) of a Quad or Image instance
		 * @param displayObject Quad or Image instance the shadow geometry will be created for
		 */
		public function QuadShadowGeometry(displayObject:Quad)
		{
			super(displayObject);
		}
		
		override protected function createEdges():Vector.<Edge>
		{
			var quad:Quad = displayObject as Quad;
			var vertexData:VertexData = new VertexData(4);
			var edges:Vector.<Edge> = new <Edge>[];
			var index:int;
			
			quad.copyVertexDataTo(vertexData);
			
			for (var i:int; i < numEdges; i++)
			{
				index = i * 2;
				
				vertexData.getPosition(indices[index], start)
				vertexData.getPosition(indices[index + 1], end);
				
				edges.push(new Edge(start.x, start.y, end.x, end.y));
			}
			
			return edges;
		}
	}
}
