# Source and package boundary

This is a source inventory for the local developer build, not a release clearance. The exact upstream and submodule revisions are in `sources.lock.json`; the primary ignored engine checkout is `work/CBFD-Recompiled`. Historical replay paths below describe their dated runs. The iOS target in `CMakeLists.txt` links `ConkerRecomp`, `librecomp`, `ultramodern`, RT64, Plume, re-spirv and zstd. `CONKER_RT64=OFF` omits the desktop RecompFrontend from the iOS host build.

| Source in the pinned checkout | License text found at | Build relationship |
| --- | --- | --- |
| CBFD-Recompiled | `LICENSE` (MIT) | Host code, RSP integration and generation scripts. |
| N64ModernRuntime | `tools/N64ModernRuntime/COPYING` (GPL version 3) | `librecomp` and `ultramodern` are linked into iOS. |
| N64Recomp | `tools/N64Recomp/LICENSE` (MIT) | Generator, headers and runtime dependencies through N64ModernRuntime. |
| RT64 | `tools/rt64/LICENSE` (MIT) | Renderer archive force-linked into iOS. |
| Plume | `tools/rt64/src/contrib/plume/LICENSE` (MIT) | Metal renderer support archive force-linked into iOS. |
| re-spirv | `tools/rt64/src/contrib/re-spirv/LICENSE` (MIT) | Renderer archive force-linked into iOS. |
| zstd | `tools/rt64/src/contrib/zstd/LICENSE` (BSD) | Compression archive force-linked into iOS. |
| hlslpp | `tools/rt64/src/contrib/hlslpp/LICENSE` (MIT) | RT64 source/header dependency. |
| o1heap, miniz, concurrentqueue, lightweightsemaphore, sse2neon | `tools/N64ModernRuntime/thirdparty/{o1heap,miniz}/LICENSE`; license headers in `concurrentqueue/{concurrentqueue,blockingconcurrentqueue,lightweightsemaphore}.h` and `sse2neon/sse2neon.h` | Runtime sources or headers. The observed texts are MIT, MIT-style, simplified BSD, zlib-style and MIT respectively. The three header notice files in `Support/Notices/` preserve the pinned comment text verbatim; concurrentqueue also includes the blocking wrapper attribution. |
| Rabbitizer, fmt, tomlplusplus, sljit | `tools/N64Recomp/lib/{rabbitizer,fmt,tomlplusplus,sljit}/LICENSE` | Recompiler and LiveRecomp dependency graph. The observed texts are MIT, MIT-style, MIT and BSD-style respectively. The older unsigned link map included LiveRecomp/sljit; the iOS patch now excludes the LiveRecomp link dependency. Current executable symbol scans found no LiveGenerator, ShimFunction or sljit symbols. Current device compiler dependency files include no tomlplusplus headers. Keep generator/tool licensing separate from the shipped runtime closure. |

`RecompiledFuncs/` is generated from the user's exact US ROM and includes native game functions, TLB page data and the recompiled audio microcode. The ROM is also imported into the app's private container at runtime. A bundle without a `.z64` file may still contain ROM-derived executable content, so a file-list check alone cannot establish a rights-safe distributable. The user-supplied ROM, generated files, saves and diagnostic gameplay captures stay under ignored `ref/` or `work/`; they must not be committed or copied into notices. At the maintainer’s request on 2026-10-07, the selected `docs/screenshots/ipad-gameplay.jpg` capture is included for README illustration. The settings and About README captures document the native shell over its paused game. These documentation images are not bundled in the app and do not authorize inclusion of ROMs, extracted assets, saves, or generated game code.

HarkinianPad is a behavior and layout reference, not a linked dependency. Its project-specific code and art are not copied into this app. The Swift touch/menu code and mobile adapters are SquirrelPad sources; the Conker and runtime changes are recorded as local patches against the pinned checkout.

## Current developer-bundle audit (2026-10-02)

Both SDK Release bundles contain 24 notice texts under `ThirdPartyNotices/`.
The three header notices were absent from the previous 21-file set despite
appearing in the device compiler dependency files. `CMakeLists.txt` now includes
those files; their bundled bytes match the pinned header excerpts. This is a
source inventory correction, not a legal clearance or exhaustive license review.

The current audited executables are ARM64:

- Simulator: `3e215625cafd772fbca0cca0c073337f34ede0104ce0059815c22a8f4b73e31c`.
- Unsigned device: `0ddc68be67679731ed766459e754e026913ae9c564a696e036756191783034d1`.

Neither executable's complete `nm -a` output contains LiveGenerator, ShimFunction
or sljit symbols. `patches/n64modernruntime-ios-no-live-recomp.patch` excludes the
LiveRecomp link dependency on iOS; the separate iOS mod patches disable scanning,
initialization and game-start mod loading. This supersedes the older map's
LiveRecomp/sljit observation. It is not physical execution proof.

A bundle-wide byte scan found no local home path, and a file inventory found no
original-ROM extension, EEPROM/save filename, private key or provisioning input.
The app still contains ROM-derived native game code and TLB data: the absence of
an original ROM file does not establish a distributable rights boundary. The
tracked `scripts/audit-app.py` reproduces the bundle checks. Current private
reports `work/package-audit-20261002-{simulator,device}.json` record 30 files each,
their hashes, matching notice bytes, source revisions, ARM64/platform identity
and the narrowly scoped scans. Normal builds contain no SimulatorInputProbe
symbols; the existing opt-in probe build is deliberately rejected. Negative
fixtures also verified rejection of wrong SDK, altered notice, private ROM
filename and symlink. This does not scan all possible secrets or establish
absence of compressed/extracted game assets; inventory review remains required.

An independent source/tools/generated-code/renderer/app replay was recorded on
2026-10-01; subsequent incremental changes produced the hashes above. The
audit checks the supplied checkout's revisions and the bundle's contents; it
does not independently prove that arbitrary executable bytes came from that
checkout. See [the acceptance matrix](ACCEPTANCE.md) for the remaining gates.

The 2026-10-02 clean replay completed source/tools/generation, macOS and both
mobile builds in `work/source-release-replay`. Simulator executable SHA-256
`dd3771acd99d8a79e1c7e31733966cdfbd74053b1e24c34e049aa33ab973b936` and unsigned
device `f4dffb9dee2b0e3858427db782292a4b9de43f141139fa8a87e0b363805ebc80` passed
`work/release-replay-audit-{iphonesimulator,iphoneos}.json` with zero failures.
These hashes supersede the earlier build identities above for the new artifacts;
earlier runtime evidence is not automatically evidence for these bytes.

Before a signed handoff, complete the final notice/rights review,
signing and physical install acceptance. Public distribution remains a separate
decision. Hardware, full-story play and meaningful in-level save fidelity remain
open in `docs/STATUS.md`.
