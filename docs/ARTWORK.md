# Pixel acorn artwork

The iPhone/iPad icon is the opaque 1024 × 1024 PNG at
[`AppIcon.png`](../Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png).
The launcher and settings header use the same artwork in `Acorn.imageset`.
It was restyled with the built-in image generation tool on 2026-10-07,
then resized for the Xcode asset catalog. iOS applies the corner mask.

Generation prompt:

> Restyle this app icon into an N64-era pixelated acorn collectible. Keep a single large recognizable warm amber acorn with brown cap and curved stem, but replace all painterly texture and smooth detail with bold, crisp chunky pixel art, as if a low-poly Nintendo 64 collectible was rendered into a 64x64 sprite and enlarged with nearest-neighbor pixels. Clearly visible square pixels, stepped edges, simple faceted shading, limited palette, restrained dithering. Center it with generous safe space against an opaque deep midnight navy background with very subtle pixel shading. No text, no lettering, no logo, no face, no additional objects, no sparkle decorations, no border. Full-bleed square iOS app icon, 1024x1024, no baked-in rounded corners. It must feel like a retro 1998 game inventory item, not a painting or modern glossy 3D illustration.

The older `scripts/generate-app-icon.swift` draws the previous geometric mark;
it does not reproduce this artwork and should not be run to regenerate it.
