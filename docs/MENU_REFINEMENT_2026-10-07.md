# Launcher and settings refinement

## Design

Use one pixel acorn, a midnight-blue surface, warm amber status labels, and blue
primary actions throughout the shell. The launcher follows KartPad’s clear
identity and play/import hierarchy. Settings follows the sidebar and scrollable
content pattern in HarkinianPad and SpaghettiPad, using SquirrelPad’s existing
controls and bindings.

The launcher distinguishes first import, a retained ROM, and a paused session.
Settings groups General, Controls, Audio, and About. Resume stays in the header;
General offers a return to the launcher without restarting the native core.
Renderer diagnostics live under About rather than on the welcome screen.
Restoring touch defaults asks before clearing saved phone and tablet layouts.

## Verification

- ARM64 Simulator and unsigned iOS device builds passed. Both bundle audits
  passed with 30 files and 24 notices; no private filename/content or excluded
  symbol findings.
- On iPad Pro 11-inch (M5), iPadOS 27 Simulator: retained-ROM launcher, Settings,
  controller bindings and picker, transparency toggle, game launch, three-dot
  menu, return to paused launcher, Resume Game, and layout editor selection/Done
  were exercised. The opening continued after resume.
- Before the in-place iPad update, Documents and Library were backed up. The
  immediate readback matched all retained files except disposable SplashBoard
  snapshots refreshed by the OS. A later readback confirmed all four files in
  Documents and Application Support still matched, including the ROM and saves.
- The iPhone 18 Pro, iOS 27 Simulator showed the fresh-import launcher in landscape.
  Phone interaction verification remains open: Device Hub lost interaction
  focus, ignored both app taps and its Home action, and later reported inactive
  computer use. Restarting only that test simulator did not resolve the viewer
  problem. No phone interaction pass is claimed.
- The three existing source-patch regression tests passed. `git diff --check`
  passed. No gameplay, audio-quality, or physical-device acceptance claim is added.

Local evidence remains ignored under `work/menu-refinement/`: before/after
screenshots, simulator/device build logs, audit report, and the preserved iPad
container. The refreshed personal unsigned IPA is
`work/SquirrelPad-menu-refinement.ipa`; it is not a public release asset.

## Woodland launcher iteration

The launcher now uses an original low-poly woodland scene, a large two-tone
game title, amber Play/Resume/Import actions, and visible Settings, Help, and
Change ROM controls. A slow background zoom adds movement; its implementation
disables motion when Reduce Motion is enabled or the scene becomes inactive.
The native settings panel and existing action closures are retained.

The README includes an actual capture of the first playable field, with the
launcher preview in a disclosure to keep the page concise. Artwork provenance
and the generation prompt are in [ARTWORK](ARTWORK.md).

- Final ARM64 Simulator and unsigned device builds passed. Both package audits
  passed with 30 files and 24 notices and no excluded-symbol or private-file
  findings. These checks do not establish distribution clearance.
- Inspected final iPad retained-ROM and iPhone first-import layouts. On iPad,
  Settings and Help opened and dismissed correctly. Device Hub focus conflicts
  prevented completing the final file-picker and phone tap checks; those remain
  open. The Reduce Motion setting was not toggled during this pass.
- Backed up both test containers before updating in place. Final iPad readback
  matched all eight files in Documents, Application Support, and Preferences.
- This pass reached and captured the first playable field. It adds no sustained
  gameplay, audio-quality, or physical-device acceptance claim.

Ignored local evidence: `work/launcher-polish/`. Refreshed personal unsigned
package: `work/SquirrelPad-woodland.ipa`.
