# SquirrelPad evidence ledger

Updated 2026-09-27. Work the lowest unmet goal in [GOAL_LOOP.md](GOAL_LOOP.md). The private ROM, generated game code, builds, logs, saves and gameplay captures stay under ignored `ref/` or `work/`.

| Gate | State | Measured result and remaining test |
| --- | --- | --- |
| G0 pinned inputs | In progress | `sources.lock.json` pins Conker and its submodules. `scripts/setup-source.sh` verifies the private US ROM (64 MiB, header `80371240`, SHA-1 `4cbadd3c4e0729dec46af64ad018050eada4f47a`) and applies pinned patches. A separate ignored checkout replayed the final local host, runtime, RT64 sampler, RT64 debug capability and Plume patches; reverse checks passed. Complete license inventory and a fully clean rebuild remain. |
| G1 macOS control | In progress | ARM64 N64RecompCLI/RSPRecomp/RecompModTool built; `python3 recomp/recompile.py` emitted 127 files. Headless host ran 15 seconds, 895 VIs and 446 display lists, exit 0. `patches/rt64-metal-sdk-scope.patch` fixed the RecompFrontend shader command; the macOS Metal rebuild passed and its host ran 120 seconds, 7174 VIs, exit 0 on Apple M1. The visual control could not be captured through the available macOS UI tool. Ordinary macOS input, audio and save/relaunch remain unverified. |
| G2 mobile core and renderer | In progress | The Conker core, RSP audio path, runtime and RT64 Metal archives compile/link into an ARM64 `iphonesimulator` app and an unsigned ARM64 `iphoneos` app. Both SDK-specific RT64 closures force-link without desktop surface symbols. Metal blobs target iOS 17.0 and Metal 3.1; iOS 18.5 Simulator loaded them. Dynamic native mod hooks are disabled on iOS. Both iPad and iPhone Simulators reached game select with the touch input bridge. This is not physical-device or audio proof. |
| G3 Simulator frame | Partial | The iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5, reached moving intro, game select and the **first playable field** on RT64 Metal. The iPad imported the checksum-verified ROM through Files; the iPhone used the same SHA-1-verified private ROM copied to its app container. Both used **Continue Imported ROM**, which rechecks the checksum. First-field captures at the new surface size: `work/evidence/ipad-first-playable-480x270.png` and `work/evidence/iphone-first-playable-720x405.png`. Fresh import on iPhone, invalid/wrong-ROM routes, macOS fidelity comparison and audio remain untested. |
| G4 touch input and audio | Partial | The continuous stick and 14 N64 touch buttons feed Conker's mobile input callback for player 0. On both Simulators, touch Start opened the game's pause screen and A resumed at the first field. Short stick/C taps changed the picture but do not establish sustained analog feel. The three-dot menu opened/closed and hid/restored the controls in the iPad field. Slider values persisted across full app relaunch on each Simulator. The new iOS Audio Queue consumed nonzero stereo PCM on both Simulators through the first field. Audible quality, interruptions/routes, simultaneous touches and controller play remain untested; the menu is an overlay and does not pause game time. |
| G5–G6 gameplay | Partial | A populated **GAME1** slot appeared after app reinstall on each Simulator and loaded the first field. The first measured iPad Home-screen interval let display lists continue; `patches/conker-mobile-lifecycle.patch` now gates the mobile VI callback while the scene is inactive. Both Simulators held their display-list count steady for ten seconds on Home and resumed rendering and Start/A input. This is a narrow lifecycle check, not proof of frozen timers/audio, two distinct save states, long play or full-story G6. |
| G7 hardware | Awaiting devices | `xcrun devicectl list devices` found no connected iPad or iPhone on 2026-09-26. Both physical acceptance rows remain open. |
| G8 package | Open | The unsigned `iphoneos` app is 11 MiB, ARM64, and contains only `Info.plist`, `PkgInfo` and the executable at bundle depth two. It has not been signed, installed on hardware, or given a complete ROM-derived-code/license audit. |

## Touch and menu comparison (2026-09-26)

The iPad comparison uses `ref/harkinianpad/docs/readme/harkinianpad-gameplay.jpg` and `ref/harkinianpad/docs/readme/simulator-settings.jpg`. SquirrelPad's viewed captures are `work/evidence/ipad-touch-game-select-final.png`, `work/evidence/ipad-touch-menu-final.png`, `work/evidence/iphone-touch-game-select.png` and `work/evidence/iphone-touch-menu-final.png`. HarkinianPad has no iPhone screenshot in this checkout, so the phone comparison uses the accepted normalized centers and menu-placement code in `ref/harkinianpad/sources/Shipwright/soh/ios/HarkinianPadTouchControls.mm`. These reference images and game captures are local, ignored evidence, not distributable assets.

| Reference behavior | SquirrelPad Simulator result | Gap |
| --- | --- | --- |
| Translucent outlined grip controls, stick and D-pad left, action/C buttons and shoulders right | Both classes visibly follow the same grouping. The phone C cluster moved slightly left after the first screenshot showed C Up touching L. The stick uses continuous axes rather than HarkinianPad's eight-way keys. | Button sizes/colors are approximate; simultaneous touch and stick feel need real handling tests. |
| Fullscreen game with permanent three-dot menu, upper right on iPad and upper middle on iPhone | Both placements appear in the captures. The phone game frame now fits vertically so **GAME1** and its bottom text remain visible; the smaller top dot clears the title. | RT64 still renders a low-resolution surface and the app magnifies it. Sharpness and scene fidelity need a macOS comparison. |
| Three-dot menu remains reachable with controls hidden; phone dot moves near the bottom while open | Both Simulators show a Controls panel with a persistent touch toggle. Disabling touch hides every game control but leaves Menu; re-enabling restores them. The phone's open-menu dot sits above the home indicator. | This is a minimal controls panel, not HarkinianPad's full settings/customization UI. It does not pause the game. |
| Transparency is opt-in, revealing a 25–100% opacity slider | The switch defaults off and reveals/hides the slider on both Simulators. A live percentage now sits above the slider. The iPad retained 44% and the iPhone retained 70% after full app relaunch; each was set by an actual Simulator click on the slider thumb. Final captures: `work/evidence/ipad-opacity-final-menu.png` and `work/evidence/iphone-opacity-final-menu.png`. | Opacity appearance and touch feel on physical displays remain untested. |

Final Simulator build: `work/touch-build-menu-size.log` (exit 0); unsigned device build: `work/touch-build-iphoneos-final.log` (exit 0). Final runs: `work/touch-iphone-final-verified.log` and `work/touch-ipad-final-run.log`. The first device build after CMake regenerated the Xcode project used the old Swift source list and failed; the rerun with the regenerated project succeeded in `work/touch-build-iphoneos-retry.log`, then the final device build succeeded. The host patch was replayed in a separate ignored checkout before these builds. No ROM or capture is staged for Git.

The transparency-menu revision rebuilt successfully for Simulator and unsigned `iphoneos` (`work/touch-build-transparency-final-sim.log`, `work/touch-build-transparency-iphoneos.log`). Its switch's saved state survived an iPhone app reinstall/relaunch. The prior slider check used an accessibility `setValue` that moved the thumb without updating SwiftUI's binding; it was not a valid persistence test.

On 2026-09-27, an actual Simulator thumb click changed the iPad value from 100% to about 63%, and a full terminate/relaunch reopened the menu at that value. After adding the percentage readout, another click changed it to 44%; a second terminate/relaunch and reinstall of the final build still showed 44%. The final iPhone build changed from 100% to 70% through the same click path and reopened at 70% after terminate/relaunch. The final menu puts the value above the slider to avoid wrapping at phone width and raises the phone panel 18 points to clear the persistent bottom three-dot button. The final iPhone run confirmed that opening the menu hides every gameplay control and tapping the dot again restores them. Final Simulator and unsigned device builds passed (`work/touch-opacity-final-sim-build.log`, `work/touch-opacity-final-device-build.log`). Final visual runs: `work/touch-opacity-final-iphone-run.log`, `work/touch-opacity-final-iphone-relaunch.log`, `work/touch-opacity-final-ipad-run.log`; captures: `work/evidence/iphone-opacity-final-touch.png`, `work/evidence/iphone-opacity-final-menu.png`, `work/evidence/ipad-opacity-final-touch.png`, `work/evidence/ipad-opacity-final-menu.png`. Simulator appearance was compared against the HarkinianPad screenshots and normalized grip layout named above; physical acceptance remains open.

## First playable field and surface check (2026-09-27)

The unchanged `9cec3b9` build reached the first playable field through the ordinary **GAME1 → NEW GAME** route on both iOS 18.5 Simulators. Touch Start paused and A resumed. Baseline captures and run logs are `work/evidence/ipad-first-playable-before.png`, `work/evidence/iphone-first-playable-before.png`, `work/g3-playable-ipad-run.log` and `work/g3-playable-iphone-run.log`. Short stick/C gestures changed the view, but did not test sustained control.

The field looked soft at the fixed 160×90-point Metal surface. The narrow follow-up uses 240×135 points with the same 16:9 layout, yielding 480×270 pixels on iPad and 720×405 on iPhone. Simulator and unsigned device builds passed (`work/g3-surface-240-sim-build.log`, `work/g3-surface-240-device-build.log`). Each installed Simulator build reopened its populated **GAME1** slot and reached the first field. Captures: `work/evidence/ipad-first-playable-480x270.png` and `work/evidence/iphone-first-playable-720x405.png`; logs: `work/g3-surface-240-ipad-run.log` and `work/g3-surface-240-iphone-run.log`. Both logs advanced display lists without a pipeline resource-limit error in this window. Touch Start/A paused/resumed on both, and the iPad three-dot menu hid/restored its controls. Viewed before/after captures show somewhat clearer edges while source textures remain soft. The pixel count is 2.25 times higher; frame pacing, heat and battery impact were not measured, so this is not a performance optimization claim. Keep the hardware performance gate open.

## macOS Metal shader-rule repair (2026-09-27)

**Pass:** the previous rebuild failed at `xcrun -sdk metal -o ...` in RecompFrontend's `InterfaceVS/PS` shader rules (`work/debug-capability-build-macos.log`). RT64's Metal SDK variable was local to its CMake directory; the shared shader function was also called from a sibling directory. The narrow scope fallback in `patches/rt64-metal-sdk-scope.patch` makes those generated rules use `xcrun -sdk macosx metal`. The patch reverse-check passed in the pinned ignored checkout. Configure and build passed (`work/g1-metal-scope-configure.log`, `work/g1-metal-scope-build.log`); the rebuilt Apple M1 Metal host ran its 120-second window and exited 0 after 7174 VIs (`work/g1-metal-scope-run.log`). The iOS Simulator and unsigned device app builds also passed (`work/g1-metal-scope-sim-build.log`, `work/g1-metal-scope-device-build.log`). **Not run:** macOS visual/audio/input comparison; the UI tool timed out while binding the app window. The VI count alone does not close G1.

## Mobile audio connection (2026-09-27)

`patches/conker-mobile-audio.patch` connects the existing mobile host audio callbacks to `Support/Conker/mobile_audio.cpp`. The Audio Queue receives the game's signed 16-bit stereo samples in the same left/right order as the desktop host; its completion callback tracks queued frames for game pacing. The patch reverse-check passed in the pinned ignored checkout. The exact source revision built for Simulator and unsigned device (`work/g4-mobile-audio-verified-sim-build.log`, `work/g4-mobile-audio-verified-device-build.log`).

The iPad and iPhone 16 Pro iOS 18.5 Simulators each rechecked an imported private ROM, traversed **GAME1 → PLAY**, and visibly reached the first field. Logs `work/g4-mobile-audio-verified-ipad-run.log` and `work/g4-mobile-audio-verified-iphone-run.log` show the game selecting 22,020 Hz, playback starting, nonzero stereo PCM queued, and an output buffer with nonzero PCM completed. Captures: `work/evidence/ipad-mobile-audio-verified-field.png` and `work/evidence/iphone-mobile-audio-verified-field.png`. Touch Start paused and A resumed in both runs. No pipeline resource-limit or Audio Queue error appeared in these windows. **Open:** audible music/effects/voice quality, buffer underruns, route/interruption behavior, long play and hardware output. The completion callback shows consumption by the Simulator output path; it does not prove what a person heard.

## Home-screen VI gate (2026-09-27)

**Fail before change:** in a playable iPad field, `work/g5-ipad-lifecycle-baseline.log` rose from display list #6120 to #6960 during a ten-second Home-screen interval. The existing scene handler cleared held touch input but let the game render in the background.

**Pass after narrow change:** `patches/conker-mobile-lifecycle.patch` waits in the mobile host's VI callback while SwiftUI's scene phase is inactive, then wakes on return. The patch reverse-check passed in the pinned ignored checkout. Simulator and unsigned device builds passed (`work/g5-ipad-lifecycle-gate-sim-build.log`, `work/g5-ipad-lifecycle-gate-device-build.log`). The iPad log `work/g5-ipad-lifecycle-gate-run.log` stayed at display list #4200 throughout the ten-second Home interval; the iPhone log `work/g5-iphone-lifecycle-gate-run.log` stayed at #5340. Both returned to the first field, continued rendering and accepted touch Start/A pause/resume. Viewed captures: `work/evidence/ipad-lifecycle-gate-resumed.png` and `work/evidence/iphone-lifecycle-gate-resumed.png`. No Audio Queue or pipeline error appeared in either run.

**Open:** the runtime's `osGetTime` and timer thread still use wall time, and this gate does not prove game time or timer messages stay frozen on return. Audio output during background/interruptions and longer sleep/wake remain unmeasured. Do not mark G5 complete until those clocks, distinct saves and repeated lifecycle transitions pass.

## GPU resource-limit experiment

The first iPad RT64 build failed to load SDK 26 Metal 4 blobs on iOS 18.5. Recompiling the 56 blobs for `air64-apple-ios17.0-simulator` with `-std=metal3.1` let RT64 initialize. Its raster pixel shaders then exceeded the Simulator's 16-sampler limit with 18 declarations. `patches/rt64-ios-sampler-limit.patch` replaces two nearest mirror/clamp samplers with a mirrored UV transform and the existing nearest clamp sampler. All six generated `RasterPS*.metal` variants now declare 16 samplers. The rebuilt Simulator app progressed from three display lists and a shader-thread abort to visible moving frames and more than 9,700 display lists. Mirror edge fidelity still needs comparison with the macOS control.

Plume's Metal query result can be null on this Simulator; the narrow guard in `patches/plume-ios-metal.patch` logs once and disables GPU timing instead of copying from null. A separate 52-buffer warning came from **`DebugPS.hlsl`**, RT64's raytracing visualization pixel shader. A diagnostic build labeled that shader and reproduced `PS=RT64 DebugPS raytracing visualization: only 31 buffers are supported in the simulator but 52 were used` in `work/diagnose-52-labelled.stdout.log`. The generated `DebugPS.hlsl.metal` has 51 pointer resources plus its argument buffer. Plume leaves `deviceCapabilities.raytracing` false on Metal, but RT64 had unconditionally created this optional debug pipeline. `patches/rt64-ios-debug-capability.patch` now creates it only when raytracing is supported, and retains the diagnostic shader name. The rebuilt iPad run reached game select with no Metal pipeline-cap error through 4,200 display lists in `work/debug-capability-run-sim.stdout.log`. This removes an unused pipeline; it does not change Conker game logic or enable raytracing. Continue ordinary input/audio/play tests rather than treating this preview as playability.

## Repeat this check

Rebuild the macOS RT64 shader inputs after any `*.hlsli` change; Ninja did not track the changed include in this checkout. The final sampler experiment forced the raster shader regeneration and rebuilt both SDK archives.

```sh
scripts/verify-rt64-ios.sh iphonesimulator
scripts/verify-rt64-ios.sh iphoneos
cmake --build work/build-app-iphonesimulator --config Release --target SquirrelPad --parallel 4
cmake --build work/build-app-iphoneos --config Release --target SquirrelPad --parallel 4
xcrun simctl install 08636791-2675-4675-8335-EF72EF954DCF work/build-app-iphonesimulator/Release-iphonesimulator/SquirrelPad.app
xcrun simctl launch --console-pty 08636791-2675-4675-8335-EF72EF954DCF com.chrissotraidis.squirrelpad
```

In the app, use **Continue Imported ROM** only when a verified private ROM is already present in its container; it is SHA-1 checked again before the game starts. Otherwise import through Files. Visually inspect the live Simulator screen, preserve the log, then terminate and shut down this iPad before testing the iPhone Simulator. Do not erase the app container to work around a Files provider timeout.

## Reproduce the macOS control

Use Xcode's macOS 26.5 SDK path for CMake on this machine; the Command Line Tools 27.0 linker rejected an SDK object. In the ignored `work/CBFD-Recompiled` checkout after `scripts/setup-source.sh <private-rom>`:

```sh
sdk=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk
cmake -S tools/N64Recomp -B tools/N64Recomp/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT="$sdk"
cmake --build tools/N64Recomp/build --target N64RecompCLI RSPRecomp RecompModTool -j 4
python3 recomp/recompile.py
cmake -S host -B host/build-macos-headless -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCONKER_RT64=OFF -DCMAKE_OSX_SYSROOT="$sdk"
cmake --build host/build-macos-headless -j 4
host/build-macos-headless/ConkerRecomp --headless --rom conker/baserom.us.z64 --seconds 15
cmake -S host -B host/build-macos-metal -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_SYSROOT="$sdk"
cmake --build host/build-macos-metal -j 4
host/build-macos-metal/ConkerRecomp --rom "$PWD/conker/baserom.us.z64" --seconds 120
```

The windowed host changes its working directory to the executable's directory, so the `--rom` value must be absolute. Both builds emit private ROM-derived native code; keep binaries local.
