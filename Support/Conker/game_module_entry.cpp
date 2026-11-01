#include "game_module.h"
#include "conker.hpp"

extern "C" void recomp_entrypoint(uint8_t*, recomp_context*);
RspExitReason conker_audio_ucode(uint8_t*, uint32_t);
#define SQUIRRELPAD_GAME_FUNCTION(address) extern "C" void func_##address(uint8_t*, recomp_context*);
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION

extern "C" __attribute__((visibility("default")))
const SquirrelPadGameModule* squirrelpad_get_game_module() {
    static const SquirrelPadGameModule module{
        squirrelpad_game_module_version, sizeof(SquirrelPadGameModule), SQUIRRELPAD_MODULE_ID,
        recomp_entrypoint, conker_audio_ucode,
        conker::register_overlays, conker::register_tlb_mapped_code,
        conker::map_tlb_code_pages, conker::decompress_rom,
#define SQUIRRELPAD_GAME_FUNCTION(address) func_##address,
#include "game_module_functions.inc"
#undef SQUIRRELPAD_GAME_FUNCTION
    };
    return &module;
}
