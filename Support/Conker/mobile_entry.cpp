#include <cstdlib>
#include <string>

int conker_native_main(int argc, char **argv);
extern "C" void squirrelpad_rt64_release_probe();
extern "C" void squirrelpad_audio_stop();

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
