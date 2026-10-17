#version 120

/*
 * HAPPY SHADERS - Shadow Pass Vertex Shader
 * Renders the scene from the sun/moon's perspective to create the shadow depth map.
 */

#include "/lib/settings.glsl"
#include "/lib/waving.glsl"

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

varying vec2 texCoord;
varying vec4 color;

// Distortion function to increase shadow detail near the player (shadow map warping)
vec2 distortShadowCoord(vec2 coord) {
    float distortFactor = length(coord);
    float distortion = mix(1.0, distortFactor, SHADOW_DISTORTION);
    return coord / distortion;
}

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color = gl_Color;

    vec4 position = gl_Vertex;

    // Compute world position for waving
    vec3 worldPos = (shadowModelViewInverse * (shadowModelView * position)).xyz + cameraPosition;

    // Apply waving animations in shadow pass so shadows match the deformed geometry
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

    // Project into shadow clip space
    gl_Position = shadowProjection * shadowModelView * position;

    // Apply shadow map distortion for better near-player detail
    gl_Position.xy = distortShadowCoord(gl_Position.xy);
}
