#!/usr/bin/env python3
"""Native-Mac synthetic ABI guard/forwarding check; never includes generated game code."""
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "work/CBFD-Recompiled/tools/N64ModernRuntime"
INCLUDES = [ROOT / "Support/Conker", ROOT / "work/CBFD-Recompiled/host/src",
            RUNTIME / "N64Recomp/include", RUNTIME / "librecomp/include", RUNTIME / "ultramodern/include",
            RUNTIME / "thirdparty", RUNTIME / "thirdparty/sse2neon"]
FLAGS = ["xcrun", "clang++", "-std=c++20", "-DSQUIRRELPAD_MODULE_ID=\"review-identity\"",
         *["-I" + str(path) for path in INCLUDES]]
MODULE = r'''
#include "game_module.h"
#include <algorithm>
static void game(uint8_t* bytes, recomp_context* ctx) { ++bytes[0]; ctx->r2 = 42; }
static RspExitReason audio(uint8_t*, uint32_t address) { return address == 123 ? RspExitReason::Broke : RspExitReason::Invalid; }
static void noargs() {}
static void map(uint8_t* bytes) { bytes[1] = 17; }
static std::vector<uint8_t> decompress(std::span<const uint8_t> rom) { return {rom.rbegin(), rom.rend()}; }
extern "C" __attribute__((visibility("default")))
const SquirrelPadGameModule* squirrelpad_get_game_module() {
    static SquirrelPadGameModule table{
        squirrelpad_game_module_version, sizeof(SquirrelPadGameModule), "review-identity",
        game, audio, noargs, noargs, map, decompress,
#define SQUIRRELPAD_GAME_FUNCTION(address) game,
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
    };
    /*MUTATE*/
    return &table;
}
'''
MAIN = r'''
#include "game_module.h"
#include "conker.hpp"
#include <cstdio>
#include <cstring>
extern "C" const char* squirrelpad_load_game_module(const char*);
extern "C" void recomp_entrypoint(uint8_t*, recomp_context*);
RspExitReason conker_audio_ucode(uint8_t*, uint32_t);
#define SQUIRRELPAD_GAME_FUNCTION(address) extern "C" void squirrelpad_bridge_##address(uint8_t*, recomp_context*);
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
int main(int argc,char**argv) {
    if (argc == 3) {
        if (!squirrelpad_load_game_module(argv[1])) return 20;
        ++argv; --argc;
    }
    const char* error = squirrelpad_load_game_module(argc > 1 ? argv[1] : nullptr);
    if (error) { std::puts(error); return 2; }
    uint8_t bytes[3] = {0, 0, 3}; recomp_context ctx{};
    recomp_entrypoint(bytes, &ctx);
    if (ctx.r2 != 42 || bytes[0] != 1) return 21;
    if (conker_audio_ucode(bytes, 123) != RspExitReason::Broke) return 22;
    conker::register_overlays(); conker::register_tlb_mapped_code(); conker::map_tlb_code_pages(bytes);
    if (bytes[1] != 17) return 23;
    auto data = conker::decompress_rom(std::span<const uint8_t>(bytes, 3));
    if (data.size() != 3 || data[0] != 3 || data[1] != 17 || data[2] != 1) return 24;
    int count = 1;
#define SQUIRRELPAD_GAME_FUNCTION(address) squirrelpad_bridge_##address(bytes, &ctx); ++count;
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
    if (bytes[0] != count) return 25;
    if (squirrelpad_load_game_module("missing-after-success")) return 26;
    std::puts("all ABI forwards and lifetime retention passed");
}
'''


def main():
    cases = {"good": "", "bad_version": "table.version = 99;", "bad_size": "table.size = 0;",
             "bad_identity": 'table.identity = "wrong";', "null_identity": "table.identity = nullptr;",
             "null_entry": "table.entrypoint = nullptr;", "null_audio": "table.audio = nullptr;",
             "null_function": "table.func_15044380 = nullptr;", "null_table": "return nullptr;"}
    results = {}
    with tempfile.TemporaryDirectory(prefix="squirrelpad ABI probe ") as temporary:
        work = Path(temporary)
        main_cpp = work / "main.cpp"
        main_cpp.write_text(MAIN)
        loader = work / "loader"
        subprocess.run([*FLAGS, ROOT / "Support/Conker/game_module_loader.cpp", main_cpp, "-o", loader], check=True)
        for name, mutate in {**cases, "no_getter": ""}.items():
            path = work / (name + ".cpp")
            path.write_text(MODULE.replace("/*MUTATE*/", mutate) if name != "no_getter"
                            else 'extern "C" __attribute__((visibility("default"))) int unused_export() {return 1;}')
            subprocess.run([*FLAGS, "-fvisibility=hidden", "-dynamiclib", path, "-o", work / (name + ".dylib")], check=True)
        for name in [*cases, "no_getter", "does-not-exist"]:
            result = subprocess.run([loader, work / (name + ".dylib")], capture_output=True, text=True)
            expected = 0 if name == "good" else 2
            assert result.returncode == expected, (name, result.returncode, result.stdout, result.stderr)
            results[name] = result.returncode
        result = subprocess.run([loader, work / "bad_identity.dylib", work / "good.dylib"], capture_output=True, text=True)
        assert result.returncode == 0, (result.returncode, result.stdout, result.stderr)
        results["retry_after_rejection"] = result.returncode
    report = {"synthetic_native_mac_abi": results, "gameplay": "not-tested", "ios_loading": "not-tested"}
    (ROOT / "work").mkdir(exist_ok=True)
    (ROOT / "work/loader-abi-result.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
