#ifndef CELSHADING_GLSL
#define CELSHADING_GLSL

#include "/lib/settings.glsl"

// Step quantization for cartoon / cel-shaded light levels
float quantizeLight(float lightLevel, int bands, float minVal) {
    #ifdef CEL_SHADING
    float fbands = float(bands);
    // Discretize into bands with a clean cutoff
    float stepped = floor(lightLevel * fbands + 0.35) / fbands;
    return mix(minVal, 1.0, clamp(stepped, 0.0, 1.0));
    #else
    return lightLevel;
    #endif
}

// Compute cartoon diffuse lighting from normal and light direction
float getCartoonDiffuse(vec3 normal, vec3 lightDir) {
    #ifdef CEL_SHADING
    float nDotL = dot(normal, lightDir);
    if (nDotL > 0.45) {
        return 1.0;
    } else if (nDotL > -0.15) {
        return 0.75;
    } else {
        return CEL_SHADOW_BRIGHTNESS;
    }
    #else
    return max(0.35, dot(normal, lightDir) * 0.5 + 0.5);
    #endif
}

// Combine ambient, sky light and torch light into stylized cartoon illumination
vec3 applyCartoonLighting(vec3 albedo, vec2 lightmapCoord, vec3 normal, vec3 lightDir, vec3 torchColor, vec3 skyTint) {
    #ifdef CEL_SHADING
    float skyLight = lightmapCoord.y;
    float blockLight = lightmapCoord.x;

    // Quantize sky light into toon steps
    float toonSky = quantizeLight(skyLight, CEL_BANDS, CEL_SHADOW_BRIGHTNESS);
    
    // Directional shading on top of sky light (only if exposed to sky)
    float toonDiffuse = getCartoonDiffuse(normal, lightDir);
    float naturalLight = toonSky * mix(0.75, 1.0, toonDiffuse);

    // Quantize torch / block light
    float toonTorch = quantizeLight(blockLight, CEL_TORCH_STEPS, 0.0);
    toonTorch = pow(toonTorch, 1.2); // Smooth falloff for cozy feeling

    // Ambient shadow color tint (cartoon style uses colored shadows instead of pure black)
    vec3 shadowColor = vec3(0.35, 0.42, 0.55) * CEL_SHADOW_BRIGHTNESS;
    vec3 ambient = mix(shadowColor, skyTint, skyLight);

    // Combine natural sunlight/skylight + torchlight + ambient
    vec3 lightFactor = ambient + naturalLight * skyTint + toonTorch * torchColor * 1.35;
    
    return albedo * lightFactor;
    #else
    return albedo;
    #endif
}

#endif // CELSHADING_GLSL
