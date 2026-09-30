#include <cassert>
#include "../Support/Conker/mobile_audio.cpp"

// Exercise the actual buffer filler without starting an audio device.
int main() {
    std::array<int16_t, output_frames * channels> data;
    AudioStreamPacketDescription packet{};
    AudioQueueBuffer buffer(data.data(), sizeof(data), &packet, 0);
    // Authored silence must not be mistaken for missing samples.
    stop_locked();
    frames_written.store(output_frames);
    rebuffering.store(false);
    fill_buffer(&buffer);
    assert(underruns.load() == 0);
    assert(inserted_silent_frames.load() == 0);
    assert(last_underrun_ns.load() == 0);
    for (auto sample : data) assert(sample == 0);
    stop_locked();
    pcm_ring.fill(123);
    // A partial drain and subsequent recovery silence have distinct counts.
    frames_written.store(64);
    rebuffering.store(false);
    fill_buffer(&buffer);
    assert(underruns.load() == 1);
    assert(inserted_silent_frames.load() == 192);
    assert(frames_read.load() == 64);
    auto timestamp = last_underrun_ns.load();
    assert(timestamp > 0);
    for (size_t i = 0; i < data.size(); ++i) assert(data[i] == (i < 128 ? 123 : 0));
    fill_buffer(&buffer);
    assert(underruns.load() == 1);
    assert(inserted_silent_frames.load() == 448);
    assert(last_underrun_ns.load() == timestamp);
    assert(frames_read.load() == 64);
    frames_written.store(64 + recovery_frames);
    fill_buffer(&buffer);
    assert(resumes.load() == 1);
    assert(inserted_silent_frames.load() == 448);
    assert(frames_read.load() == 320);
    for (auto sample : data) assert(sample == 123);
    stop_locked();
    assert(underruns.load() == 0 && resumes.load() == 0);
    assert(last_underrun_ns.load() == 0 && inserted_silent_frames.load() == 0);
    std::puts("PASS: authored silence, partial starvation, recovery silence, reserve resume, reset");
}
