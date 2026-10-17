#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/waving.glsl"

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;
varying vec3 normal;
varying vec3 worldPosition;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);

    vec4 position = gl_Vertex;
    worldPosition = position.xyz + cameraPosition;

    // Apply subtle water wave displacement on top surface
    #ifdef WATER_WAVE_DISPLACEMENT
    if (gl_Normal.y > 0.5) {
        position.xyz += getWaterDisplacement(worldPosition, frameTimeCounter);
    }
    #endif

    gl_Position = gl_ModelViewProjectionMatrix * position;
}
