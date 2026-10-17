#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"

uniform sampler2D texture;

varying vec4 color;
varying vec2 texCoord;

void main() {
    vec4 tex = texture2D(texture, texCoord) * color;
    if (tex.a < 0.1) discard;

    #ifdef STYLIZED_CLOUDS
    float sunElev = normalize(sunPosition).y;
    vec3 cloudDay = vec3(1.0, 1.0, 1.0);
    vec3 cloudSunset = vec3(1.0, 0.75, 0.60);
    vec3 cloudNight = vec3(0.25, 0.28, 0.45);

    float dayFactor = clamp(sunElev * 4.0, 0.0, 1.0);
    float sunsetFactor = clamp(1.0 - abs(sunElev) * 6.0, 0.0, 1.0);

    vec3 cloudTint = mix(cloudNight, cloudDay, dayFactor);
    cloudTint = mix(cloudTint, cloudSunset, sunsetFactor * 0.8);

    vec3 finalColor = tex.rgb * cloudTint;
    gl_FragColor = vec4(finalColor, tex.a * 0.9);
    #else
    gl_FragColor = tex;
    #endif
}
