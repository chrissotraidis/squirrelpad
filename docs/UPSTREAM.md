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

## Texture projects

Last checked: **2026-10-08**. SquirrelPad tracks other creators' work; producing
or completing replacement textures is outside this project's scope. Packs are
downloaded separately and are never bundled or automatically updated.

| Project | Tracked version / scope | SquirrelPad status | Revisit when |
| --- | --- | --- | --- |
| [Reloaded HD Icons](https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases/tag/v1.3.0) by dahmedvall95 | HD Icons v1.3.2; 403 menu, HUD and text replacements. The pack version differs from the hosting release tag. | Optional import verified on the physical iPad; see [setup and credits](ENHANCEMENTS.md#texture-packs). | A new HD Icons asset is published on the [release page](https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases). |
| [4K Ultimate Texture Pack](https://github.com/GameBeast92/Conker-s-Bad-Fur-Day-4k-Ultimate-Texture-Pack) by GameBeast92 | Broader game artwork; upstream still describes it as about 30% complete. Also the artwork source credited by HD Icons. | Tracked only. Incomplete packs are excluded from release recommendations; mobile compatibility is unverified. | Upstream reports complete coverage and provides a candidate compatible with our importer. |

For each candidate update, record its version, asset checksum, coverage and
license/credits, then check the [import requirements](ENHANCEMENTS.md#texture-packs).
Verify import, visible replacements, live off/on and persistence on iPad before
changing the supported version here. A desktop release alone is not mobile
acceptance. This is a review record, not an automatic download service.

## Decisions

| Change | Decision |
| --- | --- |
| Song transition/reload fixes | Backported from V0.1.5 `host/src/ultra_extras.cpp` into `mobile_music.cpp`, with its five static hooks. Native tests cover yielding, bounded waits, queued starts, independent players, stop/acknowledgement and timeout. Specific reported game scenes remain unverified. |
| Lighting, reflections and camera-cut fixes | Prioritize with the full renderer migration. Do not advertise desktop fixes as already present on Metal. |
| Right-stick free camera and aiming | Ported from Reloaded v1.3.1 with Apple right-stick input, speed/inversion, collision routines, and aim hooks. Digital right-stick C input is suppressed during orbit/aim; touch C-buttons remain. Simulator orbit was observed; broader collision and physical-controller coverage remain open. |
| Widescreen and smooth presentation | Defer until the renderer migration passes. Upstream includes coupled frustum, backdrop-allocation and interpolation fixes; flipping an aspect/FPS setting alone is insufficient. Game logic remains 30 Hz. |
| Crosshair, save indicator, separate audio volumes and ledge assists | Reviewed in [Reloaded v1.3.1](https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases/tag/v1.3.1). Now ported alongside intro skipping, hold-to-skip, cash/health HUD, toggle controls, walking/swimming, longer spin and reduced motion blur. All optional; see the [integration checks](ENHANCEMENTS_2026-10-08.md). |
| HD Icons v1.3.2 | Separate optional 2D pack; never bundled. Files import, persistence through update, and live off/on passed on the physical iPad. |
| Broader 4K textures | Excluded: incomplete upstream work, outside this release scope. |
| New levels/campaigns | No validated mobile-compatible candidate identified. No promise of additional campaign content. |

The music backport includes the upstream MIT text in
`Support/Conker/UPSTREAM_LICENSE.txt`; the app already bundles that dependency
notice. Source attribution records the exact upstream commit. Reloaded source adaptations retain their exact commit attribution and both MIT
notices in `Support/Conker/Reloaded`; both notices are bundled and audited.
No new texture artwork or desktop binaries were added.
