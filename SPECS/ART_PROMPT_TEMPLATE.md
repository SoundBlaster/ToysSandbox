# Flux Sprite Prompt Template

Use this as the baseline prompt system for generating toy sprites with `ollama run x/flux2-klein`.

## Style Anchor

Keep this unchanged across generations:

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style
```

## Universal Template

Use this pattern for new objects:

```text
{STYLE_ANCHOR}, {OBJECT_DESCRIPTION}, material readability, clear silhouette, toy-like appearance, physics-friendly design
```

## Object Prompts

### Ball

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, colorful rubber ball, glossy surface, simple stripes, soft reflections, toy-like appearance
```

### Pillow

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, soft fabric pillow, slightly squished shape, rounded corners, pastel colors, subtle fabric folds, soft shading, cozy toy look
```

### Brick

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, small brick block, slightly rounded edges, matte clay material, simple surface, warm red-orange color, chunky toy-like proportions
```

### Vase

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, simple ceramic vase, smooth curves, glossy surface, minimal decorative pattern, soft reflections, stable rounded base
```

### Balloon

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, inflated balloon, oval shape, thin tied end, glossy surface, bright color, soft highlight, slightly transparent feel
```

### Jelly Cube

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, semi-transparent jelly cube, soft edges, squishy appearance, subtle inner glow, glossy surface, slightly wobbly look
```

### Pot

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, small plant pot, simple cylindrical shape, matte clay or plastic material, slightly thick rim, stable base
```

### Sticky Block

```text
cartoon kids physics sandbox sprite, clean 2D game asset, simple rounded geometry, soft shading, bright playful colors, smooth outlines, minimal details, no texture noise, consistent lighting, centered object, isolated on transparent background, no shadows, no background, high readability, mobile game style, unity casual art style, soft sticky cube, slightly deformed edges, rubbery surface, semi-gloss material, subtle stretch feel, bright color, tactile toy look
```

## Negative Prompt

```text
realistic, photo, complex texture, background, environment, shadow, blur, noise, 3D render, messy details, text, watermark
```

## Material System

| Object | Material | Behavior |
| --- | --- | --- |
| Ball | rubber | bounce |
| Pillow | soft fabric | absorb |
| Brick | hard | rigid |
| Vase | fragile ceramic | break |
| Balloon | air | float |
| Jelly | gel | wobble |
| Pot | heavy | stable |
| Sticky | adhesive | stick |

## Notes

- Keep the style anchor identical for all object generations.
- Change only the object description and material language.
- Prefer simple, readable silhouettes over detail.
- Generate transparent-background sprites only.
