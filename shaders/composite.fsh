#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

varying vec2 texCoord;

void main() {
    vec4 sceneColor = texture2D(colortex0, texCoord);
    gl_FragColor = sceneColor;
}
