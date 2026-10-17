#ifndef SKY_GLSL
#define SKY_GLSL

#include "/lib/settings.glsl"

// Calculates a stylized cartoon sky gradient
vec3 getCartoonSkyColor(vec3 viewDir, vec3 sunPos, vec3 defaultSky, float rain) {
    #ifdef STYLIZED_SKY
    float sunElev = normalize(sunPos).y;
    float horizonFactor = clamp(1.0 - abs(viewDir.y) * 1.2, 0.0, 1.0);
    horizonFactor = pow(horizonFactor, 2.0);

    // Daytime cartoon sky
    vec3 dayZenith = vec3(0.25, 0.58, 0.98);
    vec3 dayHorizon = vec3(0.70, 0.88, 1.0);

    // Sunset / Sunrise vibrant cartoon colors
    vec3 sunsetZenith = vec3(0.35, 0.20, 0.55);
    vec3 sunsetHorizon = vec3(1.0, 0.52, 0.28);

    // Nighttime deep indigo
    vec3 nightZenith = vec3(0.04, 0.06, 0.15);
    vec3 nightHorizon = vec3(0.10, 0.12, 0.25);

    // Transitions based on sun elevation
    float dayFactor = clamp(sunElev * 4.0, 0.0, 1.0);
    float sunsetFactor = clamp(1.0 - abs(sunElev) * 6.0, 0.0, 1.0);
    float nightFactor = clamp(-sunElev * 4.0, 0.0, 1.0);

    vec3 skyColor = mix(mix(nightZenith, dayZenith, dayFactor), sunsetZenith, sunsetFactor * 0.7);
    vec3 horizonColor = mix(mix(nightHorizon, dayHorizon, dayFactor), sunsetHorizon, sunsetFactor);

    vec3 finalSky = mix(skyColor, horizonColor, horizonFactor);

    // Rain desaturation and overcast
    vec3 rainSky = vec3(0.38, 0.42, 0.48);
    finalSky = mix(finalSky, rainSky, rain * 0.8);

    return finalSky;
    #else
    return defaultSky;
    #endif
}

#endif // SKY_GLSL
