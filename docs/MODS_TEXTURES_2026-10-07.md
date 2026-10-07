# Upstream mods and texture packs: verification loop

## Goal and exit checks

Add useful upstream mods and a working texture-pack importer to the existing
native app. Verify actual game effects, live enable/disable, persistence,
malformed-input rejection, and retained player data. Keep the implementation
compiled ahead of time and preserve the pinned upstream source.

## Delivered

- Static adaptations of upstream `mods/cheats` and `mods/skip_cutscenes` from
  Conker commit `c55359c579448fe5c212faf4bb5c2415d6ec7fa8`.
- Recompiler hooks applied through the replayable patch stack. The original
  skip routine executes unchanged when the option is off. No generated game
  functions or ROM bytes were committed; no LiveRecomp or `.nrm` loader enabled.
- Acorn-themed Enhancements cards for cutscene skipping, protected-scene override,
  infinite health, nine lives, full wallet, and Turn Off All Mods. Defaults off.
- Files-based RT64 PNG pack import with archive/image limits, full image decoding
  during validation, persistent selection, live enable/disable, and matching status.
  Import work runs off the main thread; RT64 changes run on the renderer thread.
- Existing RT64 archive reader handles pack data directly. No extraction or code
  execution. Obsolete imported copies are collected on the next launch so a
  paused renderer can retain its mapped archive safely.

## Upstream pack used

[ConkerBFDReloaded HD Icons v1.3.2](https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases/tag/v1.3.0),
19,512,187 bytes, 403 explicit RT64 hash-v5 PNG replacements. Pack attribution:
dahmedvall95; modified GameBeast92 artwork, CC BY 4.0 according to the pack's
LICENSE.txt. Downloaded only into ignored local test storage and app containers.
No texture archive, extracted artwork, ROM, save, or compiled app is committed.

## Results

| Check | Result |
| --- | --- |
| Import through Files | Imported all 403 entries and displayed the chosen pack name. |
| In-game texture effect | HD menu title and text visibly sharpened; original appearance returned after disabling. Re-enabling during Hungover applied HD pause artwork. |
| Renderer evidence | Logged pack loaded, matching replacements (including 32 at the file menu), unload with zero replacements, then reload. Counts are cached matches, not a count of every texture currently visible. |
| Persistence | Imported selection and enabled state survived app termination, replacement install, and relaunch. |
| Health/lives/wallet | In playable Hungover, runtime logged health 3→6, lives 3→9, cash 0→9999. The pause screen visibly showed six chocolate pieces and $9999. |
| Cutscene skipping | On a temporary fresh save, Start skipped scene 0x21. L skipped throne room 0x18 and hangover 0x29 with protected scenes enabled; playable Hungover followed. |
| Off/reset | UI reset returned every mod switch to off; native regression verifies disabled hooks preserve RAM and the original skip path. |
| Invalid packs | Native parser tests reject malformed/missing JSON, missing texture, corrupt PNG, unsafe path, unsupported hash version, and mip cache. A generated one-pixel valid pack passes. |
| Source replay | Re-running setup-source.sh produced zero changed source files. |
| Build/package | Release builds and audit passed for both mobile SDKs; each has 30 files and 24 notices, with no SimulatorInputProbe or excluded mod-loader symbols. |
| Hardware install | Signed, signature-verified, and installed in place on the attached M2 iPad Pro. Launched to the native launcher. |
| Data preservation | Physical Documents/Library were backed up and independently read back before install. All nine material files matched after install; iPadOS discarded four SplashBoard snapshots. Original simulator save and backup were restored byte-for-byte after cheat/cutscene testing. |

The first simulator run exposed an address-extension bug in the new skip adapter.
It was fixed by using signed MIPS addresses for `MEM_*` accesses, then checked by
native RAM tests and the real scene skips above before the physical install.

Hardware texture gameplay remains a separate check: Device Hub's coordinate
mapping stopped reaching the physical screen reliably during this pass. The
updated app is installed and `HD-Icons-v1.3.2.rtz` is in its Files folder, ready to
import. Save-changing cheats remain off on the iPad. Simulator verification is
not a claim of full-game compatibility, hardware performance, or all-pack support.

## Reproduce and evidence

- `python3 -m unittest discover -s tests -v`: five tests passed, including static
  mod RAM checks and eight archive fixtures. Native checks require the pinned
  headers; the texture test also needs the local macOS RT64 archive and otherwise
  reports a skip.
- Build through `scripts/build-personal.py`; the new recompiler hooks are part of
  the normal tracked-input ledger. Package through the existing private workflow.
- Ignored evidence directory: `work/mods-textures/`.
- `sim-console-2.log`: live imports, unload/reload, and the three stat changes.
- `sim-cutscenes.log`: successful skip records for scenes 0x21, 0x18, and 0x29.
- `hd-game-menu.png` / `original-game-menu.png`: actual on/off comparison.
- `hd-cheats-pause.png`: gameplay stats and HD pause artwork.
- `python-tests.log`, `validation-results.json`, `replay-check.log`, package audits,
  signed app, device install result, and before/readback/after-install hashes.
- Test saves are retained privately in `simulator-after-cheats-saves/` and
  `simulator-cutscene-test-saves/`; the pre-test save is restored in the simulator.

No release was published and repository visibility was not changed.
