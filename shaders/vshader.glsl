attribute vec4 vPosition;
attribute vec4 vNormal;
attribute vec4 vTangent;
attribute vec4 vBinormal;
attribute vec4 vTextureCoordinate;

varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;
varying mat4 TBN;

uniform mat4 lightSource;
uniform vec4 cameraPosition;
uniform mat4 model;
uniform mat4 inverseModel;
uniform mat4 camera;
uniform mat4 projection;
uniform bool emissive;

void main()
{
	if (!emissive)
	{
		TBN = transpose(mat4(vTangent, vBinormal, vNormal, vec4(0.0, 0.0, 0.0, 0.0)));

		// compute normal
		N = vec3(0.0, 0.0, 1.0);

		// compute camera position in object space
		vec4 cameraPositionObject = inverseModel * cameraPosition;

		// compute eye direction
		vec4 eyeDirection = cameraPositionObject - vPosition;

		// move eye direction to tangent space
		E = (TBN * eyeDirection).xyz;

		// compute light position in object space
		vec4 lightPositionObject = inverseModel * lightSource[3];

		vec4 lightDirection;
		if (lightPositionObject.w == 0.0)
			lightDirection = lightPositionObject;
		else
			lightDirection = lightPositionObject - vPosition; 

		// move light direction to tangent space
		L = (TBN * lightDirection).xyz;
	}

	// compute gl_Position
	gl_Position = projection * camera * model * vPosition/vPosition.w;

	// compute fTextureCoord
	fTextureCoord = vec2((vTextureCoordinate.x), (vTextureCoordinate.y));
}
