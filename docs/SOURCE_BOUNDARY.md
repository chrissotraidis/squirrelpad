# Source and package boundary

This is a source inventory for the local developer build, not a release clearance. The exact upstream and submodule revisions are in `sources.lock.json`; the ignored `work/CBFD-Recompiled` checkout matched those pins on 2026-09-29. The iOS target in `CMakeLists.txt` links `ConkerRecomp`, `librecomp`, `ultramodern`, RT64, Plume, re-spirv and zstd. `CONKER_RT64=OFF` omits the desktop RecompFrontend from the iOS host build.

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
| o1heap, miniz, concurrentqueue, sse2neon | `tools/N64ModernRuntime/thirdparty/{o1heap,miniz}/LICENSE`; license headers in `concurrentqueue/concurrentqueue.h` and `sse2neon/sse2neon.h` | Runtime sources or headers. The observed texts are MIT, MIT-style, simplified BSD and MIT respectively. |
| Rabbitizer, fmt, tomlplusplus, sljit | `tools/N64Recomp/lib/{rabbitizer,fmt,tomlplusplus,sljit}/LICENSE` | Recompiler and LiveRecomp dependency graph. The observed texts are MIT, MIT-style, MIT and BSD-style respectively. The unsigned `iphoneos` link map includes Rabbitizer (22 objects), fmt (one object) and sljit through `libLiveRecomp.a(sljitLir.o)`; it shows no tomlplusplus archive object. Confirm final notice requirements against the final binary. |

`RecompiledFuncs/` is generated from the user's exact US ROM and includes native game functions, TLB page data and the recompiled audio microcode. The ROM is also imported into the app's private container at runtime. A bundle without a `.z64` file may still contain ROM-derived executable content, so a file-list check alone cannot establish a rights-safe distributable. The user-supplied ROM, generated files, saves and gameplay captures stay under ignored `ref/` or `work/`; they must not be committed or copied into notices.

HarkinianPad is a behavior and layout reference, not a linked dependency. Its project-specific code and art are not copied into this app. The Swift touch/menu code and mobile adapters are SquirrelPad sources; the Conker and runtime changes are recorded as local patches against the pinned checkout.

The 2026-09-29 unsigned `iphoneos` diagnostic link map is at ignored `work/ios-mod-load-device-LinkMap.txt`. It identifies 498 object entries, including `librecomp`, `ultramodern`, RT64, Plume, re-spirv, zstd, N64Recomp, Rabbitizer, fmt and two LiveRecomp objects. Most LiveRecomp/sljit symbols are dead stripped, but a destructor and sljit executable-memory free functions remain live. iOS game start no longer calls `ModContext::load_mods`; this does not prove that the final binary has no JIT code. The map is private because it contains personal build paths.

Before any signed handoff or release decision, inspect the final bundled-file inventory and link map, include the required complete notice texts in the package, and review the ROM-derived code, GPL boundary and remaining JIT symbols. Public distribution remains a separate decision.
