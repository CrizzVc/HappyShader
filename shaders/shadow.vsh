#version 120

/*
 * HAPPY SHADERS - Shadow Pass Vertex Shader (shaders-MakeBreezy style)
 */

#include "/lib/settings.glsl"
#include "/lib/waving.glsl"

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform float frameTimeCounter;

varying vec2 texCoord;
varying vec4 color;

// MakeBreezy shadow distortion
const float shadowMapBias = 1.0 - 25.6 / shadowDistance;

float get_distort_factor(vec2 pos) {
    return length(pos.xy) * shadowMapBias + (1.0 - shadowMapBias);
}

vec3 distort(vec3 pos) {
    float factor = get_distort_factor(pos.xy);
    return vec3(pos.xy / factor, pos.z * 0.2);
}

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color = gl_Color;

    vec4 position = gl_Vertex;
    vec3 worldPos = position.xyz + cameraPosition;

    // Apply plant and foliage waving in shadow pass
    int blockId = int(mc_Entity.x + 0.5);
    if (blockId == 10001) {
        float topWeight = clamp((mc_midTexCoord.t - gl_MultiTexCoord0.t) * 16.0, 0.0, 1.0);
        if (topWeight < 0.01) topWeight = 1.0;
        position.xyz += getFoliageOffset(worldPos, topWeight, frameTimeCounter);
    } else if (blockId == 10002) {
        position.xyz += getLeavesOffset(worldPos, frameTimeCounter);
    } else if (blockId == 10003) {
        position.xyz += getFoliageOffset(worldPos, 0.7, frameTimeCounter * 0.8);
    }

    gl_Position = gl_ModelViewProjectionMatrix * position;
    gl_Position.xyz = distort(gl_Position.xyz);
}
