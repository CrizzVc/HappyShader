#ifndef WAVING_GLSL
#define WAVING_GLSL

#include "/lib/settings.glsl"

// Wind displacement for foliage (grass, flowers, crops)
vec3 getFoliageOffset(vec3 worldPos, float topWeight, float time) {
    #ifdef WAVING_FOLIAGE
    float t = time * WAVING_SPEED * 2.2;
    
    // Multi-frequency wind simulation
    float waveA = sin(t + worldPos.x * 0.8 + worldPos.z * 0.6);
    float waveB = cos(t * 1.4 + worldPos.x * 1.3 - worldPos.z * 0.9) * 0.45;
    float waveC = sin(t * 2.1 + worldPos.x * 0.3 + worldPos.z * 1.8) * 0.25;
    
    float totalWave = (waveA + waveB + waveC) * 0.12 * WAVING_INTENSITY * topWeight;
    
    // Sway predominantly in X/Z with slight vertical dip
    return vec3(totalWave, -abs(totalWave) * 0.15, totalWave * 0.8);
    #else
    return vec3(0.0);
    #endif
}

// Gentle rustling for tree leaves
vec3 getLeavesOffset(vec3 worldPos, float time) {
    #ifdef WAVING_LEAVES
    float t = time * WAVING_SPEED * 1.5;
    
    float waveX = sin(t + worldPos.x * 1.5 + worldPos.y * 0.7);
    float waveY = cos(t * 1.2 + worldPos.z * 1.3 + worldPos.x * 0.5) * 0.6;
    float waveZ = sin(t * 0.9 + worldPos.z * 1.1 + worldPos.y * 1.2);
    
    return vec3(waveX, waveY, waveZ) * 0.035 * WAVING_INTENSITY;
    #else
    return vec3(0.0);
    #endif
}

// Gentle surface wave for water
vec3 getWaterDisplacement(vec3 worldPos, float time) {
    #ifdef WATER_WAVE_DISPLACEMENT
    float t = time * 1.8;
    
    float wave1 = sin(t + worldPos.x * 1.2 + worldPos.z * 0.8);
    float wave2 = cos(t * 1.5 - worldPos.x * 0.7 + worldPos.z * 1.1) * 0.5;
    
    float height = (wave1 + wave2) * 0.045;
    return vec3(0.0, height, 0.0);
    #else
    return vec3(0.0);
    #endif
}

#endif // WAVING_GLSL
