# 🎨 Happy Shaders

**Happy Shaders** es un shaderpack estilizado tipo **Cartoon / Toon / Cel-Shading** diseñado para **Minecraft Java Edition**, optimizado para ejecutarse de forma ultrarrápida con **Iris Shaders** y **Sodium**.

---

## ✨ Características Principales

- 🎭 **Iluminación Cel-Shading (Toon)**:
  - Bandas de luz discretizadas estilo cómic / animación.
  - Sombras suaves con tinte ambiental de color (evita oscuridad total opaca).
  - Luz cálida y acogedora de antorchas y fogatas.
- 🍃 **Animación de Viento (Waving Foliage)**:
  - Movimiento suave en hierba alta, césped, flores y cultivos (la base se mantiene anclada al suelo).
  - Susurro tridimensional en las hojas de los árboles.
  - Compatible con todos los tipos de vegetación de Minecraft moderno mediante `block.properties`.
- 🌊 **Agua Estilizada Cartoon**:
  - Color turquesa tropical / anime vibrante.
  - Ondulación suave en la superficie.
  - Destellos cáusticos y líneas de espuma procedurales animadas.
  - 3 estilos de color seleccionables (Turquesa Tropical, Azul Cielo, Laguna Esmeralda).
- 🌅 **Cielo y Atmósfera Estilizados**:
  - Degradados de cielo cartoon para el día, atardeceres dorados/rosados y noches índigo profundas.
  - Sol y luna radiantes.
  - Nubes esponjosas con iluminación dinámica acorde a la hora del día.
- ⚙️ **Menú de Configuración Integrado en Iris**:
  - Menú interactivo dentro de Minecraft (*Opciones > Gráficos > Paquetes de Shaders > Opciones de Shaders*).
  - Totalmente traducido al **Español** e **Inglés**.

---

## 🚀 Cómo Instalarlo y Probarlo en Minecraft

### Requisitos:
1. **Minecraft Java Edition** (1.20+, 1.21+ o cualquier versión moderna).
2. **Fabric** o **NeoForge**.
3. **Sodium** e **Iris Shaders**.

### Opción 1: Enlace directo para desarrollo (Recomendado)
Para ver tus cambios reflejados al instante pulsando `F3 + R` en Minecraft:

Abre PowerShell como Administrador y ejecuta:
```powershell
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\.minecraft\shaderpacks\HappyShader" -Target "c:\Users\User\OneDrive\Documents\GitHub\HappyShader"
```

### Opción 2: Copiar la carpeta
Copia la carpeta `HappyShader` directamente dentro de tu carpeta:
`%appdata%\.minecraft\shaderpacks\`

---

## 📁 Estructura del Proyecto

```
HappyShader/
├── README.md
└── shaders/
    ├── block.properties        # Mapeo de bloques para animación de viento
    ├── shaders.properties      # Definición del menú de opciones en el juego
    ├── lang/
    │   ├── es_es.lang          # Traducción en español del menú
    │   └── en_us.lang          # Traducción en inglés del menú
    ├── lib/
    │   ├── settings.glsl       # Opciones configurables (#define)
    │   ├── uniforms.glsl       # Uniforms estándar de Iris
    │   ├── celshading.glsl     # Algoritmo de bandas cel-shading
    │   ├── waving.glsl         # Fórmulas de deformación por viento
    │   ├── color.glsl          # Ajuste de saturación, contraste y tonos
    │   ├── water.glsl          # Color del agua y destellos procedurales
    │   └── sky.glsl            # Degradados estilizados del cielo
    ├── gbuffers_terrain.*      # Renderizado de bloques sólidos y vegetación
    ├── gbuffers_water.*        # Renderizado de agua y bloques translúcidos
    ├── gbuffers_entities.*     # Mobs, jugadores y cofres (incluye flash de daño)
    ├── gbuffers_hand.*         # Mano e ítems en primera persona
    ├── gbuffers_weather.*      # Lluvia y nieve
    ├── gbuffers_skybasic.*     # Cúpula celeste y degradado del cielo
    ├── gbuffers_skytextured.*  # Sol y luna
    ├── gbuffers_clouds.*       # Nubes estilo cartoon
    ├── gbuffers_textured.*     # Partículas y elementos especiales
    ├── composite.*             # Post-procesado intermedio
    └── final.*                 # Gradación final de color y contraste
```

---

## 🛠️ Cómo Editar y Añadir Nuevos Efectos

1. **Ajustar valores**: Puedes cambiar parámetros globales (número de bandas, velocidad del viento, vibración de color) en [`shaders/lib/settings.glsl`](file:///c:/Users/User/OneDrive/Documents/GitHub/HappyShader/shaders/lib/settings.glsl).
2. **Recargar en vivo**: En Minecraft con Iris instalado, cada vez que guardes un archivo GLSL, presiona `F3 + R` dentro del juego para recargar los shaders al instante sin reiniciar el juego.
