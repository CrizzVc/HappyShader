#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"

/*
 * HAPPY SHADERS - Dynamic Shadow Sampling Library
 * Samples the shadow depth map and returns a shadow factor.
 * Supports hard shadows, soft PCF filtering, and cartoon-style quantized shadows.
 */

// Shadow map sampler (depth texture rendered from sun's perspective)
uniform sampler2DShadow shadowtex0;     // Hard depth (includes transparent)
uniform sampler2DShadow shadowtex1;     // Opaque-only depth
uniform sampler2D shadowcolor0;          // Shadow albedo (for colored shadows from stained glass, etc.)

// Apply the same barrel distortion used in shadow.vsh
vec2 distortShadowCoord(vec2 coord) {
    float distortFactor = length(coord);
    float distortion = mix(1.0, distortFactor, SHADOW_DISTORTION);
    return coord / distortion;
}

// Transform a view-space position into shadow map UV + depth
vec3 getShadowCoord(vec4 viewPos, mat4 gbufferModelViewInverse) {
    // View space → world / player space
    vec4 playerPos = gbufferModelViewInverse * viewPos;

    // Player space → shadow clip space
    vec4 shadowClipPos = shadowProjection * shadowModelView * playerPos;

    // Perspective divide
    shadowClipPos.xyz /= shadowClipPos.w;

    // Apply distortion matching shadow.vsh
    shadowClipPos.xy = distortShadowCoord(shadowClipPos.xy);

    // Remap from [-1,1] to [0,1] for texture sampling
    shadowClipPos.xyz = shadowClipPos.xyz * 0.5 + 0.5;

    return shadowClipPos.xyz;
}

// Sample shadow map with optional PCF soft filtering
float getShadowFactor(vec3 shadowCoord) {
    #ifndef DYNAMIC_SHADOWS
    return 1.0;
    #endif

    // Fade out shadows at the edge of the shadow map to avoid hard cutoffs
    float edgeFade = smoothstep(0.0, 0.05, min(min(shadowCoord.x, shadowCoord.y),
                     min(1.0 - shadowCoord.x, 1.0 - shadowCoord.y)));
    if (edgeFade < 0.01) return 1.0;

    // Small bias to reduce shadow acne
    float biasedDepth = shadowCoord.z - SHADOW_BIAS;

    float shadow = 0.0;

    #if SHADOW_QUALITY == 0
    // Hard shadows: single sample
    shadow = shadow2D(shadowtex1, vec3(shadowCoord.xy, biasedDepth)).r;

    #elif SHADOW_QUALITY == 1
    // Soft shadows: 4-sample PCF (fast)
    float texelSize = 1.0 / float(SHADOW_MAP_RESOLUTION);
    shadow += shadow2D(shadowtex1, vec3(shadowCoord.xy + vec2(-texelSize, -texelSize), biasedDepth)).r;
    shadow += shadow2D(shadowtex1, vec3(shadowCoord.xy + vec2( texelSize, -texelSize), biasedDepth)).r;
    shadow += shadow2D(shadowtex1, vec3(shadowCoord.xy + vec2(-texelSize,  texelSize), biasedDepth)).r;
    shadow += shadow2D(shadowtex1, vec3(shadowCoord.xy + vec2( texelSize,  texelSize), biasedDepth)).r;
    shadow *= 0.25;

    #else
    // Soft shadows: 12-sample PCF (high quality)
    float texelSize = 1.0 / float(SHADOW_MAP_RESOLUTION);
    // Poisson-like disc offsets for natural-looking penumbra
    const vec2 offsets[12] = vec2[12](
        vec2(-0.94, -0.34), vec2(-0.25, -0.91), vec2( 0.69, -0.66),
        vec2( 0.97,  0.13), vec2( 0.41,  0.85), vec2(-0.48,  0.83),
        vec2(-0.81,  0.44), vec2( 0.15, -0.35), vec2( 0.55,  0.27),
        vec2(-0.20,  0.27), vec2( 0.12,  0.93), vec2(-0.63, -0.72)
    );
    for (int i = 0; i < 12; i++) {
        vec2 offset = offsets[i] * texelSize * 1.5;
        shadow += shadow2D(shadowtex1, vec3(shadowCoord.xy + offset, biasedDepth)).r;
    }
    shadow /= 12.0;
    #endif

    // Apply edge fade
    shadow = mix(1.0, shadow, edgeFade);

    return shadow;
}

// Get colored shadow tint from stained glass, etc.
vec3 getShadowColor(vec3 shadowCoord) {
    #ifndef DYNAMIC_SHADOWS
    return vec3(1.0);
    #endif

    float biasedDepth = shadowCoord.z - SHADOW_BIAS;

    // Check if transparent shadow is blocking
    float transparentShadow = shadow2D(shadowtex0, vec3(shadowCoord.xy, biasedDepth)).r;
    float opaqueShadow = shadow2D(shadowtex1, vec3(shadowCoord.xy, biasedDepth)).r;

    // If opaque shadow is lit but transparent shadow is dark, there's a colored blocker
    if (opaqueShadow > 0.5 && transparentShadow < 0.5) {
        vec4 shadowAlbedo = texture2D(shadowcolor0, shadowCoord.xy);
        return shadowAlbedo.rgb;
    }

    return vec3(1.0);
}

// Cartoon-stylized shadow: quantize the shadow factor into hard steps
float getCartoonShadow(float rawShadow) {
    #ifdef CEL_SHADING
    // Snap to either fully lit or fully shadowed for a clean toon look
    // with a tiny smoothstep band to avoid pixel shimmer
    return smoothstep(0.3, 0.7, rawShadow);
    #else
    return rawShadow;
    #endif
}

#endif // SHADOWS_GLSL
