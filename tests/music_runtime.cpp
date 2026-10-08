#include <cassert>
#include <chrono>
#include <thread>
#include <vector>
#include "recomp.h"

extern "C" void conker_spin_wait_pass(uint8_t*, recomp_context*);
extern "C" void conker_song_started(uint8_t*, recomp_context*);
extern "C" void conker_song_stopped(uint8_t*, recomp_context*);
extern "C" void conker_song_state(uint8_t*, recomp_context*);
static unsigned yields = 0;
extern "C" void yield_self_1ms(uint8_t*) { ++yields; }

int main() {
    std::vector<uint8_t> memory(8 * 1024 * 1024);
    auto* rdram = memory.data();
    recomp_context ctx{};
    ctx.r29 = S32(0x80001000);
    auto start = [&](unsigned player) {
        MEM_B(0x43, ctx.r29) = player;
        conker_song_started(rdram, &ctx);
    };
    auto state = [&](unsigned player, unsigned actual) {
        ctx.r5 = player;
        ctx.r2 = actual;
        conker_song_state(rdram, &ctx);
        return ctx.r2;
    };
    // A queued song must not be mistaken for a finished song; players are independent.
    assert(state(0, 0) == 0);
    start(0);
    assert(state(0, 0) == 1);
    assert(state(1, 0) == 0);
    assert(state(0, 1) == 1);
    assert(state(0, 0) == 0); // Audio thread acknowledged the start.
    start(1);
    ctx.r4 = 1;
    conker_song_stopped(rdram, &ctx);
    assert(state(1, 0) == 0);
    start(2);
    assert(state(2, 0) == 1);
    std::this_thread::sleep_for(std::chrono::milliseconds(550));
    assert(state(2, 0) == 0); // A song that never starts cannot stay alive forever.
    start(3);
    assert(state(3, 0) == 0);
    ctx.r4 = 255;
    conker_song_stopped(rdram, &ctx);
    // Both wait loops must yield and finish at the original bound without overflow.
    ctx.r16 = 0;
    ctx.r17 = 2000000;
    conker_spin_wait_pass(rdram, &ctx);
    assert(ctx.r16 == 3000 && yields == 1);
    ctx.r16 = 1999999;
    conker_spin_wait_pass(rdram, &ctx);
    assert(ctx.r16 == 2000000 && yields == 2);
    ctx.r16 = 4000000;
    ctx.r17 = 4000000;
    conker_spin_wait_pass(rdram, &ctx);
    assert(ctx.r16 == 4000000 && yields == 3);
    ctx.r16 = 0xfffffff0;
    ctx.r17 = 0xffffffff;
    conker_spin_wait_pass(rdram, &ctx);
    assert(ctx.r16 == 0xffffffff && yields == 4);
}
