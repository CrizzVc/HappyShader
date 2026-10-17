#version 120

#include "/lib/settings.glsl"
#include "/lib/color.glsl"

uniform sampler2D colortex0;

varying vec2 texCoord;

void main() {
    vec4 sceneColor = texture2D(colortex0, texCoord);

    // Apply cartoon vibrance, color grading, and contrast curve
    vec3 gradedColor = cartoonColorGrade(sceneColor.rgb);

    gl_FragColor = vec4(gradedColor, sceneColor.a);
}
