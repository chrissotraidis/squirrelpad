// Adapted from sciaschi/CBFD-Recompiled V0.1.5 (MIT), commit
// 5ea55d149eef2ff1ea36718013025c5e67619db9, host/src/ultra_extras.cpp.
// See UPSTREAM_LICENSE.txt for the upstream MIT license.
// Static mobile hooks; the game thread owns sequence-player state.
#include <chrono>
#include "recomp.h"

// A pass of a busy-wait loop in the game (issue #66): func_10008CE8, which starts a
// song on a sequence player, stops the player and then counts up to 2,000,000 (then
// 4,000,000) while it waits for the audio thread to report it stopped. On the N64
// the audio thread preempts the loop; here game threads switch only when one waits
// or yields, so the loop ran out without the audio thread running, and the new song
// went to a player still playing the old one (the bar's music played on after
// loading a save from the menu the game over leads to). conker.toml calls this at
// the head of both loops: it yields for up to 1 ms, letting the audio thread run,
// and counts that as the passes the N64 would have made in the time (about 3,000;
// a pass is some 30 cycles at 93.75 MHz), so the loop still gives up after about as
// long as it would there. The count ($s0) is kept at or under the loop's bound
// ($s1), which both loops end on.
extern "C" void yield_self_1ms(uint8_t* rdram);
extern "C" void conker_spin_wait_pass(uint8_t* rdram, recomp_context* ctx) {
    constexpr uint32_t passes_per_ms = 3000;
    yield_self_1ms(rdram);
    const uint32_t count = (uint32_t)ctx->r16;
    const uint32_t bound = (uint32_t)ctx->r17;
    ctx->r16 = (count < bound && bound - count > passes_per_ms) ? count + passes_per_ms : bound;
}

// A song just started still reads as stopped (issue #66). Starting a song (func_10008CE8) only queues
// an event for the audio thread, and the player says it's stopped (its state, +0x2C, AL_STOPPED)
// until the audio thread has handled it. On the N64 the audio thread runs before the game looks
// again; here it can run later, as threads switch only when one waits. The music manager
// (func_1000D2F8) asked the player a frame later (func_1000853C), found it stopped, took the song
// for finished and freed its channel while it played on: the next song went to that player as if it
// were free, the old one was never stopped (the wind outside the bar went on inside it, after
// skipping the walk in), and the mix-up carried on (the stone dragon's mouth faded the wrong player
// and the level's music played on, very loud). Waiting for the audio thread there doesn't work: it
// takes the song up only once the game goes on. So until it has, the player reads as playing:
// marked as just started when func_10008CE8 starts its song, and the mark cleared once the player
// plays, when the game stops it, or after 500 ms (should the song never start).
namespace {
    constexpr int sequence_players = 3; // D_8003C900
    std::chrono::steady_clock::time_point song_started_at[sequence_players];
    bool song_just_started[sequence_players] = {};
}

// func_10008CE8 at 0x10008EC4, just after it starts the song: its player number is its first
// argument, the byte at $sp + 0x43.
extern "C" void conker_song_started(uint8_t* rdram, recomp_context* ctx) {
    const uint32_t player = MEM_BU(0x43, ctx->r29);
    if (player >= sequence_players) {
        return;
    }
    song_just_started[player] = true;
    song_started_at[player] = std::chrono::steady_clock::now();
}

// func_10008F24 (stop a player) at its start: $a0 the player number.
extern "C" void conker_song_stopped(uint8_t* rdram, recomp_context* ctx) {
    const uint32_t player = (uint32_t)ctx->r4 & 0xFF;
    if (player < sequence_players) {
        song_just_started[player] = false;
    }
}

// func_1000853C (a player's state) at 0x10008560, after reading it: $v0 the state, $a1 the player.
extern "C" void conker_song_state(uint8_t* rdram, recomp_context* ctx) {
    constexpr auto start_limit = std::chrono::milliseconds(500);
    const uint32_t player = (uint32_t)ctx->r5 & 0xFF;
    if (player >= sequence_players || !song_just_started[player]) {
        return;
    }
    if ((int32_t)ctx->r2 != 0 || std::chrono::steady_clock::now() - song_started_at[player] > start_limit) {
        song_just_started[player] = false;
        return;
    }
    ctx->r2 = 1; // AL_PLAYING
}

