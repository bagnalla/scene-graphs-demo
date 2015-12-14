attribute vec4 vPosition;
attribute vec4 vNormal;
attribute vec4 vTextureCoordinate;

varying vec3 rawN;
varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;

uniform mat4 lightSource;
uniform vec4 cameraPosition;
uniform mat4 model;
uniform mat4 camera;
uniform mat4 projection;
uniform bool emissive;

void main()
{
	if (!emissive)
	{
		// compute normal
		N = (model * vNormal).xyz;
		rawN = normalize(vNormal.xyz);

		// compute vPosition in world coordinates
		vec4 vPositionWorld = (model * vPosition);

		// compute eye direction
		E = cameraPosition.xyz - vPositionWorld.xyz;

		// compute light direction
		if (lightSource[3].w == 0.0)
			L = lightSource[3].xyz;
		else
			L = (lightSource[3] - vPositionWorld).xyz;
	}

	// compute gl_Position
	gl_Position = projection * camera * model * vPosition/vPosition.w;

	// compute fTextureCoord
	fTextureCoord = vec2((vTextureCoordinate.x), (vTextureCoordinate.y));
}
