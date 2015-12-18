attribute vec4 vPosition;
attribute vec4 vNormal;
attribute vec4 vTangent;
attribute vec4 vBinormal;
attribute vec2 vTextureCoordinate;

varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;
varying mat4 inverseTBN;
varying vec4 vPositionWorld;
varying vec4 shadowMapLightDirDepth;
varying vec3 cubeMapCoord;

uniform mat4 lightSource;
uniform vec4 cameraPosition;
uniform mat4 model;
uniform mat4 inverseModel;
uniform mat4 camera;
uniform mat4 projection;
uniform bool emissive;

uniform bool useShadowMap;
uniform vec2 shadowZRange;

uniform bool onlyDepth;

uniform bool useCubeMap;

// http://stackoverflow.com/questions/21293726/opengl-project-shadow-cubemap-onto-scene
float vecToDepth (vec3 Vec)
{
  vec3  AbsVec     = abs (Vec);
  float LocalZcomp = max (AbsVec.x, max (AbsVec.y, AbsVec.z));

  float n = shadowZRange [0]; // Near plane when the shadow map was built
  float f = shadowZRange [1]; // Far plane when the shadow map was built

  float NormZComp = (f+n) / (f-n) - (2.0*f*n)/(f-n)/LocalZcomp;
  return (NormZComp + 1.0) * 0.5;
}

void main()
{
	if (onlyDepth)
	{
		gl_Position = projection * camera * model * vPosition;
		return;
	}

	// compute vPosition in world space
	vPositionWorld = model * vPosition;

	if (!emissive)
	{
		inverseTBN = mat4(vTangent, vBinormal, vNormal, vec4(0.0, 0.0, 0.0, 0.0));

		// compute normal in world space
		N = (model * vNormal).xyz;

		// compute eye direction
		E = (cameraPosition - vPositionWorld).xyz;

		vec4 lightDir;
		if (lightSource[3].w == 0.0)
			lightDir = -lightSource[3];
		else
			lightDir = vPositionWorld - lightSource[3];

		L = -lightDir.xyz;
		
		if (useShadowMap)
		{
			float lightDepth = vecToDepth(lightDir.xyz);
			shadowMapLightDirDepth = vec4(lightDir.xyz, lightDepth - 0.0002);
			//shadowMapLightDirDepth = vec4(lightDir.xyz, lightDepth - 0.0003 * sqrt(length(lightDir)));
			//shadowMapLightDirDepth = vec4(lightDir.xyz, lightDepth);
		}
	}

	if (useCubeMap)
	{
		cubeMapCoord = (vPositionWorld - model[3]).xyz;
	}

	// compute gl_Position
	gl_Position = projection * camera * vPositionWorld;

	// compute fTextureCoord
	fTextureCoord = vec2((vTextureCoordinate.x), (vTextureCoordinate.y));
}
