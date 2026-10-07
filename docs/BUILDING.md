# Building SquirrelPad

For the one-command personal builder and PadMint setup, start with the
[README](../README.md#get-started). The manual steps and historical handoff
below remain useful for development and diagnostics.

Native Apple ARM64 iPhone/iPad port of Conker's Bad Fur Day using the pinned
CBFD-Recompiled runtime and RT64 Metal renderer. The app imports a private US
ROM through Files and provides touch controls, controller bindings and EEPROM
storage.

**Development build; acceptance is incomplete.** Both SDKs build, and both
Simulator classes have reached the first playable field. Full iPad story play,
representative iPhone chapters, meaningful in-level save fidelity, macOS ordinary
play/save comparison and physical-device acceptance remain open. See
[the evidence ledger](STATUS.md) and [the full goal loop](GOAL_LOOP.md).
The [acceptance matrix](ACCEPTANCE.md) summarizes current artifacts and
what each open gate still requires.
Audio quality is unverified; routine audio experiments are currently deferred.

**2026-10-02 handoff:** Chris accepted the current developer build for transfer
to the main Mac. Further acceptance testing is deferred to that machine;
this does not mark the open tests as passed. Follow the build steps below
and [the transfer checklist](ACCEPTANCE.md#main-mac-handoff).

## Requirements

- Apple Silicon Mac, full Xcode with the iOS SDKs, and an installed Simulator
  runtime. The recorded environment uses Xcode 26.6 and iOS 18.5/26.5 Simulators.
- CMake 3.28 or newer, Ninja, Git, Python 3 and rsync.
- SDL2 and FreeType discoverable by CMake for the macOS host. The recorded build
  finds these under Homebrew's prefix. Shader tooling comes from the pinned
  RT64 checkout; a separate global `dxc` is not required.
- Sufficient free disk space for source, generated code and separate SDK builds.
  Check `df -h .` before starting; build outputs can consume many gigabytes.
- Your own **64 MiB US big-endian `.z64` ROM**, header `80371240`, SHA-1
  `4cbadd3c4e0729dec46af64ad018050eada4f47a`.

The iOS deployment target is 17.0. Recorded runtime acceptance starts at 18.5;
17.0 execution has not been verified. This repository supplies no ROM.

## 1. Prepare the pinned source

Run these commands from the SquirrelPad repository root. Keep the environment
variables in the same shell for the remaining steps:

```sh
export SQUIRRELPAD_CHECKOUT="$PWD/work/source-replay"
export SQUIRRELPAD_RT64_BUILD_TAG="-replay"
macos_sdk="$(xcrun --sdk macosx --show-sdk-path)"
private_rom="/absolute/path/to/your/private/conker-us.z64"
scripts/setup-source.sh "$private_rom"
```

`setup-source.sh` creates a separate pinned checkout, initializes its submodules,
applies the tracked patches and verifies the ROM before creating a private
symlink. It preserves a conflicting source revision or ROM path by failing.
Exact source pins are in [sources.lock.json](../sources.lock.json). Use a fresh
checkout path for an independent replay; preserve existing patched work. Do not
run upstream `build.sh` over the reference or patched trees.

## 2. Generate the game and build macOS shader inputs

```sh
cmake -S "$SQUIRRELPAD_CHECKOUT/tools/N64Recomp" \
  -B "$SQUIRRELPAD_CHECKOUT/tools/N64Recomp/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT="$macos_sdk"
cmake --build "$SQUIRRELPAD_CHECKOUT/tools/N64Recomp/build" \
  --target N64RecompCLI RSPRecomp RecompModTool --parallel 4
python3 "$SQUIRRELPAD_CHECKOUT/recomp/recompile.py"
cmake -S "$SQUIRRELPAD_CHECKOUT/host" \
  -B "$SQUIRRELPAD_CHECKOUT/host/build-macos-metal" -G Ninja \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCONKER_RT64=ON \
  -DCMAKE_OSX_SYSROOT="$macos_sdk"
cmake --build "$SQUIRRELPAD_CHECKOUT/host/build-macos-metal" --parallel 4
```

Generation replaces `RecompiledFuncs/` inside this private working checkout.
The generated native game/audio code and TLB data are ROM-derived; keep them
outside Git and public packages. The macOS build supplies RT64's shader inputs
and `file_to_c` tool for the mobile builds. Use the full-Xcode SDK reported by
`xcrun`; a Command Line Tools SDK/linker mismatch previously failed here.

Optional macOS comparison run:

```sh
"$SQUIRRELPAD_CHECKOUT/host/build-macos-metal/ConkerRecomp" \
  --rom "$SQUIRRELPAD_CHECKOUT/conker/baserom.us.z64" --seconds 120
```

The absolute ROM argument is required because the host changes its working
directory. A window or VI count alone does not establish gameplay, audio or save
acceptance. Brief automated keyboard taps can miss the host's input polling;
this has not established a production mapping defect.

For a local, inspectable macOS app window, package the same native host:

```sh
python3 scripts/package-macos-control.py "$SQUIRRELPAD_CHECKOUT/host/build-macos-metal"
```

Open the resulting `SquirrelPad macOS Control.app` and use its launcher. The
bundle runs the native executable directly and links to that build's assets;
keep it beside the build. It preserves the host's existing ROM and save profile,
contains ROM-derived game code, and is a local comparison aid, not a release
package. The script refuses to overwrite an existing bundle by default. After
rebuilding the host, close the comparison app and rerun the command with
`--refresh` to update this script's bundle. Check the printed executable SHA256
against the host build before using it for a comparison.

For an isolated macOS comparison profile, launch the executable with
`APP_FOLDER_PATH` set to an absolute private directory containing that profile.
`SQUIRRELPAD_DATA_DIR` applies to the iOS adapter and does not select the macOS
profile. Confirm the displayed slot and progress before comparing gameplay.

## 3. Build each mobile renderer and app

```sh
scripts/verify-rt64-ios.sh iphonesimulator
scripts/verify-rt64-ios.sh iphoneos
for sdk in iphonesimulator iphoneos; do
  cmake -S . -B "work/build-app-replay-$sdk" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT="$sdk" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
    -DSQUIRRELPAD_CONKER_SOURCE="$SQUIRRELPAD_CHECKOUT" \
    -DSQUIRRELPAD_RT64_ARCHIVE_DIR="$PWD/work/build-rt64-$sdk$SQUIRRELPAD_RT64_BUILD_TAG" \
    -DSQUIRRELPAD_SIM_INPUT=OFF
  xcodebuild -project "work/build-app-replay-$sdk/SquirrelPad.xcodeproj" \
    -target SquirrelPad -configuration Release -sdk "$sdk" -jobs 4 \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
done
```

The renderer script recompiles 56 Metal shaders for the selected SDK using
Metal 3.1, builds the static archives and force-links an ARM64 closure probe.
The app uses the Conker core, RSP audio path and RT64 renderer. Dynamic native
mod hooks/LiveRecomp are disabled on iOS. The optional Simulator input probe is
excluded from normal builds; its diagnostic procedure is in
[SIMULATOR_INPUT.md](SIMULATOR_INPUT.md).

Outputs:

- `work/build-app-replay-iphonesimulator/Release-iphonesimulator/SquirrelPad.app`
- `work/build-app-replay-iphoneos/Release-iphoneos/SquirrelPad.app`

The device output is **unsigned** and is not a physical-device installable
handoff. Signing and hardware installation remain pending. After changing
CMake resources, explicitly configure before building: Xcode's regeneration
phase can otherwise finish successfully using the old resource list.

Audit each normal developer bundle before installation or handoff:

```sh
for sdk in iphonesimulator iphoneos; do
  python3 scripts/audit-app.py \
    "work/build-app-replay-$sdk/Release-$sdk/SquirrelPad.app" \
    --sdk "$sdk" --source "$SQUIRRELPAD_CHECKOUT" \
    --output "work/package-audit-$sdk.json"
done
```

The audit checks pinned revisions, notice bytes, ARM64/SDK identity, excluded
LiveRecomp/probe symbols, private filenames, the exact original ROM digest,
home paths, private-key markers and symlinks. It records every bundled file's
hash. A pass covers these checks only; compressed/extracted game assets or
arbitrary secrets require separate review, and ROM-derived executable content
remains. The command neither signs nor publishes the app.

## 4. Install and use one Simulator at a time

Find an installed destination with `xcrun simctl list devices available`.
The recorded iPad M4 / iOS 18.5 destination is shown below; replace the UUID
when using another destination. Boot only a shut-down device.

```sh
simulator_udid=08636791-2675-4675-8335-EF72EF954DCF
xcrun simctl boot "$simulator_udid"
xcrun simctl bootstatus "$simulator_udid" -b
xcrun simctl install "$simulator_udid" \
  work/build-app-replay-iphonesimulator/Release-iphonesimulator/SquirrelPad.app
xcrun simctl launch "$simulator_udid" com.chrissotraidis.squirrelpad
```

Use **Choose ROM** and select your private ROM in Files. On later launches,
**Continue Imported ROM** revalidates the app's private imported copy. Input,
saves and settings acceptance should use this ordinary flow.

The three-dot menu opens and closes Controls/Audio settings and pauses the game.
It stays available with touch controls off, sits at the top center on iPhone,
and moves below the panel while Settings is open. Controls
includes controller bindings, global size/opacity, D-pad/C-button visibility
and **Edit Layout**. Tap a control in the editor to select it, drag to move it,
and use Size for its individual 70–150% scale. Hide/Show removes or restores an
individual button during gameplay; hidden buttons remain dimmed in the editor
so they can be restored. The stick cannot be hidden. Done persists the current
phone or tablet profile; Reset Layout clears that profile's positions, individual
sizes and hidden buttons. Full reference-menu parity remains unfinished.

Before switching to iPhone, terminate and shut down the iPad:

```sh
xcrun simctl terminate "$simulator_udid" com.chrissotraidis.squirrelpad
xcrun simctl shutdown "$simulator_udid"
```

Repeat with iPhone 16 Pro / iOS 18.5 UUID
`12A4163C-33A0-4936-8024-77A6D36698C5`, or another available phone.
Install in place to preserve data. Do not erase/uninstall to troubleshoot a
picker or runtime problem without first preserving private data.

## Private data and evidence

The bundle ID is `com.chrissotraidis.squirrelpad`. EEPROM data lives under the
app container's `Library/Application Support/Conker/saves/`; app preferences
store settings and separate phone/tablet layout profiles. Imported ROM storage
is owned by the app container. Preserve these when updating or testing.

On macOS, verify the runtime save writer's short-write handling using synthetic
EEPROM data (no ROM or Simulator saves are accessed):

```sh
python3 scripts/verify-save-write.py work/source-final-replay/tools/N64ModernRuntime
```

This compiles the actual writer function and file helpers, checks failed first
and replacement writes, and verifies a successful retry and backup. It does not
measure power-loss durability or in-game checkpoint fidelity.

Keep logs, game captures and build products under ignored `work/` or
`artifacts/`. Record the executable hash, source revision, destination/runtime,
commands and viewed captures in [STATUS.md](STATUS.md). A save file or
nonzero play time is insufficient proof of a distinct in-level checkpoint.

Both SDK bundles currently contain 24 upstream notice texts. See
[SOURCE_BOUNDARY.md](SOURCE_BOUNDARY.md) for the audited source/licensing
inventory and its limits. Runtime GPL components and ROM-derived executable
content remain part of the build; absence of a `.z64` file is not distribution
clearance. Public release, TestFlight and App Store delivery require a separate
decision. No physical device is presently available; Chris's remaining hardware
checks include touch feel, controllers, audio routes/listening and sustained play.
