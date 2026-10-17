#ifndef COLOR_GLSL
#define COLOR_GLSL

#include "/lib/settings.glsl"

// Helper: Calculate perceived luminance
float getLuminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

// Adjust saturation and vibrant cartoon color grading
vec3 applyVibrance(vec3 color, float vibrance) {
    float lum = getLuminance(color);
    float maxCol = max(color.r, max(color.g, color.b));
    float minCol = min(color.r, min(color.g, color.b));
    float sat = (maxCol - minCol) / max(maxCol, 0.001);
    
    // Boost less-saturated tones more gently to prevent clipping
    float boost = (1.0 - sat) * (vibrance - 1.0) + 1.0;
    return mix(vec3(lum), color, max(boost, 0.0));
}

// Stylized contrast curve
vec3 applyContrast(vec3 color, float contrast) {
    return pow(max(color, vec3(0.0)), vec3(contrast));
}

// Cartoon tone mapping & color correction
vec3 cartoonColorGrade(vec3 color) {
    // Boost saturation for happy/vibrant look
    color = applyVibrance(color, CARTOON_VIBRANCE);
    
    // Apply contrast
    color = applyContrast(color, CARTOON_CONTRAST);
    
    return clamp(color, 0.0, 1.0);
}

// Dynamic lighting colors based on day/night
vec3 getSunlightColor(float timeOfDay) {
    #ifdef WARM_LIGHTING
    // Warm golden sunshine during midday
    return vec3(1.0, 0.95, 0.88);
    #else
    return vec3(1.0, 1.0, 1.0);
    #endif
}

vec3 getTorchColor() {
    #ifdef WARM_LIGHTING
    // Cozy warm cartoon torch light
    return vec3(1.0, 0.74, 0.44);
    #else
    return vec3(1.0, 0.85, 0.65);
    #endif
}

#endif // COLOR_GLSL
