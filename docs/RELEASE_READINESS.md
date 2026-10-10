# Release readiness

Updated 2026-10-11. **v0.1.1 is an experimental source-and-recipe alpha.**
Public assets are `SquirrelPad-v0.1.1-padmint.json` and `SHA256SUMS`.
Players supply their own supported US ROM and build a personal IPA on an
Apple Silicon Mac. Personal IPAs and generated game code are never release assets.

## v0.1.1

The recipe now runs `build-personal.py` with `python3`, the Python 3.11+ that
PadMint checks. v0.1.0 ran it with PadMint's own Python, Apple's 3.9 when
`PadMint.command` starts PadMint, so the build stopped at
`hashlib.file_digest` although every check passed
([padmint#142](https://github.com/chrissotraidis/padmint/issues/142)).
PadMint 0.4.13 run with Apple Python 3.9.6 and Xcode 27.0 reproduced that
failure with v0.1.0. With this recipe it built a complete personal IPA (0.1.1,
build 2) in 655 seconds from a fresh checkout and PadMint folder without a
build cache; the publication gate passed. The game code is unchanged, so the
v0.1.0 device checks below still describe it; this IPA was not reinstalled.

## What is included

The existing game, native launcher/settings, customizable touch controls,
controller bindings and automatic touch handoff, local EEPROM saves, 1×–3×
rendering, optional picture effects, camera/audio/accessibility mods, and
Files-based RT64 packs. The optional HD Icons pack covers 2D artwork only.
Incomplete broader HD packs are excluded; community projects are tracked in
[UPSTREAM.md](UPSTREAM.md).

## Recorded checks

- Nine native, Swift controller and source-patch regressions pass. Controller
  tests cover buttons/sticks, polling when callbacks are missing, pause/resume,
  backgrounding, disconnect/reconnect and stable player-one selection.
- Device and Simulator Release builds and package audits pass: 32 files,
  26 notices, normal builds exclude the input probe.
- The final controller build was installed in place on the M2 iPad Pro.
  Independent backups matched 23 files; all nine core data files matched after
  installation, including GAME2. The user accepted the updated build.
- The physical iPad imported all 403 HD Icons entries through Files. Switching
  the pack off restored the original artwork; switching it on restored the
  sharper menu text. Pack data is not committed or bundled.
- A progressed GAME2 test save was injected with readback verification and
  loaded in the Simulator. This is not proof of hardware save progression.
- The public v0.1.0 source and recipe were fetched anonymously into a fresh
  PadMint data folder. The complete personal IPA build finished in 293 seconds
  with no supplied build cache. Its executable SHA-256 matches the tested iPad
  build: `6711f0f3a2d56809bb266c34b727a335bc415047fbcd3479128c2efb97a86e8d`.
- PadMint 0.4.11 includes SquirrelPad. All 294 PadMint tests, eight cross-platform
  CI jobs, and the full catalog audit pass. Windows CI and local release packages
  match byte-for-byte. Recipe and checksum downloads match the audited assets.

## Remaining compatibility limits

Full-story compatibility, sustained performance across devices, representative
late-game music, hardware progressed-save cold reload, and interruption/audio
routes are not fully qualified. Xbox reconnection, physical rumble, and HDMI
picture/audio require specific accessory results before they can be advertised
as verified. The user's acceptance does not establish every individual check.
iOS 17 is the deployment minimum, not a tested-device guarantee.

These limits belong in the alpha's documentation and issue reports. They are
not a claim of full-game or all-device certification. See
[controller/display checks](CONTROLLERS_DISPLAYS.md) and the historical
[acceptance matrix](ACCEPTANCE.md).

## Publication checks

Audit the source archive, reachable Git-history file contents, recipe and
checksums before publication. Publish no personal builds. PadMint's catalog must
pin the reviewed SquirrelPad revision, and its released packages must contain
that entry. Verify anonymous recipe/checksum/source downloads and a personal
build through the released PadMint package. Private verification output stays
under `work/public-readiness/` and `work/controller-handoff/`.
