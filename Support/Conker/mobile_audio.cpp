#include <AudioToolbox/AudioToolbox.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <limits>
#include <mutex>

namespace {
constexpr size_t channels = 2;
constexpr size_t frame_bytes = channels * sizeof(int16_t);
constexpr size_t one_game_buffer = 736;
// The Simulator can fall into repeated underruns if playback has no spare buffer.
constexpr size_t playback_reserve = one_game_buffer + one_game_buffer / 2;

std::mutex audio_mutex;
AudioQueueRef queue = nullptr;
std::atomic<size_t> queued_frames{0};
std::atomic<size_t> completed_nonzero_buffers{0};
std::atomic<bool> logged_completion{false};
std::atomic<int64_t> last_buffer_boundary_ns{0};
std::atomic<bool> needs_rebuffer{false};
uint32_t sample_rate = 0;
bool started = false;
bool logged_samples = false;

int64_t steady_now_ns() {
    return std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
}

void output_done(void *, AudioQueueRef audio_queue, AudioQueueBufferRef buffer) {
    const size_t frames = buffer->mAudioDataByteSize / frame_bytes;
    size_t old = queued_frames.load(std::memory_order_relaxed);
    while (!queued_frames.compare_exchange_weak(old, old > frames ? old - frames : 0,
                                                std::memory_order_relaxed)) {}
    if (old <= frames) {
        needs_rebuffer.store(true, std::memory_order_relaxed);
    }
    last_buffer_boundary_ns.store(steady_now_ns(), std::memory_order_relaxed);
    if (buffer->mUserData != nullptr) {
        completed_nonzero_buffers.fetch_add(1, std::memory_order_relaxed);
    }
    AudioQueueFreeBuffer(audio_queue, buffer);
}

void stop_locked() {
    if (queue != nullptr) {
        AudioQueueStop(queue, true);
        AudioQueueDispose(queue, true);
        queue = nullptr;
    }
    queued_frames.store(0, std::memory_order_relaxed);
    last_buffer_boundary_ns.store(0, std::memory_order_relaxed);
    needs_rebuffer.store(false, std::memory_order_relaxed);
    completed_nonzero_buffers.store(0, std::memory_order_relaxed);
    logged_completion.store(false, std::memory_order_relaxed);
    started = false;
}
}

extern "C" void squirrelpad_audio_set_frequency(uint32_t frequency) {
    std::lock_guard lock(audio_mutex);
    if (frequency == sample_rate && queue != nullptr) return;
    stop_locked();
    sample_rate = frequency;
    if (frequency == 0) return;

    AudioStreamBasicDescription format{};
    format.mSampleRate = frequency;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    format.mBytesPerPacket = frame_bytes;
    format.mFramesPerPacket = 1;
    format.mBytesPerFrame = frame_bytes;
    format.mChannelsPerFrame = channels;
    format.mBitsPerChannel = sizeof(int16_t) * 8;
    const OSStatus result = AudioQueueNewOutput(&format, output_done, nullptr, nullptr, nullptr, 0, &queue);
    if (result != noErr) {
        std::fprintf(stderr, "[mobile audio] output init failed: %d\n", (int)result);
        queue = nullptr;
    } else {
        std::fprintf(stderr, "[mobile audio] output rate %u Hz\n", frequency);
    }
}

extern "C" void squirrelpad_audio_queue_samples(int16_t *samples, size_t sample_count) {
    if (samples == nullptr || sample_count < channels || sample_count % channels != 0 ||
        sample_count > std::numeric_limits<uint32_t>::max() / sizeof(int16_t)) return;
    std::lock_guard lock(audio_mutex);
    if (queue == nullptr || queued_frames.load(std::memory_order_relaxed) > sample_rate / 2) return;
    if (started && needs_rebuffer.exchange(false, std::memory_order_relaxed)) {
        // Pause keeps queued PCM, then the normal start path resumes after two buffers.
        const OSStatus pause_result = AudioQueuePause(queue);
        if (pause_result == noErr) {
            started = false;
        } else {
            std::fprintf(stderr, "[mobile audio] rebuffer pause failed: %d\n", (int)pause_result);
        }
    }

    AudioQueueBufferRef buffer = nullptr;
    const uint32_t byte_count = static_cast<uint32_t>(sample_count * sizeof(int16_t));
    OSStatus result = AudioQueueAllocateBuffer(queue, byte_count, &buffer);
    if (result != noErr || buffer == nullptr) {
        std::fprintf(stderr, "[mobile audio] buffer allocation failed: %d\n", (int)result);
        return;
    }
    // RDRAM's native-endian 32-bit words expose each stereo pair in reverse order.
    auto *output = static_cast<int16_t *>(buffer->mAudioData);
    bool has_sound = false;
    for (size_t i = 0; i < sample_count; i += channels) {
        output[i] = samples[i + 1];
        output[i + 1] = samples[i];
        has_sound |= output[i] != 0 || output[i + 1] != 0;
    }
    buffer->mAudioDataByteSize = byte_count;
    buffer->mUserData = has_sound ? buffer : nullptr;
    const size_t frames = sample_count / channels;
    queued_frames.fetch_add(frames, std::memory_order_relaxed);
    result = AudioQueueEnqueueBuffer(queue, buffer, 0, nullptr);
    if (result != noErr) {
        queued_frames.fetch_sub(frames, std::memory_order_relaxed);
        AudioQueueFreeBuffer(queue, buffer);
        std::fprintf(stderr, "[mobile audio] enqueue failed: %d\n", (int)result);
        return;
    }
    if (!logged_samples && has_sound) {
        logged_samples = true;
        std::fprintf(stderr, "[mobile audio] queued nonzero stereo PCM\n");
    }
    if (!started && queued_frames.load(std::memory_order_relaxed) >= 2 * one_game_buffer) {
        last_buffer_boundary_ns.store(steady_now_ns(), std::memory_order_relaxed);
        result = AudioQueueStart(queue, nullptr);
        if (result != noErr) {
            std::fprintf(stderr, "[mobile audio] playback start failed: %d\n", (int)result);
        } else {
            started = true;
            std::fprintf(stderr, "[mobile audio] playback started\n");
        }
    }
}

extern "C" size_t squirrelpad_audio_get_frames_remaining() {
    std::lock_guard lock(audio_mutex);
    if (completed_nonzero_buffers.load(std::memory_order_relaxed) > 0 &&
        !logged_completion.exchange(true, std::memory_order_relaxed)) {
        std::fprintf(stderr, "[mobile audio] output consumed nonzero PCM\n");
    }
    size_t frames = queued_frames.load(std::memory_order_relaxed);
    if (started) {
        // The completion callback counts whole buffers. Estimate the portion
        // already playing so Conker sees a continuously shrinking AI length.
        const int64_t boundary = last_buffer_boundary_ns.load(std::memory_order_relaxed);
        const int64_t elapsed_ns = steady_now_ns() - boundary;
        if (boundary > 0 && elapsed_ns > 0) {
            const size_t played = static_cast<size_t>(
                static_cast<double>(elapsed_ns) * sample_rate / 1'000'000'000.0);
            frames -= std::min(frames, std::min(played, one_game_buffer));
        }
    }
    return frames > playback_reserve ? frames - playback_reserve : 0;
}

extern "C" void squirrelpad_audio_stop() {
    std::lock_guard lock(audio_mutex);
    stop_locked();
}
