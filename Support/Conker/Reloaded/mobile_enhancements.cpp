#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include "recomp.h"
#include "mobile_enhancements.h"
namespace {
using Clock = std::chrono::steady_clock;
std::atomic<uint32_t> flags{AimInvert};
std::atomic<float> speed{1}, skip_progress{0};
std::atomic<int> cash_mode{0};
std::atomic<uint16_t> raw_buttons{0};
std::atomic<uint64_t> reset_epoch{0};
std::atomic<double> scene_seen{-100}, logical_time{0};
uint64_t input_epoch=0, skip_epoch=0;
double hold_started=-1, last_check=-100;
bool release_required=false;
double now() { return std::chrono::duration<double>(Clock::now().time_since_epoch()).count(); }
}
void squirrelpad_reset_toggles();
bool squirrelpad_option(SquirrelOption option) { return (flags.load() & option) != 0; }
extern "C" void squirrelpad_set_enhancements(uint32_t value, float turn_speed, int cash) {
    if (flags.exchange(value) != value) squirrelpad_enhancement_reset();
    if (std::isfinite(turn_speed)) speed.store(std::clamp(turn_speed, 0.5f, 3.0f));
    cash_mode.store(std::clamp(cash, 0, 2));
}
extern "C" void squirrelpad_enhancement_reset() {
    reset_epoch.fetch_add(1); raw_buttons.store(0); skip_progress.store(0);
}
namespace conker {
bool camera_inverted() { return squirrelpad_option(CameraInvertX); }
bool camera_tilt_inverted() { return squirrelpad_option(CameraInvertY); }
float camera_turn_speed() { return speed.load(); }
bool free_camera_enabled() { return squirrelpad_option(FreeCamera); }
bool free_camera_mouse() { return false; }
bool skip_intro() { return squirrelpad_option(SkipIntro); }
namespace testing { double game_seconds() { return logical_time.load(); } }
namespace qol {
bool ledge_grab() { return squirrelpad_option(LedgeGrab); }
bool longer_spin() { return squirrelpad_option(LongerSpin); }
bool always_show_hud() { return squirrelpad_option(HealthHUD); }
bool toggle_r_look() { return squirrelpad_option(ToggleLook); }
bool toggle_crouch() { return squirrelpad_option(ToggleCrouch); }
bool invert_swimming() { return squirrelpad_option(Swim); }
int walk_button() { return squirrelpad_option(Walk) ? 1 : 0; }
int cash_counter() { return cash_mode.load(); }
bool cutscene_playing() { return now()-scene_seen.load() < 0.25; }
}
}
extern "C" void squirrelpad_enhancement_input(uint16_t* buttons,float* x,float* y) {
    const auto epoch=reset_epoch.load();
    if (epoch!=input_epoch) { squirrelpad_reset_toggles(); conker::look_aim::reset(); input_epoch=epoch; }
    raw_buttons.store(*buttons);
    *buttons=conker::qol::apply_toggles(*buttons);
    conker::qol::apply_walk(*buttons,x,y);
    conker::qol::apply_swim(y);
    conker::crosshair::set_buttons(*buttons);
    conker::look_aim::on_input_poll();
    if (conker::skip_intro_pressing_start()) *buttons |= 0x1000;
}
extern "C" void squirrelpad_enhancement_frame(uint8_t* rdram) {
    // This hook runs on the game thread at 30 Hz, so memory assists never race VI.
    logical_time.store(logical_time.load()+1.0/30.0);
    conker::qol::on_vi_memory(rdram);
    conker::skip_intro_on_vi(rdram);
}
extern "C" void conker_motion_blur(uint8_t*, recomp_context* ctx) {
    if (squirrelpad_option(ReduceMotion)) ctx->r3=0;
}
extern "C" int squirrelpad_skip_buttons(uint16_t pressed, bool enabled) {
    const double time=now();
    scene_seen.store(time);
    const auto epoch=reset_epoch.load();
    if (epoch!=skip_epoch || time-last_check>0.25) { hold_started=-1; release_required=false; skip_epoch=epoch; }
    last_check=time;
    if (!enabled || !squirrelpad_option(HoldSkip)) { skip_progress.store(0); return pressed; }
    if (!(raw_buttons.load() & 0x20)) { hold_started=-1; release_required=false; skip_progress.store(0); return pressed & ~0x20; }
    if (release_required) return pressed & ~0x20;
    if (hold_started<0) hold_started=time;
    const float progress=std::min(1.0, (time-hold_started)/1.2);
    skip_progress.store(progress);
    if (progress<1) return pressed & ~0x20;
    return pressed | 0x20; // Keep ready across slots until a skip actually succeeds.
}
extern "C" void squirrelpad_skip_consumed() { release_required=true; skip_progress.store(0); }
extern "C" float squirrelpad_skip_progress() {
    return conker::qol::cutscene_playing() ? skip_progress.load() : 0;
}

namespace { std::atomic<uint64_t> save_serial{0}; }
extern "C" void squirrelpad_save_completed() { save_serial.fetch_add(1); }
extern "C" uint64_t squirrelpad_save_serial() { return save_serial.load(); }
