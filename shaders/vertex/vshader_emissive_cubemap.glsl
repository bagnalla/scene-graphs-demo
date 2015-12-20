attribute vec4 vPosition;

varying vec3 cubeMapCoord;

uniform mat4 model;
uniform mat4 camera;
uniform mat4 projection;

void main()
{
	// compute vPosition in world space
	vec4 vPositionWorld = model * vPosition;
	
	// reflective
	//vec3 v = normalize(-E);
	//cubeMapCoord = v - 2 * dot(v, N) * N;
	
	// non reflective
	cubeMapCoord = (vPositionWorld - model[3]).xyz;
	
	// compute gl_Position
	gl_Position = projection * camera * vPositionWorld;
}
