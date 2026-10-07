# Enhancements

Open **••• → Enhancements**. Choices are saved on your device and applied when
play resumes, including after a relaunch. **Restore Balanced Settings** restores
2× resolution, Crisp presentation, and N64 texture filtering without touching saves.

| Option | What it does |
| --- | --- |
| 1× / 2× / 3× resolution | Renders geometry at the original resolution or two/three times each dimension. 2× is the default; choose 1× for lower GPU load. |
| Pixel / Smooth / Crisp | Changes the filter used to scale the rendered picture to the display. |
| N64 texture filtering | Preserves the original three-point filter, or switches to smoother bilinear filtering. |

The Metal surface now uses the available display area instead of magnifying a
480×270 iPad surface. The game retains its original aspect ratio and timing.
Higher rendering resolution does not add detail to source textures. Performance,
battery use, and full-game fidelity at each setting still need broader hardware testing.

## Mods researched

Checked against upstream documentation on October 7, 2026. Desktop support does
not establish compatibility with this iOS port, which pins an earlier upstream revision.

| Candidate | SquirrelPad status / next step |
| --- | --- |
| [Skip Intro, Skip Any Cutscene, and Cheats](https://github.com/sciaschi/CBFD-Recompiled#mods) | Upstream provides `.nrm` function patches and hooks. The iOS build intentionally excludes LiveRecomp and runtime code patching. Selected features would need an ahead-of-time integration and individual gameplay/save checks. No `.nrm` importer is exposed. |
| [RT64 `.rtz` texture packs](https://github.com/sciaschi/CBFD-Recompiled#texture-packs) | Promising asset-only route. The mobile renderer does not yet load replacement packs. It needs a bounded local importer, format validation, memory limits, and a verified compatible pack before enabling this UI. |
| [GLideN64 `.htc` conversion](https://github.com/sciaschi/CBFD-Recompiled#texture-packs) | Current desktop upstream documents conversion for RGBA8 packs and Rice hash matching. That newer pipeline is not automatically present in our pinned renderer. Compressed packs are not supported by that converter. |
| [4K Ultimate Texture Pack](https://github.com/GameBeast92/Conker-s-Bad-Fur-Day-4k-Ultimate-Texture-Pack) | The author describes it as work in progress, approximately 30% complete. Its README does not establish SquirrelPad/RT64 compatibility. No pack was downloaded or bundled. |
| Widescreen / high-frame-rate presentation | Upstream reports pause-background cropping and animation/camera artifacts. Keep original aspect and timing until mobile scene-specific checks pass. |
| Asset-only ROM hacks | Current desktop upstream has validation for these. SquirrelPad still validates the exact supported original US ROM; do not bypass the checksum. |

The next useful mod milestone is a verified, optional RT64 texture pack. A
working import, a reliable unload/reset, and measured memory usage are required
before calling it supported. No game assets or third-party texture packs are
included in this repository.
