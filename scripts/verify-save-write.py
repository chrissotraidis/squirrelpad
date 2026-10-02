#!/usr/bin/env python3
"""Compile the real runtime save writer and inject a short-write failure on macOS."""
import argparse
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("runtime", type=Path, help="Patched N64ModernRuntime checkout")
args = parser.parse_args()
runtime = args.runtime.resolve()
source = (runtime / "librecomp/src/pi.cpp").read_text()
start = source.index("void update_save_file() {")
end = source.index("\nextern std::atomic_bool exited;", start)
writer = source[start:end]

# Use the actual function body and actual files.cpp. Only runtime context and
# the error-dialog callback are substituted; no game/ROM data is involved.
harness = r'''
#include "files.hpp"
#include <csignal>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <mutex>
#include <string>
#include <vector>
#include <sys/resource.h>
#include <sys/wait.h>
#include <unistd.h>
struct {
    std::mutex save_buffer_mutex;
    std::vector<char> save_buffer;
} save_context;
static std::filesystem::path save_path;
static int error_count = 0;
namespace ultramodern {
std::filesystem::path get_save_file_path() { return save_path; }
namespace error_handling {
void message_box(const char*) { ++error_count; }
}
}
''' + writer + r'''
static std::string read(const std::filesystem::path& path) {
    std::ifstream file(path, std::ios::binary);
    return {std::istreambuf_iterator<char>(file), {}};
}
int main(int argc, char** argv) {
    if (argc != 2) return 10;
    save_path = std::filesystem::path(argv[1]) / "synthetic-eeprom.bin";
    save_context.save_buffer.assign(2048, 'Z');
    update_save_file();
    save_context.save_buffer.assign(2048, 'A');
    update_save_file();
    if (error_count || read(save_path) != std::string(2048, 'A')) return 11;
    save_context.save_buffer.assign(2048, 'B');
    for (bool first_save : {true, false}) {
      pid_t child = fork();
      if (child < 0) return 12;
      if (!child) {
        // First save has no live file or backup. A failed temp write must not
        // install a partial EEPROM as the live save.
        if (first_save) save_path = std::filesystem::path(argv[1]) / "first-save.bin";
        signal(SIGXFSZ, SIG_IGN);
        rlimit limit{512, 512};
        if (setrlimit(RLIMIT_FSIZE, &limit)) _exit(13);
        update_save_file();
        bool preserved = first_save ? !std::filesystem::exists(save_path)
                                    : read(save_path) == std::string(2048, 'A');
        bool backup_preserved = first_save ? !std::filesystem::exists(save_path.string() + ".bak")
                                          : read(save_path.string() + ".bak") == std::string(2048, 'Z');
        preserved = preserved && backup_preserved;
        if (!preserved || error_count != 1) {
            std::cerr << "rejected test: live bytes=" << read(save_path).size()
                      << "; errors=" << error_count << '\n';
        }
        _exit(preserved && error_count == 1 ? 0 : 14);
      }
      int status = 0;
      if (waitpid(child, &status, 0) != child || !WIFEXITED(status) || WEXITSTATUS(status)) {
        std::cerr << "FAIL: short write damaged save/backup or missed error; first=" << first_save << "; child status " << status << '\n';
        return 15;
      }
    }
    // After the failed write, an unrestricted retry must recover normally.
    update_save_file();
    if (error_count || read(save_path) != std::string(2048, 'B') ||
        read(save_path.string() + ".bak") != std::string(2048, 'A') ||
        std::filesystem::exists(save_path.string() + ".temp")) return 16;
    std::cout << "PASS: short first/replacement writes preserved live and backup; normal retry retained backup\n";
}
'''
with tempfile.TemporaryDirectory(prefix="squirrelpad-save-write-") as directory:
    directory = Path(directory)
    test_source = directory / "test.cpp"
    test_source.write_text(harness)
    executable = directory / "test"
    sdk = subprocess.check_output(["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True).strip()
    subprocess.run(["xcrun", "--sdk", "macosx", "clang++", "-std=c++20", "-pthread", "-isysroot", sdk,
                    "-I", str(runtime / "librecomp/include/librecomp"),
                    str(test_source), str(runtime / "librecomp/src/files.cpp"),
                    "-o", str(executable)], check=True)
    subprocess.run([str(executable), str(directory)], check=True)
