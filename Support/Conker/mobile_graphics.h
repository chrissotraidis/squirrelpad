#pragma once

#include <cstdint>

// One atomic word keeps a complete UI selection together across threads.
constexpr uint32_t squirrelpad_graphics_options(int resolution, int filter, bool smoothing) {
    const auto scale = (resolution >= 1 && resolution <= 3) ? resolution : 2;
    const auto display = (filter >= 0 && filter <= 2) ? filter : 2;
    return uint32_t(scale | (display << 4) | (int(smoothing) << 8));
}

extern "C" uint32_t squirrelpad_get_graphics();
