// Adapted for SquirrelPad from ConkerBFDReloaded v1.3.1,
// commit 90a014dbac5019c20a1b7a820ea16a1f0553052f. See LICENSE.txt and THIRD_PARTY_LICENSE.txt.
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include "recomp.h"
#include "mobile_enhancements.h"
namespace { constexpr int32_t current_room = (int32_t)0x800BE9F0; }
namespace {
    enum class Skip { Off, Logos, Bar, PressingStart, Done };
    std::atomic<Skip> skip_state{ Skip::Off };
    constexpr uint32_t legal_screens = 0x25, bar = 0x1D;
    constexpr int32_t room_timer = (int32_t)0x800E0A90; // refreshes since the room began
    constexpr int32_t logo_frames_before_skip = 10;     // earlier, the bar never loads (the mod's measurement)
    constexpr int32_t press_start_at = 20, show_menu_at = 60; // bar room timer

    void finish_skip() {
        skip_state = Skip::Done;

    }
}

extern "C" void func_1501C730(uint8_t* rdram, recomp_context* ctx);

// func_15007A70(a, b, room)'s entry: the game changing rooms.
extern "C" void conker_room_change(uint8_t* rdram, recomp_context* ctx) {
    uint32_t room = (uint32_t)(ctx->r6 & 0xFFFF);
    static const bool probe = std::getenv("CONKER_PROBE") != nullptr;
    if (probe) {
        std::printf("[room] %02X -> %02X\n", (uint32_t)MEM_W(0, current_room), room);
    }
    Skip state = skip_state;
    if (state == Skip::Off && room == legal_screens && conker::skip_intro()) {
        skip_state = Skip::Logos;

    } else if (state != Skip::Off && state != Skip::Done && room != legal_screens && room != bar) {
        finish_skip(); // somewhere unexpected: just show it
    }
}

// func_151DE6D4 (the logos' frame, boot phase 0) at its return: after 10 frames, ask for
// the bar in place of the opening, as the logos' own end asks for the opening.
extern "C" void conker_skip_intro_logos(uint8_t* rdram, recomp_context* ctx) {
    if (skip_state != Skip::Logos || MEM_W(0, room_timer) < logo_frames_before_skip) {
        return;
    }
    skip_state = Skip::Bar;
    MEM_B(0, (int32_t)0x8008FE28) = 2;
    MEM_B(0, (int32_t)0x800E0B94) = 1; // boot phase
    MEM_B(0, (int32_t)0x800D2E40) = 0;
    // func_1501C730(6, bar, 0, 0, 1), from a hook: registers saved and put back, the fifth
    // argument in this function's outgoing argument space.
    recomp_context saved = *ctx;
    int32_t saved_arg = MEM_W(0x10, ctx->r29);
    ctx->r4 = 6;
    ctx->r5 = (int32_t)bar;
    ctx->r6 = 0;
    ctx->r7 = 0;
    MEM_W(0x10, ctx->r29) = 1;
    func_1501C730(rdram, ctx);
    MEM_W(0x10, saved.r29) = saved_arg;
    *ctx = saved;
    MEM_B(0, (int32_t)0x800E0B96) = 0xFF;
}

// func_15007A70 at its return, the room loaded: in the bar, what the opening's end
// (func_151DE85C) would have left behind.
extern "C" void conker_skip_intro_room_loaded(uint8_t* rdram, recomp_context* ctx) {
    if (skip_state != Skip::Bar || (uint32_t)MEM_W(0, current_room) != bar || MEM_W(0, room_timer) > 5) {
        return;
    }
    MEM_B(0, (int32_t)0x800D2E40) = 0;
    MEM_B(0, (int32_t)0x800E0B94) = 3; // boot phase
    MEM_B(0, (int32_t)0x8008FD80) = 1;
    MEM_B(0, (int32_t)0x8008FE28) = 2;
    MEM_B(0, (int32_t)0x8008FDA4) = 0;
    int32_t game_state = MEM_W(0, (int32_t)0x8008FDD4);
    if (game_state != 0) {
        MEM_B(0x3E, game_state) = 0;
        MEM_B(0x2B, game_state) = 5;
        MEM_B(0x2C, game_state) = 5;
    }
}

// Every screen refresh: in the bar, press Start once it's running, then show the menu.
void conker::skip_intro_on_vi(uint8_t* rdram) {
    Skip state = skip_state;
    if ((state != Skip::Bar && state != Skip::PressingStart) || (uint32_t)MEM_W(0, current_room) != bar) {
        return;
    }
    int32_t timer = MEM_W(0, room_timer);
    if (state == Skip::Bar && timer >= press_start_at) {
        skip_state = Skip::PressingStart;
    } else if (state == Skip::PressingStart && timer >= show_menu_at) {
        finish_skip();
    }
}

bool conker::skip_intro_pressing_start() {
    return skip_state == Skip::PressingStart;
}
