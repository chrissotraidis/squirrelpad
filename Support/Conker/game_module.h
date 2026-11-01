#pragma once
#include <cstddef>
#include <cstdint>
#include <span>
#include <vector>
#include "recomp.h"
#include "librecomp/rsp.hpp"

// One runtime lives in the app. The module owns only translated code and data.
// identity binds this table to the exact source pins, patches and bridge sources.
struct SquirrelPadGameModule {
    uint32_t version;
    uint32_t size;
    const char* identity;
    void (*entrypoint)(uint8_t*, recomp_context*);
    RspUcodeFunc* audio;
    void (*register_overlays)();
    void (*register_tlb_mapped_code)();
    void (*map_tlb_code_pages)(uint8_t*);
    std::vector<uint8_t> (*decompress_rom)(std::span<const uint8_t>);
#define SQUIRRELPAD_GAME_FUNCTION(address) void (*func_##address)(uint8_t*, recomp_context*);
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
};
using SquirrelPadGetModule = const SquirrelPadGameModule*();
constexpr uint32_t squirrelpad_game_module_version = 1;
