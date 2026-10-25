#include "game_module.h"
#include "conker.hpp"
#include <cstdio>
#include <cstring>
#include <dlfcn.h>

namespace {
const SquirrelPadGameModule* module = nullptr;
void* library = nullptr;
}

extern "C" const char* squirrelpad_load_game_module(const char* path) {
    if (module) return nullptr;
    if (!path || !*path) return "The game module is missing. Build this copy with PadMint again.";
    void* candidate = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!candidate) {
        std::fprintf(stderr, "[game module] %s\n", dlerror());
        return "The game module could not load. Build this copy with PadMint and install it again.";
    }
    auto getter = reinterpret_cast<SquirrelPadGetModule*>(dlsym(candidate, "squirrelpad_get_game_module"));
    const auto* value = getter ? getter() : nullptr;
    bool valid = value && value->version == squirrelpad_game_module_version &&
        value->size == sizeof(SquirrelPadGameModule) && value->identity &&
        std::strcmp(value->identity, SQUIRRELPAD_MODULE_ID) == 0 && value->entrypoint && value->audio &&
        value->register_overlays && value->register_tlb_mapped_code && value->map_tlb_code_pages && value->decompress_rom;
#define SQUIRRELPAD_GAME_FUNCTION(address) valid = valid && value->func_##address;
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
    if (!valid) {
        dlclose(candidate);
        return "The game module belongs to a different app build. Build this copy with PadMint again.";
    }
    library = candidate; // Keep code and overlay pointers alive for the lifetime of the app.
    module = value;
    return nullptr;
}

extern "C" void recomp_entrypoint(uint8_t* rdram, recomp_context* ctx) { module->entrypoint(rdram, ctx); }
RspExitReason conker_audio_ucode(uint8_t* rdram, uint32_t address) { return module->audio(rdram, address); }
void conker::register_overlays() { module->register_overlays(); }
void conker::register_tlb_mapped_code() { module->register_tlb_mapped_code(); }
void conker::map_tlb_code_pages(uint8_t* rdram) { module->map_tlb_code_pages(rdram); }
std::vector<uint8_t> conker::decompress_rom(std::span<const uint8_t> rom) { return module->decompress_rom(rom); }
#define SQUIRRELPAD_GAME_FUNCTION(address) \
    extern "C" void squirrelpad_bridge_##address(uint8_t* rdram, recomp_context* ctx) { module->func_##address(rdram, ctx); }
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
