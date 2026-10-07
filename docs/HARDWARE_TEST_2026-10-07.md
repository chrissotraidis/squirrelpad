# Title, menu, and first hardware build

The launcher pairs Georgia Bold Italic for “Conker’s” with a condensed,
tracked “BAD FUR DAY” subtitle. Both are system fonts, with no downloaded font
dependency. The README launcher image reflects this version.

The menu retains the General / Controls / Audio / About sidebar, persistent
Resume button, and native controls. This iteration separates touch controls,
size and appearance, and controller bindings into distinct cards. Edit Touch
Layout is visible first, and the menu explains why it is unavailable before
gameplay. The header identifies the paused game; selected sidebar rows use a
subtle blue highlight. Existing bindings and session lifecycle are retained.
References: SpaghettiPad's Controls sidebar and touch settings, plus KartPad's
native grouped settings and layout-editor flow. This is pattern parity, not a
claim that SquirrelPad implements every setting from those projects.

## Hardware finding and fix

The initial signed build exited on the attached M2 iPad Pro with
`-[AGXG14GDevice location]: unrecognized selector`. Plume queried the macOS-only
`MTLDevice.location` selector on physical iOS. The existing Simulator branch
avoided this call, which explains why Simulator launch passed.

`plume-ios-device-type.patch` classifies physical iOS GPUs as integrated,
retains the Simulator virtual-device branch, and preserves macOS detection.
It is part of the normal pinned patch stack. Full stack replay and the three
patch-stack regression tests passed.

## Verification

- Both final mobile SDK builds and bundle audits passed: 30 files, 24 notices,
  no excluded-symbol or private-file findings. Signed device bundle verification
  passed with `codesign --verify --deep --strict`.
- Inspected title layout on iPad and iPhone Simulators. On iPad Simulator,
  checked Settings, Controls, transparency on/off, Audio, Done, Play, three-dot
  menu, and Edit Touch Layout / Done. No custom layout or binding was reset.
- Installed on the attached iPad Pro 12.9-inch (6th generation), iPadOS 27.0.1.
  There was no SquirrelPad installation before this task. Before replacing the
  first crashing build, Documents and Library were backed up; they contained
  only OS-generated caches/snapshots, with no imported ROM or saves.
- The repaired build visibly launched. The user's local ROM was copied into
  this app's Documents folder and imported through the normal Files picker.
  The opening animation and GAME1 selection screen rendered. Logs recorded
  game-renderer initialization and nonzero audio PCM consumption, which does
  not establish audible quality.
- Device Hub remote taps did not produce a visible response from the in-game
  menu or A button after startup. Direct on-device input confirmation is still
  needed to distinguish an app issue from remote-input limitations. Sustained
  gameplay, controller input, audio listening, and save fidelity remain open.

| Local artifact | SHA-256 |
| --- | --- |
| Simulator executable | `e794e5846cb84489d8a1d5935ba31f4a6b26f9eefef18ed17715190a7f3d13d7` |
| Unsigned device executable | `a355461c7f77c09d7f000031ee1c4b43dd677da832f66983762b500b04094269` |
| Installed signed executable | `b05b7df6c2fdf156eeab2b32d4ca5aa5b1e342172ba1c54242048b4656120517` |
| Personal signed IPA | `4410a141e9558fc0bb4d42f86be4fa4a48a3bd35a303d3341fc77e8cd0658b20` |

The signed package is `work/SquirrelPad-hardware-test.ipa`. Logs, signatures,
container backup, device inventory, and build reports remain local under
`work/title-menu-hardware/`. No personal binary or game input is published.
