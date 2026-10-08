# Release readiness

Updated 2026-10-08. SquirrelPad is an experimental personal build. Public access
is not live: the source repository is private and has no recipe release.

The alpha's scope is the existing game, native Apple controls/settings, local
saves, resolution/filter options, optional static mods, and optional 2D HD Icons.
The incomplete broader HD texture pack is excluded. Additional camera/HUD/assist
features are not release requirements; their disposition is in [UPSTREAM.md](UPSTREAM.md).

## Closeout checks

| Area | Evidence and next action |
| --- | --- |
| Source patch updates | The installer now accepts known earlier patch-stack prefixes, while preserving unknown local edits. Native and patch regressions pass. |
| Music | V0.1.5 sequence-player fixes backported. State-machine regression passes; specific bar/dragon/game-over playback checks remain open. |
| Builds | Current Simulator build and bundle audit pass. Final device build and PadMint run are being recorded below. |
| Physical device | Previous signed build installed with material app data preserved. Sustained play, controller feel, audio routes and progressed-save reloads remain open. |
| Textures | Previous Simulator run verified all 403 HD Icons entries and live on/off. Physical-device result will be recorded separately. |
| Public availability | Publish source and recipe/checksums only, then add the catalog entry and verify unauthenticated download/build. Never publish the personal IPA or private generated game code. |

## Release scope and remaining acceptance

A bounded hardware check needs normal controls, pause/resume, a progressed save
and cold reload, sleep/wake, and HD Icons on/off. It does not require claiming
full-story compatibility. Until that pass is complete, describe builds as an
experimental alpha with the limits above.

Release assets are the versioned copy of `padmint.json` and `SHA256SUMS`.
The local catalog entry is in `../padforge/catalog/squirrelpad.json`; its null
`manifest` is intentional because PadMint reads the recipe from a release.
It is not evidence of a published catalog entry. Source publication is a separate
visibility change, followed by a recipe release and catalog readback.

## Verification record

Private logs and artifacts are under `work/release-readiness/`. Final results
are recorded here after verification, not inferred from an older build.
