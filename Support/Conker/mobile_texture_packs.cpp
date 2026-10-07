#include "mobile_texture_packs.h"
#include <atomic>
#include <mutex>
#include <regex>
#include "common/rt64_filesystem_zip.h"
#include "common/rt64_replacement_database.h"
#include "stb/stb_image.h"

namespace {
std::mutex requestMutex;
SquirrelPadTextureRequest request{{}, 0};
std::atomic<int> status{0};
std::atomic<unsigned> matches{0};
bool safePath(const std::string &s) {
    if (s.empty() || s.front() == '/' || s.find('\\') != s.npos || s.find(':') != s.npos) return false;
    for (const auto &part : std::filesystem::path(s)) if (part == ".." || part == ".") return false;
    return true;
}
}
// Return the number of resolved replacements; negative results are user-facing errors.
// Archives stay zipped: never extract or execute their contents.
extern "C" int squirrelpad_validate_texture_pack(const char *path) {
    try {
        if (!path || std::filesystem::file_size(path) > 256ull * 1024 * 1024) return -1;
        auto fs = RT64::FileSystemZip::create(path, "");
        if (!fs) return -2;
        size_t total = 0, count = 0;
        for (const auto &name : *fs) {
            const auto size = fs->getSize(name);
            if (!safePath(name) || ++count > 8192 || size > 32ull * 1024 * 1024) return -3;
            total += size;
            if (total > 512ull * 1024 * 1024) return -3;
            if (name == "rt64-low-mip-cache.bin") return -4;
        }
        if (!fs->exists("rt64.json") || fs->getSize("rt64.json") > 4 * 1024 * 1024) return -4;
        std::vector<uint8_t> bytes;
        if (!fs->load("rt64.json", bytes)) return -4;
        const auto data = json::parse(bytes);
        const auto &config = data.at("configuration");
        if (config.value("hashVersion", 0) != 5 || config.value("configurationVersion", 0) != 3 ||
            config.value("autoPath", "rt64") != "rt64") return -4;
        RT64::ReplacementDatabase db = data;
        // PNG-only initially: bounds can be validated before allocating GPU textures.
        // Omit mip caches and DDS rather than claiming support for unchecked payloads.
        if (fs->exists(RT64::ReplacementLowMipCacheFilename)) return -4;
        if (db.textures.empty() || db.textures.size() > 4096) return -5;
        const std::regex hash("^[0-9a-fA-F]{16}$");
        for (const auto &t : db.textures) if (!safePath(t.path) || !std::regex_match(t.hashes.rt64, hash)) return -5;
        std::unordered_map<uint64_t, RT64::ReplacementResolvedPath> resolved;
        std::vector<uint64_t> missing;
        db.resolvePaths(fs.get(), 0, resolved, false, &missing);
        if (!missing.empty() || resolved.size() != db.textures.size()) return -5;
        uint64_t pixels = 0;
        for (const auto &[key, texture] : resolved) {
            if (!safePath(texture.relativePath) || std::filesystem::path(texture.relativePath).extension() != ".png") return -6;
            if (!fs->load(texture.relativePath, bytes)) return -6;
            int w = 0, h = 0, components = 0;
            if (!stbi_info_from_memory(bytes.data(), int(bytes.size()), &w, &h, &components) ||
                w <= 0 || h <= 0 || w > 4096 || h > 4096) return -6;
            pixels += uint64_t(w) * h;
            if (pixels > 64ull * 1024 * 1024) return -3;
            auto *decoded = stbi_load_from_memory(bytes.data(), int(bytes.size()), &w, &h, &components, 4);
            if (!decoded) return -6;
            stbi_image_free(decoded);
        }
        return int(resolved.size());
    } catch (...) { return -2; }
}
extern "C" void squirrelpad_set_texture_pack(const char *path) {
    std::lock_guard lock(requestMutex);
    std::string next = path ? path : "";
    if (request.path == next) return;
    request.path = std::move(next);
    ++request.revision;
    status.store(request.path.empty() ? 0 : 1);
    matches.store(0);
}
SquirrelPadTextureRequest squirrelpad_texture_request() {
    std::lock_guard lock(requestMutex); return request;
}
void squirrelpad_texture_result(int result, unsigned matched) { status.store(result); matches.store(matched); }
extern "C" int squirrelpad_texture_status() { return status.load(); }
extern "C" unsigned squirrelpad_texture_matches() { return matches.load(); }
