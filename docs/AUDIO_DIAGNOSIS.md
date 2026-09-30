# Audio diagnosis — 2026-09-30

Audio acceptance is **open**. Measured underruns are real, but attributing all
reported glitches to the Simulator or claiming physical iOS audio is fixed would
go beyond the evidence.

## What is established

| Question | Evidence | Conclusion |
| --- | --- | --- |
| Does playback actually run out of samples? | `work/audio-thread-cause-ipad-run.log`: 317 ms PCM submission gap, zero queued frames, underrun 2; 6,504 inserted silent frames over 316 seconds. | Yes. These are missing samples replaced with silence, not merely suspicious callback counts. |
| Is audio computation itself taking hundreds of milliseconds? | The task immediately preceding that gap took 253.237 ms wall time but 1.064 ms thread CPU. | Most of the delay was off CPU. This measurement does not identify every reason for the delay. |
| Does host scheduling contribute? | `work/audio-state-ipad-run.log`: another task remained runnable across several samples, used 0.864 ms CPU over 124 ms wall time, then produced a 108 ms submission gap. | Scheduling delay on this Mac is supported for this event. Its remaining reserve prevented an underrun, so it is a precursor rather than a reproduced silence event. |
| Is the virtual remote-desktop audio device responsible? | Actual app output-device queries during reproductions reported MacBook Air Speakers / BuiltInSpeakerDevice. | Jump Desktop Audio was not the active output route in those reproductions. |
| Were sample values or transport corrupted? | Bounded vector/scalar decoder replays agreed; source-to-AudioQueue checks matched 499,712 stereo frames on each Simulator; paired system-mix recordings found no large missing/repeated segment in those quiet windows. | No defect found in those captured intervals. This is not an all-scene or listening-quality pass. |
| Would real iOS hardware eliminate the glitches? | No physical device is available. Both Simulator classes use this Mac's scheduler and audio output. | Unknown. Two Simulator classes are not independent physical-device controls. |

Detailed experiment conditions, hashes, negative controls and limitations are in
[STATUS.md](STATUS.md), under the audio-cause, runnable-thread, decoder replay,
ring verification and paired system-output entries. Diagnostic recordings and
private ROM data remain ignored under `work/`.

## Next useful test

### Longer gameplay check, 2026-09-30

The Birdy route reproduced one further underrun followed by reserve recovery in
`work/birdy-route-ipad-run.log`, between display-list reports 66,360 and 66,420.
Earlier 87/81/100 ms submission gaps retained 2,328–2,680 queued frames and did
not underrun. The counter's implementation was rechecked: it increments when
active playback has fewer samples than an output buffer requires, and the
missing remainder is explicitly zero-filled. It is not a count of ordinary
silent game samples.

A 50-second system-mix recording during the scene-testing sequence completed
with 2,652 accepted buffers, zero rejected buffers and no writer error
(`work/evidence/birdy-route-ipad-dialogue.caf`). This run did not capture paired
submitted PCM, and the underrun report has no event timestamp; therefore the
recording cannot yet localize the exact failing sample boundary. It is neither
a listening-quality pass nor proof of a Simulator-only cause. No audio change
was justified or retained.

### Rolling failure-capture attempt

An environment-enabled temporary recorder kept a rolling raw-input and filled-
output window, freezing 64 output buffers after the first starvation event.
The roughly 30-minute iPad run (`work/audio-flight-ipad-run.log`, game startup
09:06:42 to termination 09:37:21, local time) had no logged underrun, >=80 ms
submission gap, callback gap, drop or stalled queue. Its route included startup,
field/water movement, background/foreground, pause/quit/reload and the outside
context pad. It did not repeat the full Birdy dialogue route. Output-device
query again reported MacBook Air Speakers. No natural event means there is no
paired failure window to analyze; this is not an audible-quality pass.

The recorder's deliberate-starvation boundary check produced 1,536 injected
zero frames, eight ring wraps, 1,000 output buffers and zero sample mismatches
against separately stored raw input. That validates this capture format and
verifier, not a natural cause. Private tooling/results remain under
`work/audio-flight-{candidate.cpp,test.cpp,synthetic.bin,synthetic-result.json}`
and `work/instrument-audio-flight.py`. System-mix recordings completed with
zero rejected buffers: `work/evidence/audio-flight-ipad.caf` (600 seconds),
`audio-flight-ipad-lifecycle.caf` (180 seconds) and
`audio-flight-ipad-continuation.caf` (600 seconds). The last extends across
restoration of the normal app and is not a single-build comparison.

Temporary capture code was removed and byte-checked against the committed
backend; normal input-probe-OFF build and installation were restored. The
intermittent measured starvation remains established from earlier runs. This
quiet run does not explain Chris's reported glitches or prove a device-only
cause. Repeat only with a failing route or another concrete discriminating
measurement; more quiet windows cannot close acceptance.

### Diagnostic improvement

The backend now reports the latest underrun's steady-clock timestamp in the
same units as PCM submission gaps, plus cumulative inserted silent frames at
underrun and reserve-recovery reports. The total includes recovery silence and
excludes zeros already present in game PCM. These are snapshots taken when the
game queries queue depth, not a complete per-event trace; multiple events may
be aggregated before reporting. Sample generation, buffering and pacing are
unchanged. This improves failure correlation and is not an audio fix.

The standalone check uses the production buffer filler without starting an
audio device. It verifies authored silence, partial starvation, continued
recovery silence, resume and reset:

```sh
xcrun --sdk macosx clang++ -std=c++20 \
  -isysroot "$(xcrun --sdk macosx --show-sdk-path)" \
  scripts/verify-audio-events.cpp -framework AudioToolbox \
  -o work/audio-event-test
work/audio-event-test
```

Capture a reproducible audible failure in an identified scene, with the same
interval's submitted PCM, inserted-silence count and system output. Determine
whether the defect first appears in generated PCM, late production, or downstream
playback. Quiet short captures alone cannot close the issue. Do not increase
buffering or retain a priority change without a repeatable improvement; the
previous priority comparison did not show one.

Chris's scene and description (crackle, repetition, silence or incorrect voice)
would help correlate the reported defect. Physical-device audio/routes and long
play still need Chris when hardware becomes available. No physical-device fix is
claimed, and no game logic change is justified by the current diagnosis.
