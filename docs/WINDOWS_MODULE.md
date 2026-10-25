# Windows-host iOS module development

This is a draft next-release route. Current SquirrelPad v0.1.2 remains a Mac-only
source-and-recipe release. The changed recipe requires a matching game-free shell
that has not been published. Do not use an older IPA as its base.

The Swift/Metal app, N64ModernRuntime, mobile integration and enhancements stay
in the shell. Only generated game functions, TLB code/data, the generated RSP
microcode and its overlay table enter the private module. The module exports one
function returning a versioned table; the app checks the complete table and a
source-contract digest before starting the core. All N64 runtime state remains
in the app. The app force-loads its runtime/support archives so APIs called only
by the module remain exported.

The contract digest covers source pins, the entire patch stack, the Conker bridge
and enhancement source. Paths sort by exact repository-relative POSIX names and
line endings normalize to LF so Windows and Mac compute the same digest. New
releases must produce the shell and recipe from the same revision. A mismatched
module gives an actionable launcher error instead of entering the game.

## Build

On an Apple Silicon Mac with the existing documented Xcode/tools:

```sh
python3 scripts/build-module-shell.py --sdk iphoneos --jobs 4
```

This builds RT64 shaders directly from the renderer and needs no ROM or generated
game source. Its result is `work/build-shell-iphoneos/Release-iphoneos/SquirrelPad.app`.
It still needs the normal source/binary release gates and packaging before any
publication. The old full app comparison route is unchanged:

```sh
python3 scripts/build-personal.py --rom "/path/to/your supported US ROM" --sdk iphoneos --jobs 4
```

Windows needs Visual Studio Build Tools, Desktop development with C++, and a
Windows SDK. The backend finds the installation with `vswhere` and sets up its
compiler environment for the child process; a developer command prompt is not
required. Native ARM64 tools are used when installed, otherwise x64 tools are
used. Source and build folders should be on a local NTFS drive. CMake's Windows
link/archive commands cannot use a UNC network share as their working directory.

The next recipe uses PadMint's existing `ios_module` pipeline. For developer
validation with a local matching empty IPA:

```sh
python -m padmint build squirrelpad --repo /path/to/checkout --revision FULL_COMMIT --disc "/path/to/your supported US ROM" --app /path/to/matching-shell.ipa --target ios --jobs 4
```

PadMint prepares its shared open-source iOS SDK, supplies `{ios_toolchain}`, checks
imports against the shell, and inserts the library into `Frameworks/`. No Xcode
SDK, ROM or translated code is uploaded. Native source staging preserves existing
inputs, uses no Windows symlink privilege, checks source pins, and only reapplies
known patches. CMake receives the running Python explicitly, so bundled Windows
Python does not need to be registered on PATH. A fresh CMake configure prevents
reusing a different workspace's SDK/compiler paths. The generated input ledger
must match every input declared by the pinned recompiler.

## Validation and limits

Recorded during development on 26 October 2026 (Japan time):

- Real Windows 11 ARM64 native Python/MSVC built N64Recomp and RSPRecomp and
  translated the supported private ROM. After sorting the recompiler's unordered
  switch-case emission, all 127 generated files match Mac output after newline
  normalization. The sorting patch changes emission order, not branch targets.
- A real game module compiles on Windows ARM64 using pinned LLVM 21.1.8 and
  PadMint's open-source SDK. The corresponding empty shell compiles on Mac;
  normal package checks and PadMint's public-content gate pass with zero
  address-named game functions. Private module imports are checked separately.
- Synthetic native-Mac loader tests exercise all forwards, rejection of wrong
  table version/size/identity, absent callbacks, missing modules, and retry after
  a rejected module. Run `python3 scripts/check-module-loader.py` after source
  setup. These tests do not establish iOS loader or gameplay compatibility.

This is build evidence only. Install/launch/gameplay of the module-based IPA,
representative saves, native Windows x64 hardware, clean packaged-player builds,
and publication are still separate gates. The existing static Mac path must
continue to pass before any release. Current released catalog flags stay unchanged.
