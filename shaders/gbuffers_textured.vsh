#version 120

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;

    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
