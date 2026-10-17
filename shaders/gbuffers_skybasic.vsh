#version 120

varying vec4 color;
varying vec3 viewVector;

void main() {
    color = gl_Color;
    viewVector = gl_Vertex.xyz;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
