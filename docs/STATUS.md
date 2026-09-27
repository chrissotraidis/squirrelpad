# SquirrelPad evidence ledger

Updated 2026-09-26 23:27 CDT. Work the lowest unmet goal in [GOAL_LOOP.md](GOAL_LOOP.md). The private ROM, generated game code, builds, logs, saves and gameplay captures stay under ignored `ref/` or `work/`.

| Gate | State | Measured result and remaining test |
| --- | --- | --- |
| G0 pinned inputs | In progress | `sources.lock.json` pins Conker and its submodules. `scripts/setup-source.sh` verifies the private US ROM (64 MiB, header `80371240`, SHA-1 `4cbadd3c4e0729dec46af64ad018050eada4f47a`) and applies pinned patches. A separate ignored checkout replayed the final local host, runtime, RT64 sampler, RT64 debug capability and Plume patches; reverse checks passed. Complete license inventory and a fully clean rebuild remain. |
| G1 macOS control | In progress | ARM64 N64RecompCLI/RSPRecomp/RecompModTool built; `python3 recomp/recompile.py` emitted 127 files. Headless host ran 15 seconds, 895 VIs and 446 display lists, exit 0. Metal host previously ran 120 seconds, 7159 VIs, exit 0 on Apple M1. An incremental macOS rebuild after this RT64 change stopped in RecompFrontend's existing shader rule (`xcrun -sdk metal -o ...` omits a tool name); log: `work/debug-capability-build-macos.log`. The updated RT64 code compiled and linked for both iOS SDKs, but a fresh macOS control is not verified. Viewed macOS gameplay, ordinary input, audio and save/relaunch still need capture. |
| G2 mobile core and renderer | In progress | The Conker core, RSP audio path, runtime and RT64 Metal archives compile/link into an ARM64 `iphonesimulator` app and an unsigned ARM64 `iphoneos` app. Both SDK-specific RT64 closures force-link without desktop surface symbols. Metal blobs target iOS 17.0 and Metal 3.1; iOS 18.5 Simulator loaded them. Dynamic native mod hooks are disabled on iOS. Both iPad and iPhone Simulators reached game select with the touch input bridge. This is not physical-device or audio proof. |
| G3 Simulator frame | Partial | The iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5, reached moving intro and game-select frames on RT64 Metal. The iPad imported the checksum-verified ROM through Files; the iPhone test used the same SHA-1-verified private ROM copied to its app container. Both then used **Continue Imported ROM**, which rechecks the checksum. Final layout captures: `work/evidence/ipad-touch-game-select-final.png` and `work/evidence/iphone-touch-game-select.png`. First playable scene, fresh import on iPhone and audio remain untested. |
| G4 touch input | Partial | The app now has a continuous stick and 14 N64 touch buttons wired through Conker's mobile input callback for player 0. On both Simulators, A entered the **NEW GAME** doorway from **GAME1** and B returned; the three-dot menu opened/closed, disabled/restored the overlay and changed opacity. Held input is cleared when the menu opens, controls disable, the scene leaves active state or the core exits. Analog movement, simultaneous touches, C camera, controller and audio still need ordinary-play tests; the menu is an overlay and does not pause game time. |
| G5–G6 gameplay | Open | No save/relaunch, lifecycle, ordinary play or full-story evidence. Game-select interactions alone do not satisfy these gates. |
| G7 hardware | Awaiting devices | `xcrun devicectl list devices` found no connected iPad or iPhone on 2026-09-26. Both physical acceptance rows remain open. |
| G8 package | Open | The unsigned `iphoneos` app is 11 MiB, ARM64, and contains only `Info.plist`, `PkgInfo` and the executable at bundle depth two. It has not been signed, installed on hardware, or given a complete ROM-derived-code/license audit. |

## Touch and menu comparison (2026-09-26)

The iPad comparison uses `ref/harkinianpad/docs/readme/harkinianpad-gameplay.jpg` and `ref/harkinianpad/docs/readme/simulator-settings.jpg`. SquirrelPad's viewed captures are `work/evidence/ipad-touch-game-select-final.png`, `work/evidence/ipad-touch-menu-final.png`, `work/evidence/iphone-touch-game-select.png` and `work/evidence/iphone-touch-menu-final.png`. HarkinianPad has no iPhone screenshot in this checkout, so the phone comparison uses the accepted normalized centers and menu-placement code in `ref/harkinianpad/sources/Shipwright/soh/ios/HarkinianPadTouchControls.mm`. These reference images and game captures are local, ignored evidence, not distributable assets.

| Reference behavior | SquirrelPad Simulator result | Gap |
| --- | --- | --- |
| Translucent outlined grip controls, stick and D-pad left, action/C buttons and shoulders right | Both classes visibly follow the same grouping. The phone C cluster moved slightly left after the first screenshot showed C Up touching L. The stick uses continuous axes rather than HarkinianPad's eight-way keys. | Button sizes/colors are approximate; simultaneous touch and stick feel need real handling tests. |
| Fullscreen game with permanent three-dot menu, upper right on iPad and upper middle on iPhone | Both placements appear in the captures. The phone game frame now fits vertically so **GAME1** and its bottom text remain visible; the smaller top dot clears the title. | RT64 still renders a low-resolution surface and the app magnifies it. Sharpness and scene fidelity need a macOS comparison. |
| Three-dot menu remains reachable with controls hidden; phone dot moves near the bottom while open | Both Simulators show a Controls panel with persistent touch toggle and opacity slider. Disabling touch hides every game control but leaves Menu; re-enabling restores them. The phone's open-menu dot sits above the home indicator. | This is a minimal controls panel, not HarkinianPad's full settings/customization UI. It does not pause the game. |

Final Simulator build: `work/touch-build-menu-size.log` (exit 0); unsigned device build: `work/touch-build-iphoneos-final.log` (exit 0). Final runs: `work/touch-iphone-final-verified.log` and `work/touch-ipad-final-run.log`. The first device build after CMake regenerated the Xcode project used the old Swift source list and failed; the rerun with the regenerated project succeeded in `work/touch-build-iphoneos-retry.log`, then the final device build succeeded. The host patch was replayed in a separate ignored checkout before these builds. No ROM or capture is staged for Git.

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
