#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"

/*
 * HAPPY SHADERS - Dynamic Shadow Library (shaders-MakeBreezy implementation)
 * 
 * Features:
 * - MakeBreezy radial distortion formula with shadowMapBias
 * - Complementary/MakeBreezy normal and distance-based bias (compute_bias)
 * - MakeBreezy Z-compression (pos.z * 0.2)
 * - MakeBreezy shadow_blur (5-tap rotated kernel)
 * - MakeBreezy pcf (8-sample Vogel disk with interleaved gradient dither)
 * - Smooth distance edge fade (shadow_fade)
 * - Colored translucent shadows (stained glass, etc.)
 */

// Shadow map samplers
uniform sampler2DShadow shadowtex0;     // Full depth (opaque + transparent)
uniform sampler2DShadow shadowtex1;     // Opaque-only depth
uniform sampler2D shadowcolor0;          // Shadow albedo for colored shadows

// --- MakeBreezy Distortion ---
const float shadowMapBias = 1.0 - 25.6 / shadowDistance;

float get_distort_factor(vec2 pos) {
    return length(pos.xy) * shadowMapBias + (1.0 - shadowMapBias);
}

vec3 distort(vec3 pos) {
    float factor = get_distort_factor(pos.xy);
    return vec3(pos.xy / factor, pos.z * 0.2);
}

vec3 undistort(vec3 pos) {
    float factor = get_distort_factor(pos.xy);
    return vec3(pos.xy * factor, pos.z / 0.2);
}

// --- MakeBreezy Shadow Bias ---
vec3 compute_bias(vec3 PlayerPos, vec3 WorldNormal, float NdotL, float Skylight) {
    float DistanceBias = pow(dot(PlayerPos, PlayerPos), 0.75);
    DistanceBias = 0.12 + 0.0008 * DistanceBias;
    vec3 Bias = WorldNormal * DistanceBias * (2.0 - 0.95 * max(NdotL, 0.0));

    if (Skylight < 0.5) {
        vec3 EdgeFactor = 0.2 * (0.5 - fract(PlayerPos + cameraPosition + WorldNormal * 0.01));
        Bias += max(0.5 - Skylight, 0.0) * EdgeFactor;
    }
    
    return Bias;
}

// Convert player space to shadow NDC space
vec3 player_shadow(vec3 PlayerPos) {
    vec4 clip = shadowProjection * (shadowModelView * vec4(PlayerPos + gbufferModelViewInverse[3].xyz, 1.0));
    return clip.xyz / clip.w;
}

// --- MakeBreezy Dither and Vogel Disk PCF ---
const vec2 vogel_disk[8] = vec2[](
    vec2(0.120644,  0.015554),
    vec2(-0.164001, 0.161802),
    vec2(0.020080, -0.262884),
    vec2(0.196867,  0.278013),
    vec2(-0.373623, -0.049764),
    vec2(0.345447, -0.206961),
    vec2(-0.121358, 0.450796),
    vec2(-0.227491, -0.414080)
);

float dither(vec2 pos) {
    return fract(52.9829189 * fract(0.06711056 * pos.x + 0.00583715 * pos.y));
}

// MakeBreezy 5-tap kernel blur
float shadow_blur(vec3 SampleCoord, float Radius) {
    vec3 Off1 = vec3(-0.33, 1.0, 0.0) / float(SHADOW_MAP_RESOLUTION) * Radius;
    vec3 Off2 = vec3(1.0, 0.33, 0.0) / float(SHADOW_MAP_RESOLUTION) * Radius;
    float Color = shadow2D(shadowtex0, SampleCoord).r * 0.25;
    Color += shadow2D(shadowtex0, SampleCoord + Off1).r * 0.1875;
    Color += shadow2D(shadowtex0, SampleCoord - Off1).r * 0.1875;
    Color += shadow2D(shadowtex0, SampleCoord + Off2).r * 0.1875;
    Color += shadow2D(shadowtex0, SampleCoord - Off2).r * 0.1875;
    return Color;
}

// MakeBreezy 8-tap Vogel disk PCF
float pcf(float PenumbraSize, vec3 ShadowPosUndistorted, vec2 FragCoord) {
    const int SAMPLE_COUNT = 8;
    float Dith = dither(FragCoord) * 6.28318530718;
    vec2 Offset = vec2(cos(Dith), sin(Dith)) / float(SHADOW_MAP_RESOLUTION);
    mat2 RotationOffset = mat2(
        Offset.x, Offset.y,
        -Offset.y, Offset.x
    );

    float ShadowColorFinal = 0.0;
    for (int i = 0; i < SAMPLE_COUNT; i++) {
        vec2 OffsetP = RotationOffset * vogel_disk[i] * PenumbraSize;
        vec3 ShadowPosD = ShadowPosUndistorted + vec3(OffsetP, 0.0);
        ShadowPosD = distort(ShadowPosD);
        ShadowPosD = ShadowPosD * 0.5 + 0.5;
        ShadowColorFinal += shadow2D(shadowtex0, ShadowPosD).r;
    }
    return ShadowColorFinal / float(SAMPLE_COUNT);
}

// MakeBreezy smooth distance fade
float shadow_fade(vec3 PlayerPos, float Dist) {
    return smoothstep(Dist - 32.0, Dist, length(PlayerPos));
}

// Main calculateShadow function
void calculateShadow(vec4 viewPos, vec3 normal, vec3 lightDir, vec2 fragCoord, float skyLight,
                     out float shadowFactor, out vec3 shadowColorTint) {
    shadowFactor = 1.0;
    shadowColorTint = vec3(1.0);

    #ifdef DYNAMIC_SHADOWS
    vec3 PlayerPos = (gbufferModelViewInverse * viewPos).xyz;
    vec3 WorldNormal = normalize(mat3(gbufferModelViewInverse) * normal);
    float NdotL = clamp(dot(normal, lightDir), 0.0, 1.0);

    vec3 bias = compute_bias(PlayerPos + gbufferModelViewInverse[3].xyz, WorldNormal, NdotL, skyLight);
    vec3 ShadowPosUndistorted = player_shadow(PlayerPos + bias);
    vec3 ShadowPos = distort(ShadowPosUndistorted);
    ShadowPos = ShadowPos * 0.5 + 0.5;

    float ShadowFinal = 1.0;

    #if SHADOW_FILTER == 0
        // Crisp / pixelated toon shadow
        ShadowFinal = shadow2D(shadowtex0, ShadowPos).r;
    #elif SHADOW_FILTER == 1
        // MakeBreezy 5-tap kernel blur
        ShadowFinal = shadow_blur(ShadowPos, SHADOW_BLUR_RADIUS);
    #else
        // MakeBreezy 8-tap Vogel disk PCF
        ShadowFinal = pcf(SHADOW_BLUR_RADIUS * 2.0, ShadowPosUndistorted, fragCoord);
    #endif

    // MakeBreezy distance fade
    float fade = shadow_fade(PlayerPos, shadowDistance);
    shadowFactor = mix(ShadowFinal, 1.0, fade);

    // Stained glass colored shadows
    #ifdef COLORED_SHADOW
    float det = shadow2D(shadowtex0, ShadowPos).r;
    float blk = shadow2D(shadowtex1, ShadowPos).r;
    if (blk > 0.5 && det < 0.5) {
        shadowColorTint = texture2D(shadowcolor0, ShadowPos.xy).rgb;
    }
    #endif
    #endif
}

// Overload with default skylight = 1.0
void calculateShadow(vec4 viewPos, vec3 normal, vec3 lightDir, vec2 fragCoord,
                     out float shadowFactor, out vec3 shadowColorTint) {
    calculateShadow(viewPos, normal, lightDir, fragCoord, 1.0, shadowFactor, shadowColorTint);
}

// --- Backward Compatibility Wrappers ---
vec3 getShadowCoord(vec4 viewPos, mat4 gbufferModelViewInverse) {
    vec3 PlayerPos = (gbufferModelViewInverse * viewPos).xyz;
    vec3 ShadowPosUndistorted = player_shadow(PlayerPos);
    vec3 ShadowPos = distort(ShadowPosUndistorted);
    return ShadowPos * 0.5 + 0.5;
}

float getShadowFactor(vec3 shadowCoord) {
    #ifndef DYNAMIC_SHADOWS
    return 1.0;
    #endif
    #if SHADOW_FILTER == 1
    return shadow_blur(shadowCoord, SHADOW_BLUR_RADIUS);
    #else
    return shadow2D(shadowtex0, shadowCoord).r;
    #endif
}

float getCartoonShadow(float rawShadow) {
    return rawShadow;
}

vec3 getShadowColor(vec3 shadowCoord) {
    #ifndef DYNAMIC_SHADOWS
    return vec3(1.0);
    #endif
    #ifdef COLORED_SHADOW
    float det = shadow2D(shadowtex0, shadowCoord).r;
    float blk = shadow2D(shadowtex1, shadowCoord).r;
    if (blk > 0.5 && det < 0.5) {
        return texture2D(shadowcolor0, shadowCoord.xy).rgb;
    }
    #endif
    return vec3(1.0);
}

#endif // SHADOWS_GLSL
