varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;
varying mat4 inverseTBN;
varying vec3 shadowCoordDepth;

uniform vec4 materialAmbient, materialDiffuse, materialSpecular;
uniform float materialShininess;
uniform mat4 lightSource;
uniform mat4 model;
uniform sampler2D tex;
uniform sampler2D bumpTex;
uniform sampler2DShadow shadowTex;
uniform samplerCubeShadow shadowCubeMap;
uniform bool textureBlend;
uniform int shadowMode;
uniform vec2 shadowZRange;

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
	vec4 bump = texture2D(bumpTex, fTextureCoord);
	bump = normalize(2.0*bump-1.0);
	bump = model * inverseTBN * bump;
	vec3 NN = normalize(normalize(bump.xyz) + normalize(N));
	//vec3 NN = normalize(bump.xyz);

	vec3 EE = normalize(E);

	vec4 texColor = texture2D(tex, fTextureCoord);

	//float d = (2.0 * shadowZRange.x) / (shadowZRange.y + shadowZRange.x - texColor * (shadowZRange.y - shadowZRange.x));
	//texColor *= d;
	
	vec4 ambientProduct, diffuseProduct, specularProduct;
	float shininess;
	if (textureBlend)
	{
		ambientProduct = mix(materialAmbient, texColor, 0.5) * lightSource[0];
		diffuseProduct = mix(materialDiffuse, texColor, 0.5) * lightSource[1];
		specularProduct = mix(materialSpecular, texColor, 0.5) * lightSource[2];
		shininess = materialShininess;
		/*ambientProduct = texColor * materialAmbient * lightSource[0];
		diffuseProduct = texColor * materialDiffuse * lightSource[1];
		specularProduct = texColor * materialSpecular * lightSource[2];*/
	}
	else
	{
		ambientProduct = 0.5 * texColor * lightSource[0];
		diffuseProduct = texColor * lightSource[1];
		specularProduct = texColor * lightSource[2];
		shininess = 32.0;
	}

	float distance;
	//if (lightSource[3].w == 0.0)
		distance = 1.0;
	//else
	//	distance = pow(length(L), 2.0);

	vec3 LL = normalize(L);
	float LdotN = dot(LL, NN);

	vec4 ambient, diffuse, specular;

	// ambient
	ambient = ambientProduct / distance;

	// diffuse
	float Kd = max(LdotN, 0.0);
	//float Kd = abs(LdotN);
	diffuse = Kd * diffuseProduct / distance;

	// specular
	vec3 H = normalize(LL+EE);
	float Ks = pow(max(dot(NN, H), 0.0), shininess) / distance;
	if (LdotN < 0.0)
		specular = vec4(0.0, 0.0, 0.0, 1.0);
	else
		specular = Ks*specularProduct;

	if (shadowMode == 1)
	{
		//vec3 posLight = (lightProjection * vPositionWorld).xyz;
		//vec3 coordDepth = vec3((posLight.x + 1.0) / 2.0, (posLight.y + 1.0) / 2.0, (posLight.z + 1.0) / 2.0 * 0.90);
		//float shadowVal = shadow2D(shadowTex, coordDepth);
		float shadowVal = shadow2D(shadowTex, shadowCoordDepth).x;
		diffuse = diffuse * shadowVal;
		specular = specular * shadowVal;
	}
	else if (shadowMode == 2)
	{
		vec3 lightDir = -L;
		float d = vecToDepth(lightDir) - 0.002;
		float shadowVal = shadowCube(shadowCubeMap, vec4(lightDir, d)).x;
		diffuse = diffuse * shadowVal;
		specular = specular * shadowVal;
	}

	gl_FragColor = vec4((ambient + diffuse + specular).xyz, 1.0);
}
