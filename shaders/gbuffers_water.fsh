#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/celshading.glsl"
#include "/lib/color.glsl"
#include "/lib/water.glsl"
#include "/lib/shadows.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;
varying vec3 normal;
varying vec3 worldPosition;
varying vec4 viewPos;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.05) discard;

    vec3 lightDir = normalize(sunPosition);
    vec3 torchColor = getTorchColor();
    vec3 sunColor = getSunlightColor(1.0);

    #ifdef CARTOON_WATER
    // Check if translucent surface is water (biome-tinted or low alpha)
    bool isWater = (color.a < 0.99 || (color.r < 0.9 && color.b > 0.5));
    if (isWater) {
        // Stylized cartoon water tint and procedural caustics
        vec3 waterBase = getCartoonWaterBaseColor();
        float ripple = getCartoonWaterRipples(worldPosition.xz, frameTimeCounter);
        albedo.rgb = mix(albedo.rgb, waterBase, 0.65) + vec3(ripple);
        albedo.a = clamp(WATER_TRANSPARENCY, 0.1, 1.0);
    }
    #endif

    // Calculate dynamic shadow
    float shadowFactor = 1.0;
    vec3 shadowColorTint = vec3(1.0);
    #ifdef DYNAMIC_SHADOWS
    vec3 shadowCoord = getShadowCoord(viewPos, gbufferModelViewInverse);
    float rawShadow = getShadowFactor(shadowCoord);
    shadowFactor = getCartoonShadow(rawShadow);
    shadowColorTint = getShadowColor(shadowCoord);
    #endif

    #ifdef CEL_SHADING
    vec3 litColor = applyCartoonLighting(albedo.rgb, lmCoord, normal, lightDir, torchColor, sunColor, shadowFactor, shadowColorTint);
    #else
    vec3 lightVal = texture2D(lightmap, lmCoord).rgb;
    vec3 litColor = albedo.rgb * lightVal * mix(SHADOW_DARKNESS, 1.0, shadowFactor);
    #endif

    gl_FragColor = vec4(litColor, albedo.a);
}
