// Adapted for SquirrelPad from ConkerBFDReloaded v1.3.1,
// commit 90a014dbac5019c20a1b7a820ea16a1f0553052f. See LICENSE.txt and THIRD_PARTY_LICENSE.txt.
#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include "mobile_enhancements.h"
namespace {
using clock = std::chrono::steady_clock;
constexpr uint16_t button_r = 0x10, button_l = 0x20;
std::atomic<float> dot_raise{0};
std::atomic<uint16_t> buttons_held{0};
std::atomic<int64_t> look_button_at{0}, look_alone_since{0}, look_last_ran{0}, aimed_at{0}, active_at{0};
}
void conker::crosshair::aiming(bool zoomed) {
    active_at = clock::now().time_since_epoch().count();
    dot_raise = 0.0f;
    if (!zoomed) {
        aimed_at = clock::now().time_since_epoch().count();
    }
}

void conker::crosshair::look_mode(float vertical_fov) {
    // Only when the game put Conker in the look mode to throw (the knives in the barn), not when the
    // player looks around with R or L: not while either is held, nor for a moment after (the camera
    // swings back for a few frames once let go), and only once the look mode has run that way for a
    // little while.
    const int64_t now = clock::now().time_since_epoch().count();
    const auto ticks = [](auto d) { return (int64_t)std::chrono::duration_cast<clock::duration>(d).count(); };
    if (now - look_last_ran.load() > ticks(std::chrono::milliseconds(200))) {
        look_alone_since = now; // (a new spell of the look mode)
    }
    look_last_ran = now;
    active_at = now;
    if ((buttons_held.load() & (button_r | button_l)) != 0 || now - look_button_at.load() < ticks(std::chrono::milliseconds(700))) {
        look_alone_since = now;
        return;
    }
    if (now - look_alone_since.load() >= ticks(std::chrono::milliseconds(250))) {
        aimed_at = now;
        // Throws from the look mode fly above the view's centre: measured on the knives in the barn
        // (the knife lands 0.41 of the way from the centre to the top, at the game's 50 degrees),
        // a fixed angle above it, so it's placed by the field of view in use.
        constexpr float throw_angle = 10.8f * 3.14159265f / 180.0f;
        float raise = 0.0f;
        if (vertical_fov > 1.0f && vertical_fov < 170.0f) {
            raise = std::tan(throw_angle) / std::tan(vertical_fov * 0.5f * 3.14159265f / 180.0f);
        }
        dot_raise = std::clamp(raise, 0.0f, 0.9f);
    }
}

void conker::crosshair::set_buttons(uint16_t buttons) {
    buttons_held = buttons;
    if ((buttons & (button_r | button_l)) != 0) {
        look_button_at = clock::now().time_since_epoch().count();
    }
}

extern "C" float squirrelpad_crosshair_raise() {
    const auto last = clock::time_point(clock::duration(aimed_at.load()));
    if (!squirrelpad_option(Crosshair) || conker::qol::cutscene_playing() ||
        clock::now() - last >= std::chrono::milliseconds(100)) return -1;
    return dot_raise.load();
}

bool conker::crosshair::aiming_active() {
    return clock::now() - clock::time_point(clock::duration(active_at.load())) < std::chrono::milliseconds(100);
}
void conker::crosshair::reset() {
    active_at=0; aimed_at=0; look_last_ran=0; look_alone_since=0; look_button_at=0; buttons_held=0;
}
