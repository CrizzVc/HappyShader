#ifndef SETTINGS_GLSL
#define SETTINGS_GLSL

// ==========================================
//           HAPPY SHADERS SETTINGS
// ==========================================

/*
  Iris / OptiFine configurable options.
  You can tweak these directly here or inside Minecraft in:
  Options > Video Settings > Shader Packs > Shader Options
*/

// --- CEL-SHADING (TOON LIGHTING) ---
#define CEL_SHADING               // Enables stylized stepped / cartoon lighting [true false]
#define CEL_BANDS 3               // Number of light bands [2 3 4 5]
#define CEL_SHADOW_BRIGHTNESS 0.38 // Ambient shadow brightness [0.20 0.25 0.30 0.35 0.38 0.45 0.50]
#define CEL_TORCH_STEPS 3         // Stepped torch light levels [2 3 4]

// --- WAVING ANIMATIONS ---
#define WAVING_FOLIAGE            // Enable waving for grass, crops and flowers [true false]
#define WAVING_LEAVES             // Enable gentle rustling on tree leaves [true false]
#define WAVING_SPEED 1.0          // Speed of the wind animation [0.5 0.75 1.0 1.25 1.5 2.0]
#define WAVING_INTENSITY 1.0      // Amplitude of wind sway [0.5 0.75 1.0 1.25 1.5]

// --- CARTOON WATER ---
#define CARTOON_WATER             // Stylized translucent cartoon water [true false]
#define WATER_WAVE_DISPLACEMENT   // Gentle wave displacement on water surface [true false]
#define WATER_RIPPLES             // Animated stylized surface highlights/ripples [true false]
#define WATER_STYLE 0             // Water color style: 0: Tropical Turquoise, 1: Deep Sky Blue, 2: Emerald Lagoon [0 1 2]
#define WATER_TRANSPARENCY 0.70   // Water transparency factor [0.4 0.5 0.6 0.7 0.8 0.9]

// --- DYNAMIC SHADOWS ---
#define DYNAMIC_SHADOWS           // Enable real-time shadow mapping from the sun/moon [true false]
#define SHADOW_MAP_RESOLUTION 1024 // Shadow map resolution in pixels [512 1024 2048 4096]
#define SHADOW_QUALITY 1          // Shadow filter quality: 0: Hard, 1: Soft (4-tap PCF), 2: Ultra (12-tap PCF) [0 1 2]
#define SHADOW_DISTANCE 4         // Shadow render distance in chunks [2 3 4 6 8 12]
#define SHADOW_BIAS 0.0008        // Depth bias to reduce shadow acne [0.0004 0.0006 0.0008 0.0012 0.0016]
#define SHADOW_DISTORTION 0.85    // Shadow map barrel distortion for near-player detail [0.70 0.80 0.85 0.90 0.95]
#define SHADOW_DARKNESS 0.15      // How dark the shadowed areas are (0=black, 1=no shadow) [0.0 0.05 0.10 0.15 0.20 0.30]

// --- COLOR & ATMOSPHERE ---
#define CARTOON_VIBRANCE 1.35     // Saturation and color vibrancy multiplier [0.8 1.0 1.2 1.35 1.5 1.7]
#define CARTOON_CONTRAST 1.08     // Comic contrast curve [0.9 1.0 1.08 1.15 1.25]
#define WARM_LIGHTING             // Warmer sun and torch colors for a joyful/happy look [true false]
#define STYLIZED_SKY              // Stylized gradient sky and sunset colors [true false]
#define STYLIZED_CLOUDS           // Clean cartoon clouds [true false]

#endif // SETTINGS_GLSL
