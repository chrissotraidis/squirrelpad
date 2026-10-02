# Developer-build acceptance

Updated 2026-10-02. **Incomplete: no full-story playability claim.**
This matrix preserves the full scope in [GOAL_LOOP.md](GOAL_LOOP.md).
The detailed dated record is [STATUS.md](STATUS.md); each passing check covers
only its stated scope.

## Current artifacts

| Artifact | Executable SHA-256 | Scope |
| --- | --- | --- |
| Earlier normal ARM64 Simulator app | `3e215625cafd772fbca0cca0c073337f34ede0104ce0059815c22a8f4b73e31c` | Probe excluded; earlier runtime evidence |
| Earlier unsigned ARM64 device app | `0ddc68be67679731ed766459e754e026913ae9c564a696e036756191783034d1` | Build and package checks; no signed install |
| Clean replay ARM64 Simulator app | `dd3771acd99d8a79e1c7e31733966cdfbd74053b1e24c34e049aa33ab973b936` | Probe excluded; iPhone 18.5 first field; fresh iPad 18.5 import/retention/menu smoke passed |
| Clean replay unsigned ARM64 device app | `f4dffb9dee2b0e3858427db782292a4b9de43f141139fa8a87e0b363805ebc80` | Independent build and package audit passed; no signed install |
| Diagnostic Simulator app | `b2c4386aa82a16bee11726b3b73efae8f9dc484a3bb83b2f40b2e15f5617ed87` | Opt-in controller investigation; not ordinary-touch acceptance |

Earlier normal bundles passed `scripts/audit-app.py` on 2026-10-02 against
`work/source-final-replay`: each has 30 files and 24 matching notices, correct
ARM64/SDK identity and no flagged private names/content, symlinks or excluded
runtime/probe symbols. Reports remain private under
`work/package-audit-20261002-{simulator,device}.json`.
The audit has limited content/signature checks; ROM-derived executable code
remains. See [SOURCE_BOUNDARY.md](SOURCE_BOUNDARY.md).

## Goal matrix

| Gate | Recorded evidence | Remaining acceptance |
| --- | --- | --- |
| G0 inputs | Pinned inputs, private ROM validation, tracked patches and independent source replay | Preserve those boundaries for every subsequent build/package |
| G1 macOS control | Native ARM64 build, intro, keyboard selection into first field; matched field audio comparison recorded | Sustained ordinary movement, music/SFX/voice qualification and meaningful save/cold reload |
| G2 mobile link | Both SDKs build the real core/audio/Metal renderer; current bundle audits pass | Reopen if a later source change breaks this closure |
| G3 Simulator integration | Both classes reached moving intro/first field; current build rejects invalid/wrong ROM without changing stored ROM/EEPROM | Complete same-build fresh-import and scene-fidelity matrix; retained-ROM launch is not fresh import |
| G4 sound/input | Ordinary Start/A pause/resume and menu return; diagnostic controller movement/camera/interaction/jump | Ordinary sustained/simultaneous touch and release; controller attach/remove on both classes; audible categories/quality; remaining compact-menu scrolling/reference behavior |
| G5 persistence/lifecycle | Current normal-build changed-volume cold relaunch passed on both 18.5 classes; background clock/audio recovery recorded; current short-write fix and first-field cold reload on both classes; diagnostic GAME2 tutorial payload restored | Two distinct progressed checkpoints/reloads on both classes; remaining interruption/memory-pressure cases; earlier-build evidence needs qualification for the final build |
| G6 gameplay | Diagnostic Birdy lesson/cure and tutorial reload; isolated jump shown by video | Full iPad story through ending, representative iPhone chapters, checkpoint reloads and demanding-scene timing/fidelity |
| G7 hardware | No physical-device acceptance | Blocked by input: iPad/iPhone and signing; eventual touch feel, controllers, audio routes, sleep/interruption and sustained play |
| G8 handoff | Independent replay recorded; current audits, notices and setup instructions | Fresh final source/tools/generation replay passed; clean host and both mobile SDK builds plus audits passed; final source/notice review remains; signed local install, completed final acceptance matrix; public distribution requires separate decision |

iOS 26.5 phone/tablet startup and UI checks were recorded with an earlier normal
build. They do not complete the current build's startup/input/save/lifecycle
matrix. Deployment target 17.0 is a build setting, not verified 17.0 execution.

## Next actions and external inputs

1. Qualify ordinary held input in a healthy normal iPad 18.5 Simulator:
   hold the blue stick off-center for two seconds, release, and observe movement
   and stopping. Repeat after menu open/close. Capture any failure before editing
   the input path. CUA's brief drag has not established this check.
2. Reach the green island/jump tutorial and a later checkpoint, save it, and cold
   reload it. The bounded river commands recorded on 2026-10-02 returned to the
   starting bank; they are not a successful route or a demonstrated port defect.
3. Establish the macOS ordinary gameplay/save control and continue the complete
   iPad route plus representative iPhone chapters. Do not count diagnostic
   controller actions as ordinary-touch proof.

Chris's immediate input is the brief manual **Simulator** hold/release
observation, because the available UI API exposes neither a timed hold nor
simultaneous touches. Signing and physical-device rows remain separate.
A compact Settings drag also failed in Apple’s native Settings control on
2026-10-02, while the native accessibility scroll action worked. Treat the
automated drag as unqualified; verify ordinary scrolling before changing
SquirrelPad’s gesture path. Audio tuning stays deferred until a specific audible
reproduction exists.

The clean replay on 2026-10-02 used `work/source-release-replay` and fresh
`-release-replay` renderer/app directories. All seven source pins and 127
generated files matched. Both audits have zero failures (30 files, 24 notices).
The real save-writer short-write/replacement/retry regression passed. iPhone
18.5 loaded GAME1 into the first field, paused/resumed with Start/A, restored
controls after Settings, and returned after Home with the same process. This
is a bounded regression check; older slider and diagnostic evidence retains
its original executable identity. The preserved iPad had an install/boot
stall; no device or save was erased. See the latest STATUS entry.

Fresh iPad 18.5 `0A04D7B6…` imported the verified ROM through Files, rendered
the intro, retained Continue Imported ROM across cold launch, and restored
controls after closing Settings. No fresh-iPad first-field claim. Both test
Simulators were shut down after this batch.

On the same clean-replay iPhone build, Simulator Device → Lock followed by
Home/unlock restored the same process, landscape controls and Start/A
pause/resume. Cold relaunch loaded GAME1 and the first field again. Queue
stop/start was logged; audible recovery and exact clock freeze were not
measured. Memory-warning injection was not run. The iPad equivalent remains
open; see the dated lock-recovery entry in STATUS.md.

Recovery update: old iPad `605FB671…` no longer has its app-data directory.
The independently preserved, checksum-valid GAME2 fixture was copied intact
into healthy iPad `0A04D7B6…` after backing up that destination's saves.
Normal build recognizes restored GAME1 metadata. GAME2 selection/reload is
pending a manual held-stick gesture; the Simulator is prepared at the room
selector. This is fixture restoration, not an in-place update acceptance.
