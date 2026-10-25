# Windows-host iOS module development

This is a draft next-release route. Current SquirrelPad v0.1.2 remains a Mac-only
source-and-recipe release. The changed recipe requires a matching game-free shell
that has not been published. Do not use an older IPA as its base.
It also requires the shared SDK and import checks in
[PadMint PR #177](https://github.com/chrissotraidis/padmint/pull/177), which are not
in public PadMint 0.5.14. Release the PadMint prerequisite first, then the matching
SquirrelPad shell and recipe; no new public version number is claimed here.
The draft recipe marks Windows ARM64 and x64 as experimental. Their build
evidence has different limits, recorded below.

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
used; Windows x64 needs the x64/x86 C++ component. Source and build folders should
be on a local NTFS drive. CMake's Windows link/archive commands cannot use a UNC
network share as their working directory.

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
- The development PadMint Windows ZIP (PadMint source `4a78bb0`) completed the
  normal `padmint build` flow from SquirrelPad `fff85cf` in a local Windows path
  containing spaces. Its bundled x64 Python 3.13.15 correctly reported a Windows
  ARM64 host, used native ARM64 generator tools, and built/checked/inserted the
  module in 35 seconds. Tools and source were cached; this is not a clean-machine
  or native-x64-hardware result. Readback confirmed the same contract digest in
  the final shell and module.
- A second packaged run from SquirrelPad `63068a2` started with a fresh local
  checkout, no upstream source, and an absent `PADMINT_HOME`. PadMint downloaded
  its complete managed tool set and built the private IPA without manual repair:
  5 minutes 21 seconds including downloads, with 99 seconds in the build stage.
  The existing Visual Studio prerequisite supplied its native ARM64 compiler.
  All 127 generated files again matched Mac after newline normalization; final
  shell/module identities matched, the module exported only its table getter,
  and strict imports passed (117 app callbacks, 21 known runtime names, 9 standard
  C++ names). No files in the supplied shell changed; only the module was added.
  This validates a clean PadMint environment on the existing Windows ARM64 VM,
  not a newly installed Windows system or native x64 hardware.
- [Native Windows x64 CI](https://github.com/chrissotraidis/squirrelpad/actions/runs/40211903260)
  built the pinned MSVC generators from fresh public sources and executed
  hand-authored MIPS and RSP fixtures. Separate x64 generator executables running
  under Windows ARM64 emulation translated the private ROM; all 127 generated
  files matched Mac after newline normalization.
- A complete private backend build from `c8eede2` used x64 LLVM 21.1.8 and x64
  MSVC generators under Windows ARM64 emulation, completing in 146 seconds.
  The compiler, linker and both generators were verified as x64 PE executables;
  native ARM64 helper tools and cached source were reused. The resulting arm64
  iOS module passed the same strict import check (117 app callbacks, 21 known
  runtime names, 9 standard C++ names). Independent IPA readback confirmed
  matching shell/module identities and unchanged shell files, with only the
  module added. This was a backend build using development PadMint helpers,
  not a fresh complete player run on native x64 hardware. Standard C++ names are
  classified by namespace; their device availability is not verified.
- Apple `/usr/bin/python3` (3.9) completed the same next-release module recipe
  with the development PadMint code and matching local shell, again with cached
  tools/source. The previous full static Mac route also produced an audited IPA.
  All 21 repository tests passed after source setup.
- Synthetic native-Mac loader tests exercise all forwards, rejection of wrong
  table version/size/identity, absent callbacks, missing modules, and retry after
  a rejected module. Run `python3 scripts/check-module-loader.py` after source
  setup. These tests do not establish iOS loader or gameplay compatibility.

This is build evidence only. Install/launch/gameplay of the module-based IPA,
representative saves, a full private build on native Windows x64 hardware, and
publication are still separate gates. The static maintainer build and the
development-package tests are separate from the required current-main PadMint player checks before and
after a future game release. Current released catalog flags stay unchanged.
