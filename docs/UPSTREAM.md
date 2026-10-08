# Upstream review

Reviewed 2026-10-08. The working source remains pinned in `sources.lock.json`.
The setup script reads that lock rather than maintaining a second revision.

## Selected candidate

[CBFD-Recompiled V0.1.5](https://github.com/sciaschi/CBFD-Recompiled/releases/tag/V0.1.5),
commit `5ea55d149eef2ff1ea36718013025c5e67619db9`, is 108 commits ahead of our
`c55359c579448fe5c212faf4bb5c2415d6ec7fa8` base. It is a migration candidate,
not the current mobile engine.

An ordered source-patch preflight found conflicts in `conker-host.patch`,
`conker-macos-window-init.patch`, `conker-mobile-audio.patch`,
`conker-mobile-lifecycle.patch`, `conker-mobile-mods.patch`, and the new music
backport. Later failures may depend on earlier ones. This ran in a temporary
source tree without changing the working engine. Private result:
`work/release-readiness/upstream-preflight.json`.

The RT64 and runtime patch stages applied in that preflight, but applying patches
is not a successful compile, Metal render, or gameplay test. Promotion requires
rebasing the Apple host changes, removing the now-redundant music backport,
regenerating private code, rebuilding both SDKs, and checking saved-game reloads,
scene transitions and rendering on the iPad. Keep runtime code generation off.

## Decisions

| Change | Decision |
| --- | --- |
| Song transition/reload fixes | Backported from V0.1.5 `host/src/ultra_extras.cpp` into `mobile_music.cpp`, with its five static hooks. Native tests cover yielding, bounded waits, queued starts, independent players, stop/acknowledgement and timeout. Specific reported game scenes remain unverified. |
| Lighting, reflections and camera-cut fixes | Prioritize with the full renderer migration. Do not advertise desktop fixes as already present on Metal. |
| Right-stick free camera and aiming | Retain as the next optional control improvement. Requires bridging Apple controller input, preserving C-buttons during aiming/cutscenes, and collision testing. |
| Widescreen and smooth presentation | Defer until the renderer migration passes. Upstream includes coupled frustum, backdrop-allocation and interpolation fixes; flipping an aspect/FPS setting alone is insufficient. Game logic remains 30 Hz. |
| Crosshair, save indicator, separate audio volumes and ledge assists | Reviewed in [Reloaded v1.3.1](https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases/tag/v1.3.1). Optional later ports, not requirements or claims for this alpha. |
| HD Icons v1.3.2 | Separate optional 2D pack; never bundled. Verify mobile import and on/off behavior. |
| Broader 4K textures | Excluded: incomplete upstream work, outside this release scope. |
| New levels/campaigns | No validated mobile-compatible candidate identified. No promise of additional campaign content. |

The MIT notice for the existing CBFD-Recompiled dependency also covers the music
backport. Its source attribution records the exact upstream commit. No Reloaded
code, new texture artwork, or desktop binaries were added.
