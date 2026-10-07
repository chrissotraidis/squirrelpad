// Static iOS adaptations of sciaschi/CBFD-Recompiled mods/cheats and
// mods/skip_cutscenes at c55359c. Same game addresses/conditions; no JIT.
#include <atomic>
#include <cstdio>
#include "recomp.h"
namespace { std::atomic<unsigned> options{0}; }
extern "C" void squirrelpad_set_mods(unsigned flags) { options.store(flags & 31); }
extern "C" void squirrelpad_mod_frame(uint8_t *rdram) {
    const auto flags = options.load();
    auto &health = MEM_BU(0, S32(0x800CC49A));
    auto &lives = MEM_BU(0, S32(0x800D2144));
    auto &cash = MEM_W(0, S32(0x800D2148));
    if ((flags & 1) && health != 0 && health < 6) {
        std::printf("[mobile mods] health %u -> 6\n", unsigned(health)); health = 6;
    }
    if ((flags & 2) && lives < 9) {
        std::printf("[mobile mods] lives %u -> 9\n", unsigned(lives)); lives = 9;
    }
    if ((flags & 4) && cash < 9999) {
        std::printf("[mobile mods] cash %d -> 9999\n", int(cash)); cash = 9999;
    }
}
extern "C" int squirrelpad_mod_skip(uint8_t *rdram, int i) {
    const auto flags = options.load();
    if (!(flags & 8)) return -1; // Execute the untouched original routine.
    if (i < 0 || i >= 8) return 0;
    const auto scene = MEM_W(0, S32(0x800BE9F0));
    auto &sceneSkip = MEM_B(0, S32(0x8008FD84));
    const auto buttons = MEM_HU(0, S32(0x800BE710));
    int result = 0;
    if (scene == 0x1D) {
        if (sceneSkip != 0) { sceneSkip = 0; return 1; }
        if (MEM_BU(0, S32(0x800C35E8)) != 5) return 0;
    }
    if (scene == 0x21) result = (buttons & 0x1000) && MEM_W(0, S32(0x800C35B0)) >= 0x12D;
    else if (buttons & 0x20) {
        if (MEM_BU(0, S32(0x800C3C9C)) && !(flags & 16)) return 0;
        result = MEM_BU(0, S32(0x800D2E40)) || MEM_BU(0, S32(0x800C3C99)) ||
            (MEM_W(i * 4, S32(0x800C35B0)) + 0x1E < MEM_W(i * 4, S32(0x800C3640)));
    }
    if (result) std::printf("[mobile mods] skipped cutscene scene=%x slot=%d\n", unsigned(scene), i);
    return result;
}
