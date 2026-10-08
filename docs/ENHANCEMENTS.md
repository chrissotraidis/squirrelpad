# Enhancements

Open **••• → Enhancements**. Settings persist and apply when you play or resume.

## Picture

| Option | What it does |
| --- | --- |
| 1× / 2× / 3× resolution | Renders geometry at the original resolution or two/three times each dimension. Start with 2× Balanced. |
| Pixel / Smooth / Crisp | Changes how the rendered picture is scaled to the display. |
| N64 texture filtering | Original three-point filtering, or smoother bilinear filtering when switched off. |

**Restore Balanced Settings** resets these three choices without changing mods,
texture packs, or saves. Original aspect ratio and game timing are retained.

## Upstream mods

These are compiled-in adaptations of [sciaschi's Cheats and Skip Any Cutscene](https://github.com/sciaschi/CBFD-Recompiled/tree/c55359c579448fe5c212faf4bb5c2415d6ec7fa8/mods).
All default to off. There is no runtime code generation or `.nrm` importer.

| Option | Behavior |
| --- | --- |
| Skip unseen cutscenes | L skips eligible scenes, including ones you have not watched. The opening uses Start after its initial timing gate. |
| Also skip protected scenes | Optional, experimental override for scripted scenes. The opening throne-room and hangover transitions were tested; other scenes may depend on their scripts completing. |
| Infinite health | Refills health to six while alive; does not resurrect Conker after health reaches zero. |
| Nine lives | Refills the life counter to nine. |
| Full wallet | Refills cash to $9,999. |

**Turn Off All Mods** stops these effects. Lives and cash can be written into the
normal game save; turning a mod off does not restore previous saved values.

## Texture packs

1. Download an RT64 `.rtz` pack to Files.
2. Choose **Import Texture Pack** in Enhancements.
3. Resume. The status shows how many cached game textures matched replacements.
4. Turn **Use imported textures** off to restore original artwork. Import another
   pack to replace the selection. One pack is active at a time.

The [HD Icons v1.3.2 pack](https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases/tag/v1.3.0)
was tested in the iPadOS 27 Simulator: all 403 entries imported, menu/HUD/text
replacements rendered, and live disable/re-enable restored/reapplied them.
This is a sharper 2D artwork pack, not a complete environment retexture.
Pack by **dahmedvall95**, using modified artwork by **GameBeast92** from the
[4K Ultimate Texture Pack](https://github.com/GameBeast92/Conker-s-Bad-Fur-Day-4k-Ultimate-Texture-Pack).
The pack's LICENSE.txt identifies CC BY 4.0 and describes the modifications.
Download packs separately; neither these textures nor a game ROM are bundled.

Supported imports have `rt64.json` at the archive root, configuration version 3,
RT64 hash version 5, explicit texture paths/hashes, and PNG replacements. Limits:
256 MiB archive, 4,096 mapped textures, 4,096 pixels per image dimension,
64 million decoded pixels across the mappings (256 MiB RGBA before mipmaps).
The importer also bounds entry counts and decompressed bytes, decodes every
mapped image before accepting the pack, and rejects unsafe paths and missing
textures. Archives are read directly, never extracted or executed. A rejected
import keeps the previous selection.

DDS textures, prebuilt mip caches, `.htc`/Rice packs, arbitrary `.nrm` mods,
asset-only ROM hacks, and automatic downloads are not supported. Desktop support
for these features does not establish compatibility with this pinned iOS build.
The incomplete full 4K Ultimate pack is excluded from the release scope. It is
not bundled, recommended for installation, or treated as a release requirement.

## Compatibility fixes

The mobile build backports V0.1.5's music sequence-player fixes: a song's stop
wait yields to the audio thread, and a queued start is not mistaken for a finished
song. These are automatic fixes, not cheat switches. Native regressions verify
the state transitions; specific late-game audio scenes still need playback
verification. See [upstream review](UPSTREAM.md) for the remaining migration.

See [the verification record](MODS_TEXTURES_2026-10-07.md) for the exact test scope.
