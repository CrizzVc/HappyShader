#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;
varying vec3 normal;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);

    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
