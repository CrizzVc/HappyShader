#version 120

#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/celshading.glsl"
#include "/lib/color.glsl"
#include "/lib/shadows.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec4 entityColor;

varying vec4 color;
varying vec2 texCoord;
varying vec2 lmCoord;
varying vec3 normal;
varying vec4 viewPos;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.1) discard;

    vec3 lightDir = normalize(sunPosition);
    vec3 torchColor = getTorchColor();
    vec3 sunColor = getSunlightColor(1.0);

    // Calculate dynamic shadow (shaders-MakeBreezy style)
    float shadowFactor = 1.0;
    vec3 shadowColorTint = vec3(1.0);
    #ifdef DYNAMIC_SHADOWS
    calculateShadow(viewPos, normal, lightDir, gl_FragCoord.xy, lmCoord.y, shadowFactor, shadowColorTint);
    #endif

    #ifdef CEL_SHADING
    vec3 litColor = applyCartoonLighting(albedo.rgb, lmCoord, normal, lightDir, torchColor, sunColor, shadowFactor, shadowColorTint);
    #else
    vec3 lightVal = texture2D(lightmap, lmCoord).rgb;
    vec3 litColor = albedo.rgb * lightVal * mix(SHADOW_DARKNESS, 1.0, shadowFactor);
    #endif

    // Handle damage flash (turns mob red when taking damage)
    litColor = mix(litColor, entityColor.rgb, entityColor.a);

    gl_FragColor = vec4(litColor, albedo.a);
}
