#version 120

/*
 * HAPPY SHADERS - Shadow Pass Fragment Shader
 * Writes depth (and optionally color for translucent shadow tinting).
 */

uniform sampler2D texture;

varying vec2 texCoord;
varying vec4 color;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;

    // Discard fully transparent pixels so they don't cast shadows
    if (albedo.a < 0.1) discard;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = albedo;
}
