# Native enhancement integration — 2026-10-08

SquirrelPad now compiles selected ConkerBFDReloaded v1.3.1 improvements into the
Apple app. Source: `90a014dbac5019c20a1b7a820ea16a1f0553052f`. The engine stays
on the existing `sources.lock.json` pin; this is not a V0.1.5 engine promotion.

## Implemented

- Right-stick orbit with upstream collision routines, speed/inversion and aim hooks.
- Optional aiming crosshair, calibrated upstream for barn knives.
- Music, effects and streamed-speech volumes, separate from master volume.
- Successful-save confirmation, animated cash counter and persistent health HUD.
- Intro skipping, 1.2-second hold-to-skip, and visible hold progress.
- Toggle look/crouch, hold-to-walk, underwater pitch inversion, longer tail spin,
  ledge assistance and reduced motion blur.
- Native settings persistence, pause/input reset, and touch-button accessibility activation. Short taps are retained until the
  next game input poll, then released, instead of being lost between frames.

All assists default off. Original inverted vertical stick aiming and 100% audio
mix remain the defaults. No texture artwork, game data, desktop binaries or
runtime code loader were added. Two exact upstream MIT notices are bundled.

## Checks

Eight native/patch tests pass. The save-writer fault-injection check also passes:
short writes preserve the live save and backup, and retry succeeds. The new RAM fixture links the real bridge, input,
free-camera, aim, crosshair, audio, intro, accessibility and ledge modules.
It covers toggle edges and pause resets, diagonal walking limits, underwater-only
inversion, tail-spin restoration, descending/once-per-fall ledge masks, camera
axis limits, duplicate C-button suppression, independent voice/stream volumes,
clamping, hold timing across multiple cutscene slots, disabled skip behavior,
motion-blur suppression and the save completion counter. Generated room-change
and collision functions deliberately assert if called in that fixture; their
presence is not simulated gameplay coverage.

Simulator and iphoneos Release builds pass. Audits cover 32 files and 26 notices,
correct ARM64/SDK identity, pinned dependency revisions and excluded probe/JIT
symbols. Test-only virtual input is disabled in the installed device build and
final simulator build.

The iPadOS 27 simulator reached the file menu with automatic intro skipping,
loaded the preserved GAME1 slot (0:06:03), and reached the first playable area.
The health and animated cash HUD rendered. A two-second right-stick test orbited
from behind Conker to the front; neutral input stopped the orbit. Settings
changes persisted across an app restart. A private simulator input probe was
used for sustained controller input; this is not a physical controller test.

A signed build was installed in place on the attached M2 iPad running iPadOS
27.0.1. Documents and Library were backed up and independently read back before
installation. All 11 material files matched after installation, including the
ROM, EEPROM saves, imported HD Icons pack and preferences. The app launched and
its new settings were inspected on hardware. After the final skip-state fix,
a second in-place install preserved all eight core files against the original
ROM/save/pack backup and a fresh, independently read-back preference backup.
The final short-touch fix was installed after a fresh full backup and independent
readback. All eight core files again matched after installation. OS caches,
SplashBoard and Saved Application State are excluded from core-file comparisons;
they change during ordinary launches and are preserved in the full backups.
On this final build, a remote touch of A advanced the physical iPad from the
GAME1 selection to its New Game submenu. This closes the earlier missed-tap
smoke failure; it does not establish sustained gameplay or controller acceptance.

## Still open

- Real-controller camera feel and collision coverage across more rooms.
- Live weapon crosshair calibration beyond the upstream barn-knife case.
- Physical swimming, ledge, tail-spin and per-category audio acceptance.
- A visible save-confirmation check tied to a gameplay save, and sustained story play.
- The full engine/renderer migration, including widescreen and interpolation.

The incomplete broader HD pack remains excluded. These checks establish a
working local integration and bounded smoke tests, not full-game release approval.
Private build logs, package audits, input traces and preserved app data are in
`work/enhancements-loop/`. Do not publish that directory or its personal apps.
