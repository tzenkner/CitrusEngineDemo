package starling.extensions.lighting.geometry
{
	import starling.extensions.lighting.core.Edge;
	import starling.extensions.lighting.core.ShadowGeometry;
	import starling.extensions.lighting.core.display.Polygon;
	import starling.utils.VertexData;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * @author Szenia Zadvornykh
	 */
	public class PolygonShadowGeometry extends ShadowGeometry
	{
		/**
		 * subclass of ShadowGeometry that creates shadow geometry matching the vertex data of a Polygon
		 * @param displayObject Polygon instance the shadow geometry will be created for
		 */
		public function PolygonShadowGeometry(displayObject:Polygon)
		{
			super(displayObject);
		}
		
		override protected function createEdges():Vector.<Edge>
		{
			var polygon:Polygon = displayObject as Polygon;
			var vertexData:VertexData = polygon.vertexData;
			var numEdges:int = vertexData.numVertices - 1 / 2;
			
			var edges:Vector.<Edge> = new <Edge>[];
			
			for (var i:int = 0; i < numEdges - 1; i++)
			{
				vertexData.getPosition(i, start);
				vertexData.getPosition(i + 1, end);
				
				edges.push(new Edge(start.x, start.y, end.x, end.y));
			}
			
			vertexData.getPosition(i, start);
			vertexData.getPosition(0, end);
			
			edges.push(new Edge(start.x, start.y, end.x, end.y));
			
			return edges;
		}
	}
}
