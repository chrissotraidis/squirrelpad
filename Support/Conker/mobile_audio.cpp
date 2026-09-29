#include <AudioToolbox/AudioToolbox.h>

#include <array>
#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <mutex>

namespace {
constexpr size_t channels = 2;
constexpr size_t frame_bytes = channels * sizeof(int16_t);
constexpr size_t one_game_buffer = 736;
constexpr size_t playback_reserve = 5 * one_game_buffer;
constexpr size_t startup_frames = 6 * one_game_buffer;
constexpr size_t recovery_frames = 2 * one_game_buffer;
constexpr size_t output_frames = 256;
constexpr size_t output_buffer_count = 4;
constexpr size_t ring_frames = 1 << 15;

std::mutex audio_mutex;
AudioQueueRef queue = nullptr;
std::array<AudioQueueBufferRef, output_buffer_count> output_buffers{};
std::array<int16_t, ring_frames * channels> pcm_ring{};
std::atomic<uint64_t> frames_written{0};
std::atomic<uint64_t> frames_read{0};
std::atomic<bool> accepting_output{false};
std::atomic<bool> rebuffering{true};
std::atomic<size_t> underruns{0};
std::atomic<size_t> resumes{0};
std::atomic<size_t> completed_nonzero_buffers{0};
std::atomic<size_t> completed_buffers{0};
std::atomic<int64_t> last_callback_ns{0};
std::atomic<size_t> callback_gaps_over_40ms{0};
std::atomic<int64_t> largest_callback_gap_us{0};
std::atomic<OSStatus> callback_error{noErr};
std::atomic<uint16_t> output_volume{256};
uint32_t sample_rate = 0;
std::chrono::steady_clock::time_point next_retry;
std::chrono::steady_clock::time_point last_callback_progress;
size_t observed_completed_buffers = 0;
bool started = false;
bool scene_active = true;
bool paused_for_inactive = false;
bool logged_samples = false;
bool logged_completion = false;
size_t logged_underruns = 0;
size_t logged_resumes = 0;
size_t dropped_buffers = 0;
size_t dropped_frames = 0;
size_t logged_callback_gaps = 0;

size_t available_frames() {
    return static_cast<size_t>(frames_written.load(std::memory_order_acquire) -
                               frames_read.load(std::memory_order_acquire));
}

void fill_buffer(AudioQueueBufferRef buffer) {
    auto *output = static_cast<int16_t *>(buffer->mAudioData);
    const uint64_t read = frames_read.load(std::memory_order_relaxed);
    const uint64_t written = frames_written.load(std::memory_order_acquire);
    const size_t available = static_cast<size_t>(written - read);

    if (rebuffering.load(std::memory_order_relaxed) && available >= recovery_frames) {
        rebuffering.store(false, std::memory_order_relaxed);
        resumes.fetch_add(1, std::memory_order_relaxed);
    }
    const bool playing = !rebuffering.load(std::memory_order_relaxed);
    const size_t frames_to_copy = playing ? std::min(available, output_frames) : 0;
    bool has_sound = false;
    const int32_t volume = output_volume.load(std::memory_order_relaxed);
    for (size_t i = 0; i < frames_to_copy; ++i) {
        const size_t offset = ((read + i) % ring_frames) * channels;
        output[i * channels] = static_cast<int16_t>(pcm_ring[offset] * volume / 256);
        output[i * channels + 1] = static_cast<int16_t>(pcm_ring[offset + 1] * volume / 256);
        has_sound |= output[i * channels] != 0 || output[i * channels + 1] != 0;
    }
    if (frames_to_copy < output_frames) {
        std::memset(output + frames_to_copy * channels, 0,
                    (output_frames - frames_to_copy) * frame_bytes);
    }
    if (frames_to_copy > 0) {
        frames_read.store(read + frames_to_copy, std::memory_order_release);
    }
    if (playing && frames_to_copy < output_frames) {
        rebuffering.store(true, std::memory_order_relaxed);
        underruns.fetch_add(1, std::memory_order_relaxed);
    }
    buffer->mUserData = has_sound ? buffer : nullptr;
    buffer->mAudioDataByteSize = output_frames * frame_bytes;
}

void output_done(void *, AudioQueueRef audio_queue, AudioQueueBufferRef buffer) {
    const auto now_ns = std::chrono::duration_cast<std::chrono::nanoseconds>(
                            std::chrono::steady_clock::now().time_since_epoch()).count();
    const int64_t previous_ns = last_callback_ns.exchange(now_ns, std::memory_order_relaxed);
    if (previous_ns != 0) {
        const int64_t gap_us = (now_ns - previous_ns) / 1000;
        if (gap_us >= 40000) {
            callback_gaps_over_40ms.fetch_add(1, std::memory_order_relaxed);
            int64_t largest = largest_callback_gap_us.load(std::memory_order_relaxed);
            while (gap_us > largest && !largest_callback_gap_us.compare_exchange_weak(
                       largest, gap_us, std::memory_order_relaxed)) {}
        }
    }
    completed_buffers.fetch_add(1, std::memory_order_relaxed);
    if (buffer->mUserData != nullptr) {
        completed_nonzero_buffers.fetch_add(1, std::memory_order_relaxed);
    }
    if (!accepting_output.load(std::memory_order_acquire)) return;
    fill_buffer(buffer);
    const OSStatus result = AudioQueueEnqueueBuffer(audio_queue, buffer, 0, nullptr);
    if (result != noErr && accepting_output.load(std::memory_order_relaxed)) {
        callback_error.store(result, std::memory_order_relaxed);
    }
}

void stop_locked() {
    accepting_output.store(false, std::memory_order_release);
    if (queue != nullptr) {
        AudioQueueStop(queue, true);
        AudioQueueDispose(queue, true);
        queue = nullptr;
    }
    output_buffers.fill(nullptr);
    frames_written.store(0, std::memory_order_relaxed);
    frames_read.store(0, std::memory_order_relaxed);
    rebuffering.store(true, std::memory_order_relaxed);
    underruns.store(0, std::memory_order_relaxed);
    resumes.store(0, std::memory_order_relaxed);
    completed_nonzero_buffers.store(0, std::memory_order_relaxed);
    completed_buffers.store(0, std::memory_order_relaxed);
    last_callback_ns.store(0, std::memory_order_relaxed);
    callback_gaps_over_40ms.store(0, std::memory_order_relaxed);
    largest_callback_gap_us.store(0, std::memory_order_relaxed);
    callback_error.store(noErr, std::memory_order_relaxed);
    started = false;
    paused_for_inactive = false;
    logged_samples = false;
    logged_completion = false;
    logged_underruns = 0;
    logged_resumes = 0;
    dropped_buffers = 0;
    dropped_frames = 0;
    logged_callback_gaps = 0;
    next_retry = {};
    last_callback_progress = {};
    observed_completed_buffers = 0;
}

void create_queue_locked() {
    if (sample_rate == 0) return;
    AudioStreamBasicDescription format{};
    format.mSampleRate = sample_rate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    format.mBytesPerPacket = frame_bytes;
    format.mFramesPerPacket = 1;
    format.mBytesPerFrame = frame_bytes;
    format.mChannelsPerFrame = channels;
    format.mBitsPerChannel = sizeof(int16_t) * 8;
    OSStatus result = AudioQueueNewOutput(&format, output_done, nullptr, nullptr, nullptr, 0, &queue);
    if (result != noErr) {
        std::fprintf(stderr, "[mobile audio] output init failed: %d\n", (int)result);
        queue = nullptr;
        next_retry = std::chrono::steady_clock::now() + std::chrono::seconds(1);
        return;
    }
    for (auto &buffer : output_buffers) {
        result = AudioQueueAllocateBuffer(queue, output_frames * frame_bytes, &buffer);
        if (result != noErr || buffer == nullptr) {
            std::fprintf(stderr, "[mobile audio] buffer allocation failed: %d\n", (int)result);
            stop_locked();
            next_retry = std::chrono::steady_clock::now() + std::chrono::seconds(1);
            return;
        }
    }
    std::fprintf(stderr, "[mobile audio] output rate %u Hz\n", sample_rate);
}
}

extern "C" void squirrelpad_audio_set_frequency(uint32_t frequency) {
    std::lock_guard lock(audio_mutex);
    if (frequency == sample_rate && queue != nullptr) return;
    stop_locked();
    sample_rate = frequency;
    create_queue_locked();
}

extern "C" void squirrelpad_audio_set_volume(float volume) {
    if (!std::isfinite(volume)) return;
    output_volume.store(static_cast<uint16_t>(std::lround(std::clamp(volume, 0.0f, 1.0f) * 256.0f)),
                        std::memory_order_relaxed);
}

extern "C" void squirrelpad_audio_set_active(bool active) {
    std::lock_guard lock(audio_mutex);
    if (scene_active == active) return;
    scene_active = active;
    if (queue == nullptr || !started) return;
    if (!active) {
        last_callback_ns.store(0, std::memory_order_relaxed);
        const OSStatus result = AudioQueuePause(queue);
        if (result == noErr) {
            paused_for_inactive = true;
        } else {
            std::fprintf(stderr, "[mobile audio] background pause failed: %d\n", (int)result);
            stop_locked();
            next_retry = std::chrono::steady_clock::now() + std::chrono::seconds(1);
        }
    } else if (paused_for_inactive) {
        const OSStatus result = AudioQueueStart(queue, nullptr);
        if (result == noErr) {
            paused_for_inactive = false;
            last_callback_ns.store(0, std::memory_order_relaxed);
            observed_completed_buffers = completed_buffers.load(std::memory_order_relaxed);
            last_callback_progress = std::chrono::steady_clock::now();
        } else {
            std::fprintf(stderr, "[mobile audio] foreground resume failed: %d\n", (int)result);
            stop_locked();
            next_retry = std::chrono::steady_clock::now() + std::chrono::seconds(1);
        }
    }
}

extern "C" void squirrelpad_audio_queue_samples(int16_t *samples, size_t sample_count) {
    if (samples == nullptr || sample_count < channels || sample_count % channels != 0) return;
    std::lock_guard lock(audio_mutex);
    if (queue == nullptr && sample_rate != 0 && std::chrono::steady_clock::now() >= next_retry) {
        create_queue_locked();
    }
    if (queue == nullptr) return;

    if (started) {
        const auto now = std::chrono::steady_clock::now();
        const size_t completed = completed_buffers.load(std::memory_order_relaxed);
        if (completed != observed_completed_buffers) {
            observed_completed_buffers = completed;
            last_callback_progress = now;
        } else if (available_frames() > sample_rate / 2 &&
                   now - last_callback_progress > std::chrono::milliseconds(500)) {
            std::fprintf(stderr, "[mobile audio] output callback stalled; restarting queue\n");
            stop_locked();
            create_queue_locked();
            if (queue == nullptr) return;
        }
    }

    const size_t frames = sample_count / channels;
    const uint64_t written = frames_written.load(std::memory_order_relaxed);
    const uint64_t read = frames_read.load(std::memory_order_acquire);
    const size_t available = static_cast<size_t>(written - read);
    if (frames > ring_frames - available || available > sample_rate / 2) {
        ++dropped_buffers;
        dropped_frames += frames;
        if (dropped_buffers <= 3 || dropped_buffers % 128 == 0) {
            std::fprintf(stderr, "[mobile audio] dropped %zu PCM buffers (%zu frames total); queued %zu frames, incoming %zu\n",
                         dropped_buffers, dropped_frames, available, frames);
        }
        return;
    }

    bool has_sound = false;
    for (size_t i = 0; i < frames; ++i) {
        const size_t offset = ((written + i) % ring_frames) * channels;
        pcm_ring[offset] = samples[i * channels + 1];
        pcm_ring[offset + 1] = samples[i * channels];
        has_sound |= pcm_ring[offset] != 0 || pcm_ring[offset + 1] != 0;
    }
    frames_written.store(written + frames, std::memory_order_release);
    if (!logged_samples && has_sound) {
        logged_samples = true;
        std::fprintf(stderr, "[mobile audio] queued nonzero stereo PCM\n");
    }

    if (scene_active && !started && available + frames >= startup_frames) {
        rebuffering.store(false, std::memory_order_relaxed);
        for (auto *buffer : output_buffers) {
            fill_buffer(buffer);
            const OSStatus result = AudioQueueEnqueueBuffer(queue, buffer, 0, nullptr);
            if (result != noErr) {
                std::fprintf(stderr, "[mobile audio] enqueue failed: %d\n", (int)result);
                stop_locked();
                return;
            }
        }
        accepting_output.store(true, std::memory_order_release);
        const OSStatus result = AudioQueueStart(queue, nullptr);
        if (result != noErr) {
            std::fprintf(stderr, "[mobile audio] playback start failed: %d\n", (int)result);
            stop_locked();
            next_retry = std::chrono::steady_clock::now() + std::chrono::seconds(1);
        } else {
            started = true;
            last_callback_progress = std::chrono::steady_clock::now();
            std::fprintf(stderr, "[mobile audio] playback started\n");
        }
    }
}

extern "C" size_t squirrelpad_audio_get_frames_remaining() {
    std::lock_guard lock(audio_mutex);
    if (queue == nullptr) return 0;
    if (completed_nonzero_buffers.load(std::memory_order_relaxed) > 0 && !logged_completion) {
        logged_completion = true;
        std::fprintf(stderr, "[mobile audio] output consumed nonzero PCM\n");
    }
    const size_t drain_count = underruns.load(std::memory_order_relaxed);
    if (drain_count != logged_underruns) {
        logged_underruns = drain_count;
        std::fprintf(stderr, "[mobile audio] underrun %zu; collecting PCM reserve\n", drain_count);
    }
    const size_t resume_count = resumes.load(std::memory_order_relaxed);
    if (resume_count != logged_resumes) {
        logged_resumes = resume_count;
        std::fprintf(stderr, "[mobile audio] reserve refilled %zu\n", resume_count);
    }
    const OSStatus error = callback_error.exchange(noErr, std::memory_order_relaxed);
    if (error != noErr) std::fprintf(stderr, "[mobile audio] callback enqueue failed: %d\n", (int)error);
    const size_t gaps = callback_gaps_over_40ms.load(std::memory_order_relaxed);
    if (gaps != logged_callback_gaps) {
        logged_callback_gaps = gaps;
        if (gaps <= 3 || gaps % 64 == 0) {
            std::fprintf(stderr, "[mobile audio] callback gaps >=40 ms: %zu; longest %lld us; queued %zu frames\n",
                         gaps, (long long)largest_callback_gap_us.load(std::memory_order_relaxed),
                         available_frames());
        }
    }
    const size_t frames = available_frames();
    return frames > playback_reserve ? frames - playback_reserve : 0;
}

extern "C" void squirrelpad_audio_stop() {
    std::lock_guard lock(audio_mutex);
    stop_locked();
}
