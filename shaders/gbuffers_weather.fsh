#version 120

#include "/lib/settings.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.05) discard;

    vec3 lightVal = texture2D(lightmap, lmCoord).rgb;
    // Boost cartoon rain/snow visibility slightly
    vec3 weatherCol = albedo.rgb * (lightVal * 0.8 + vec3(0.25));

    gl_FragColor = vec4(weatherCol, albedo.a);
}
