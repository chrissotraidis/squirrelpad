#include <algorithm>
#include <atomic>
#include <cstdint>

namespace {
std::atomic<uint16_t> buttons{0};
std::atomic<float> stick_x{0.0f};
std::atomic<float> stick_y{0.0f};
}

extern "C" void squirrelpad_touch_button(uint16_t mask, int pressed) {
    if (pressed) {
        buttons.fetch_or(mask);
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
    stick_x.store(0.0f);
    stick_y.store(0.0f);
}

extern "C" bool squirrelpad_mobile_get_input(int player, uint16_t *out_buttons,
                                                float *out_x, float *out_y) {
    if (player != 0) { return false; }
    *out_buttons = buttons.load();
    *out_x = stick_x.load();
    *out_y = stick_y.load();
    return true;
}
