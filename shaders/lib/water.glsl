#ifndef WATER_GLSL
#define WATER_GLSL

#include "/lib/settings.glsl"

// Water base tint depending on selected style
vec3 getCartoonWaterBaseColor() {
    #if WATER_STYLE == 0
    // Tropical Turquoise (Caribbean look)
    return vec3(0.18, 0.72, 0.86);
    #elif WATER_STYLE == 1
    // Deep Sky Blue (Classic vibrant anime blue)
    return vec3(0.12, 0.50, 0.92);
    #else
    // Emerald Lagoon
    return vec3(0.16, 0.80, 0.65);
    #endif
}

// Procedural stylized cartoon water ripples
float getCartoonWaterRipples(vec2 worldXZ, float time) {
    #ifdef WATER_RIPPLES
    vec2 p = worldXZ * 1.8;
    float t = time * 1.2;
    
    float waveA = sin(p.x * 2.0 + t + sin(p.y * 1.8 - t));
    float waveB = cos(p.y * 2.0 - t * 1.1 + cos(p.x * 1.7 + t));
    float pattern = abs(waveA + waveB);
    
    // Sharp stylized cartoon caustic highlight
    return smoothstep(1.25, 1.75, pattern) * 0.35;
    #else
    return 0.0;
    #endif
}

#endif // WATER_GLSL
