#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/color.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.05) discard;

    vec3 lightVal = texture2D(lightmap, lmCoord).rgb;
    vec3 litColor = albedo.rgb * lightVal;

    gl_FragColor = vec4(litColor, albedo.a);
}
