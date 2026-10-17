#version 120

#include "/lib/settings.glsl"

uniform sampler2D texture;

varying vec4 color;
varying vec2 texCoord;

void main() {
    vec4 tex = texture2D(texture, texCoord) * color;
    if (tex.a < 0.05) discard;

    // Stylized warm radiant sun/moon
    #ifdef STYLIZED_SKY
    vec3 brightColor = tex.rgb * vec3(1.15, 1.08, 0.95);
    gl_FragColor = vec4(brightColor, tex.a);
    #else
    gl_FragColor = tex;
    #endif
}
