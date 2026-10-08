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
| Source patch updates | The installer now accepts known earlier patch-stack prefixes, while preserving unknown local edits. Seven native and patch regression tests pass. |
| Music | V0.1.5 sequence-player fixes backported. State-machine regression passes; specific bar/dragon/game-over playback checks remain open. |
| Builds | Both SDK builds and bundle audits pass (30 files, 24 notices). The actual PadMint runner completed a personal IPA; 13 PadMint manifest/gate tests pass. |
| Physical device | Updated signed build installed. Independent before/after readbacks preserve 11 material files. Apple initially required online developer verification; launch succeeded on retry. Sustained play, controller feel, audio routes and progressed-save reloads remain open. |
| Textures | The physical iPad imported all 403 entries through Files and visibly rendered sharper menu text before the update. The updated build retained the pack; disabling it restored original menu artwork and cleared cached replacements. Re-enabling restored the sharper artwork and 32 matching cached replacements. |
| Public availability | Publish source and recipe/checksums only, then add the catalog entry and verify unauthenticated download/build. Never publish the personal IPA or private generated game code. |

## Release scope and remaining acceptance

A bounded hardware check needs normal controls, pause/resume, a progressed save
and cold reload, and sleep/wake. HD Icons on/off passed on the physical iPad. It does not require claiming
full-story compatibility. Until that pass is complete, describe builds as an
experimental alpha with the limits above.

Release assets are the versioned copy of `padmint.json` and `SHA256SUMS`.
The local catalog entry is in `../padforge/catalog/squirrelpad.json`; its null
`manifest` is intentional because PadMint reads the recipe from a release.
It is not evidence of a published catalog entry. Source publication is a separate
visibility change, followed by a recipe release and catalog readback.

## Verification record

Private logs and artifacts are under `work/release-readiness/`.

- Simulator executable: `6bf176b5d91d08f74bf8b80d7d9c10077889374bc65831284383c8649c4b317b`.
- Device executable before signing: `a2cc354c6733e5aecc58c4138bd5e7b1ee75594b8071ba0cb9bd6b0eb351bd8f`.
- PadMint build at `1b5d902c38969622b91e79230678aaed972fa06e`: completed, personal-only;
  record `build/padmint/fadc658b52fd2460/runs/4549be59ae38494eab4f52761c9e86e3/record.json`.
- Recipe and source-review archive passed both `padmint audit` and the reference
  release gate. This does not make the personal IPA publishable.
- Local catalog/recipe contract: zero problems, with release fetching substituted
  by the candidate recipe. The live whole-catalog audit still reports SquirrelPad's
  absent release and an unrelated BlueWake help-link mismatch. Neither is hidden
  as a passing public-catalog check.
- Updated Simulator app cold-started, retained the pack and GAME1, and loaded the
  first playable field, paused, and resumed. This is retained-save smoke coverage, not progressed-save
  acceptance or validation of the specific late-game music reports.


- Physical DeviceHub input opened native settings and controlled texture switching,
  but remote A/Start gestures did not advance GAME1. Direct touch/controller
  gameplay acceptance is still open; this is not recorded as a passing input test.
