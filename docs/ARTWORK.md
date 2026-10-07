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

## Woodland launcher

The original background is saved as
[`Woodland.jpg`](../Resources/Assets.xcassets/Woodland.imageset/Woodland.jpg).
It was generated with the built-in image tool on 2026-10-07 and encoded as a
443 KB JPEG for the asset catalog. It is decorative original artwork, not a
game screenshot. The separate README gameplay image is an actual Simulator
capture, resized without changing its content.

Generation prompt:

> Use case: stylized-concept. Asset type: full-screen panoramic background for SquirrelPad, a native iPad/iPhone N64 game launcher. Create a striking nostalgic late-1990s low-poly woodland at golden hour: angular amber oak canopy, deep teal shaded foliage, a winding path and small river receding into misty blue hills, warm sunbeams. A single oversized golden acorn collectible floats above a mossy stone on the RIGHT third, its brown faceted cap and curved stem clear, a little magical warm light below it. The acorn should look like a chunky Nintendo 64 inventory object with low-resolution pixel textures and stepped silhouette, no smooth Pixar look. Composition: very wide landscape 16:9, ideally 2048x1152. Left 55 percent is dark quiet teal woodland with low contrast and abundant negative space for live white title and buttons; all dominant artwork and sunset on right. Main acorn centered at 76 percent width and 47 percent height, within middle 55 percent vertical area to survive wide phone crops. Sophisticated limited palette of forest teal, ink navy, ochre, burnt orange, honey gold. Tangible polygon facets and pixel textures, scenic depth, no modern glossy gradients on objects, no photorealism, no drawn outlines. Environment artwork only: NO letters, text, logos, characters, UI, controls, frames, borders, badges or watermarks. Original scene, not a screenshot or a recreation of any game location.
