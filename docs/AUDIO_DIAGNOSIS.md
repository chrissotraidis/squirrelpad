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
