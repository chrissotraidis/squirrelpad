# Windows-host iOS module development

This is an experimental development route. Current SquirrelPad v0.1.2 remains a
Mac-only source-and-recipe release; the public PadMint catalog does not enable
Windows builds. PadMint **0.5.15 or newer** includes the shared SDK and import
checks from [PadMint #177](https://github.com/chrissotraidis/padmint/pull/177).
Use the latest PadMint, this reviewed source branch, and a matching game-free
shell through `--app`. Do not use an older personal IPA as its base.

The shell can be built on GitHub without a ROM, then combined with a game module
built on the player's Windows computer. Releases remain source and recipe only:
this route does not require publishing a shell or a personal IPA. Windows ARM64
and x64 remain experimental; their recorded evidence has different limits below.

The Swift/Metal app, N64ModernRuntime, mobile integration and enhancements stay
in the shell. Only generated game functions, TLB code/data, the generated RSP
microcode and its overlay table enter the private module. The module exports one
function returning a versioned table; the app checks the complete table and a
source-contract digest before starting the core. All N64 runtime state remains
in the app. The app force-loads its runtime/support archives so APIs called only
by the module remain exported.

The contract digest covers source pins, the entire patch stack, the Conker bridge,
enhancement source and host-generator CMake wrapper/UTF-8 manifest. Paths sort by exact repository-relative POSIX names and
line endings normalize to LF so Windows and Mac compute the same digest. New
releases must produce the shell and recipe from the same revision. A mismatched
module gives an actionable launcher error instead of entering the game.

## Personal shell on GitHub

**Hosted shell build verified; private manual runs/downloads and device acceptance
remain untested.** This workflow is part of the Windows-module draft; it is not a
claim that the public release supports Windows.
A Windows computer with Visual Studio C++ Build Tools is still required for the
local module step. A phone alone cannot finish this build.

1. Create an empty **private** repository in your GitHub account. Copy the reviewed
   Windows-module branch into it. Replace the account and repository placeholders:

   ```powershell
   git clone --branch codex/windows-module --single-branch https://github.com/chrissotraidis/squirrelpad.git SquirrelPad-source
   git -C SquirrelPad-source remote add personal https://github.com/YOUR_ACCOUNT/YOUR_PRIVATE_REPOSITORY.git
   git -C SquirrelPad-source push personal HEAD:main
   ```

2. In that private repository, open **Actions → Build SquirrelPad shell for Windows
   → Run workflow**. The Mac runner builds only the app and runtime from public
   source. There is no ROM input, game-module upload or cache. This uses your
   private-repository Actions allowance.
3. Open the completed run. Under **Artifacts** at the bottom, download
   **SquirrelPad-shell-…** and extract it into a `SquirrelPad-shell` folder beside
   your source folder. Sign into GitHub to see the download. On a phone, GitHub's
   desktop website view can make Actions and Artifacts easier to find. Downloads
   are retained for one day.
4. Keep `SOURCE_COMMIT.txt`, `MODULE_IDENTITY.txt` and `SHA256SUMS` with the shell.
   They identify the source and module contract the shell was built against.
   The unsigned shell alone cannot play the game.

Manual runs refuse public repositories and the official SquirrelPad repository.
Pull-request checks build and audit the shell but upload no artifact. No release
is created by the workflow.

### Finish locally on Windows

Install Visual Studio Build Tools with **Desktop development with C++** and a
Windows SDK, as described below. Extract the latest Windows PadMint ZIP. From
PowerShell in the folder containing `SquirrelPad-source` and `SquirrelPad-shell`,
run the following, replacing the PadMint and ROM paths with your own:

```powershell
$source = (Resolve-Path ".\SquirrelPad-source").Path
$shell = (Resolve-Path ".\SquirrelPad-shell\SquirrelPad-shell.ipa").Path
$revision = (Get-Content ".\SquirrelPad-shell\SOURCE_COMMIT.txt" -Raw).Trim()
git -C "$source" checkout --detach "$revision"
& "C:\Tools\PadMint\PadMint.cmd" tools squirrelpad --repo "$source" --target ios
& "C:\Tools\PadMint\PadMint.cmd" build squirrelpad --repo "$source" --revision "$revision" --disc "C:\Games\conker-us.z64" --app "$shell" --target ios --jobs 4
```

PadMint downloads its managed tools, builds the private module from your ROM,
checks its imports against the supplied shell, and prints the personal IPA's
location. `--app` uses your downloaded shell; it does not fetch a shell from a
public release. Keep that IPA on your own computer, sign and install it using
your usual sideloading tool, then import the same supported ROM in the app.
Use the existing bundle ID and signing account when installing over an earlier
copy to keep saves. This route's launch, audio and save acceptance is still open.

## Build

On an Apple Silicon Mac with the existing documented Xcode/tools:

```sh
python3 scripts/build-module-shell.py --sdk iphoneos --jobs 4
```

This builds RT64 shaders directly from the renderer and needs no ROM or generated
game source. Its result is `work/build-shell-iphoneos/Release-iphoneos/SquirrelPad.app`.
To create a local unsigned shell IPA after the app audit, add
`--output /path/to/new/SquirrelPad-shell.ipa`. The GitHub workflow also runs
PadMint's content gate before allowing a private artifact download. The old full
app comparison route is unchanged:

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
The Windows generators carry a process-local UTF-8 manifest. Visual Studio path
discovery, its environment output and Python child processes use explicit encodings,
so non-English folder names do not require changing Windows settings. Old direct
upstream generator build caches are reconfigured once for the maintained wrapper.
Source patch replay also decodes Git's repository paths as UTF-8; its preservation
and retry tests use non-English source directories on both Mac and Windows.

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
- The Unicode-path follow-up passed all 28 Apple Python 3.9 tests and 17 portable
  tests under bundled Windows Python. A fresh native ARM64 MSVC generator build
  executed public CPU/RSP fixtures with Unicode working, build, temporary, input
  and output paths; both embedded manifests retained `asInvoker` and UTF-8.
  The bundled interpreter started with UTF-8 mode off. A fresh Mac generator build
  passed the same public fixtures. These checks use no original game input.
- A matching Mac shell/private-module pair was rebuilt after the host-wrapper
  identity changed. All 127 regenerated files matched the earlier Mac output
  after newline normalization; imports remained 117 app callbacks, 21 known
  runtime names and 9 classified C++ names. Packaging preserved all 32 shell
  entries and added only the module. The earlier private Windows proofs remain
  tied to their recorded source revisions; this follow-up is not a new Windows
  private-game or device-runtime acceptance claim.

This is build evidence only. Install/launch/gameplay of the module-based IPA,
representative saves, a full private build on native Windows x64 hardware, and
release availability are still separate gates. The static maintainer build and the
development-package tests are separate from the required current-main PadMint player checks before and
after a future game release. Current released catalog flags stay unchanged.

## October 29 integration

The draft now includes main's provider-tolerant, asynchronous ROM import (#8).
Module validation runs after import and before starting the core, preserving the
loader's rejection messages. The synthetic ROM-import runtime test and Swift syntax
check pass. Apple Python 3.9 passes all 3 shell-package tests, 17 portable-module
tests and 6 source-preservation tests; both workflows pass actionlint. The shell-only
workflow and local `--app` handoff avoid needing a published shell.

At `102ec408`, the [hosted shell build](https://github.com/chrissotraidis/squirrelpad/actions/runs/40833079369)
and [native Windows x64 generator checks](https://github.com/chrissotraidis/squirrelpad/actions/runs/40833079361)
passed; both pull-request runs retained zero artifacts. A fresh local shell build
also passed its audit and PadMint's content gate. The documented Windows handoff
then completed in 164 seconds with the public PadMint 0.5.24 ZIP, one job, an
existing managed tool cache, and that fresh shell in the Windows 11 ARM64 VM.
Independent IPA readback passed ZIP CRC, matching shell/module source identities
and iOS architecture/minimum-version checks. All 32 shell files were unchanged;
only the private game module was added. This is not a fresh Windows installation
or a full private build on native x64 hardware.

Private `workflow_dispatch` runs and artifact downloads have not been exercised.
A fresh current-main Mac PadMint player check remains pending. Physical-device launch/audio/save validation
also remains pending. The evidence above is tied to `102ec408`; earlier Windows
and shell results remain tied to their recorded revisions.
