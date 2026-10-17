#ifndef UNIFORMS_GLSL
#define UNIFORMS_GLSL

// Matrices
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

// Positions & Vectors
uniform vec3 cameraPosition;
uniform vec3 upPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 shadowLightPosition;

// World & Time
uniform int worldTime;
uniform int worldDay;
uniform int isEyeInWater;
uniform int hideGUI;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float wetness;

// Screen dimensions
uniform float viewWidth;
uniform float viewHeight;

// Shadow mapping
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#endif // UNIFORMS_GLSL
