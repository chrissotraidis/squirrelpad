// Adapted for SquirrelPad from ConkerBFDReloaded v1.3.1,
// commit 90a014dbac5019c20a1b7a820ea16a1f0553052f. See LICENSE.txt and THIRD_PARTY_LICENSE.txt.
#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <cstring>
#include "recomp.h"
#include "mobile_enhancements.h"
namespace {
using clock = std::chrono::steady_clock;
constexpr uint16_t button_l = 0x20;
int64_t ticks() { return clock::now().time_since_epoch().count(); }
double seconds_since(int64_t t) { return std::chrono::duration<double>(clock::now()-clock::time_point(clock::duration(t))).count(); }
    // Toggle R-Look / Toggle Crouch.
    struct Toggle {
        bool was_down = false;
        bool held = false;
        uint16_t apply(uint16_t buttons, uint16_t button, bool enabled) {
            const bool down = (buttons & button) != 0;
            if (!enabled) {
                held = false;
                was_down = down;
                return buttons;
            }
            if (down && !was_down) {
                held = !held;
            }
            was_down = down;
            return held ? (buttons | button) : (buttons & (uint16_t)~button);
        }
    };
    Toggle toggle_r, toggle_z;
}

uint16_t conker::qol::apply_toggles(uint16_t buttons) {
    constexpr uint16_t button_r = 0x0010, button_z = 0x2000;
    buttons = toggle_r.apply(buttons, button_r, conker::qol::toggle_r_look());
    buttons = toggle_z.apply(buttons, button_z, conker::qol::toggle_crouch());
    return buttons;
}

// Walk Button (Accessibility): while L is held (or after a press, with Toggle), the stick is turned
// down to a gentle push, so the game itself plays Conker's walk (animation 0x01, about a fifth of
// his run's speed; from about half a push the game runs). Steering is the stick's; pushing less goes
// slower still. L does nothing in play (it's only Skip Any Cutscene's hold, in cutscenes); Toggle
// L toggles on a short tap, so holding L to skip never does.
namespace {
    constexpr float walk_stick = 0.3f;
    constexpr double walk_tap_seconds = 0.3; // Toggle L: only a tap this short toggles, on release
    bool walk_toggled = false;
    bool walk_l_was_held = false;
    int64_t walk_l_pressed = 0;     // when L went down
    bool walk_l_in_cutscene = false; // a cutscene played while L was down (Skip Any Cutscene's hold)
    // Only on foot: standing on the ground (flags + 0x100 top byte 0x01) in one of his on-foot
    // animations. Swimming (0x27, also "on the ground") and the air (jumps, the tail spin) keep the
    // whole stick. Set each VI from his object (on_vi_memory), read on the input thread.
    std::atomic<bool> on_foot{ false };
    // Invert Swimming: swimming underwater (animation 0xD1 floating, 0xCE swimming; on the surface
    // he has others, 0x6C, 0x27), where the stick steers like a plane (up dives). Set with on_foot.
    std::atomic<bool> underwater{ false };
    bool on_foot_animation(uint16_t animation) {
        switch (animation) {
            case 0x0F: case 0x49: // standing
            case 0x01: case 0x02: // walking, running
            case 0x21: case 0x36: // turning, landing
            case 0x7A:            // pressed against a wall
            case 0x64: case 0x65: case 0x66: // on a beam: walking, balancing
                return true;
            default:
                return false;
        }
    }
}

static void update_on_foot(uint8_t* rdram) {
    constexpr int32_t player = (int32_t)0x800CC2D0;
    const uint8_t flags = (uint8_t)((uint32_t)MEM_W(0, (gpr)(player + 0x100)) >> 24);
    const uint16_t animation = (uint16_t)((uint32_t)MEM_W(0, (gpr)(player + 0x84)) >> 16);
    on_foot = flags == 0x01 && on_foot_animation(animation);
    underwater = animation == 0xD1 || animation == 0xCE;
}

void conker::qol::apply_swim(float* y) {
    if (conker::qol::invert_swimming() && underwater.load()) {
        *y = -*y;
    }
}

void conker::qol::apply_walk(uint16_t buttons, float* x, float* y) {
    const int mode = conker::qol::walk_button(); // 0 off, 1 hold L, 2 toggle L
    const bool l_held = (buttons & button_l) != 0;
    // A tap toggles when L is let go; a hold never does (holding L to skip a cutscene, even one
    // that starts or ends during the hold).
    if (l_held && !walk_l_was_held) {
        walk_l_pressed = ticks();
        walk_l_in_cutscene = false;
    }
    if (l_held && conker::qol::cutscene_playing()) {
        walk_l_in_cutscene = true;
    }
    if (mode == 2 && !l_held && walk_l_was_held && !walk_l_in_cutscene &&
        !conker::qol::cutscene_playing() && seconds_since(walk_l_pressed) < walk_tap_seconds) {
        walk_toggled = !walk_toggled;
    }
    walk_l_was_held = l_held;
    if (mode != 2) {
        walk_toggled = false;
    }
    const bool walking = (mode == 1) ? l_held : walk_toggled;
    if (walking && on_foot.load()) {
        // Pushed diagonally, a controller reports up to about 1.4 (both axes at their ends), which
        // turned down was still enough for the game to run: the push is capped at a full one first.
        const float push = std::sqrt(*x * *x + *y * *y);
        const float scale = walk_stick / std::max(1.0f, push);
        *x *= scale;
        *y *= scale;
    }
}

// Longer Tail Spin: pressing A again in a jump makes Conker spin his tail: his upward speed (his
// object's + 0x20, D_800CC2D0 is player 1's) is set to 7 and his gravity (+ 0x24) to 1.0, which stays
// until he lands (a jump's is 6.2, standing 5.0). He floats up and glides down. With the option on,
// while he spins (gravity exactly 1.0 or ours, in the air) gravity is lower and he falls more slowly,
// so the spin lasts longer. Set once per VI: the game keeps the value until he lands.
namespace {
    constexpr uint32_t player_object = 0x800CC2D0;
    constexpr float spin_gravity = 1.0f, longer_gravity = 0.55f, longer_fall_speed = -6.0f;
}

void conker::qol::longer_spin_on_vi(uint8_t* rdram) {
    const gpr object = (gpr)(int32_t)player_object;
    auto read = [&](int offset) { uint32_t w = (uint32_t)MEM_W(offset, object); float f; std::memcpy(&f, &w, 4); return f; };
    auto write = [&](int offset, float f) { uint32_t w; std::memcpy(&w, &f, 4); MEM_W(offset, object) = (int32_t)w; };
    const float gravity = read(0x24), height = read(0x28);
    if (!conker::qol::longer_spin()) {
        if (gravity == longer_gravity) write(0x24, spin_gravity);
        return;
    }
    if (height <= 0.0f || (gravity != spin_gravity && gravity != longer_gravity)) {
        return;
    }
    write(0x24, longer_gravity);
    if (read(0x20) < longer_fall_speed) {
        write(0x20, longer_fall_speed);
    }
}

void conker::qol::on_vi_memory(uint8_t* rdram) {
    update_on_foot(rdram);
    conker::qol::longer_spin_on_vi(rdram);
    if (conker::qol::always_show_hud()) MEM_W(0, S32(0x800D2444)) = 240;
}
void squirrelpad_reset_toggles() {
    toggle_r = {}; toggle_z = {}; walk_toggled = false; walk_l_was_held = false;
}
