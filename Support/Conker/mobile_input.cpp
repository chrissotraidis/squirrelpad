#include <algorithm>
#include <atomic>
#include <cstdint>
#include "Reloaded/mobile_enhancements.h"

namespace {
std::atomic<uint16_t> buttons{0};
std::atomic<uint16_t> pending_touch_presses{0};
std::atomic<float> stick_x{0.0f};
std::atomic<float> stick_y{0.0f};
std::atomic<uint16_t> controller_buttons{0};
std::atomic<float> controller_x{0.0f};
std::atomic<float> controller_y{0.0f};
std::atomic<float> camera_x{0}, camera_y{0};
}

extern "C" void squirrelpad_touch_button(uint16_t mask, int pressed) {
    if (pressed) {
        buttons.fetch_or(mask);
        pending_touch_presses.fetch_or(mask);
    } else {
        buttons.fetch_and(static_cast<uint16_t>(~mask));
    }
}

extern "C" void squirrelpad_touch_stick(float x, float y) {
    stick_x.store(std::clamp(x, -1.0f, 1.0f));
    stick_y.store(std::clamp(y, -1.0f, 1.0f));
}

extern "C" void squirrelpad_touch_clear() {
    buttons.store(0);
    pending_touch_presses.store(0);
    stick_x.store(0.0f);
    stick_y.store(0.0f);
}

extern "C" void squirrelpad_controller_set_state(uint16_t mask, float x, float y) {
    controller_buttons.store(mask);
    controller_x.store(std::clamp(x, -1.0f, 1.0f));
    controller_y.store(std::clamp(y, -1.0f, 1.0f));
}

extern "C" void squirrelpad_controller_camera(float x,float y) {
    camera_x.store(std::clamp(x,-1.0f,1.0f)); camera_y.store(std::clamp(y,-1.0f,1.0f));
}
extern "C" void squirrelpad_camera_axes(float* x,float* y) { *x=camera_x.load(); *y=camera_y.load(); }
extern "C" void squirrelpad_controller_clear() {
    squirrelpad_controller_camera(0,0);
    squirrelpad_enhancement_reset();
    squirrelpad_controller_set_state(0, 0.0f, 0.0f);
}

extern "C" bool squirrelpad_mobile_get_input(int player, uint16_t *out_buttons,
                                                float *out_x, float *out_y) {
    if (player != 0) { return false; }
    // Preserve a touch press that begins and ends between the game's 30 Hz polls.
    // Consume it once; held buttons continue to use their live state.
    const uint16_t touch_buttons = buttons.load() | pending_touch_presses.exchange(0);
    *out_buttons = touch_buttons | controller_buttons.load();
    const float touch_x = stick_x.load();
    const float touch_y = stick_y.load();
    const float pad_x = controller_x.load();
    const float pad_y = controller_y.load();
    if (pad_x * pad_x + pad_y * pad_y > touch_x * touch_x + touch_y * touch_y) {
        *out_x = pad_x;
        *out_y = pad_y;
    } else {
        *out_x = touch_x;
        *out_y = touch_y;
    }
    // Preserve touch C-buttons; avoid duplicate digital right-stick movement
    // while orbiting or aiming. Fixed cameras and menus retain C-button mapping.
    if (conker::free_camera_enabled() && (conker::normal_camera() || conker::crosshair::aiming_active())) {
        *out_buttons = (*out_buttons & ~uint16_t(0xF)) | (touch_buttons & 0xF);
    }
    squirrelpad_enhancement_input(out_buttons,out_x,out_y);
    return true;
}
