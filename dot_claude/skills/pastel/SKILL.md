---
name: pastel
description: Work with colors using the pastel CLI — generate color schemes, palettes, gradients, convert formats, manipulate colors, check accessibility. Use when the user asks about colors, color schemes, palettes, theming, or color manipulation.
user-invocable: true
allowed-tools: Bash(pastel *)
argument-hint: [color or task description]
---

# pastel — Color CLI Skill

Use the `pastel` CLI to fulfill color-related requests. Pastel reads/writes colors via stdin/stdout, making it composable with pipes.

## IMPORTANT: Always show colors visually

Whenever you produce a list of colors, always end your response with a shell command the user can run to preview them:

```
colors hex1 hex2 hex3 ...
```

Pass hex values WITHOUT the `#` prefix — the function adds it automatically. The `colors` fish function renders each color as a terminal swatch using pastel. Always include this so the user can see the actual colors.

## Color Input Formats

All commands accept colors in these formats:
- Named: `red`, `lightslategray`, `cornflowerblue`
- Hex: `#778899`, `778899`, `#789` (shorthand)
- RGB: `rgb(119, 136, 153)` or `119,136,153`
- HSL: `hsl(210, 14.3%, 53.3%)`
- With alpha: `#77889980`, `rgba(119,136,153,0.5)`, `hsla(210,14.3%,53.3%,50%)`
- Stdin: use `-` to read from pipe
- Screen picker: use `pick` as color value

## Commands Reference

### Inspect a color
```bash
pastel color <color>...
# Example:
pastel color ff6b6b 4ecdc4 556270
```

### Convert format
```bash
pastel format <type> <color>
# Types: rgb, hex, hsl, hsv, lch, oklch, lab, oklab, luminance, brightness,
#        cmyk, name, ansi-8bit, ansi-24bit, rgb-r/g/b, hsl-hue/saturation/lightness
pastel format hex "rgb(255, 107, 107)"
pastel format hsl cornflowerblue
pastel format lch "#4ecdc4"
```

### Generate color schemes

**Complementary** (180° hue rotation):
```bash
pastel complement <color>
pastel complement "#e74c3c"
```

**Analogous** (nearby hues, rotate by ±30°):
```bash
pastel rotate 30 <color>
pastel rotate -30 <color>
# Full analogous trio:
pastel rotate 30 "#3498db"; pastel rotate -30 "#3498db"
```

**Triadic** (rotate by 120° and 240°):
```bash
pastel rotate 120 <color>
pastel rotate 240 <color>
```

**Tetradic / Split-complementary** (rotate by 90°, 180°, 270°):
```bash
pastel rotate 90 <color>; pastel rotate 180 <color>; pastel rotate 270 <color>
```

**Gradient** between colors:
```bash
pastel gradient <color1> <color2> -n <steps>
pastel gradient --colorspace HSL <color1> <color2> -n 10
# Colorspaces: Lab (default), LCh, RGB, HSL, OkLab
pastel gradient "#ff6b6b" "#4ecdc4" -n 8
```

**Distinct visually separate colors**:
```bash
pastel distinct <count> [seed-colors...]
pastel distinct 6
pastel distinct 5 "#ff0000"   # include red in set
# More accurate but slower:
pastel distinct -m CIEDE2000 8
```

**Random colors**:
```bash
pastel random -n <count> --strategy <strategy>
# Strategies: vivid (default), rgb, gray, lch_hue
pastel random -n 10
pastel random -n 5 --strategy lch_hue   # same lightness/chroma, random hue
```

### Manipulate colors

**Lighten / darken** (0.0–1.0 amount):
```bash
pastel lighten 0.1 <color>
pastel darken 0.15 <color>
```

**Saturate / desaturate**:
```bash
pastel saturate 0.2 <color>
pastel desaturate 0.3 <color>
```

**Rotate hue** (degrees, can be negative):
```bash
pastel rotate 45 <color>
```

**Set a specific property**:
```bash
pastel set lightness 0.9 <color>
pastel set hue 200 <color>
pastel set alpha 0.5 <color>
# Properties: lightness, hue, chroma, lab-a, lab-b, oklab-l, oklab-a, oklab-b,
#             red, green, blue, hsl-hue, hsl-saturation, hsl-lightness, alpha
```

**Mix two colors**:
```bash
pastel mix <base-color> <other-color>
pastel mix --colorspace RGB --fraction 0.3 red blue
# Colorspaces: Lab (default), LCh, RGB, HSL, OkLab
# fraction: 0.0 = all base, 1.0 = all other
```

**Desaturate completely** (to gray, preserving luminance):
```bash
pastel to-gray <color>
```

**Create gray tone**:
```bash
pastel gray <lightness>   # 0.0 (black) to 1.0 (white)
pastel gray 0.85
```

### Accessibility

**Text color for background** (returns black or white for best contrast):
```bash
pastel textcolor <bg-color>
pastel textcolor "#3498db"
```

**Simulate colorblindness**:
```bash
pastel colorblind <type> <color>
# Types: prot (protanopia), deuter (deuteranopia), trit (tritanopia)
pastel colorblind deuter "#e74c3c"
```

**Check 24-bit terminal support**:
```bash
pastel colorcheck
```

### Utility

**List all named colors**:
```bash
pastel list
pastel list --sort brightness   # brightness, luminance, hue, chroma, random
```

**Sort colors**:
```bash
pastel sort-by hue <colors>...
pastel sort-by luminance --reverse <colors>...
pastel sort-by chroma --unique <colors>...
```

**Print colored text**:
```bash
pastel paint <color> "text"
pastel paint --on <bg-color> <fg-color> "text"
pastel paint --bold --italic --underline <color> "text"
```

**Pick color from screen** (requires external picker):
```bash
pastel pick
pastel pick 3   # pick 3 colors
```

## Composable Pipelines

Colors flow through stdin/stdout as hex lines, enabling powerful pipes:

```bash
# Generate 5 vivid random colors sorted by hue
pastel random -n 5 | pastel sort-by hue | pastel format hex

# Full complementary scheme from a seed color
echo "#3498db" | pastel format hex
pastel complement "#3498db" | pastel format hex

# Shades scale: 5-step dark-to-light gradient
pastel gradient black "#3498db" -n 5 | pastel format hex

# Tints scale: color to white
pastel gradient "#e74c3c" white -n 7 | pastel format hex

# Analogous scheme: base + two neighbors
pastel color "#3498db"; pastel rotate 30 "#3498db"; pastel rotate -30 "#3498db"

# Triadic palette
pastel color "#e74c3c"; pastel rotate 120 "#e74c3c"; pastel rotate 240 "#e74c3c"

# Check accessibility: get readable text for each color in a palette
pastel distinct 5 | pastel format hex | while read c; do
  echo "bg=$c fg=$(pastel textcolor $c | pastel format hex)"
done

# Colorblind-safe check on a distinct palette
pastel distinct 4 | pastel colorblind deuter

# Extract dominant hue variant at fixed lightness
pastel set lightness 0.5 "#e74c3c" | pastel format hsl
```

## Common Tasks

**Generate a full UI palette from a brand color:**
```bash
COLOR="#3498db"
echo "Base:        $COLOR"
echo "Complement:  $(pastel complement $COLOR | pastel format hex)"
echo "Dark:        $(pastel darken 0.2 $COLOR | pastel format hex)"
echo "Light:       $(pastel lighten 0.2 $COLOR | pastel format hex)"
echo "Muted:       $(pastel desaturate 0.3 $COLOR | pastel format hex)"
echo "Text on bg:  $(pastel textcolor $COLOR | pastel format hex)"
```

**Generate a tonal scale (like Tailwind shades):**
```bash
pastel gradient black "#3498db" white -n 11 | pastel format hex
```

**Create a harmonious 6-color palette:**
```bash
pastel distinct 6 | pastel sort-by hue | pastel format hex
```
