# Settings and enhancements goal loop — October 7, 2026

## Goal and exit checks

Refine the settings into the launcher's acorn/woodland identity, add KartPad-style
project/support links, research Conker mods, and ship useful renderer options
that can be verified in this mobile build. This is a bounded product pass, not
a claim of full-game acceptance under the broader GOAL_LOOP document.

1. Implement the theme, About links, and supported rendering controls.
2. Build, inspect screenshots, exercise settings and the renderer, and repair findings.
3. Verify the revised build on the attached iPad; record remaining compatibility limits.

## Iterations

- Replaced blue/navy settings with forest surfaces, amber actions, rounded type,
  subtle woodland header art, and restrained card borders. Kept native controls
  and the existing pause/resume, layout editor, audio, and controller actions.
- Added a linked SquirrelPad identity, GitHub/source, issue, release, and upstream
  credit links. KartPad references: `apple/ios/KartPadRuntimeOverlayHost.mm`
  (release and issue destinations), plus the existing grouped runtime menu.
- Added saved 1×/2×/3× internal resolution, Pixel/Smooth/Crisp presentation, and
  N64 three-point versus bilinear texture filtering. Restoring Balanced resets
  only these settings. Swift publishes a validated atomic selection; the renderer
  applies it before its next display list, using RT64's synchronized configuration
  update. Resolution changes discard incompatible framebuffers.
- Replaced the magnified 240×135-point surface with the available display area.
  RT64 retains the original aspect ratio and game timing. The render surface is
  explicitly excluded from touch hit testing.
- Visual review caught the long Enhancements sidebar label wrapping. Increased
  its available width and kept labels on one line with bounded text scaling.
- Source review caught misleading wording about the texture toggle: RT64 uses
  bilinear filtering when three-point filtering is off. Corrected the UI and docs.

## Verification

- Final Release builds passed for both `iphoneos` and `iphonesimulator`.
- Both package audits passed: 30 files, 24 notices. Existing patch tests: 3 passed.
- Native bridge harness checked all 18 supported combinations, out-of-range
  fallback, and 100,000 concurrent reads against alternating complete selections.
- iPad Simulator: settings open before and during gameplay; 3× and texture choice
  survive an in-place reinstall/relaunch; 1×/Pixel and 3×/Crisp show the expected
  visible sharpness difference; Restore Balanced returns to 2×/Crisp/three-point.
- SquirrelPad's GitHub row opened Safari. The repository remains private, so an
  unauthenticated browser receives GitHub's 404 page. No visibility was changed.
- Physical M2 iPad Pro / iPadOS 27.0.1: installed over the existing app after
  backing up Documents and Library and verifying a second readback (21 files).
  Code signature passed deep/strict verification. The retained ROM was found.
  Viewed launcher, General, Enhancements, About, and in-game pause menu through
  Device Hub. 3× rendered the opening; restoring Balanced while paused produced
  a logged live change back to 2× and resumed rendering. The earlier remote
  in-game menu failure did not reproduce in this build.
- iPhone Simulator build/launch passed, but Device Hub taps did not activate its
  launcher buttons in this pass, including after a targeted simulator restart.
  A process sample showed the main thread idle in its run loop. This does not
  establish the cause or phone interaction acceptance; compact UI interaction
  verification remains open. No other simulator was restarted.

Local evidence is under ignored `work/settings-enhancements/`: build/audit logs,
renderer logs, before/update backups, harness, and captures. Representative
settings captures are in `docs/screenshots/ipad-{enhancements,about}.jpg`.

Unsigned executable SHA-256:

- Simulator: `5bb157568d9e375568b48392464738ba6a304ba2047550ff66b1747d496cc532`
- Device: `d2231effac79ed16a08252e5304fe8a6b8aadb4c769613a66506db6d2cffd1f8`

## Remaining work

[Enhancement compatibility](ENHANCEMENTS.md) records the researched upstream
mods, `.rtz` packs, `.htc` conversion, and ROM hacks. No unsupported mod importer
or game assets were added. A validated texture-pack loader is a future milestone.
Full-story play, sustained device performance/thermals, and save/audio acceptance
remain separate gates. Source and the private hardware test build are the outputs
of this pass; there is no public app release.
