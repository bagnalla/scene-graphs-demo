attribute vec4 vPosition;
attribute vec4 vNormal;
attribute vec4 vTangent;
attribute vec4 vBinormal;
attribute vec4 vTextureCoordinate;

varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;
varying mat4 inverseTBN;

uniform mat4 lightSource;
uniform vec4 cameraPosition;
uniform mat4 model;
uniform mat4 inverseModel;
uniform mat4 camera;
uniform mat4 projection;
uniform bool emissive;

void main()
{
	// compute vPosition in world space
	vec4 vPositionWorld = model * vPosition;

	if (!emissive)
	{
		inverseTBN = mat4(vTangent, vBinormal, vNormal, vec4(0.0, 0.0, 0.0, 0.0));

		// compute normal in world space
		N = model * vNormal;

		// compute eye direction
		E = cameraPosition - vPositionWorld;

		if (lightSource[3].w == 0.0)
			L = (lightSource[3].xyz);
		else
			L = (lightSource[3] - vPositionWorld).xyz; 
	}

	// compute gl_Position
	gl_Position = projection * camera * vPositionWorld;

	// compute fTextureCoord
	fTextureCoord = vec2((vTextureCoordinate.x), (vTextureCoordinate.y));
}
