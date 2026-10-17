#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/waving.glsl"

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

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

    // Apply waving to plants and leaves
    int blockId = int(mc_Entity.x + 0.5);
    if (blockId == 10001) {
        // Plants, grass, crops: anchor bottom, sway top
        float topWeight = clamp((mc_midTexCoord.t - gl_MultiTexCoord0.t) * 16.0, 0.0, 1.0);
        if (topWeight < 0.01) topWeight = 1.0; // Fallback for single-quad flowers
        vec3 offset = getFoliageOffset(worldPosition, topWeight, frameTimeCounter);
        position.xyz += offset;
    } else if (blockId == 10002) {
        // Leaves: multi-directional gentle rustling
        vec3 offset = getLeavesOffset(worldPosition, frameTimeCounter);
        position.xyz += offset;
    } else if (blockId == 10003) {
        // Water plants (seagrass, lilypads)
        vec3 offset = getFoliageOffset(worldPosition, 0.7, frameTimeCounter * 0.8);
        position.xyz += offset;
    }

    gl_Position = gl_ModelViewProjectionMatrix * position;
}
