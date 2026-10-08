# Picture lab — 2026-10-08

Optional filters under Settings → Enhancements → Picture lab. Defaults remain
unchanged: the master switch is off. Enhanced sets color/glow/clarity to
65/35/40%; CRT sets color/glow/scanlines to 25/20/75%. Original bypasses effects
without resetting render quality, texture packs, saves or the chosen strengths.

The four controls are native SwiftUI settings. One atomic word transfers the
clamped 0–100% strengths to the renderer. RT64's normal configuration lock
passes that selection to the final VI shader, after game rendering and before
the native touch UI. This does not use the unavailable ray-traced post-process
path. Zero selects the original shader result without extra texture sampling.

- Rich color: modest saturation and contrast adjustment.
- Soft glow: eight neighboring bright samples, with a fixed small radius. This
  is a lightweight SDR halo, not a full HDR bloom pyramid or new scene lighting.
- Clarity: four neighboring samples with sharpening bounded by local extrema.
  This is an original unsharp-mask implementation, not AMD CAS or AI detail.
- CRT: native-resolution scanlines, derivative-based suppression at small
  display sizes and mild corner darkening. No flicker or simulated frame loss.

## Verification

- Ordered source setup applies cleanly and is repeatable.
- Eight existing native/patch regression tests pass. These tests do not establish
  shader appearance; the actual shader output was checked separately below.
- Updated Metal shaders and RT64 archives build for both mobile SDKs. Both
  Release apps build and pass bundle audits (32 files, 26 notices); simulator
  input probes remain disabled.
- Simulator loaded the existing GAME1 slot (0:06:03), reached the playable field,
  and rendered Original, Enhanced, CRT and Original again from the same camera.
  Captures are actual game frames; Conker's idle pose and scene animations differ.
- Renderer logs confirm 00000000 → 00282341 → 4b001419 → 00000000 selections.
  Independent Soft glow off survives an app restart along with the enabled
  master switch and other strengths. Presets and the bypass were exercised
  through the visible Settings UI. Automated AX slider assignment moved its
  thumb without delivering a value-change event; custom touch-drag acceptance
  remains a manual check, not a claimed pass.
- Final simulator selection returned to Original, with Enhanced strengths ready
  for the next use. No cheat, camera or texture choices were changed.
- Signed device build installed in place on the M2 iPad. Fresh Documents/Library
  backup and independent readback matched before installation; all eight core
  files matched again afterward. App launch succeeded. Device Hub remote pointer
  actions did not reliably activate the physical iPad's native settings during
  this pass, so physical effect appearance/performance remain unverified.

Private evidence and original PNGs are under `work/visual-effects/`. The
`screenshots` folder contains original.png, enhanced.png, crt.png, settings.png
and original-restored.png. Preserve the data backups and personal build there;
do not publish them as release assets.

## Remaining scope

No new texture pack, AI inference, MetalFX, ambient occlusion, widescreen or
frame interpolation is claimed here. Image quality in later scenes, sustained
GPU cost/battery use and physical touch-slider adjustment still need acceptance.
The feature is deliberately optional and labeled experimental.
