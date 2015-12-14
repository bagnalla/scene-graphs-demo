varying vec3 N;
varying vec3 rawN;
varying vec3 L;
varying vec3 E;
varying vec2 fTextureCoord;

uniform vec4 materialAmbient, materialDiffuse, materialSpecular;
uniform float materialShininess;
uniform mat4 lightSource;
uniform mat4 model;
uniform bool emissive;
uniform vec4 emissionColor;
uniform float alphaOverride;
uniform bool useTexture;
uniform sampler2D Tex;
uniform bool useBumpMap;
uniform sampler2D BumpTex;
uniform mat4 normalRotation;

void main()
{
	if (useTexture && emissive)
	{
		gl_FragColor = texture2D(Tex, fTextureCoord);
	}
	// if emissive then just do use the emission color
	else if (emissive)
	{
		gl_FragColor = emissionColor;
	}
	else
	{
		vec3 NN;
		if (useBumpMap)
		{
			vec4 bump = texture2D(BumpTex, fTextureCoord);
			bump = normalize(2.0*bump-1.0);

			vec3 up = vec3(0.0, 0.0, -1.0);
			vec3 v = cross(rawN, up);
			float s = max(0.5, length(v));
			float c = dot(rawN, up);
			mat3 skew = mat3(vec3(0.0, v.z, -v.y), vec3(-v.z, 0.0, v.x), vec3(v.y, -v.x, 0.0));
			mat3 R = mat3(1.0) + skew + (skew * skew) * ((1.0 - c) / s*s);

			bump.xyz = R * bump.xyz;
			bump = normalRotation * bump;
			NN = normalize(normalize(bump.xyz) / 2.0 + normalize(N));
		}
		else
		{
			NN = normalize(N);
		}

		vec3 EE = normalize(E);

		vec4 objectAmbient, objectDiffuse, objectSpecular;
		if (useTexture)
		{
			vec4 texColor = texture2D(Tex, fTextureCoord);
			objectAmbient = mix(materialAmbient, texColor, 0.5);
			objectDiffuse = mix(materialDiffuse, texColor, 0.5);
			objectSpecular = mix(materialSpecular, texColor, 0.5);
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
		/*vec4 ambientProduct = objectAmbient;
		vec4 diffuseProduct = objectDiffuse;
		vec4 specularProduct = objectSpecular;*/

		float distance;
		if (lightSource[3].w == 0.0)
			distance = 1.0;
		else
			distance = pow(length(L), 2.0);

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

		gl_FragColor = vec4((ambient + diffuse + specular).xyz, 1.0);
		//gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}

	if (alphaOverride != 0.0)
	{
		if (gl_FragColor.xyz == vec3(0.0, 0.0, 0.0))
			gl_FragColor.w = 0.0;
		else
			gl_FragColor.w = alphaOverride;
	}
}
