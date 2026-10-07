# Main Mac build and PadMint integration, 2026-10-07

The main Mac rebuilt the pinned sources using Xcode 27.0 and the supported
US ROM. Build/source revision: `c28a1852198a957ca4d9961700e8d6c9e1cbab46`.
Later documentation-only commits do not change these binary identities.

- The local macOS comparison app launched, accepted Start Game, and visibly
  rendered Conker's opening sequence. This is startup/render evidence, not
  a full gameplay, audio, or save-fidelity acceptance pass.
- Local PadMint 0.4.9 ran the actual repository recipe through `padmint build`.
  Its record finished with `status: completed`, exit code 0, valid ARM64 iOS IPA
  structure, and a SwiftUI app lifecycle linked against SDK 27.0.
- Both mobile SDK builds passed `scripts/audit-app.py`: 30 files, 24 matching
  dependency notices, no forbidden runtime/probe symbols, and no private
  filenames, home paths, or symlinks detected by that scoped audit.
- The device IPA contains the acorn AppIcon and both device families `[1, 2]`.
  It is unsigned, personal-only, and contains translated game code.
- Three synthetic patch-stack regressions passed: overlapping patches on a
  fresh checkout, repeat application, and preservation on bad patches or local
  edits. PadMint's 13 manifest/gate tests and catalog listing test passed.

| Artifact | SHA-256 |
| --- | --- |
| macOS executable | `daf3c390913d71ed25389e0f072a44754167e8aad37f23d2c0d8b326f0f1a9a5` |
| iPhone/iPad executable | `fc5835308492397764e1c7486f98716a13663a06324eb692350abd16f0ca28aa` |
| Simulator executable | `3b3b658823745c101840572bb8c3bad828c359e47826e3b945932d96477f9c65` |
| Personal IPA | `9b7640a0467b2457b0b6c2fc95372cd9ac939e551930e6f5be637774e14264a8` |

Private local evidence lives under ignored `work/` and `build/padmint/`.
The convenient IPA is `work/SquirrelPad.ipa`; normal SDK app bundles are under
`work/build-app-{iphoneos,iphonesimulator}/Release-{sdk}/SquirrelPad.app`.
The Mac comparison app is in `work/CBFD-Recompiled/host/build-macos-metal/`.

## Publication status

The recipe is in SquirrelPad. A matching catalog entry is prepared in the local
PadMint checkout (`catalog/squirrelpad.json`) with iOS on Apple Silicon marked
experimental and the ROM required at build time. Public catalog delivery is
pending an owner decision about this private repository's visibility and a
source/recipe release. No personal binaries or ROMs were published.

The full catalog audit reported two findings: SquirrelPad has no reachable
published recipe yet, and BlueWake's existing `#getting-started` help anchor is
missing from its released README. The latter is outside this change.

Physical-device installation, sustained play, audio quality, and in-level save
fidelity remain open. See [the acceptance matrix](ACCEPTANCE.md).
