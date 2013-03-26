package starling.extensions.lighting.shaders
{
	import starling.core.Starling;
	import starling.errors.AbstractMethodError;
	import starling.extensions.lighting.core.LightLayer;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	/**
	 * @author Szenia Zadvornykh
	 */
	public class StarlingShaderBase
	{
		protected var _name:String;
		protected var _programAssembler:AGALMiniAssembler;
		
		/**
		 * abstract baseclass wrapping shader code and registration with Starling
		 */
		public function StarlingShaderBase(name:String)
		{
			_name = name;
			_programAssembler = new AGALMiniAssembler();
			
			register();
		}
		
		private function register():void
		{
			var target:Starling = Starling.current;
			
			if (target.hasProgram(_name))
				return;
			
			target.registerProgram(_name, assembleVertexShader(), assembleFragmentShader());
		}
		
		private function assembleVertexShader():ByteArray
		{
			_programAssembler.assemble(Context3DProgramType.VERTEX, vertexShaderProgram());
			
			return _programAssembler.agalcode;
		}
		
		protected function vertexShaderProgram():String
		{
			throw new AbstractMethodError();
		}
		
		private function assembleFragmentShader():ByteArray
		{
			_programAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShaderProgram());
			
			return _programAssembler.agalcode;
		}
		
		protected function fragmentShaderProgram():String
		{
			throw new AbstractMethodError();
		}
		
		final public function activate(context:Context3D):void
		{
			if (LightLayer.Program != _name)
			{
				context.setProgram(program);
				LightLayer.Program == _name
			}
			
			activateHook(context);
		}
		
		protected function activateHook(context:Context3D):void
		{
		}
		
		final public function get program():Program3D
		{
			return Starling.current.getProgram(name);
		}
		
		final public function get name():String
		{
			return _name;
		}
	}
}
