#include <cstdlib>
#include <atomic>
#include <condition_variable>
#include <mutex>
#include <string>
#include "mobile_graphics.h"

int conker_native_main(int argc, char **argv);
extern "C" void squirrelpad_rt64_release_probe();
extern "C" void squirrelpad_audio_stop();
extern "C" void squirrelpad_audio_set_active(bool active);
extern "C" void squirrelpad_set_clock_paused(bool paused);

namespace {
std::mutex activity_mutex;
std::condition_variable activity_changed;
bool active = true;
std::atomic<uint32_t> graphics_options{squirrelpad_graphics_options(2, 2, true)};
std::atomic<uint32_t> visual_options{0};
}

extern "C" void squirrelpad_set_visual_effects(int color, int glow, int clarity, int crt) {
    visual_options.store(squirrelpad_visual_options(color, glow, clarity, crt), std::memory_order_relaxed);
}

extern "C" uint32_t squirrelpad_get_visual_effects() {
    return visual_options.load(std::memory_order_relaxed);
}

extern "C" void squirrelpad_set_graphics(int resolution, int filter, bool smoothing) {
    graphics_options.store(squirrelpad_graphics_options(resolution, filter, smoothing), std::memory_order_relaxed);
}

extern "C" uint32_t squirrelpad_get_graphics() {
    return graphics_options.load(std::memory_order_relaxed);
}

extern "C" void squirrelpad_set_active(bool value) {
    if (!value) squirrelpad_audio_set_active(false);
    squirrelpad_set_clock_paused(!value);
    {
        std::lock_guard lock(activity_mutex);
        active = value;
    }
    if (value) squirrelpad_audio_set_active(true);
    if (value) activity_changed.notify_all();
}

extern "C" void squirrelpad_wait_while_inactive() {
    std::unique_lock lock(activity_mutex);
    activity_changed.wait(lock, [] { return active; });
}

extern "C" int squirrelpad_run_core(const char *rom, const char *data_dir, int seconds) {
    if (rom == nullptr || data_dir == nullptr || seconds < 0) {
        return -1;
    }
    setenv("SQUIRRELPAD_DATA_DIR", data_dir, 1);
    squirrelpad_rt64_release_probe();
    std::string duration = std::to_string(seconds);
    char app[] = "SquirrelPad";
    char rom_option[] = "--rom";
    char duration_option[] = "--seconds";
    char headless_option[] = "--headless";
    char *args[] = { app, rom_option, const_cast<char *>(rom), duration_option, duration.data(), headless_option };
    const int result = conker_native_main(6, args);
    squirrelpad_audio_stop();
    return result;
}
