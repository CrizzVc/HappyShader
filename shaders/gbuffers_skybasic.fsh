#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/sky.glsl"

varying vec4 color;
varying vec3 viewVector;

void main() {
    vec3 viewDir = normalize(viewVector);
    vec3 skyColor = getCartoonSkyColor(viewDir, sunPosition, color.rgb, rainStrength);

    gl_FragColor = vec4(skyColor, color.a);
}
