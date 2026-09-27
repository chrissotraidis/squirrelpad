# SquirrelPad evidence ledger

Updated 2026-09-26 22:25 CDT. Work the lowest unmet goal in [GOAL_LOOP.md](GOAL_LOOP.md). The private ROM, generated game code, builds, logs, saves and gameplay captures stay under ignored `ref/` or `work/`.

| Gate | State | Measured result and remaining test |
| --- | --- | --- |
| G0 pinned inputs | In progress | `sources.lock.json` pins Conker and its submodules. `scripts/setup-source.sh` verifies the private US ROM (64 MiB, header `80371240`, SHA-1 `4cbadd3c4e0729dec46af64ad018050eada4f47a`) and applies pinned patches. A separate ignored checkout replayed the final local host, runtime, RT64 sampler and Plume patches; reverse checks passed. Complete license inventory and a fully clean rebuild remain. |
| G1 macOS control | In progress | ARM64 N64RecompCLI/RSPRecomp/RecompModTool built; `python3 recomp/recompile.py` emitted 127 files. Headless host ran 15 seconds, 895 VIs and 446 display lists, exit 0. Metal host ran 120 seconds, 7159 VIs, exit 0 on Apple M1. Viewed macOS gameplay, ordinary input, audio and save/relaunch still need capture. |
| G2 mobile core and renderer | In progress | The Conker core, RSP audio path, runtime and RT64 Metal archives compile/link into an ARM64 `iphonesimulator` app and an unsigned ARM64 `iphoneos` app. Both SDK-specific RT64 closures force-link without desktop surface symbols. Metal blobs target iOS 17.0 and Metal 3.1; iOS 18.5 Simulator loaded them. Dynamic native mod hooks are disabled on iOS. An iPad Simulator ran the game-backed RT64 renderer past 9,700 display lists without a process crash. This is not device execution or an audio/input pass. |
| G3 Simulator frame | Partial | The iPad Pro 11-inch (M4), iOS 18.5, imported the checksum-verified ROM through Files. After an unrelated local Files provider timeout on relaunch, **Continue Imported ROM** rechecked the stored ROM and resumed the ordinary app route. Viewed Nintendo animation, Conker animation and the game-select screen on the actual RT64 Metal surface; captures are `work/evidence/ipad-rt64-16samplers-*.png`. The surface is a 160×90 diagnostic preview. Metal still logs one `VSMain/PSMain` pipeline exceeding the Simulator's 31-buffer cap (52 used), so G3's no-GPU-error condition is open. iPhone Simulator and first playable scene remain untested. |
| G4–G6 gameplay | Open | No touch/controller bridge, routed audio, persistence, lifecycle, ordinary play or full-story evidence. VI and display-list counts alone do not satisfy these gates. |
| G7 hardware | Awaiting devices | `xcrun devicectl list devices` found no connected iPad or iPhone on 2026-09-26. Both physical acceptance rows remain open. |
| G8 package | Open | The unsigned `iphoneos` app is 11 MiB, ARM64, and contains only `Info.plist`, `PkgInfo` and the executable at bundle depth two. It has not been signed, installed on hardware, or given a complete ROM-derived-code/license audit. |

## GPU resource-limit experiment

The first iPad RT64 build failed to load SDK 26 Metal 4 blobs on iOS 18.5. Recompiling the 56 blobs for `air64-apple-ios17.0-simulator` with `-std=metal3.1` let RT64 initialize. Its raster pixel shaders then exceeded the Simulator's 16-sampler limit with 18 declarations. `patches/rt64-ios-sampler-limit.patch` replaces two nearest mirror/clamp samplers with a mirrored UV transform and the existing nearest clamp sampler. All six generated `RasterPS*.metal` variants now declare 16 samplers. The rebuilt Simulator app progressed from three display lists and a shader-thread abort to visible moving frames and more than 9,700 display lists. Mirror edge fidelity still needs comparison with the macOS control.

Plume's Metal query result can be null on this Simulator; the narrow guard in `patches/plume-ios-metal.patch` logs once and disables GPU timing instead of copying from null. A separate 52-buffer raster pipeline warning remains. The current Plume diagnostic prints only generic entry names (`VSMain`/`PSMain`), so the precise compiled shader variant has not been identified. It did not prevent the captured intro/game-select frames. Next bounded experiment: label or fingerprint RT64 shader blobs at pipeline creation, map the warning to its HLSL source, then remove only unused bindings or test a smaller RT64 configuration. Lower display resolution alone does not change binding counts.

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
