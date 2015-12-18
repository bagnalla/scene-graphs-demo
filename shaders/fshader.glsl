varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;
varying mat4 inverseTBN;
varying vec4 vPositionWorld;
varying vec4 shadowMapLightDirDepth;
varying vec3 cubeMapCoord;

uniform vec4 materialAmbient, materialDiffuse, materialSpecular;
uniform float materialShininess;
uniform mat4 lightSource;
uniform vec4 cameraPosition;
uniform mat4 model;
uniform bool emissive;
uniform vec4 emissionColor;
uniform float alphaOverride;
uniform bool useTexture;
uniform sampler2D Tex;
uniform bool textureBlend;
uniform bool useBumpMap;
uniform sampler2D BumpTex;
uniform bool useCubeMap;
uniform samplerCube cubeMap;
uniform bool useShadowMap;
uniform samplerCubeShadow shadowMap;

uniform bool onlyDepth;

void main()
{
	if (onlyDepth)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}
	if (emissive)
	{
		if (useTexture)
		{
			gl_FragColor = texture2D(Tex, fTextureCoord);
		}
		else if (useCubeMap)
		{
			gl_FragColor = texture(cubeMap, cubeMapCoord);
			//gl_FragColor.xyz = vec3(pow(gl_FragColor.x, 64.0), pow(gl_FragColor.y, 64.0), pow(gl_FragColor.z, 64.0)); 
		}
		else
		{
			gl_FragColor = emissionColor;
		}
	}
	else
	{
		vec3 NN = normalize(N);
		if (useBumpMap)
		{
			vec4 bump = texture2D(BumpTex, fTextureCoord);
			bump = normalize(2.0*bump-1.0);
			bump = model * inverseTBN * bump;
			NN = normalize(normalize(bump.xyz) + NN);
		}

		vec3 EE = normalize(E);

		vec4 objectAmbient, objectDiffuse, objectSpecular;
		if (useTexture)
		{
			vec4 texColor = texture2D(Tex, fTextureCoord);
			if (textureBlend)
			{
				objectAmbient = mix(materialAmbient, texColor, 0.5);
				objectDiffuse = mix(materialDiffuse, texColor, 0.5);
				objectSpecular = mix(materialSpecular, texColor, 0.5);
			}
			else
			{
				objectAmbient = texColor;
				objectDiffuse = texColor;
				objectSpecular = texColor;
			}
		}
		else if (useCubeMap)
		{
			// REFLECTIVE STUFF
			vec3 v = normalize((vPositionWorld - cameraPosition).xyz);
			vec3 cubeCoord = v - 2 * dot(v, NN) * NN;
			vec4 texColor = texture(cubeMap, cubeCoord);

			//vec4 texColor = texture(cubeMap, cubeMapCoord);
			objectAmbient = mix(materialAmbient, texColor, 0.5);
			objectDiffuse = mix(materialDiffuse, texColor, 0.5);
			objectSpecular = mix(materialSpecular, texColor, 0.5);

			//objectAmbient.xyz = vec3(pow(texColor.x, 64.0), pow(texColor.y, 64.0), pow(texColor.z, 64.0)); 
			//objectDiffuse.xyz = vec3(pow(texColor.x, 64.0), pow(texColor.y, 64.0), pow(texColor.z, 64.0)); 
			//objectSpecular.xyz = vec3(pow(texColor.x, 64.0), pow(texColor.y, 64.0), pow(texColor.z, 64.0));
		}
		else
		{
			objectAmbient = materialAmbient;
			objectDiffuse = materialDiffuse;
			objectSpecular = materialSpecular;
		}

		vec4 ambientProduct = objectAmbient * lightSource[0];
		vec4 diffuseProduct = objectDiffuse * lightSource[1];
		vec4 specularProduct = objectSpecular * lightSource[2];

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
		float Ks = pow(max(dot(NN, H), 0.0), materialShininess) / distance;
		if (LdotN < 0.0)
			specular = vec4(0.0, 0.0, 0.0, 1.0);
		else
			specular = Ks*specularProduct;

		if (useShadowMap)
		{
			float shadowVal = shadowCube(shadowMap, shadowMapLightDirDepth);
			diffuse = diffuse * shadowVal;
			specular = specular * shadowVal;
		}

		gl_FragColor = vec4((ambient + diffuse + specular).xyz, 1.0);
		//gl_FragColor = vec4((objectAmbient - 0.5 + objectDiffuse - 0.5 + objectSpecular - 0.5).xyz, 1.0);
	}

	if (alphaOverride != 0.0)
	{
		if (gl_FragColor.xyz == vec3(0.0, 0.0, 0.0))
			gl_FragColor.w = 0.0;
		else
			gl_FragColor.w = alphaOverride;
	}
}
