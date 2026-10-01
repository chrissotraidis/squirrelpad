# SquirrelPad evidence ledger

Updated 2026-09-30. Work the lowest unmet goal in [GOAL_LOOP.md](GOAL_LOOP.md). The private ROM, generated game code, builds, logs, saves and gameplay captures stay under ignored `ref/` or `work/`.

| Gate | State | Measured result and remaining test |
| --- | --- | --- |
| G0 pinned inputs | Pass for source inputs | `sources.lock.json` pins Conker and its submodules. A fresh ignored checkout replayed every patch and regenerated 127 game files byte-for-byte identical to the existing output from the verified private US ROM. `docs/SOURCE_BOUNDARY.md` inventories the source/licensing boundary; independent tool/renderer builds and package audit remain G8. |
| G1 macOS control | In progress | ARM64 N64RecompCLI/RSPRecomp/RecompModTool built; `python3 recomp/recompile.py` emitted 127 files. Headless host ran 15 seconds, 895 VIs and 446 display lists, exit 0. `patches/rt64-metal-sdk-scope.patch` fixed the RecompFrontend shader command; the macOS Metal rebuild passed and its host ran 120 seconds, 7174 VIs, exit 0 on Apple M1. A later macOS startup-order fix made the native window inspectable: moving intro, GAME1 file select and native Settings were viewed through CUA on 2026-09-30. Escape opened/closed Settings; ordinary keyboard selection has not reached gameplay. A bounded event trace found CUA key-down/key-up share a timestamp and SDL reports the key released when polling; loaded A/Start bindings are correct. This is an automation timing limitation, not a demonstrated input-mapping defect. Audio fidelity and save/relaunch remain unverified. |
| G2 mobile core and renderer | In progress | The Conker core, RSP audio path, runtime and RT64 Metal archives compile/link into an ARM64 `iphonesimulator` app and an unsigned ARM64 `iphoneos` app. Both SDK-specific RT64 closures force-link without desktop surface symbols. Metal blobs target iOS 17.0 and Metal 3.1; iOS 18.5 Simulator loaded them. iOS excludes mod scanning, LiveRecomp initialization and the game-start `load_mods` call. The latest iOS link excludes LiveRecomp entirely; neither final executable contains LiveGenerator, ShimFunction or sljit symbols, and the device map marks native mod protect/patch functions dead stripped. Runtime RDRAM still uses non-executable mmap/mprotect. Physical execution remains unverified. Both iPad and iPhone Simulators reached gameplay with the touch input bridge. This is not physical-device or audio proof. |
| G3 Simulator frame | Partial | The iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5, reached moving intro, game select and the **first playable field** on RT64 Metal. Fresh iPad Pro 13-inch (M5) and iPhone 17 Pro iOS 26.5 runs rejected invalid and wrong-checksum files, imported the pinned US ROM through Files, reached the first field, and loaded a saved GAME1 slot after cold app relaunch. Touch Start/A paused/resumed in that field. Captures: `work/evidence/ipad26-fresh-import-relaunch-first-field.png`, `work/evidence/iphone26-fresh-import-relaunch-first-field.png`. macOS fidelity comparison, long play and audio quality remain open. |
| G4 touch input and audio | Partial | The continuous stick and 14 N64 touch buttons feed Conker's mobile input callback for player 0. A separate GameController state maps extended-gamepad buttons and sticks into the same callback; a hidden virtual controller supplied combined A, C-right and left-stick input in the first playable field on both Simulators, then cleared on disconnect. Individual actions, controller title navigation and physical hardware remain unverified. On both Simulators, touch Start opened the game's pause screen and A resumed at the first field. Short stick/C taps changed the picture but do not establish sustained analog feel. The three-dot menu opened/closed and hid/restored the controls in the iPad field. Opacity, control size, D-pad/C-button visibility and separate iPad/iPhone touch positions persisted across full app relaunch; Restore Defaults returned the defaults. The iOS Audio Queue consumed nonzero stereo PCM on both Simulators. After Chris reported heavy glitches, a five-buffer reserve reduced measured restarts in separate Simulator runs, but did not eliminate them and adds about 100 ms of nominal buffering. A later queue-depth trace confirmed real underruns and the restored iPad build still restarted twice through display list #4620; intermittent sample starvation remains measured, but its relationship to the audible complaint and its practical severity are unverified. Routine audio diagnosis is deferred following Chris's 2026-09-30 correction. Pausing the queue with scene inactivity removed the immediate resume underrun in two short cycles on each Simulator; this does not establish general audio quality. Audible quality, interruptions/routes, simultaneous touches and controller play remain open; Settings now pauses game time. |
| G5–G6 gameplay | Partial | Populated **GAME1** slots survived app reinstall on each Simulator and loaded the first field. On iPad, a new **GAME2** slot was created, and after cold relaunch it showed **PLAY** with a nonzero play time. The mobile VI gate stops display-list progression on Home. The iOS runtime patch froze `osGetTime()` and timer-message enqueues through two ten-second gameplay background cycles on each Simulator; both resumed rendering and touch Start/A. A subsequent Audio Queue pause change removed the immediate resume underrun in two more short cycles on each Simulator. Distinct in-level save fidelity, sleep/wake, long play and full-story G6 remain open. |
| G7 hardware | Awaiting devices | `xcrun devicectl list devices` found no connected iPad or iPhone on 2026-09-26. Both physical acceptance rows remain open. |
| G8 package | In progress | A separate checkout builds its own recompiler tools, generated game code, macOS shader inputs and both iOS RT64 archive closures. Both SDK app bundles carry 21 pinned upstream notice texts, and the latest executables have no absolute home path strings. The app contains ROM-derived executable code. Full notice/rights review, signing, installable handoff and hardware install remain. |

## Fresh iPadOS and iOS 26.5 ROM imports (2026-09-28)

The ordinary Simulator app with executable SHA-256 `b2d583661b79ababd9d69310c794fd4d590bb123aeae3d55be0cae3c5e954624` was installed on a fresh iPad Pro 13-inch (M5), iPadOS 26.5 Simulator. The launcher initially offered only **Choose ROM**. Through its Files picker, a 15-byte `.z64` file produced the size/header rejection and a 64 MiB big-endian ROM with one modified byte produced the checksum rejection. Neither started the core. A file matching the pinned US SHA-1 imported through the same UI, reached **GAME1 → NEW GAME**, and rendered the opening sequence. The private test files and captures remain in ignored Simulator/`work/` storage; `work/evidence/ipad26-wrong-rom-rejected.png` shows the checksum rejection.

The iPad then reached the first playable field. A 2,048-byte EEPROM save and `.bak` appeared under the app's `Library/Application Support/Conker/saves/`. After a cold terminate/launch, **Continue Imported ROM → GAME1 → PLAY** showed a nonzero play time and loaded that field; touch Start paused and A resumed. The field was viewed in Simulator and captured at `work/evidence/ipad26-fresh-import-relaunch-first-field.png`. The Simulator initially launched the iPad app in portrait despite its landscape orientation entries. The ROM picker was usable. Rotating during the new-game opening kept the game visible but placed controls over a narrower picture. The raw `simctl` screenshot is stored in portrait orientation although the viewed Simulator window was landscape.

The same exact app executable was installed on a fresh iPhone 17 Pro, iOS 26.5 Simulator. Files import rejected a short `.z64` file with the size/header message and a modified 64 MiB ROM with the checksum message. It accepted the private pinned-US-SHA-1 ROM, then reached **GAME1 → NEW GAME → first playable field**. Touch Start paused and A resumed. A 2,048-byte EEPROM save and `.bak` appeared in the phone app container. A cold terminate/launch retained **Continue Imported ROM**, and **GAME1 → PLAY** displayed `0:06:03` before loading the field again. Both field views were visually checked; captures: `work/evidence/iphone26-fresh-import-first-field.png` and `work/evidence/iphone26-fresh-import-relaunch-first-field.png`. The raw `simctl` captures have the same portrait-orientation quirk. This verifies first-slot creation and reload, not distinct in-level save fidelity, sustained analog control, long play, audio quality, or full-story progress.

## First extended-gamepad bridge (2026-09-29)

**Partial:** `Sources/ControllerInput.swift` now selects one connected extended gamepad and maps its left stick, A/B, triggers as Z, shoulders, Menu as Start, D-pad and right stick as C buttons to Conker's player-0 input. Connection, disconnection, foreground loss and the Settings pause clear held controller input. `Support/Conker/mobile_input.cpp` keeps controller and touch state separate, ORs held buttons, and uses the stronger stick vector without splitting its X/Y axes. A direct native mixer check passed (`work/controller-mixer-check.cpp`). The first app build had no controller attached; controller gameplay, feel and rumble remain **unverified**.

The exact Simulator build (SHA-256 `5c85ccf1c1903581c169bb3fc4ed5d02adebae61291ccf9a11ac198326e29006`) and unsigned device build passed (`work/controller-build-{sim,device}.log`). The iPad Pro 11-inch (M4) and iPhone 16 Pro iOS 18.5 Simulators installed it in place and visibly advanced through the moving intro with the existing touch controls (`work/controller-{ipad,iphone}-run.log`; viewed captures `work/evidence/{ipad,iphone}-controller-bridge-intro.png`). The iPhone three-dot Settings pane opened and closed, returning the controls. These were touch regressions, not controller gameplay or audio-quality checks.

**Virtual-controller event path passed (diagnostic candidate only):** with no controller attached to this Mac, a temporary iOS Simulator-only `GCVirtualController` injected A, right-stick C-right and left-stick X=0.75. On both iPad and iPhone iOS 18.5, the actual Conker player-0 callback logged mask `0x8001`, X=0.75, Y=0.00, then mask zero and axes zero after disconnect (`work/controller-virtual-probe-{ipad,iphone}-run.log`; viewed intro captures `work/evidence/{ipad,iphone}-virtual-controller-intro.png`). This verifies the GameController event route into the game callback and held-input release on virtual disconnect. It does not show title navigation, camera movement in gameplay, physical attachment, or the full mapping.

The injected controller and callback logger were removed byte-for-byte, leaving the source tree clean. The ordinary Simulator rebuild passed (`work/controller-virtual-restored-build.log`), contains no probe marker, and has executable SHA-256 `34d5e1b61ffb6492f2e36d42f6526a16b956931ce02464668d21ff1de83910c0`. This differs from the prior build's hash despite the restored source; reproducible-binary output is therefore not established. That rebuilt app was installed in place on each class and visibly returned to the moving intro (`work/controller-restored-{ipad,iphone}-run.log`; viewed `work/evidence/{ipad,iphone}-controller-restored-intro.png`). Next exercise the virtual controller after reaching the first playable field, then use Simulator forwarding or a physical controller for attachment and feel tests.

**First-field controller diagnostic (same date):** a second temporary build waited for Settings to close before connecting the hidden virtual controller. On both iPad Pro 11-inch (M4) and iPhone 16 Pro iOS 18.5, the ordinary touch route selected saved **GAME1 → PLAY** and visibly reached the first field. Viewed baseline captures are `work/evidence/{ipad,iphone}-controller-field-before.png`. Closing Settings applied A plus C-right and left-stick X=0.75 for eight seconds; the actual game callback logged mask `0x8001` and X=0.75, then all zeros after virtual disconnect (`work/controller-field-probe-{ipad,iphone}-run.log`). The iPad and iPhone views changed during the held interval; captures are `work/evidence/ipad-controller-field-after.png` and `work/evidence/iphone-controller-field-during.png`. These combined inputs demonstrate a live controller route in playable gameplay and release on disconnect, but do not isolate analog movement, jump and camera effects individually or test a physical controller. The probe build was not hashed before it was replaced, limiting exact-artifact comparison.

Both temporary source changes were restored byte-for-byte. The ordinary Simulator rebuild passed (`work/controller-field-restored-build.log`), has no probe marker, and returned to SHA-256 `34d5e1b61ffb6492f2e36d42f6526a16b956931ce02464668d21ff1de83910c0`, the already viewed ordinary build above. No production input or game-logic change was retained. **G4 remains partial:** repeat the field with one controller input at a time, use a forwarded physical controller for attach/remove and capability reporting when available, and continue audio and reference-menu work.

## Touch layout editor (2026-09-28)

**Pass for layout editing:** the Controls pane now opens an in-game editor that repositions the stick and buttons by dragging and saves separate normalized iPad and iPhone positions. Editing clears held touch input; the drag gesture only moves controls and does not send a game button or stick value. The editor offers Reset Layout and Done, while Restore Defaults in Settings clears both saved layouts. The first candidate exposed a drag-coordinate bug: the iPad saved the original position. Using the parent layout coordinate space and committing the pointer location on drag end corrected it.

The final Simulator executable SHA-256 is `56a45a10f1e5f90060c83ea3d2d0a1d3c4d23f932dcf47c784432bf891e82d8a`; Simulator and unsigned device builds passed (`work/layout-editor-final-sim-build.log`, `work/layout-editor-device-build.log`). On iPad Pro 13-inch (M5), iPadOS 26.5, that build moved A left, kept it after cold relaunch, and returned it to its default through Restore Defaults. Viewed capture: `work/evidence/ipad26-layout-editor-final-relaunch.png`. On iPhone 17 Pro, iOS 26.5, the behavior-equivalent candidate moved A, retained it after cold relaunch and restored its default (`work/evidence/iphone26-layout-editor-moved.png`); the final build then loaded **GAME1 → PLAY → first field**, used Start/A to pause and resume, and a short stick drag changed Conker's facing (`work/evidence/iphone26-layout-editor-final-field.png`). The reference `ref/harkinianpad/docs/readme/simulator-settings.jpg` still has controller bindings, devices and other settings that this menu lacks. Audio glitches, physical touch feel, simultaneous touch, controller play and long gameplay remain open.

### Settings and editor pause (2026-09-28)

Opening Settings or the touch layout editor now suspends the game through the existing scene activity gate; closing Settings or tapping Done resumes it when the app is foregrounded. The menu no longer leaves the game advancing while its touch controls are hidden. Simulator and unsigned device builds passed (`work/menu-core-pause-{sim,device}-build.log`); the Simulator executable SHA-256 is `7f954113ba4cfdba2b011d019b852978ca74890d8485be5124a183d86cf62af6`.

On iPad Pro 11-inch (M4), iOS 18.5, the Settings overlay held display list #1260 and produced byte-identical screenshots across ten seconds (`work/evidence/ipad-menu-core-paused*.png`). The layout editor separately held #4200 across five seconds. Closing Settings and Done each resumed visible progression; the same app reached the first field and touch Start/A paused/resumed (`work/menu-core-pause-ipad-run.log`, `work/evidence/ipad-menu-core-resumed-field.png`). On iPhone 16 Pro, iOS 18.5, Settings held #3600 with byte-identical ten-second screenshots (`work/evidence/iphone-menu-core-paused*.png`); closing it resumed to #5160 and Start/A paused/resumed the first field (`work/menu-core-pause-iphone-run.log`, `work/evidence/iphone-menu-core-resumed-field.png`). Both runs started Audio Queue playback, queued and consumed nonzero PCM, and logged no Audio Queue error. This verifies the pause transition and visual/input return, not clean audio or a complete reference-style menu.

## Audio menu control (2026-09-28)

The three-dot Settings menu now has a functional Audio pane with a saved Master Volume slider and Restore Default Volume. The output callback applies the selected gain to PCM after reading the game ring; at 100% it passes the original samples unchanged. This is a menu control, **not a fix for the reported audio glitches**. The reference `ref/harkinianpad/docs/readme/simulator-settings.jpg` has an Audio sidebar item, but its broader settings and binding UI remain unimplemented here.

The Simulator and unsigned device builds passed (`work/menu-audio-sim-build.log`, `work/menu-audio-device-build.log`). In the iPad Pro 11-inch (M4) iOS 18.5 Simulator, an actual slider click set 0%; a full app relaunch still showed 0%. The game then queued nonzero PCM but did not report nonzero output. Restore Default Volume changed the pane to 100%, and the same game run reported nonzero output (`work/menu-audio-ipad-muted-relaunch.log`). In the iPhone 16 Pro iOS 18.5 Simulator, a click set 50%; a full relaunch still showed 50%, and the game launched with nonzero PCM output (`work/menu-audio-iphone-relaunch.log`). Both menu panes and game launch screens were viewed in the Simulators against the reference image. Accessibility `setValue` alone moved the thumb without saving the value, so persistence was checked only after an actual click changed the displayed percentage.

The iPhone screenshot exposed a separate layout gap: its landscape camera cutout overlapped the left side of the Settings panel. A narrower compact panel now leaves visible side margins, clearing the cutout while keeping the Controls and Audio rows and their actions reachable. The revised Simulator and unsigned device builds passed (`work/menu-iphone-safearea-sim-build.log`, `work/menu-iphone-safearea-device-build.log`). Both panes were viewed on the iPhone and iPad Simulators against the same reference; the iPhone menu closed and game launch still showed the touch controls (`work/menu-iphone-safearea-{iphone,ipad}-run.log`). Audibility and glitch frequency remain unverified by these menu checks.

## Touch and menu comparison (2026-09-26)

The iPad comparison uses `ref/harkinianpad/docs/readme/harkinianpad-gameplay.jpg` and `ref/harkinianpad/docs/readme/simulator-settings.jpg`. SquirrelPad's viewed captures are `work/evidence/ipad-touch-game-select-final.png`, `work/evidence/ipad-touch-menu-final.png`, `work/evidence/iphone-touch-game-select.png` and `work/evidence/iphone-touch-menu-final.png`. HarkinianPad has no iPhone screenshot in this checkout, so the phone comparison uses the accepted normalized centers and menu-placement code in `ref/harkinianpad/sources/Shipwright/soh/ios/HarkinianPadTouchControls.mm`. These reference images and game captures are local, ignored evidence, not distributable assets.

| Reference behavior | SquirrelPad Simulator result | Gap |
| --- | --- | --- |
| Translucent outlined grip controls, stick and D-pad left, action/C buttons and shoulders right | Both classes visibly follow the same grouping. The phone C cluster moved slightly left after the first screenshot showed C Up touching L. The stick uses continuous axes rather than HarkinianPad's eight-way keys. | Button sizes/colors are approximate; simultaneous touch and stick feel need real handling tests. |
| Fullscreen game with permanent three-dot menu, upper right on iPad and upper middle on iPhone | Both placements appear in the captures. The phone game frame now fits vertically so **GAME1** and its bottom text remain visible; the smaller top dot clears the title. | RT64 still renders a low-resolution surface and the app magnifies it. Sharpness and scene fidelity need a macOS comparison. |
| Three-dot menu remains reachable with controls hidden; phone dot moves near the bottom while open | Both Simulators show a Controls panel with a persistent touch toggle. Disabling touch hides every game control but leaves Menu; re-enabling restores them. The phone's open-menu dot sits above the home indicator. | This is a minimal controls panel, not HarkinianPad's full settings/customization UI. It does not pause the game. |
| Transparency is opt-in, revealing a 25–100% opacity slider | The switch defaults off and reveals/hides the slider on both Simulators. A live percentage now sits above the slider. The iPad retained 44% and the iPhone retained 70% after full app relaunch; each was set by an actual Simulator click on the slider thumb. Final captures: `work/evidence/ipad-opacity-final-menu.png` and `work/evidence/iphone-opacity-final-menu.png`. | Opacity appearance and touch feel on physical displays remain untested. |

Final Simulator build: `work/touch-build-menu-size.log` (exit 0); unsigned device build: `work/touch-build-iphoneos-final.log` (exit 0). Final runs: `work/touch-iphone-final-verified.log` and `work/touch-ipad-final-run.log`. The first device build after CMake regenerated the Xcode project used the old Swift source list and failed; the rerun with the regenerated project succeeded in `work/touch-build-iphoneos-retry.log`, then the final device build succeeded. The host patch was replayed in a separate ignored checkout before these builds. No ROM or capture is staged for Git.

The transparency-menu revision rebuilt successfully for Simulator and unsigned `iphoneos` (`work/touch-build-transparency-final-sim.log`, `work/touch-build-transparency-iphoneos.log`). Its switch's saved state survived an iPhone app reinstall/relaunch. The prior slider check used an accessibility `setValue` that moved the thumb without updating SwiftUI's binding; it was not a valid persistence test.

On 2026-09-27, the three-dot menu gained a larger dark Settings surface, a Controls sidebar and a scrollable controls pane, following the layout of `ref/harkinianpad/docs/readme/simulator-settings.jpg` without exposing reference tabs or bindings that this port cannot operate. Viewed captures: `work/evidence/ipad-menu-fullpanel-final.png` and `work/evidence/iphone-menu-fullpanel-final.png`. On iPad, switching Touch Controls off hid the game buttons while Menu stayed reachable; Restore Defaults brought them back. On iPhone, the transparency slider and Restore Defaults were reached by scrolling the compact pane; Restore Defaults cleared transparency, and tapping the bottom three-dot button closed the panel and restored game controls. The final Simulator and unsigned device builds passed (`work/menu-scroll-viewport-sim-build.log`, `work/menu-scroll-viewport-device-build.log`), with runs in `work/menu-scroll-viewport-ipad-run.log` and `work/menu-scroll-viewport-iphone-run.log`. The panel is still a small functional subset of the reference and does not pause game time.

The next small Controls addition exposes D-pad and C-button visibility as saved group switches, following the reference's ability to hide touch controls without adding inactive controller-binding UI. Both iOS 18.5 Simulators showed the selected groups disappear while Start, stick, A/B, Z, L and R remained; terminate/relaunch kept the hidden state, and Restore Defaults brought both groups back. After reset, the iPad's A/Start path loaded **GAME1** into the field. The iPad panel and hidden overlay were viewed against `ref/harkinianpad/docs/readme/simulator-settings.jpg` and `ref/harkinianpad/docs/readme/harkinianpad-gameplay.jpg`; local captures are `work/evidence/ipad-menu-button-visibility.png` and `work/evidence/ipad-touch-groups-hidden.png`. The phone panel was also viewed in Simulator. Simulator and unsigned device builds passed (`work/menu-button-visibility-build-app-iphonesimulator.log`, `work/menu-button-visibility-build-app-iphoneos.log`); run logs are `work/menu-button-visibility-iphone-run.log`, `work/menu-button-visibility-iphone-relaunch.log`, `work/menu-button-visibility-ipad-run.log` and `work/menu-button-visibility-ipad-relaunch.log`. Per-button drag placement and more reference settings remain open.

A saved 80–120% Control Size slider now scales the buttons and stick. On iPad, 116% persisted after a full terminate/relaunch; moving the stick lower separated it from the D-pad. On iPhone, 120% persisted after relaunch; the action and C buttons were spaced to avoid overlap at that maximum. The exact final Simulator build reached **GAME1 → PLAY** on both devices, and Start/A paused/resumed in the first field. The three-dot menu opened over gameplay, and Restore Defaults returned the iPhone slider to 100%. Viewed captures: `work/evidence/ipad-touch-size-final-field.png`, `work/evidence/ipad-menu-control-size-116.png`, `work/evidence/iphone-touch-size-120-separated.png` and `work/evidence/iphone-menu-control-size-120.png`. Simulator and unsigned device builds passed (`work/menu-control-size-phone-layout-sim-build.log`, `work/menu-control-size-phone-layout-device-build.log`); final runs are `work/menu-control-size-final-ipad-run.log` and `work/menu-control-size-phone-layout-run.log`. The longer iPad run logged 17 audio playback starts through display list #6,780, including close clusters, so the audio glitch remains open.

On 2026-09-27, an actual Simulator thumb click changed the iPad value from 100% to about 63%, and a full terminate/relaunch reopened the menu at that value. After adding the percentage readout, another click changed it to 44%; a second terminate/relaunch and reinstall of the final build still showed 44%. The final iPhone build changed from 100% to 70% through the same click path and reopened at 70% after terminate/relaunch. The final menu puts the value above the slider to avoid wrapping at phone width and raises the phone panel 18 points to clear the persistent bottom three-dot button. The final iPhone run confirmed that opening the menu hides every gameplay control and tapping the dot again restores them. Final Simulator and unsigned device builds passed (`work/touch-opacity-final-sim-build.log`, `work/touch-opacity-final-device-build.log`). Final visual runs: `work/touch-opacity-final-iphone-run.log`, `work/touch-opacity-final-iphone-relaunch.log`, `work/touch-opacity-final-ipad-run.log`; captures: `work/evidence/iphone-opacity-final-touch.png`, `work/evidence/iphone-opacity-final-menu.png`, `work/evidence/ipad-opacity-final-touch.png`, `work/evidence/ipad-opacity-final-menu.png`. Simulator appearance was compared against the HarkinianPad screenshots and normalized grip layout named above; physical acceptance remains open.

On 2026-09-28, the menu's backdrop and panel became translucent so the live field remains visible behind Settings, closer to HarkinianPad's `simulator-settings.jpg`. The exact app built for Simulator and unsigned device (`work/menu-scrim-sim-build.log`, `work/menu-scrim-device-build.log`). Both iOS 18.5 Simulators reached **GAME1 → PLAY → first field**; viewed menu captures are `work/evidence/ipad-menu-translucent-field.png` and `work/evidence/iphone-menu-translucent-field.png`. On iPad, Close restored the controls; on iPhone, the bottom three-dot button restored them. This is a visual polish step; the menu still lacks the reference's full settings and binding controls.

## First playable field and surface check (2026-09-27)

The unchanged `9cec3b9` build reached the first playable field through the ordinary **GAME1 → NEW GAME** route on both iOS 18.5 Simulators. Touch Start paused and A resumed. Baseline captures and run logs are `work/evidence/ipad-first-playable-before.png`, `work/evidence/iphone-first-playable-before.png`, `work/g3-playable-ipad-run.log` and `work/g3-playable-iphone-run.log`. Short stick/C gestures changed the view, but did not test sustained control.

The field looked soft at the fixed 160×90-point Metal surface. The narrow follow-up uses 240×135 points with the same 16:9 layout, yielding 480×270 pixels on iPad and 720×405 on iPhone. Simulator and unsigned device builds passed (`work/g3-surface-240-sim-build.log`, `work/g3-surface-240-device-build.log`). Each installed Simulator build reopened its populated **GAME1** slot and reached the first field. Captures: `work/evidence/ipad-first-playable-480x270.png` and `work/evidence/iphone-first-playable-720x405.png`; logs: `work/g3-surface-240-ipad-run.log` and `work/g3-surface-240-iphone-run.log`. Both logs advanced display lists without a pipeline resource-limit error in this window. Touch Start/A paused/resumed on both, and the iPad three-dot menu hid/restored its controls. Viewed before/after captures show somewhat clearer edges while source textures remain soft. The pixel count is 2.25 times higher; frame pacing, heat and battery impact were not measured, so this is not a performance optimization claim. Keep the hardware performance gate open.

## macOS Metal shader-rule repair (2026-09-27)

**Pass:** the previous rebuild failed at `xcrun -sdk metal -o ...` in RecompFrontend's `InterfaceVS/PS` shader rules (`work/debug-capability-build-macos.log`). RT64's Metal SDK variable was local to its CMake directory; the shared shader function was also called from a sibling directory. The narrow scope fallback in `patches/rt64-metal-sdk-scope.patch` makes those generated rules use `xcrun -sdk macosx metal`. The patch reverse-check passed in the pinned ignored checkout. Configure and build passed (`work/g1-metal-scope-configure.log`, `work/g1-metal-scope-build.log`); the rebuilt Apple M1 Metal host ran its 120-second window and exited 0 after 7174 VIs (`work/g1-metal-scope-run.log`). The iOS Simulator and unsigned device app builds also passed (`work/g1-metal-scope-sim-build.log`, `work/g1-metal-scope-device-build.log`). **Not run:** macOS visual/audio/input comparison; the UI tool timed out while binding the app window. The VI count alone does not close G1.

## Mobile audio connection (2026-09-27)

`patches/conker-mobile-audio.patch` connects the existing mobile host audio callbacks to `Support/Conker/mobile_audio.cpp`. The Audio Queue receives the game's signed 16-bit stereo samples in the same left/right order as the desktop host; its completion callback tracks queued frames for game pacing. The patch reverse-check passed in the pinned ignored checkout. The exact source revision built for Simulator and unsigned device (`work/g4-mobile-audio-verified-sim-build.log`, `work/g4-mobile-audio-verified-device-build.log`).

The iPad and iPhone 16 Pro iOS 18.5 Simulators each rechecked an imported private ROM, traversed **GAME1 → PLAY**, and visibly reached the first field. Logs `work/g4-mobile-audio-verified-ipad-run.log` and `work/g4-mobile-audio-verified-iphone-run.log` show the game selecting 22,020 Hz, playback starting, nonzero stereo PCM queued, and an output buffer with nonzero PCM completed. Captures: `work/evidence/ipad-mobile-audio-verified-field.png` and `work/evidence/iphone-mobile-audio-verified-field.png`. Touch Start paused and A resumed in both runs. No pipeline resource-limit or Audio Queue error appeared in these windows. **Open:** audible music/effects/voice quality, buffer underruns, route/interruption behavior, long play and hardware output. The completion callback shows consumption by the Simulator output path; it does not prove what a person heard.

Chris heard heavy audio glitching in this build. The first diagnostic found that Audio Queue buffer completions could leave the queue empty repeatedly: the iPad run reached 347 empty completions by buffer 2,816 (`work/audio-rate-diagnostic-ipad-run.log`), and an iPhone run without recovery reached 461 by buffer 1,536 (`work/audio-reserve-diagnostic-iphone-run.log`). The queue's frame count changed only at whole-buffer completion while the desktop SDL queue drains continuously. The first rebuffer revision estimated the played portion between callbacks, started with two game buffers, and, after an empty completion, paused and resumed when two buffers were ready. Apple's `AudioQueuePause` preserves enqueued buffers. In diagnostic builds, the iPad had 13 empty completions by buffer 2,816 (`work/audio-rebuffer-diagnostic-ipad-run.log`), and iPhone had 5 by buffer 1,536 (`work/audio-rebuffer-diagnostic-iphone-run.log`). These are separate runs, so the counters indicate a reduced underrun risk rather than proving audible quality. The temporary counters were removed from the final source; Simulator and unsigned device builds passed (`work/audio-rebuffer-final-build-app-iphonesimulator.log`, `work/audio-rebuffer-final-build-app-iphoneos.log`). The clean app reached **GAME1 → PLAY** and rendered the opening field on both Simulators (`work/audio-rebuffer-final-ipad-run.log`, `work/audio-rebuffer-final-iphone-run.log`) without Audio Queue or Metal errors in those windows. **Open:** Chris should listen to the final build; this change may leave pops during rebuffering or other audio faults.

The next small buffer experiment holds two game buffers in reserve and starts playback after three are queued. The same app source built for Simulator and unsigned device (`work/audio-prefill3-sim-build.log`, `work/audio-prefill3-device-build.log`). On iPad, the run logged three playback starts including the initial start through display list #4,080; on iPhone, three through #5,160 (`work/audio-prefill3-ipad-run.log`, `work/audio-prefill3-iphone-run.log`). Both reached **GAME1 → PLAY**, and touch Start/A paused/resumed in the first field. Viewed captures: `work/evidence/ipad-audio-prefill3-field.png` and `work/evidence/iphone-audio-prefill3-field.png`. Neither log showed an Audio Queue or Metal error in that window. The preceding clean-source runs logged 15 starts through #5,880 on iPad and 27 through #15,300 on iPhone. Runs differ in scene and length, and starts only indicate rebuffer events; audible quality and added output latency remain unverified. **Open:** Chris should listen for glitches in the new build and check whether sound effects feel delayed.

The longer iPad run in `work/menu-control-size-final-ipad-run.log` still restarted playback 17 times through display list #6,780. A temporary diagnostic build (`work/audio-gap-diagnostic-ipad-run.log`) measured four rebuffer events after game-audio submission gaps of 136.2, 139.9, 100.1 and 139.4 ms. The then-current two-buffer reserve represented about 67 ms at the game's 22,020 Hz output rate, so such gaps could drain it. Increasing the reserve/start threshold from two/three to three/four buffers produced six starts through #6,780 on iPad but eight through #5,340 on iPhone (`work/audio-reserve3-ipad-run.log`, `work/audio-reserve3-iphone-run.log`), while adding about 33 ms of latency. Clearing a potentially stale rebuffer flag on start still left a five-start cluster near #5,040 on iPhone (`work/audio-clear-stale-iphone-run.log`). Reducing the RT64 surface from 240×135 to 160×90 points gave two starts through #5,340 on iPhone and five through #6,780 on iPad (`work/audio-surface160-iphone-run.log`, `work/audio-surface160-ipad-run.log`), but visibly softened the image and did not remove restarts. These were separate runs with different timing, so they are diagnostic, not a controlled proof of a fix. The temporary logging, three/four-buffer, flag and surface changes were reverted before the follow-up below.

## Audio timing and reserve follow-up (2026-09-27)

Chris still hears heavy glitches. A 20-second Simulator process sample (`work/audio-profile-ipad-sample.txt`) found the game audio thread waiting for messages in most samples and also caught it inside `AudioQueuePause` during recovery. This sample does not identify the source of the initial late message. Temporary arrival-time logging then showed normal production close to 22,020 frames/s, with occasional 131–135 ms gaps before the audio submit function and 42–68 ms spent in `AudioQueuePause` afterward (`work/audio-arrival-diag-ipad-run.log`). Thus the short reserve was vulnerable to bursts even though average audio production was on rate. The earlier throughput trace had a 352 ms interval between completed submissions; that measure included recovery time (`work/audio-throughput-diag-ipad-run.log`).

Two narrow recovery experiments were rejected. Removing the pause let the iPhone Audio Queue drain more than 300 times in one run (`work/audio-no-pause-iphone-run.log`). Giving the VI clock iOS interactive QoS still left a cluster of restarts near display list #5,700 on iPad (`work/audio-vi-qos-ipad-run.log`). Both source edits were reverted.

The retained change raises the reserve from two to five 736-frame game buffers and starts output after six instead of three. At 22,020 Hz, nominal reserve/prefill rise from about 67/100 ms to 167/200 ms. In a separate diagnostic iPad run, playback started once initially and once more after a 175.6 ms input gap at about 222 seconds (`work/audio-reserve5-ipad-run.log`); the iPhone run had only the initial start through about 294 seconds (`work/audio-reserve5-iphone-run.log`). Both reached **GAME1 → PLAY** and the first field; captures are `work/audio-reserve5-ipad-field.png` and `work/audio-reserve5-iphone-field.png`. The temporary counters were removed. The final source built for Simulator and unsigned device (`work/audio-reserve5-final-sim-build.log`, `work/audio-reserve5-final-device-build.log`), and the rebuilt app reached the first field on both Simulators (`work/audio-reserve5-final-ipad-run.log`, `work/audio-reserve5-final-iphone-run.log`; captures `work/audio-reserve5-final-ipad-field.png`, `work/audio-reserve5-final-iphone-field.png`).

**G4 remains open.** These are different run windows and queue restarts are only a proxy for audible glitches. The larger buffer did not eliminate every restart, and the added latency may make effects feel late. Next, time VI/event delivery and RT64 work at a late audio arrival, then reduce the actual stall. Chris should judge audible quality and effect timing on physical devices when available; Simulator playback and logs are the current proxy.

## Audio Queue sample-clock correction (2026-09-27)

Temporary paired VI/audio timestamps on iPad showed a three-retrace skip and a 90.8 ms audio submission gap at the same millisecond (`work/audio-vi-correlation-ipad-run.log`). Another run had an eight-retrace skip next to a 250.6 ms submission gap and a playback restart (`work/audio-timeline-candidate-ipad-run.log`). The VI loop therefore contributes to some producer stalls, but this trace does not identify why the VI thread was late. No VI scheduling or game-logic change was retained.

Apple's output callback can return a buffer before its contents finish playing. The diagnostic Audio Queue sample clock confirmed this here: callbacks commonly reported 300–500 more frames acquired than played, or about 14–23 ms at 22,020 Hz (`work/audio-clock-diagnostic-ipad-run.log`). The previous `osAiGetLength` bridge subtracted a whole buffer at callback and then estimated further playback from wall time. The retained change instead subtracts the queue's played sample time from the total frames successfully enqueued, with the earlier estimate as a fallback if the sample clock is unavailable. After one rebuffer in the candidate run, callback and sample time still tracked one another; the game reached **GAME1 → PLAY** and the first field.

The diagnostic code was removed. Simulator and unsigned device builds passed (`work/audio-timeline-final-sim-build.log`, `work/audio-timeline-final-device-build.log`). The exact clean build reached **GAME1 → PLAY** and the first field on both iPad Pro 11-inch (M4) and iPhone 16 Pro iOS 18.5 Simulators, with nonzero PCM consumed and no Audio Queue error in those windows (`work/audio-timeline-final-ipad-run.log`, `work/audio-timeline-final-iphone-run.log`). This corrects the reported queue length; it does not remove the measured producer stalls or prove audible quality. **G4 remains open**, including listening for pops and delay, route/interruption tests, and real-device audio.

The same callback timing could also falsely request a recovery pause while the last buffer was still playing. A follow-up gates that pause on the sample clock reaching the end of enqueued PCM; if the clock query is unavailable, it keeps the earlier recovery behavior. The clean source built for Simulator and unsigned device (`work/audio-clock-rebuffer-sim-build.log`, `work/audio-clock-rebuffer-device-build.log`). Both iOS 18.5 Simulators reached **GAME1 → PLAY** and the first field with nonzero PCM consumed and no Audio Queue error (`work/audio-clock-rebuffer-ipad-run.log`, `work/audio-clock-rebuffer-iphone-run.log`). The iPad run had one recovery after its initial start and stayed in the playable field; the iPhone window had only its initial start. These are separate timing windows, so they do not establish a quantitative improvement or audible quality. **G4 remains open.**

## VI wake timing and macOS control retry (2026-09-27)

The existing macOS Metal host ran the ordinary windowed command for 180 seconds, exited 0 and reported 10,779 VIs (`work/g1-windowed-control-run.log`). The computer UI tool listed ConkerRecomp as running but timed out twice when binding its window, so no visible macOS gameplay, input, or audible comparison was established. **G1 remains open.**

On iPad Pro 11-inch (M4), a temporary runtime trace measured the VI loop entering sleep 8–16 ms before its deadline, then occasionally waking 17–58 ms after it (`work/audio-vi-wake-diagnostic2-ipad-run.log`). That supports late wakeup as the immediate cause of those skipped retraces; it does not prove why the host scheduler was late. A temporary iOS `mach_wait_until` substitution still woke 17–52 ms late and had an audio playback restart in a separate GAME1 → PLAY run (`work/audio-mach-wait-ipad-run.log`). The substitution and both diagnostics were reverted from the ignored runtime checkout. **No timer change was retained.** Next, trace the audio queue depth and producer cadence around a late VI wake, then change only the boundary that demonstrably loses audio; maintain the macOS and iPhone regression routes.

After the revert, Simulator and unsigned device builds passed (`work/audio-vi-reverted-sim-build.log`, `work/audio-vi-reverted-device-build.log`). The clean iPad Simulator app reached **GAME1 → PLAY** and the first field, consumed nonzero PCM, and emitted no diagnostic line or Audio Queue error in the checked window (`work/audio-vi-reverted-ipad-run.log`).

## Audio drain and recovery boundary (2026-09-27)

The iPad queue-depth trace tied an 11-retrace VI skip to a 305.8 ms gap before the next 736-frame PCM submission. The Audio Queue sample clock showed **zero** frames left, so this was a real underrun, not merely an early completion callback. The current recovery then spent 192.2 ms in `AudioQueuePause`; a second pause soon after took 35.6 ms (`work/audio-depth-correlation-ipad-run.log`). The pause adds to an already audible gap, but the producer stall begins before the audio adapter.

Two temporary alternatives were tested and **rejected**. A three-retrace catch-up limit in the VI loop still had a recovery by display list #3780 on iPad (`work/audio-vi-catchup-ipad-run.log`). Removing the recovery pause initially allowed an iPhone run to keep roughly 2,770–4,000 frames queued with one playback start through display list #5820 (`work/audio-no-pause-clock-iphone-run.log`), but the longer iPad run exposed the failure: after a 121.2 ms gap drained the queue, reported sample-clock depth stayed at zero across successive five-second snapshots while completed nonzero buffers kept increasing from 4,805 to 7,060 (`work/audio-no-pause-clock-ipad-run.log`). The same run had a 355.2 ms producer gap and no way to rebuild its reserve. This rejects pause removal even with the newer sample-clock accounting. The earlier uninstrumented no-pause iPad run also reached zero after a 269.9 ms gap (`work/audio-no-pause-ipad-run.log`).

All temporary audio and VI edits were removed. The restored source built for Simulator and unsigned device (`work/audio-depth-reverted-sim-build.log`, `work/audio-depth-reverted-device-build.log`). The exact restored iPad build reached **GAME1 → PLAY** and the first field, consumed nonzero PCM, and had no adapter error or diagnostic lines; it still restarted playback twice through display list #4620 (`work/audio-depth-reverted-ipad-run.log`). **Audio is still glitchy and G4 remains open.** The next audio change needs to preserve a prefilled reserve after a real drain without blocking the game's PCM producer in `AudioQueuePause`; prove the recovery on both Simulators with a forced or naturally observed drain, then compare audible playback before keeping it. Do not treat a playback-start count alone as an audio-quality pass.

## Nonblocking Audio Queue recovery (2026-09-27)

The mobile adapter now writes game PCM into a bounded ring. A fixed Audio Queue output callback pulls 256-frame chunks, emits silence on an underrun, and resumes PCM when the six-game-buffer reserve has refilled. It no longer calls `AudioQueuePause` from the game's PCM submission path. The five-game-buffer reported reserve remains, and Conker game logic is unchanged. A temporary diagnostic deliberately delayed the PCM producer for 350 ms on iPad: the callback recorded one underrun and one refill, then nonzero output continued with only the original playback start through display list #6420 (`work/audio-pull-forced-gap-ipad-run.log`). The delay hook was removed from the retained source.

The exact retained source built for iOS Simulator and unsigned device (`work/audio-pull-final-sim-build.log`, `work/audio-pull-final-device-build.log`). Both iOS 18.5 Simulators reached **GAME1 → PLAY** and the first field; captures are `work/evidence/ipad-audio-pull-final-field.png` and `work/evidence/iphone-audio-pull-final-field.png`. Both logs show nonzero PCM consumed and no callback enqueue error. Natural underruns still occurred: four on iPad through display list #5640 and seven on iPhone through #6300 (`work/audio-pull-final-ipad-run.log`, `work/audio-pull-final-iphone-run.log`). The run windows and schedules differ from earlier experiments, so these counts do not establish an audible improvement. **G4 remains open:** measure and reduce the VI/PCM producer stalls, check output timing and interruptions, and judge glitches and effect delay by listening on real devices when available.

## Audio start recovery and remaining glitches (2026-09-27)

Chris reported heavy glitches in the pull-adapter build. Temporary probes found 107–290 ms gaps between PCM submissions while VIs continued, and RT64 display-list calls as long as 988 ms during a stressed iPad run. The game audio timer was sometimes over 50 ms late. Giving that timer iOS interactive QoS did not prevent underruns, and turning off RT64 render-to-RAM still left five underruns by display list #5580; both experiments were reverted. One heavily instrumented run reached the ring's half-second limit and dropped packets continuously. That condition did not recur in the bounded-log rerun, so its callback state and cause remain unproven. Probe logs are `work/audio-event-probe-ipad-run.log`, `work/audio-timer-qos-ipad-run.log`, `work/audio-no-ram-ipad-run.log` and `work/audio-drop-callback-ipad-run.log`.

A separate reproducible failure was `AudioQueueStart` returning `-66680` (`kAudioQueueErr_InvalidDevice`). The old adapter discarded the queue and could not start again without a game frequency change. `Support/Conker/mobile_audio.cpp` now retries failed queue creation, buffer allocation or playback start on later PCM submissions, no more often than once per second. A test build forced the first start to fail; after changing the Simulator's audio output from the system's Jump Desktop Audio route to MacBook Air Speakers and rebooting that Simulator, the next attempt started and consumed nonzero PCM (`work/audio-retry-forced-ipad-reboot-run.log`). The forced-failure hook was removed.

The retained source built for Simulator and unsigned device (`work/audio-retry-final-sim-build.log`, `work/audio-retry-final-device-build.log`). iPad and iPhone iOS 18.5 Simulators each reached **GAME1 → PLAY** and the first field with nonzero PCM consumed and no queue error; captures are `work/evidence/ipad-audio-retry-final-field.png` and `work/evidence/iphone-audio-retry-final-field.png`. The iPad had zero reported underruns through display list #7080; the iPhone had one through #7140 (`work/audio-retry-final-ipad-run.log`, `work/audio-retry-final-iphone-run.log`). Different runs and output routes make those counts unsuitable as an audio-quality comparison. **G4 remains open:** the retry fixes a permanent-silence failure, but does not establish glitch-free playback. Measure the producer/RT64 stalls and test interruptions, output routes and audible quality before calling audio complete.

## Stalled output callback recovery (2026-09-27)

The earlier stressed iPad trace had a fixed 11,160-frame ring level while new PCM packets were dropped. That suggests the output callback stopped draining, but the heavy per-packet diagnostic logging prevents treating the trace alone as proof of why it stopped. The mobile adapter now watches completed Audio Queue buffers. If the game has over half a second of queued PCM and no callback progress for 500 ms, it discards that stale queue and recreates it; ordinary underruns still use the existing pull/rebuffer path.

A temporary test hook stopped re-enqueuing callback buffers after 1,000 completions on the iPad Simulator. The watchdog logged one stalled-output restart, then playback started again and consumed nonzero PCM (`work/audio-watchdog-forced-ipad-run.log`). The hook was removed. The retained source built for Simulator and unsigned device (`work/audio-watchdog-final-sim-build.log`, `work/audio-watchdog-final-device-build.log`), then both iOS 18.5 Simulators reached **GAME1 → PLAY** and the first field. The iPad run had no unexpected restart, callback error or reported underrun through display list #8160; the iPhone had none through #8280 (`work/audio-watchdog-final-ipad-run.log`, `work/audio-watchdog-final-iphone-run.log`). Viewed captures: `work/evidence/ipad-audio-watchdog-final-field.png` and `work/evidence/iphone-audio-watchdog-final-field.png`.

**G4 remains open.** This closes the forced stalled-callback recovery case, not the previously measured PCM producer gaps or Chris's audible-glitch report. The next run should pair PCM submission and callback timestamps with RT64 display-list durations in the same gameplay window, then change the actual source of any remaining underrun. Simulator counters alone do not establish audio fidelity.

## Paired audio and RT64 stall trace (2026-09-27)

After Chris reported continuing glitches, temporary timestamp probes paired Audio Queue callbacks, PCM submissions, VI progress and RT64 display-list work in the same iPad GAME1 → PLAY run. A 486 ms display-list call overlapped a 248 ms PCM submission gap and an underrun (`work/audio-pair-probe-ipad-run.log`). The callback kept completing buffers while the game produced no new PCM. A second run localized two 138–248 ms display-list calls to RT64 `State::fullSync` with render-to-RAM active; neither the ubershader pipeline wait nor its measured GPU worker wait exceeded 30 ms (`work/audio-rt64-phase-ipad-run.log`).

A finer phase trace found a 260 ms full sync with 11 framebuffer pairs: 166 ms in framebuffer setup, 51 ms in command recording and 3 ms in GPU wait. It overlapped a 188 ms PCM gap and was followed by an underrun (`work/audio-rt64-sync-ipad-run.log`). Another run had a 440 ms full sync, mostly 398 ms of CPU preparation, while two successive PCM gaps of 204 and 160 ms drained even an experimental eight-game-buffer reserve (`work/audio-eight-reserve-ipad-run.log`). Raising only Conker's audio thread 4 to iOS user-interactive QoS also left an underrun alongside a 556 ms full sync (`work/audio-thread4-qos-ipad-run.log`). These are paired timing observations, not proof that one specific RT64 function blocks the audio thread. The larger reserve would add roughly 100 ms of nominal latency, so both experiments were reverted. Temporary probes were removed from the source.

One more temporary setup probe separated the work before command recording. In an iPad GAME1 → PLAY run, `TextureCache::waitForGPUUploads` took 104 ms in one two-pair sync and 81 ms in another. `FramebufferRenderer::addFramebuffer` and its surrounding framebuffer setup took 112 ms in a separate two-pair sync and 91 ms in a six-pair sync; the run reported two underruns by display list #4800 (`work/audio-rt64-setup-ipad-run.log`). The two slow paths vary by frame, so neither can be skipped safely on this evidence. That probe was also removed.

A follow-up iPad run split `addFramebuffer` into resource growth, descriptor setup and game-call work. Descriptor setup alone took 338.8, 236.5 and 368.9 ms while framebuffer resources were already allocated; the run had two audio underruns (`work/audio-upload-fb-ipad-run.log`). A temporary Plume cache skipped exact repeated native resource bindings, but a separate GAME1 → PLAY run still showed 44–68 ms descriptor stages and five underruns (`work/audio-descriptor-cache-probe-ipad-run.log`). Individual Metal bindings on the Simulator's non-Tier-2 argument-encoder path also took 10–43 ms for both textures and buffers (`work/audio-metal-binding-probe-ipad-run.log`). These runs are not controlled audio-quality comparisons. The cache and probes were rejected, and the original RT64 and Plume patches restored. The restored Simulator archive and app built, and the iPad reached GAME1 → PLAY and the first field (`work/audio-metal-binding-restored-archive-build.log`, `work/audio-metal-binding-restored-app-build.log`, `work/audio-metal-binding-restored-ipad-run.log`). **Audio remains open:** investigate the argument-encoder stalls and the separate texture-upload waits without altering game logic or relying on more buffering alone.

An individual-call split then measured 37.4 ms in `MTLArgumentEncoder::setTexture` and 40.7 ms in `setBuffer`, with negligible retain time, on the iPad Simulator's Tier-1 path (`work/audio-metal-stage-probe-ipad-run.log`). The app still entered GAME1 → PLAY and rendered the first field. This points inside Metal's argument encoder rather than Plume's retain/release bookkeeping. The probe was removed; no unverified direct-write or Tier-2 override was retained.

A paired scheduling check set only the iOS graphics thread to utility QoS. Its iPad GAME1 → PLAY run had no reported underrun through display list #9060 (`work/audio-gfx-utility-ipad-run.log`), but the rebuilt default-QoS run on the same route also had none through #9060 (`work/audio-gfx-default-paired-ipad-run.log`). There is no measured benefit, so the QoS change was removed. A separate temporary pause immediately after rendering display list #4200 tested whether delaying graphics completion can drain the audio queue: 400 ms produced no reported underrun through #5100 (`work/audio-gfx-sleep-ipad-run.log`), while 1000 ms was followed by one underrun and reserve refill near #4620 (`work/audio-gfx-sleep1s-ipad-run.log`). Both had started playback and consumed nonzero PCM before the pause. This establishes a long-delay failure path, not the cause or frequency of Chris's ordinary audible glitches. The pause was removed; the restored app rebuilt (`work/audio-gfx-sleep-restored-sim-build.log`), then reached GAME1 → PLAY and the first field on the iPad. That ordinary restored run had one underrun near #2280 (`work/audio-gfx-sleep-restored-ipad-run.log`), so the audible-glitch report remains plausible and **audio remains open**.

**Next narrow target:** pair normal PCM submission gaps with graphics completion timing, then isolate one expensive RT64 upload or framebuffer operation and compare a single renderer change on the same GAME1 → PLAY route. Do not mask stalls with still more output latency or claim audible fidelity from counters. Physical-device listening, routes and interruptions remain open.

## Framebuffer parameter binding cut (2026-09-28)

**Pass:** `patches/rt64-static-fb-params.patch` binds each framebuffer's fixed parameter buffer to its real and dummy descriptor sets when those sets are created. `addFramebuffer` continues updating the buffer contents and rebinding the changing color and depth textures, but no longer calls Metal's argument encoder twice per framebuffer on later use. The patch was reverse-checked, reapplied and built for the iOS Simulator RT64 archive/app and unsigned device archive/app (`work/audio-fb-static-sim-rt64-build.log`, `work/audio-fb-static-sim-app-build.log`, `work/audio-fb-static-device-rt64-build.log`, `work/audio-fb-static-device-app-build.log`). On iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5, the same installed build reached **Continue Imported ROM → GAME1 → PLAY → first field**; the field and touch Start/A pause/resume were visually inspected on each (`work/audio-fb-static-ipad-run.log`, `work/audio-fb-static-iphone-run.log`).

**Fail for audio:** the iPad reported four underruns through display list #10020, first near #3060; the iPhone reported one through #8580, near #2640. These independent runs do not prove a change in underrun rate relative to the baseline. The binding cut is a narrow renderer work reduction, not an audio fix. Next instrument remaining framebuffer texture bindings and texture-upload waits in one ordinary gameplay window, then compare a single change against the same route. Speaker/headphone quality still needs a real device.

## Texture-upload audio investigation (2026-09-28)

**Fail for audio:** a temporary iPad Simulator trace on the ordinary GAME1 → PLAY route recorded three underruns near display list #2880 while the RT64 upload worker processed several slow batches. One single-texture batch spent 89.1 ms in its two Metal descriptor `setTexture` calls; another spent 38.4 ms there. A two-texture batch spent 28.4 ms binding and 64.6 ms waiting for GPU work, with `TextureCache::waitForGPUUploads` blocking the renderer for 95.4 ms (`work/audio-upload-wait-ipad-run.log`). The timing is adjacent, not proof that any one call caused each underrun. The upload wait protects textures used by the next frame, so it was not removed.

Setting only RT64's upload thread to iOS user-initiated QoS did not improve this route: the iPad logged two underruns near display list #3180, a later 76.8 ms upload wait, and 18 underruns by #8160 (`work/audio-upload-qos-ipad-run.log`). The QoS change and all timing probes were rejected. The original RT64 source was restored and built for Simulator (`work/audio-upload-probes-restored-sim-rt64-build.log`, `work/audio-upload-probes-restored-sim-app-build.log`). The exact restored app reached GAME1 → PLAY and the first field; its capture is `work/audio-upload-probes-restored-ipad-field.png`, and it logged seven underruns through display list #5160 (`work/audio-upload-probes-restored-ipad-run.log`). This is still an audio failure, and the Simulator runs are not controlled audible-quality comparisons.

The runtime's Apple `set_native_thread_priority` is a no-op, so a separate iOS-only experiment gave its VI event thread user-interactive QoS. The iPad candidate reached the first field with one underrun through #10500, and Start/A still paused/resumed (`work/audio-vi-qos-ipad-run.log`, `work/audio-vi-qos-ipad-field.png`). The iPhone candidate also reached the field and paused/resumed, but had three underruns through #9300 (`work/audio-vi-qos-iphone-run.log`, `work/audio-vi-qos-iphone-field.png`). After reverting the priority change, the paired iPhone default run had the same three underruns through #9300 and reached the field (`work/audio-vi-qos-restored-sim-app-build.log`, `work/audio-vi-qos-restored-iphone-run.log`, `work/audio-vi-qos-restored-iphone-field.png`). This does not establish a repeatable audio benefit; VI priority remains unchanged in the retained source.

**Next narrow target:** reduce the Tier-1 Metal argument-encoder binding cost or a measured GPU wait without changing game logic or increasing audio latency, then replay the same route on both Simulators. Physical-device listening and audio-route checks remain for Chris when an iPad and iPhone are available.

### Paired texture binding check (2026-09-28)

`patches/rt64-ios-texture-pair.patch` binds the texture decoder's adjacent TMEM and RGBA32 slots with one Metal Tier-1 `MTLArgumentEncoder::setTextures` call. Other backends and Metal Tier-2 retain the two-call behavior. A temporary timing probe confirmed this branch executed and recorded a 16.1 ms paired call near an underrun; the probe was removed. The patch was reverse-applied, cleanly replayed, and built in the final Simulator and unsigned `iphoneos` RT64/app targets (`work/audio-texture-pair-final-{sim,device}-{rt64,app}-build.log`).

The exact final Simulator app reached **Continue Imported ROM → GAME1 → PLAY → first field** on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5. Touch Start paused and A resumed in both viewed runs (`work/audio-texture-pair-final-ipad-field.png`, `work/audio-texture-pair-final-iphone-field.png`; matching `work/audio-texture-pair-final-{ipad,iphone}-run.log`). The iPad logged three underruns through display list #3480; the iPhone logged four through #4560. A prior candidate run logged five through #10380. These runs do not establish an audio improvement over the variable baseline. **Chris's audio-glitch report remains open.** Next measure actual PCM producer gaps and ring depth at each underrun, then tie a slow producer interval to its blocking thread before another renderer or audio change. The reference-style three-dot menu remains a separate open UI gap.

### PCM producer-gap trace (2026-09-28)

A temporary iPad GAME1 → PLAY trace reached the first field and logged two underruns through display list #5400 (`work/audio-gap-probe-ipad-run.log`). The audio output callback's recorded maximum interval never crossed the probe's 25 ms reporting threshold. At the two underruns, only 8 and 80 frames remained in the PCM ring; the most recent game PCM submission was 105 and 173 ms old. The next producer submissions showed 223 and 219 ms gaps. This run supports **late PCM production** as a real failure path; it does not locate the wait or establish that every audible glitch takes this path.

A second temporary trace timed the mobile RT64 `send_dl` and `update_screen` calls alongside the audio trace (`work/audio-gap-renderer-ipad-run.log`). `send_dl` sometimes took over 300 ms and once 802 ms near producer gaps, but its per-frame logging was noisy and the run accumulated 23 underruns by display list #2490. Do not compare that run's underrun count with the ordinary build. Both probes were removed, the original source files were byte-checked against saved copies, and the uninstrumented Simulator app rebuilt (`work/audio-gap-probes-restored-sim-app-build.log`). Next isolate which RT64 wait or game-thread dependency delays PCM production, with sparse diagnostics and an ordinary-run control. Audio remains open.

### Audio recovery and host-load check (2026-09-28)

Two sparse iPad traces put some PCM producer gaps over 150 ms beside long `send_dl` spans, but the Mac's load rose above 20–50 during those runs (`work/audio-sparse-ipad-run.log`). A separate trace found occasional audio RSP tasks over 100 ms while many producer gaps had no matching long RSP task (`work/audio-rsp-probe-ipad-run.log`). The latter run also had hundreds of underruns under severe host load. All timing probes were removed, their source files were byte-checked against backups, and the uninstrumented Simulator app rebuilt (`work/audio-rsp-probe-restored-sim-build.log`). Neither trace identifies a safe renderer or RSP change.

The output queue previously waited for six 736-frame game buffers after *every* underrun, about 200 ms at Conker's 22,020 Hz output rate. `Support/Conker/mobile_audio.cpp` now resumes after two game buffers, about 67 ms, while keeping the six-buffer initial startup threshold. This removes roughly 134 ms of silence deliberately added by the recovery policy; it does not prevent the producer gap that caused the underrun. The Simulator and unsigned device apps built (`work/audio-recovery-sim-build.log`, `work/audio-recovery-device-build.log`). The exact Simulator build reached **GAME1 → PLAY → first field** on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5 (`work/evidence/ipad-audio-recovery-field.png`, `work/evidence/iphone-audio-recovery-field.png`).

**Audio still fails:** the iPad run reported 337 underruns through display list #2400; the iPhone run reported 71 through #4020 (`work/audio-recovery-ipad-run.log`, `work/audio-recovery-iphone-run.log`). A separate default-build iPad run reported 147 through #2100 (`work/audio-native-baseline-ipad-run.log`), but Simulator boot drove the Mac's load above 160–190, so these are not controlled quality comparisons. Keep the shorter recovery as a bounded silence reduction, not a claim that the glitch is fixed. Re-run the ordinary gameplay route at stable host load before retaining any renderer resolution or scheduling change; measure producer gaps and audible output. Physical speaker/headphone quality, interruptions and routes still need Chris's devices.

### Audio task and RT64 resolution check (2026-09-28)

A temporary sparse trace of the iPad first field logged 32 PCM submission gaps over 120 ms (`work/audio-task-snapshot-ipad-run.log`). The latest audio RSP task had finished before the end of 28 gaps; a graphics `send_dl` call was active at the end of 27. The trace kept only the latest task, so these overlaps do not prove what delayed PCM. The Mac's load was about 20–25 and the run reached 920 underruns by display list #4380. Both temporary probes were removed, their source files matched saved backups, and the uninstrumented Simulator app rebuilt (`work/audio-task-snapshot-restored-sim-build.log`).

An RT64 `Resolution::Original` trial reduced internal scale to 1× and still reached **GAME1 → PLAY → first field** on the iPad (`work/evidence/ipad-audio-resolution-native-field.png`). A same-boot default → original → default sequence recorded 311 underruns through display list #3900, 171 through #4800, and 183 through #3960, respectively (`work/audio-resolution-{default,native,default-repeat}-ipad-run.log`; default captures under `work/evidence/`). The default repeat approached the candidate as the host load changed, while the candidate looked softer. **The resolution change was rejected and the original renderer source restored byte-for-byte.** Counts from these runs cannot establish an audio improvement.

A 10-second `sample` of the uninstrumented default build in the first field (`work/audio-resolution-default-field-sample.txt`) found the audio game thread waiting for messages in 4,304 of 4,483 samples; the separate RSP task thread spent 4,110 samples waiting and 363 running tasks. The graphics thread spent 3,813 samples in `send_dl`, including 542 in a Metal fence wait. This shows the sampled thread states, not which wait caused an underrun. **G4 audio remains open:** next correlate a PCM gap with the audio game's timer/message wake and RT64 fence completion in the same sparse trace, under measured host load. Keep the image scale until that trace identifies a safe change.

### Audio wake and PCM gap isolation (2026-09-28)

An iPad first-field trace counted 13 PCM submission gaps over 120 ms and four VI wake gaps over 80 ms (`work/audio-vi-cadence-probe-ipad-run.log`). The first three PCM gaps overlapped a long VI gap; ten did not. The VI clock therefore contributes to some stalls but cannot alone account for this run. A separate first-field run logged 14 underruns and nine long PCM gaps with **no dropped AI event messages** at the runtime message queue (`work/audio-ai-drop-probe-ipad-run.log`). That rules out observed queue overflow in this window, not all wake-delivery latency.

Timing Conker's audio game thread (`func_10009400`) against PCM submission showed matching 151.7 ms and 200.6 ms wake/submission gaps in sequence. Another cluster included 207 ms and 143 ms inside its PCM-producing call (`func_100095A0`); the run logged seven underruns through display list #7140 (`work/audio-game-thread-probe-ipad-run.log`). The Mac's load averaged roughly 5–11 during these runs, and their different timing windows make underrun counts incomparable. The earlier timer at RDRAM `0x8003A588` belongs to the general event thread, so its late firings are not direct audio-thread evidence. **Audio remains glitchy.** All temporary probes were removed and their sources byte-checked against saved copies; no audio/runtime behavior was retained from these diagnostics.

A follow-up split eight audio-work spans over 80 ms across `func_100099BC`, the AI bridge/frame setup, `n_alAudioFrame`, and the send tail (`work/audio-work-stages-ipad-run.log`). The time moved between stages: two calls spent 127 and 101 ms in `func_100099BC` (which can block on a message receive), while others spent 150 or 87 ms in the tail. The iPad reached display list #3300, but the Mac's load averaged roughly 20–40 and the run logged 76 underruns, so these timings cannot justify changing one callee or comparing underrun totals. The probe was removed and its generated source restored byte-for-byte. A less loaded, paired trace at the message queue and audio thread is needed before a runtime scheduling change.

### Audio scheduler queue timing (2026-09-28)

A sparse temporary trace of three Conker audio-related message queues reproduced an iPad first-field underrun near display list #3900. The audio thread's blocking receive from `0x8003E5D0` lasted 86.4 and 82.1 ms immediately before that underrun; no PI or RSP-completion receive over 80 ms appeared in this run (`work/audio-mq-wait-ipad-run.log`). A second run traced the scheduler's queue `0x8003B218` and its sends to the audio queue. Two earlier clusters paired 100.6/106.3 ms scheduler receives with 105.4/107.7 ms send gaps and 105.5/112.8 ms audio receives. Later, five underruns were logged near multiple 70–156 ms send gaps and long scheduler/RSP-completion receives (`work/audio-mq-send-ipad-run.log`). The viewed game reached **GAME1 → PLAY → first field**. Host load was roughly 3–8 during these checks, but instrumentation and varying scene timing prevent a controlled underrun-rate comparison.

These calls include the runtime's cooperative scheduling delay, so their durations do **not** yet prove that the VI sender itself was late. The scheduler sends the audio thread's work message while handling VI events in Conker's `func_100049E0`; the next probe should time actual VI enqueue versus scheduler dequeue and audio-thread resume in one sparse trace. Both temporary wrappers were removed, `ultra_translation.cpp` matched its saved original byte-for-byte, and the ordinary Simulator app rebuilt (`work/audio-mq-probes-restored-sim-build.log`). At source revision `831faef`, the restored app executable SHA-256 was `8ce518bfbd0a7d33aa3f923c7acb7177257a49703506250065ada9b4b61f1847`. It visibly reached **GAME1 → PLAY → first field** and logged 26 underruns through display list #7200 (`work/audio-mq-probes-restored-ipad-run.log`). Five were already present before display list #120; later clusters also occurred. This ordinary run reinforces the audio failure, but its different timing cannot be compared numerically with the probes. **No scheduling or game-logic change was retained; audio remains open.**

### VI wake and audio-message correlation (2026-09-28)

A sparse iPad Pro 11-inch (M4), iOS 18.5 trace timed the runtime VI loop and Conker's scheduler/audio queues together (`work/audio-vi-enqueue-ipad-run.log`). It visibly reached **GAME1 → PLAY → first field**. One VI wake interval lasted 102.8 ms and skipped five VIs. The scheduler completed its receive 3.0 ms after that wake and sent audio work 3.4 ms after it, following a 106.0 ms gap between audio-work sends. The audio-thread receive later took 188.5 ms, and the run logged an underrun. A second 86.7 ms VI gap skipped four VIs. Separately, an 85.3 ms scheduler receive and 90.3 ms audio-send gap appeared without a matching VI wake over the probe's 70 ms threshold. **A delayed VI loop is one observed source of late audio work, but does not explain every stall.** The wake-gap measurement does not distinguish an overslept deadline from time spent in the VI loop before its next sleep; queue receive duration also includes cooperative scheduling delay. Next time the VI deadline before/after `sleep_until`, plus VI enqueue versus scheduler resume, in a single sparse trace before changing thread priority or timing.

The probe changed only ignored working-checkout source, then both `events.cpp` and `ultra_translation.cpp` were restored and byte-checked against saved originals. The ordinary Simulator app rebuilt with both files recompiled (`work/audio-vi-enqueue-probes-restored-sim-build.log`) and visibly reached **GAME1 → PLAY → first field** after an in-place install (`work/audio-vi-enqueue-probes-restored-ipad-run.log`). That short restored run reported no underrun through display list #3000; scene timing and host load differ, so it is not an audio-quality comparison. No audio or game-logic fix was retained. **G4 audio remains open.**

### VI deadline and external-message delivery (2026-09-28)

Two more temporary iPad Pro 11-inch (M4), iOS 18.5 probes reached **GAME1 → PLAY → first field**. In `work/audio-vi-deadline-ipad-run.log`, the VI loop entered `sleep_until` about 11–16 ms before its deadline but sometimes woke 57–91 ms late, skipping three to five VIs. One separate long VI interval spent 108 ms *outside* sleep, including 105 ms between wake and VI enqueue. The run logged seven audio underruns through display list #7260. The signed deadline metrics from the first trace's diagnostic printer were malformed when negative; the positive wake, sleep, body, and enqueue intervals are usable. The corrected printer in `work/audio-vi-delivery-ipad-run.log` reproduced 57–91 ms deadline lateness, plus one 95 ms loop-body delay. That second trace logged eight underruns through #4620. Host load was roughly 10–14, and logging and scene timing differ, so these counts are not a quality comparison.

The second trace also timestamped VI messages at the runtime's external queue. The first eight observed VI messages reached Conker's scheduler queue in 8–265 microseconds; later messages waited 53, 61, 62 and 79 ms before delivery, all with successful sends. These delays are distinct from the VI sleep overrun. The runtime only drains external messages at game-thread scheduling points, so the next narrow trace should time its queue drain and the VI loop's screen-update, state-update and mutex phases against a long graphics call. Do not alter VI cadence, queue dropping, or game logic based on the current trace. A previous `mach_wait_until` and VI-QoS trial also failed to establish an improvement, so repeating those switches is not the next step.

All three temporary runtime files (`events.cpp`, `mesgqueue.cpp`, `ultra_translation.cpp`) were restored and byte-checked against their saved originals. The ordinary Simulator app rebuilt with all three recompiled (`work/audio-vi-delivery-probes-restored-sim-build.log`); its executable SHA-256 is `8ce518bfbd0a7d33aa3f923c7acb7177257a49703506250065ada9b4b61f1847`, byte-identical to the earlier uninstrumented GAME1 → PLAY → first-field build. **No audio fix was retained. G4 remains open.**

### VI loop phase check (2026-09-28)

A temporary iPad first-field trace timed the VI loop from wake through screen action, state update, message mutex acquisition and VI enqueue (`work/audio-vi-phases-ipad-run.log`). The run logged an underrun near display list #1440, with no measured wake-to-enqueue phase over 50 ms through #6900. More underruns appeared after #7200. This rules out a long in-loop phase for the first observed underrun in this run, but does not identify its cause or explain the earlier deadline oversleeps and external-message delivery delays. The probe was removed, `events.cpp` matched its backup byte-for-byte, and the ordinary Simulator app rebuilt (`work/audio-vi-phases-restored-sim-build.log`). No audio scheduling or game-logic change was retained; audible glitches remain open.

### Three-dot menu contrast and close action (2026-09-28)

The Settings panel now uses a compact X close action, lighter backdrop and darker panel, and tighter content spacing on iPhone. The layout still uses the reference's blue Settings header and left category list; further menu parity remains open. The exact Simulator executable SHA-256 was `b7c1ec89ae687d70547db25ded854fa83099f537d1ceeaa789e39ffc370abf4f`. Simulator and unsigned device builds passed (`work/menu-contrast-final-sim-build.log`, `work/menu-contrast-final-device-build.log`).

On iPhone 16 Pro and iPad Pro 11-inch (M4), iOS 18.5, the menu opened, switched to Audio, and closed from the X or three-dot control. Viewed captures are `work/evidence/iphone-menu-contrast-final.png` and `work/evidence/ipad-menu-contrast-final.png`. On iPad, the same build launched the private ROM, hid touch controls while the menu was open over the game, restored them on close, and kept rendering (`work/evidence/ipad-menu-contrast-gameplay.png`, `work/menu-contrast-final-ipad-run.log`). This verifies the menu behavior and appearance in these Simulator windows, not touch feel or audio quality on physical devices.

The reference capture `ref/harkinianpad/docs/readme/simulator-settings.jpg` shows the game clearly through its dark Settings panel. SquirrelPad's 90%-black panel plus backdrop obscured it more heavily. Reducing the panel to 78% black retains legible white controls while making the game visible behind both tabs. The exact Simulator build passed (`work/menu-translucency-sim-build.log`, executable SHA-256 `de8494a72a3e9a4e111de8daa71bbbdcc6990b22d7f3ce4aa08dc22b5a1bab66`). On iPhone 16 Pro and iPad Pro 11-inch (M4), iOS 18.5, the imported game rendered beneath the menu, Audio selection worked, and X restored the touch overlay. Viewed captures: `work/evidence/iphone-menu-translucency-audio.png`, `work/evidence/ipad-menu-translucency-controls.png`; logs: `work/menu-translucency-iphone-run.log`, `work/menu-translucency-ipad-run.log`. This is a visual/menu check through the opening sequence, not an audio-quality or long-play result. The reference has substantially broader settings and binding UI; menu parity remains open.

### Paired VI, message, renderer and PCM timing (2026-09-28)

One sparse iPad Pro 11-inch (M4), iOS 18.5 trace reached **GAME1 → PLAY → first field** (`work/audio-unified-ipad-run.log`, viewed capture `work/evidence/ipad-audio-unified-field.png`). Around display list #1260, a 346 ms RT64 `send_dl` span overlapped a 106 ms PCM submission gap, a VI message delivered 61 ms after enqueue, two VI deadline misses of 49 and 60 ms, and one audio underrun. An earlier 100 ms PCM gap preceded that graphics span. Later 100–134 ms display-list spans and a 48 ms VI deadline miss appeared without another logged underrun through #7020. This is a same-run correlation, **not proof that the graphics call caused the underrun**. The next narrow renderer experiment should time the CPU preparation, framebuffer worker execute/wait, and native-RAM copy portions of `RT64::State::fullSync` during a PCM gap; avoid changing VI cadence or audio latency from this trace alone.

The temporary timing probes in `events.cpp`, `mesgqueue.cpp` and `Support/Conker/mobile_audio.cpp` were restored byte-for-byte against saved originals. The ordinary Simulator app rebuilt (`work/audio-unified-restored-sim-build.log`, executable SHA-256 `f4277fc31d269b7b6b74c67b5b603ebae6337eaa880e26532a7b0fdafffadccd`) and visibly reached the first field again (`work/evidence/ipad-audio-unified-restored-field.png`, `work/audio-unified-restored-ipad-run.log`). That short ordinary run had no reported underrun through display list #5340, but scene timing and instrumentation differ, so it does not establish an audio-quality improvement. **No audio or renderer change was retained; G4 remains open.**

### RT64 fullSync CPU phase check (2026-09-28)

Two temporary RT64 probes reached **GAME1 → PLAY → first field** on the iPad Pro 11-inch (M4), iOS 18.5 Simulator. In the coarse trace (`work/audio-fullsync-phase-ipad-run.log`, viewed capture `work/evidence/ipad-audio-fullsync-phase-field.png`), a 297 ms `State::fullSync` call spent 296 ms in its render-to-RAM branch and 9 ms waiting for GPU work. A later 305 ms call spent 301 ms in that branch and 8 ms in the measured GPU wait; three Audio Queue underruns appeared around these calls. The timings are nested, so the GPU wait is included in the render branch, not additional time.

The finer trace (`work/audio-fullsync-fine-ipad-run.log`, viewed capture `work/evidence/ipad-audio-fullsync-fine-field.png`) separated framebuffer setup, tile mapping, preparation, command recording, GPU execution and wait. The first 236 ms call included 179 ms in command recording and 22 ms in GPU wait, followed by an underrun. The next 212 ms call included 61 ms recording, 49 ms execute, 34 ms preparation and 11 ms GPU wait, followed by another underrun. A later 258 ms call included 147 ms recording and 15 ms GPU wait without a logged underrun. These are correlations from separate Simulator schedules; the broad recording phase still contains multiple framebuffer operations. They identify a narrower CPU area to inspect, but do not prove it caused the PCM gap or justify a renderer change yet.

The temporary `rt64_state.cpp` instrumentation was restored byte-for-byte from its backup. RT64 and the ordinary Simulator app rebuilt (`work/audio-fullsync-restored-rt64-build.log`, `work/audio-fullsync-restored-sim-build.log`); the ordinary executable SHA-256 is `b7c1ec89ae687d70547db25ded854fa83099f537d1ceeaa789e39ffc370abf4f` and contains no `[probe fullsync]` string. This rebuilt binary was not replayed after the fine probe; the preceding ordinary build's first-field check is recorded above. **No audio or renderer change was retained. G4 remains open.** Next, isolate command recording's expensive operation only if a natural long call reproduces alongside a PCM gap, then make one measured change with an ordinary iPad and iPhone regression run.

### Renderer wall time versus CPU time (2026-09-28)

Two more temporary iPad Pro 11-inch (M4), iOS 18.5 probes reached **GAME1 → PLAY → first field**. The operation trace (`work/audio-record-phase-ipad-run.log`, viewed capture `work/evidence/ipad-audio-record-phase-field.png`) had one Audio Queue underrun by display list #3660 with no command recording call above the probe's 50 ms threshold. Near #5040, more underruns appeared with a 342 ms recording call (317 ms in `recordSetup`) and a 612 ms call (348 ms in framebuffer start operations, 243 ms in render-target-to-native calls). The long time moved among unrelated operations, so the earlier broad recording span does not identify one expensive function. Host load rose from roughly 7 to 11 during that cluster.

The second trace measured both wall time and **thread CPU time** in RT64 (`work/audio-cpu-clock-ipad-run.log`, viewed capture `work/evidence/ipad-audio-cpu-clock-field.png`). A first-field `State::fullSync` took 965 ms wall time but only 14 ms thread CPU; its command recording included 457 ms wall time and 7 ms thread CPU. Multiple Audio Queue underruns occurred around this stall. Other 85–177 ms `fullSync` calls used roughly 9–12 ms thread CPU. This shows the measured thread was mostly waiting or not scheduled during those calls; it cannot distinguish Metal/lock waits from host scheduling, nor prove the renderer caused every underrun. Simulator host load reached roughly 15. A CPU optimization of one framebuffer function is therefore unsupported by this evidence.

Both probes were removed and `rt64_state.cpp` byte-checked against its original. RT64 and the ordinary Simulator app rebuilt (`work/audio-cpu-clock-restored-rt64-build.log`, `work/audio-cpu-clock-restored-sim-build.log`). The executable SHA-256 is `f4277fc31d269b7b6b74c67b5b603ebae6337eaa880e26532a7b0fdafffadccd`, byte-identical to the earlier first-field-checked ordinary build. No audio or renderer behavior changed. The next scheduling candidate is the Apple `set_native_thread_priority` no-op in N64ModernRuntime: VI requests `Critical`, game threads request `High`, and the timer requests `VeryHigh`, but none take effect on Apple. Any iOS QoS mapping must be checked for actual application and replayed through gameplay on both Simulators before claiming benefit. **G4 remains open.**

### iOS runtime thread priority candidate (2026-09-28)

`patches/n64modernruntime-ios-qos.patch`, replayed by `scripts/setup-source.sh`, maps the runtime's iOS `Critical` thread to `QOS_CLASS_USER_INTERACTIVE` and `VeryHigh`/`High` to `QOS_CLASS_USER_INITIATED`. Lower levels and macOS behavior are unchanged. The iOS call reads back its QoS and logs a failure or mismatch. The patch reverse-checks against the pinned runtime checkout. This is a scheduling correction, not an established audio fix; game logic is unchanged.

The final Simulator and unsigned device builds passed (`work/audio-qos-final-sim-build.log`, `work/audio-qos-final-device-build.log`); Simulator executable SHA-256 is `65876a552ce389adf78d9c24e7344344648f94273553d87f0f466212a6acd6a7`. The iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5, reached **GAME1 → PLAY → first field**. Viewed captures are `work/evidence/ipad-audio-qos-final-field.png` and `work/evidence/iphone-audio-qos-final-field.png`. Neither log reported a QoS set/readback failure. The iPad run logged no Audio Queue underrun through display list #5400 (`work/audio-qos-final-ipad-run.log`). The iPhone run logged **four underruns**, beginning near #4320, through #5460 (`work/audio-qos-final-iphone-run.log`). Short runs under different host loads cannot establish comparative audio quality, and the iPhone result directly shows the glitch remains. **G4 remains open.** Next, measure a longer controlled baseline/candidate pair under comparable load and isolate the PCM producer gap before changing audio buffering or renderer behavior. Physical audio quality and routes still require Chris's devices.

### Partial audio chunk recovery (2026-09-28)

A temporary iPhone 16 Pro, iOS 18.5 callback snapshot caught one first-field underrun after a **96 ms gap** since the last PCM submission, with **208 of 256 frames** still in the ring (`work/audio-underrun-gap-probe-iphone-run.log`, viewed capture `work/evidence/iphone-audio-underrun-gap-probe-field.png`). The previous callback discarded those 208 frames, then entered reserve recovery. The temporary timing probe was removed. `Support/Conker/mobile_audio.cpp` now copies the available frames into that short chunk, zeros only its missing tail, and still enters the same recovery state. This preserves about 9 ms of PCM in the observed case; it does not close the producer gap.

The exact changed app built for Simulator and unsigned device (`work/audio-partial-tail-sim-build.log`, `work/audio-partial-tail-device-build.log`); Simulator executable SHA-256 is `6cab57192494ab6707d2e8868d3dfb1bce13c0e1c7c6bd3409af045838a4925d`. The iPhone and iPad reached **GAME1 → PLAY → first field** with viewed captures `work/evidence/iphone-audio-partial-tail-field.png` and `work/evidence/ipad-audio-partial-tail-field.png`. The iPhone logged **four underruns** near display list #5880 and recovered from each, then continued through #6300 (`work/audio-partial-tail-iphone-run.log`). The iPad logged none through #8280 (`work/audio-partial-tail-ipad-run.log`). Different host schedules prevent an underrun-rate comparison. **G4 audio remains open:** identify and shorten the producer stall; verify actual speaker/headphone output on physical devices.

### AI buffer-length pacing check (2026-09-28)

The mobile bridge reports zero remaining frames until its ring contains more than `5 × 736 = 3,680` frames. N64ModernRuntime then subtracts roughly 92 more frames from the reported AI length, and Conker's audio function chooses a 552-frame buffer only at 249 or more reported frames. Thus at the observed 208-frame underrun, the game cannot be choosing the short buffer because of an inflated AI length. That hypothesis is ruled out by the current code path; late audio-work delivery remains plausible.

A temporary iPhone 16 Pro, iOS 18.5 pacing probe reached **GAME1 → PLAY → first field** and continued through display list #12000 without a reported underrun (`work/audio-ai-pacing-probe-iphone-run.log`; visually inspected `work/evidence/iphone-audio-ai-pacing-field.png`). Since the probe printed its buffer counts only on an underrun, this run gives no direct buffer-count sample and no quality comparison. The probe was removed; the ordinary Simulator app rebuilt (`work/audio-ai-pacing-restored-sim-build.log`, executable SHA-256 `eeeb26ea3831a7ada46b6859dcecc106567f3321eff7857cd61ff40fda2eb3b8`) with no probe string in source or binary. **G4 stays open.**

Runtime source review gives the next narrow trace: `mesgqueue.cpp` drains VI/AI/SP/DP messages only when a game thread enters a message queue operation or waits for an external message. The graphics thread posts SP completion before `send_dl`, but posts DP completion after it returns. A slow `send_dl` could therefore delay a game thread waiting for DP, while a separate late VI wake can delay it independently. Neither relationship is proved for the next underrun. Time DP enqueue/delivery, scheduler audio-work send, and PCM submission in one run before changing completion order or game scheduling.

### DP-to-audio timing probe (2026-09-28)

A temporary combined trace on the iPhone 16 Pro, iOS 18.5 Simulator reached **GAME1 → PLAY → first field** (viewed capture `work/evidence/iphone-audio-dp-pcm-probe-field.png`). Through display list #6300, `work/audio-dp-pcm-probe-iphone-run.log` recorded several RT64 `send_dl` calls over 80 ms, up to 169 ms, but no Audio Queue underrun, PCM submission gap over 75 ms, delayed DP delivery over 40 ms, or audio-work send gap over 75 ms. The thresholds leave smaller timing changes unobserved. This run does not reproduce the failure or establish that the renderer blocks the audio producer. The source probes were restored byte-for-byte. The ordinary Simulator app rebuilt (`work/audio-dp-pcm-restored-sim-build.log`) with no probe marker; its executable SHA-256 is `eeeb26ea3831a7ada46b6859dcecc106567f3321eff7857cd61ff40fda2eb3b8`, identical to the earlier checked ordinary build. No behavior change was retained; **G4 remains open**. Next capture a natural underrun with low-volume continuous timestamps around DP, audio-work and PCM submission before changing scheduling or graphics completion.

### Shorter underrun recovery rejected (2026-09-28)

At the 22,020 Hz game output rate, the existing two-game-buffer refill threshold is about 67 ms of PCM; a one-buffer threshold would be about 33 ms. A temporary one-buffer iPad Pro 11-inch (M4), iOS 18.5 build reached **GAME1 → PLAY → first field** with no logged underrun through display list #6600 (`work/audio-short-recovery-ipad-run.log`, viewed capture `work/evidence/ipad-audio-short-recovery-field.png`). That ordinary run did not exercise recovery. A separate build with a one-time 400 ms producer pause exercised it, but logged seven underruns before the pause and 27 total by display list #240 (`work/audio-short-recovery-forced-gap-ipad-run.log`). Different scene timing prevents a rate comparison, yet the repeated underrun/refill cycle gives no basis to retain the shorter threshold. Both the forced pause and one-buffer change were removed; `Support/Conker/mobile_audio.cpp` matches the prior commit byte-for-byte, and the restored Simulator build passed with no probe marker (`work/audio-short-recovery-restored-sim-build.log`). **No audio change was retained; G4 remains open.** The next experiment should target the measured producer stall rather than lowering the refill reserve.

### Bounded audio event-history run (2026-09-28)

A temporary low-output timeline buffer recorded renderer submission, DP/VI enqueue and delivery, scheduler audio-work sends, PCM submission and Audio Queue underrun events, dumping its recent history only after an underrun. The iPad Pro 11-inch (M4), iOS 18.5 run reached **GAME1 → PLAY → first field** (viewed capture `work/evidence/ipad-audio-timeline-field.png`) and continued through display list #15540 without an underrun (`work/audio-timeline-probe-ipad-run.log`). Therefore no failure history was dumped and no causal conclusion follows; the extra instrumentation may also affect scheduling. All three modified sources were restored byte-for-byte from saved originals. The ordinary Simulator build passed (`work/audio-timeline-restored-sim-build.log`), contains no timeline marker, and has executable SHA-256 `1f2e28273ae935fd2064dd4d5da1437e98e3d6c069858513523fe2dacf4d411d`, matching the previous restored build. **G4 remains open.** Further audio diagnosis needs a natural failure under a controlled scene/load, while independent save and lifecycle acceptance work can continue.

## Second save slot (2026-09-27)

On the iPad Simulator, touch stick navigation reached **GAME2 → NEW GAME** and A started it. The private EEPROM hash changed after the opening sequence and remained changed after termination. A cold relaunch revisited **GAME2**, which showed **PLAY** and `0:04:25` (`work/evidence/ipad-game2-save-relaunch.png`, `work/g5-game2-ipad-relaunch.log`). This proves a second occupied game-select slot persisted. It does not verify an in-level checkpoint or that two different game positions reload correctly; that remains part of G5.

## Home-screen VI gate (2026-09-27)

**Fail before change:** in a playable iPad field, `work/g5-ipad-lifecycle-baseline.log` rose from display list #6120 to #6960 during a ten-second Home-screen interval. The existing scene handler cleared held touch input but let the game render in the background.

**Pass after narrow change:** `patches/conker-mobile-lifecycle.patch` waits in the mobile host's VI callback while SwiftUI's scene phase is inactive, then wakes on return. The patch reverse-check passed in the pinned ignored checkout. Simulator and unsigned device builds passed (`work/g5-ipad-lifecycle-gate-sim-build.log`, `work/g5-ipad-lifecycle-gate-device-build.log`). The iPad log `work/g5-ipad-lifecycle-gate-run.log` stayed at display list #4200 throughout the ten-second Home interval; the iPhone log `work/g5-iphone-lifecycle-gate-run.log` stayed at #5340. Both returned to the first field, continued rendering and accepted touch Start/A pause/resume. Viewed captures: `work/evidence/ipad-lifecycle-gate-resumed.png` and `work/evidence/iphone-lifecycle-gate-resumed.png`. No Audio Queue or pipeline error appeared in either run.

**Open:** the runtime's `osGetTime` and timer thread still use wall time, and this gate does not prove game time or timer messages stay frozen on return. Audio output during background/interruptions and longer sleep/wake remain unmeasured. Do not mark G5 complete until those clocks, distinct in-level save states and repeated lifecycle transitions pass.

## Background clock baseline (2026-09-28)

A temporary `osGetTime()` print at the existing scene-activity bridge measured the iPad Pro 11-inch (M4), iOS 18.5 Simulator during one Home-screen interval. The first inactive notification read 1,146,155,109 ticks; the next active notification read 2,105,362,265 ticks. At 46,875,000 ticks per second, the game clock advanced 20.46 seconds while the app was backgrounded (`work/g5-clock-probe-ipad-run.log`). The VI display-list count stayed at #240 until the return and then resumed at #300. The probe was removed. This confirms that the VI gate alone does not freeze `osGetTime()`; it does not show whether any particular game timer fired. A fix must keep the VI schedule, `osGetTime()` and queued timer deadlines on one paused clock, then recheck background/foreground on both Simulators.

## Mobile game clock pause (2026-09-28)

`patches/n64modernruntime-ios-clock.patch` pauses the iOS runtime clock when the Swift scene becomes inactive, shifts its origin on resume, and wakes the timer thread to recalculate pending deadlines. It leaves the macOS runtime clock unchanged. The existing mobile VI callback gate remains in place. The patch reverse-check and Simulator build passed; a temporary activity-bridge probe was used only for measurement and removed afterward.

The candidate app loaded **GAME1 → PLAY → first field** on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5. During a Home-screen interval of at least ten seconds from gameplay, the iPad clock changed from 8,128,742,906 to 8,128,743,093 ticks (187 ticks, about 4 microseconds) and its display-list count held at #4800. The iPhone clock changed from 9,700,035,656 to 9,700,035,890 ticks (234 ticks, about 5 microseconds) and its count held at #5580. Both resumed rendering the same field and accepted touch Start/A pause/resume. Logs: `work/g5-clock-candidate-{ipad,iphone}-run.log`; viewed captures: `work/evidence/{ipad,iphone}-clock-candidate-field-{before,after}.png`.

An Audio Queue underrun appeared immediately after each resume. This clock change does not solve audio interruption/recovery. Timer-message counts during inactivity, repeated cycles, longer sleep/wake, distinct in-level saves and physical-device behavior remain open; do not mark G5 complete.

With the probe removed, the ordinary Simulator and unsigned device builds passed (`work/g5-clock-final-{sim,device}-build.log`). The Simulator executable SHA-256 was `a9c0e137040d92f08a098a1905fcfb8ba7320897cb3124032080ba65b629ba75` and contained no `LIFECLOCK` marker. That exact Simulator app was installed in place on each iOS 18.5 device, reached **GAME1 → PLAY → first field**, and accepted touch Start/A pause/resume (`work/g5-clock-final-{ipad,iphone}-run.log`, viewed `work/evidence/{ipad,iphone}-clock-final-field.png`). The final-app run did not repeat the background clock print; the quantitative pause measurement above belongs to the candidate that differed only by that temporary print.

## Timer delivery during backgrounding (2026-09-28)

A temporary counter at the iOS runtime's timer-message enqueue point measured two gameplay Home-screen cycles per iOS 18.5 Simulator. On iPad, it held at 10,274 through the first interval, rose to 12,720 during foreground play, then held at 12,720 through the second. On iPhone, it held at 11,841, rose to 14,359 in the foreground, then held at 14,359. `osGetTime()` also stayed within a few hundred ticks at each inactive/active boundary, and the first field and touch Start/A still worked after the second return. Logs: `work/g5-timer-probe-{ipad,iphone}-run.log`; the gameplay screens were viewed in Simulator. An audio underrun followed each return on each device, so audio recovery remains open.

The counter and activity print were removed. The patch reverse-check passed and the ordinary Simulator app rebuilt (`work/g5-timer-probe-restored-sim-build.log`); its executable hash returned to `a9c0e137040d92f08a098a1905fcfb8ba7320897cb3124032080ba65b629ba75` with no `LIFETIMER` marker. This verifies enqueues in these windows, not every timer use or longer sleep/wake; G5 remains partial.

## Audio Queue background pause (2026-09-28)

The timer-pause runs above had an Audio Queue underrun immediately after every return from Home. The game clock and PCM producer pause while the scene is inactive, but the output queue previously kept consuming samples. `Support/Conker/mobile_audio.cpp` now pauses an already started Audio Queue on scene inactivity and restarts it on activation. Initial playback waits for an active scene; a failed queue pause or restart tears the queue down for the existing retry path. The callback-progress clock resets on a successful restart so the foreground producer does not mistake the paused interval for a stall. Game logic and PCM format are unchanged.

A temporary lifecycle log measured two gameplay Home-screen cycles of about ten seconds each on both iOS 18.5 Simulators. The iPad log had two successful pause/start pairs and no underrun (`work/g5-audio-pause-probe-ipad-run.log`). The iPhone had two pairs and no underrun; its completed nonzero output-buffer count increased from 17,045 before the first pause to 24,155 before the second (`work/g5-audio-pause-probe-iphone-run.log`). The field reappeared after each return; touch Start/A still paused and resumed gameplay. These counts show the Simulator output callback kept consuming nonzero PCM after resume, not that the sound was clean.

The temporary success prints were removed. The final Simulator and unsigned device builds passed (`work/g5-audio-pause-final-{sim,device}-build.log`); the Simulator executable SHA-256 is `7ec396b20f6c932f9c4d3c3fad8dfedc74ef890bf1bf0d3323d6329860d8d5bf` and contains no `AUDIO_LIFECYCLE` marker. Installed in place, that exact app reached **GAME1 → PLAY → first field** on iPad Pro 11-inch (M4) and iPhone 16 Pro, returned from a Home interval, and accepted touch Start/A. Viewed final captures: `work/evidence/{ipad,iphone}-audio-pause-final-field.png`. The final run was visually checked; quantitative queue counts belong to the diagnostic candidate. Ordinary gameplay still has reported glitches and measured foreground underruns in earlier runs. Audible quality, audio route/interruption handling, longer sleep/wake and physical devices remain open.

## Foreground audio after lifecycle change (2026-09-28)

An ordinary `59ac6dd` iPad Pro 11-inch (M4), iOS 18.5 run reached **GAME1 → PLAY → first field**, consumed nonzero PCM, and advanced through display list #15,420 with no logged Audio Queue underrun or callback restart (`work/audio-after-lifecycle-ipad-run.log`; viewed capture `work/evidence/ipad-audio-after-lifecycle-field.png`). Host load was roughly 3–8. This is one scene and one run; it does not establish clean audible output or erase the earlier foreground failures.

The queue also has a silent PCM discard path when its ring exceeds half a second. A temporary log at that path observed no discard, underrun, or callback restart through display list #10,440 in a second iPad first-field run (`work/audio-drop-probe-ipad-run.log`; the field was viewed in Simulator). The probe was removed, `Support/Conker/mobile_audio.cpp` matched the committed source byte-for-byte, and the ordinary Simulator build passed (`work/audio-drop-probe-restored-sim-build.log`) without an `AUDIO_DROP_PROBE` marker. Its executable SHA-256 is `b2d583661b79ababd9d69310c794fd4d590bb123aeae3d55be0cae3c5e954624`; it was installed in place and visibly reopened the ROM launcher. **G4 audio remains open.** The next audio check should target a reproducible audible symptom or compare captured output PCM against the macOS control; another no-underrun first-field run would not prove quality.

A temporary Audio Queue callback probe captured the last 20 seconds of queued stereo PCM during an iPad Pro 11-inch (M4), iOS 18.5 GAME1 → PLAY → first-field run (`work/audio-output-capture-ipad-run.log`; viewed `work/evidence/ipad-audio-output-capture-field.png`). The 22,020 Hz capture contained 440,400 frames with no reported underrun, no clipped frame, and no all-zero stereo run longer than three frames. This rules out a long silent gap in that queued window, but cannot establish what the Simulator speaker rendered or explain Chris's audible glitches in other runs. The probe was removed byte-for-byte; the restored Simulator build passed (`work/audio-output-capture-restored-sim-build.log`) with no probe marker and executable SHA-256 `56a45a10f1e5f90060c83ea3d2d0a1d3c4d23f932dcf47c784432bf891e82d8a`, identical to the pre-probe app. Audio quality remains open. A useful next comparison needs the same identifiable scene and output capture on macOS, or a reproduced glitch with a timestamp so the producer and output paths can be checked together.

## Opening PCM comparison with macOS (2026-09-29)

The macOS Metal control ran for 180 seconds and 10,786 VIs (`work/g1-macos-visual-retry.log`). Computer Use timed out when selecting its window, so this run does not verify its visible scene or audible output. Temporary capture probes in the macOS and iOS PCM producers each recorded the first 64 nonzero 736-frame packets. Both first became nonzero at packet 423. Two runs on each platform reproduced their respective hashes. The iPad Pro 11-inch (M4), iOS 18.5 Simulator reached a viewed intro during capture (`work/audio-parity-raw-ipad-run.log`; macOS log: `work/audio-parity-raw-mac-run.log`).

The iPad stream begins 184 stereo frames later. After aligning that offset, the first 9,942 interleaved 16-bit samples match exactly; later samples diverge. This confirms a common opening PCM segment, but does not establish whole-scene parity or explain the reported glitches. The probes were removed byte-for-byte. Restored macOS and iOS builds passed (`work/audio-parity-restored-{mac,ios}-build.log`); the iOS executable SHA-256 returned to `7f954113ba4cfdba2b011d019b852978ca74890d8485be5124a183d86cf62af6`. The raw capture is ignored and contains no staged game data. **G1 visual/audio control and G4 audio quality remain open.** Next compare the same controlled game scene for a longer window and locate the first divergent sound event or reproduced audible glitch before changing the producer or output queue.

## Controller bindings in the Settings menu (2026-09-29)

The Controls tab now reports the GameController API's selected extended gamepad name and haptics availability, followed by the current fixed N64 button mappings. This follows the controller-status and binding rows in `ref/harkinianpad/docs/readme/simulator-settings.jpg`; the bindings are informational and cannot yet be edited. Touch Layout remains below them. No game input mapping or audio logic changed.

The compact Simulator build and unsigned device build passed (`work/menu-gamepad-compact-{sim,device}-build.log`); the Simulator executable SHA-256 is `ad3a917304e1b807081fbedaeaedf8abd4eb60cd47eb0c8f2223f8e190c86d9e`. That exact app was installed on the iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5 Simulators. In both, the imported ROM launched, the menu showed the new rows, scrolling reached Control Size, button visibility, Edit Layout and Restore Defaults, Audio still opened, and closing the menu returned to the touch overlay. Viewed screenshots: `work/evidence/ipad-menu-gamepad-compact.png`, `work/evidence/iphone-menu-gamepad-compact.png`, and `work/evidence/iphone-menu-gamepad-mappings.png`. The Simulator reports a `Gamepad` without physical hardware, so this is UI and framework-state evidence, not a real controller or rumble test. The iPhone Simulator briefly rendered a blank frame during a scroll; switching tabs restored the menu and it stayed responsive. The menu still needs further reference polish, especially the three-dot button visible below the compact panel, and audio quality remains open.

## Single menu close control (2026-09-29)

The floating three-dot control previously remained visible outside the compact Settings panel on iPhone, overlapping the panel's lower edge. `Sources/SquirrelPadApp.swift` now shows that control only while Settings is closed; the X inside Settings remains its close action. Simulator and unsigned device builds passed (`work/menu-hide-duplicate-{sim,device}-build.log`), with Simulator executable SHA-256 `46810c3bd8e52ee57a41d7f946d03c9202250ed7ef15a68f4d0c00d27c58bc36`. The exact app was installed in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5. On both, the imported ROM launched, Settings opened with no second menu button, and X restored the game and touch controls. Audio selection also worked on iPhone. Viewed captures: `work/evidence/{ipad,iphone}-menu-hide-duplicate.png`; launch logs: `work/menu-hide-duplicate-{ipad,iphone}-run.log`. This is a menu regression check, not audio-quality or playability completion. The reported glitches and full-story gate remain open.

## Ordinary first-field audio and touch route (2026-09-29)

The unmodified `ea1146c` Simulator executable (SHA-256 `46810c3bd8e52ee57a41d7f946d03c9202250ed7ef15a68f4d0c00d27c58bc36`) was installed in place on iPad Pro 11-inch (M4), iOS 18.5. The ordinary flow used Continue Imported ROM, GAME1, PLAY, and the first field. Touch Start paused and A resumed the field; brief stick drags and A/B taps were attempted, but their short visible changes do not establish sustained movement, jump or combat behavior. The viewed field capture is `work/evidence/ipad-g6-touch-audio-route-field.png`; the log is `work/g6-ipad-touch-audio-route-run.log`. Nonzero PCM was queued and consumed, and no Audio Queue underrun, callback stall or restart was logged through display list #13,140. This one run does not establish clean audible output; Chris's reported glitches remain open.

For source-versus-output comparison, the earlier 20-second iPad Audio Queue callback capture was wrapped losslessly as `work/evidence/ipad-audio-queue-capture-20s.wav` (22,020 Hz, stereo, 440,400 frames). It belongs to the earlier diagnostic run described above, not to `ea1146c`. That captured segment had no reported queue underrun or clipped sample; its largest adjacent sample jump was about 0.11 of full scale. It can help distinguish glitches already present in queued PCM from glitches introduced afterward, but cannot establish what the Simulator's output device played. This Mac currently reports Jump Desktop Audio as its default output device. No system audio setting was changed. The macOS RT64 control source selects an SDL Metal window and SDL audio, but Computer Use timed out again when trying to inspect its window; the macOS visual and audible control remain unverified.

## Simulator stick-drag measurement (2026-09-29)

The prior ordinary first-field run's brief Computer Use drags did not show sustained walking. A temporary diagnostic in `Support/Conker/mobile_input.cpp` measured three more iPad Pro 11-inch (M4), iOS 18.5 Simulator drags through the SwiftUI `TouchStick` callback (`work/touch-stick-probe-ipad-run.log`). Each produced one small axis update (X=0.05, Y=0.07), then released; Conker's player-0 callback polled that nonzero value only 0, 0 and 1 times. Thus those automated drags cannot establish a sustained analog hold. This is a limitation of the observed Computer Use gesture delivery in this test, not proof of an app-side stick failure or of physical touch behavior. Do not use the prior short drags as G4 analog-movement evidence.

The probe source was restored byte-for-byte from `work/touch-stick-probe-original.cpp`, the ordinary Simulator app rebuilt (`work/touch-stick-probe-restored-sim-build.log`), and its executable SHA-256 returned to `46810c3bd8e52ee57a41d7f946d03c9202250ed7ef15a68f4d0c00d27c58bc36` with no probe marker. That is the same app already viewed in GAME1 → PLAY → first field through display list #13,140. G4 still needs a sustained touch-stick hold plus movement/camera/action checks on each class; physical feel remains G7.

## Isolated analog movement in gameplay (2026-09-29)

A temporary hidden `GCVirtualController` connected only after Settings closed in the first playable field and held **left stick X=0.75 only** for eight seconds. No button or camera input was injected. On iPad Pro 11-inch (M4) and iPhone 16 Pro iOS 18.5, the Conker player-0 callback received X=0.75 with button mask zero for 179 and 241 polls, respectively, then returned to zero on release (`work/isolated-stick-probe-{ipad,iphone}-run.log`). Viewed before/after captures in `work/evidence/{ipad,iphone}-isolated-stick-{before,after}.png` show Conker moved from the starting field to the wall. This isolates sustained analog movement through the virtual controller path on both Simulator classes. It does not validate the SwiftUI touch-stick hold, physical controller feel, camera/action mappings, or audio quality.

The three diagnostic source files were restored byte-for-byte, leaving tracked source clean. The ordinary Simulator rebuild passed (`work/isolated-stick-restored-sim-build.log`), has no probe marker, and launches to the ROM screen on iPhone. Its executable SHA-256 is `98c9332bc96e706d40ecb3e59cb7bf86bb6ee739b00d163a242785519957e9fb`; the different hash from the earlier ordinary build is not understood, so this does not assert reproducible binary output. G4 remains partial. Next isolate a sustained touch-stick hold with a gesture method that can deliver one, then test camera/action input and the reported audio glitches in a controlled scene.

## Wider compact Settings panel (2026-09-29)

The reference `ref/harkinianpad/docs/readme/simulator-settings.jpg` uses nearly the full landscape viewport. SquirrelPad's iPhone panel had much wider side margins. The compact panel now subtracts 64 points from the viewport width and height, and its scroll area grows with the panel; the iPad dimensions are unchanged. The exact Simulator executable SHA-256 is `3db1466b571b2434806e125df76b0f43275aaf417f36d9190ac4d727d5989d77`. Simulator and unsigned device builds passed (`work/menu-width-only-{sim,device}-build.log`); the restored source rebuild returned the same hash (`work/menu-width-restored-final-sim-build.log`). On iPhone 16 Pro iOS 18.5, the wider Controls panel opened over the running intro, showed the game beneath it, and X returned to touch controls (`work/evidence/iphone-menu-width-only-{controls,game}.png`). The same build opened Controls and Audio on iPad Pro 11-inch (M4), iOS 18.5 (`work/evidence/ipad-menu-width-only-controls.png`).

An intermittent **visual redraw defect remains**: in both Simulator classes, opening the menu or changing tabs from the ROM launcher sometimes leaves parts of the panel border/header black although accessibility still lists the controls. A transparent pre-game Metal surface and a `compositingGroup` did not reliably prevent it; forcing a new panel identity on tab changes also failed on the return to Controls. Those experiments were removed. This commit improves compact size only; it does not establish full menu parity or clean audio. Next isolate the menu redraw against the Metal-backed SwiftUI view before adding more reference features.

## GPU resource-limit experiment

The first iPad RT64 build failed to load SDK 26 Metal 4 blobs on iOS 18.5. Recompiling the 56 blobs for `air64-apple-ios17.0-simulator` with `-std=metal3.1` let RT64 initialize. Its raster pixel shaders then exceeded the Simulator's 16-sampler limit with 18 declarations. `patches/rt64-ios-sampler-limit.patch` replaces two nearest mirror/clamp samplers with a mirrored UV transform and the existing nearest clamp sampler. All six generated `RasterPS*.metal` variants now declare 16 samplers. The rebuilt Simulator app progressed from three display lists and a shader-thread abort to visible moving frames and more than 9,700 display lists. Mirror edge fidelity still needs comparison with the macOS control.

Plume's Metal query result can be null on this Simulator; the narrow guard in `patches/plume-ios-metal.patch` logs once and disables GPU timing instead of copying from null. A separate 52-buffer warning came from **`DebugPS.hlsl`**, RT64's raytracing visualization pixel shader. A diagnostic build labeled that shader and reproduced `PS=RT64 DebugPS raytracing visualization: only 31 buffers are supported in the simulator but 52 were used` in `work/diagnose-52-labelled.stdout.log`. The generated `DebugPS.hlsl.metal` has 51 pointer resources plus its argument buffer. Plume leaves `deviceCapabilities.raytracing` false on Metal, but RT64 had unconditionally created this optional debug pipeline. `patches/rt64-ios-debug-capability.patch` now creates it only when raytracing is supported, and retains the diagnostic shader name. The rebuilt iPad run reached game select with no Metal pipeline-cap error through 4,200 display lists in `work/debug-capability-run-sim.stdout.log`. This removes an unused pipeline; it does not change Conker game logic or enable raytracing. Continue ordinary input/audio/play tests rather than treating this preview as playability.

## Repeat this check

Rebuild the macOS RT64 shader inputs after any `*.hlsli` change; Ninja did not track the changed include in this checkout. The final sampler experiment forced the raster shader regeneration and rebuilt both SDK archives.

```sh
scripts/verify-rt64-ios.sh iphonesimulator
scripts/verify-rt64-ios.sh iphoneos
cmake --build work/build-app-iphonesimulator --config Release --target SquirrelPad --parallel 4
cmake --build work/build-app-iphoneos --config Release --target SquirrelPad --parallel 4
xcrun simctl install 08636791-2675-4675-8335-EF72EF954DCF work/build-app-iphonesimulator/Release-iphonesimulator/SquirrelPad.app
xcrun simctl launch --console-pty 08636791-2675-4675-8335-EF72EF954DCF com.chrissotraidis.squirrelpad
```

In the app, use **Continue Imported ROM** only when a verified private ROM is already present in its container; it is SHA-1 checked again before the game starts. Otherwise import through Files. Visually inspect the live Simulator screen, preserve the log, then terminate and shut down this iPad before testing the iPhone Simulator. Do not erase the app container to work around a Files provider timeout.

## Reproduce the macOS control

Use Xcode's macOS 26.5 SDK path for CMake on this machine; the Command Line Tools 27.0 linker rejected an SDK object. In the ignored `work/CBFD-Recompiled` checkout after `scripts/setup-source.sh <private-rom>`:

```sh
sdk=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk
cmake -S tools/N64Recomp -B tools/N64Recomp/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT="$sdk"
cmake --build tools/N64Recomp/build --target N64RecompCLI RSPRecomp RecompModTool -j 4
python3 recomp/recompile.py
cmake -S host -B host/build-macos-headless -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCONKER_RT64=OFF -DCMAKE_OSX_SYSROOT="$sdk"
cmake --build host/build-macos-headless -j 4
host/build-macos-headless/ConkerRecomp --headless --rom conker/baserom.us.z64 --seconds 15
cmake -S host -B host/build-macos-metal -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_SYSROOT="$sdk"
cmake --build host/build-macos-metal -j 4
host/build-macos-metal/ConkerRecomp --rom "$PWD/conker/baserom.us.z64" --seconds 120
```

The windowed host changes its working directory to the executable's directory, so the `--rom` value must be absolute. Both builds emit private ROM-derived native code; keep binaries local.

## Translucent Settings redraw isolation (2026-09-29)

On the iPad Pro 11-inch (M4), iOS 18.5 Simulator, the intermittent partial Settings redraw also occurred with the RT64 Metal surface temporarily removed: Controls showed missing border segments while accessibility still listed its controls. A no-Metal build with a fully opaque black panel drew Controls and Audio completely in the observed opening and tab switch, but that one pass does not prove a fix and loses the reference's translucency. Two narrower translucent variants—a separately filled `drawingGroup` backing and a rectangular backing clipped to the rounded panel—both reproduced missing header/border regions on Controls → Audio; the latter failure was captured at `work/evidence/ipad-menu-clip-backdrop-audio-failure.png`. Removing the dimming layer behind the menu also reproduced the defect on Controls opening. These were diagnostic builds, not acceptance builds. All source changes were removed. The next menu experiment should isolate the panel's presentation from the main game/launcher ZStack while retaining a translucent backdrop and the current close/tab interactions; background modifier substitutions alone are exhausted by this evidence. Menu parity remains open.

A further small variant moved the unchanged translucent Settings ZStack to an `.overlay` on the game/launcher ZStack. On the same iPad Simulator, Controls initially drew, but Controls → Audio again left the right header and border black; a second screenshot without interaction showed the failure persisted. The variant was removed. A separate SwiftUI overlay at that level is therefore insufficient; next inspect a distinct presentation host or reproduce the issue in a minimal SwiftUI/Simulator view before changing the production menu again.

A `fullScreenCover` with clear presentation background also retained the launcher translucency but reproduced the same persistent partial header/border loss on Controls → Audio on the iPad Pro 11-inch (M4), iOS 18.5 Simulator; it additionally exposed the status bar. The probe was removed. Panel placement alone, including a distinct SwiftUI full-screen presentation, has not fixed this defect. Stop changing presentation modifiers without a smaller reproduction or a different rendering hypothesis.

## macOS Metal control visibility retry (2026-09-29)

From the pinned ignored checkout, `host/build-macos-metal/ConkerRecomp --rom "$PWD/conker/baserom.us.z64" --seconds 180` exited normally with 10,785 VIs (`work/macos-control-20260929-run.log`). The macOS app bundle was also launched during a Computer Use attempt; its process appeared in the app inventory, but `getApp('com.chrissotraidis.squirrelpad.macoscontrol')` timed out repeatedly instead of returning a window or screenshot. Both host processes exited. This confirms host progression only, not visible gameplay, ordinary input, or audible output. The macOS G1 control remains open. Use a working visual/audio capture path before treating host progression as the comparison oracle for iOS fidelity or glitches.

## Paired Simulator display captures refine the menu defect (2026-09-29)

The ordinary `a3d2011` menu source was rebuilt (Simulator executable SHA-256 `3db1466b571b2434806e125df76b0f43275aaf417f36d9190ac4d727d5989d77`) and installed in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5. On the iPad Audio tab, the Simulator *window* capture lost header and border regions, while an immediate `xcrun simctl io <iPad-UDID> screenshot` of the device display contained the complete header, X and border (`work/evidence/ipad-menu-ordinary-audio-{window,simctl}.png`). The raw device image is rotated relative to the Simulator window. Thus that iPad window capture alone is not evidence of an app-side redraw failure.

The iPhone is different: its raw device screenshots show the missing left border segment on both Controls and Audio (`work/evidence/iphone-menu-ordinary-{controls,audio}-simctl.png`), matching the Simulator window. This confirms an iPhone-class visible defect in the rendered display, though the exact SwiftUI/compositor cause remains unknown. A diagnostic replacement of `ScrollView` with `VStack` did not give a valid layout and did not resolve the window-capture symptom; it was removed. Moving the border above the panel as a separate noninteractive layer and raising only the compact panel background opacity from 0.78 to 0.96 also left the iPhone gap. Both were removed. Do not infer the iPad and iPhone have the same failure from window captures; use paired device-display screenshots for future visual checks. The source is clean and the final ordinary Simulator rebuild passed (`work/menu-paired-capture-final-sim-build.log`); its executable hash is `e38d9a451eda462e001d9d960ea88f19bd7353d7b539074fe0b8a0ad7b66244d`, so this entry does not claim byte-for-byte reproducibility from source equality. No menu fix was retained; iPhone border fidelity remains open.

A final iPhone launcher isolation hid `importPanel` only while Settings was open. The raw device-display capture (`work/evidence/iphone-menu-no-launcher-simctl.png`) removed the launcher text beneath the translucent menu but retained the same missing left border segment. This rules out the launcher card as a necessary cause of that iPhone gap. The probe was removed; the ordinary Simulator source rebuilt to executable SHA-256 `3db1466b571b2434806e125df76b0f43275aaf417f36d9190ac4d727d5989d77` (`work/menu-underlay-restored-final-build.log`) and was reinstalled in place before Simulator shutdown. The next menu investigation needs a minimal reproduction of the specific iPhone stroke/compositor failure or physical-device comparison, rather than another unmeasured opacity/layout change.

## iOS 26.5 compact menu replay (2026-09-29)

The same ordinary Simulator executable (`3db1466b571b2434806e125df76b0f43275aaf417f36d9190ac4d727d5989d77`) was installed in place on iPhone 17 Pro, iOS 26.5. Settings opened and X restored the ROM launcher. The viewed raw device-display capture `work/evidence/iphone17-ios265-menu-controls-simctl.png` still has the same missing segment along the compact panel's left outer border as iPhone 16 Pro on iOS 18.5. Thus the gap is not limited to the older Simulator runtime. This check covers launcher/menu only; it does not pass the iOS 26.5 gameplay, input, save or lifecycle matrix.

## Compact menu cutout margin (2026-09-29)

The apparent missing left border on landscape iPhone was at the Dynamic Island cutout. The compact panel had a fixed 32-point side margin after `a3d2011`; the iPhone 16 Pro window reported 62-point left and right safe-area insets. The compact panel now uses the key window's larger horizontal inset plus 8 points, with a 32-point minimum. The iPad panel dimensions remain unchanged. This reclassifies the iPhone gap described above as cutout coverage, rather than evidence of a SwiftUI stroke failure. Simulator window captures can still omit regions that appear in raw device-display screenshots, so the latter remain the visual check.

The exact candidate Simulator executable SHA-256 is `b73ba6ab0d7397e970ca57cbac69eb5b3f52db0df6cebe0fee5770958b33671d`. Simulator and unsigned device builds passed (`work/menu-safe-margin-{sim,device}-build.log`). On iPhone 16 Pro, iOS 18.5, raw Controls and Audio captures showed a continuous border (`work/evidence/iphone-menu-safe-margin-{controls,audio}-simctl.png`); X returned to the launcher, and the imported ROM intro resumed with touch controls after closing Settings. On iPhone 17 Pro, iOS 26.5, the raw Audio capture also showed the complete border (`work/evidence/iphone17-ios265-menu-safe-margin-audio-simctl.png`), and X returned to the launcher. On iPad Pro 11-inch (M4), iOS 18.5, Controls and Audio opened and X returned to the launcher. These are menu regressions, not full reference parity, clean audio, full playthrough or physical-device acceptance.

## Explicit game audio session (2026-09-29)

The iOS shell previously left `AVAudioSession` at the system default while creating an Audio Queue. After validating the private ROM and before starting the core, it now selects the playback category and logs either the selected category or the error. This makes game-audio routing explicit; it does not change PCM generation, Audio Queue buffering or game logic. Simulator and unsigned device builds passed (`work/audio-session-category-{sim,device}-build.log`); the Simulator executable SHA-256 is `4039991fb099b2cdebb7d5c3a67e7337ebe41a6c7429726243241c60be3c98fa`.

Installed in place, that app logged `AVAudioSessionCategoryPlayback` on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5 (`work/audio-session-category-{ipad,iphone}-log.txt`). Both showed the moving intro with touch controls (viewed captures `work/evidence/{ipad,iphone}-audio-session-category-intro.png`). On the iPhone relaunch, `work/audio-session-category-iphone-run.log` also recorded 22,020 Hz output, playback start, and nonzero PCM consumed through display list #660; the viewed running capture is `work/evidence/iphone-audio-session-category-intro-running.png`. This verifies category selection and an adjacent startup regression only. Audible quality, the reported foreground glitches, route switching, interruptions and physical speaker/headphone output remain open. The next audio experiment needs a reproduced glitch timestamp tied to both producer and output timing, rather than treating this category change as a glitch fix.

## Controller mapping rows and current audio replay (2026-09-29)

The controller mapping list in Settings now uses compact N64-action and blue gamepad-binding chips, closer to the row treatment in `ref/harkinianpad/docs/readme/simulator-settings.jpg`. It is still informational: no gamepad mapping or touch input behavior changed. The exact Simulator executable SHA-256 is `af132e7096beca096d9e728cddeb8ac79f76851371953d132ffee4e3c623010e`. Simulator and unsigned device builds passed (`work/menu-binding-chips-final-sim-build.log`, `work/menu-binding-chips-device-build.log`). Installed in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5, Controls showed the new rows, Audio opened, and X restored the launcher. The raw iPad capture `work/evidence/ipad-menu-binding-chips-controls.png` showed the complete panel. On iPhone, an accessibility-targeted scroll reached the mappings and Touch Layout (`work/evidence/iphone-menu-binding-chips-scrolled.png`); the Audio tab still showed the previously saved 50% volume. Coordinate scrolling in the Simulator window did not move the view, so this does not establish physical touch-scroll feel. Full reference-style editable bindings remain open.

Before that UI change, the ordinary `8eb5d4d` iPhone 16 Pro, iOS 18.5 build reached GAME1 → PLAY → first field and continued through display list #7320 with no logged Audio Queue underrun or callback stall (`work/audio-current-iphone-field-run.log`; viewed `work/evidence/iphone-audio-current-first-field.png`). A C-left tap did not show a clear camera change, so C-button gameplay remains unverified. This no-underrun run does not resolve Chris's audible-glitch report or establish clean output.

The macOS Metal control again exited normally after 120 seconds and 7188 VIs (`work/macos-control-window-retry-run.log`), but Computer Use timed out selecting its live app bundle; the directly launched binary was not listed as a running app. No window or audible output was captured. G1's macOS visual/audio comparison remains open.

## Atomic Apple save replacement (2026-09-29)

The N64ModernRuntime save helper previously copied a complete `.temp` file over the live EEPROM. On Apple platforms, `patches/n64modernruntime-apple-save-atomic.patch` now renames the same-directory temporary file over the live path after making the existing backup; other platforms retain the prior copy path. `scripts/setup-source.sh` replays the patch. This narrows the window for a process interruption to leave a partial live save, but the backup copy is still non-atomic and power-loss durability has not been measured.

A small host harness called the helper for three successive 2,048-byte revisions and checked each live file, previous-revision `.bak`, and absence of `.temp` (`work/save-atomic-test.cpp`; run passed). The patch reverse-checks on the current runtime checkout and applies cleanly to its pristine `files.cpp`. Simulator and unsigned device builds passed (`work/save-atomic-{sim,device}-build.log`), including compilation of that runtime source. The Simulator executable SHA-256 was `d856b15ff23c855fab9ece255f6185c1393d89b884f0224c2c049ffa0b4e911d`.

Installed in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5, the existing GAME1 save remained selectable and entered the first field. Both live EEPROM hashes changed during play, while each live file and backup remained 2,048 bytes and no `.temp` remained. After termination and cold relaunch on the same install, GAME1 remained selectable and entered the saved scene on both Simulators (`work/evidence/{ipad,iphone}-save-atomic-relaunch-field.png`; `work/save-atomic-{ipad,iphone}-relaunch.log`). The iPhone raw capture caught the transition into the scene; the Simulator window observation showed Conker sitting in it. This establishes a normal save/relaunch regression, not distinct in-level checkpoint fidelity, forced-interruption recovery, clean audio, or physical-device acceptance.

## Mobile PCM discard probe (2026-09-29)

`Support/Conker/mobile_audio.cpp` silently rejected an incoming PCM buffer when its ring lacked room or held more than half a second of audio. The unchanged rejection path now counts discarded buffers/frames and logs the first three events, then every 128th event with the queued and incoming frame counts. This is diagnostic only; it does not repair the reported glitches. Simulator and unsigned device builds passed (`work/audio-drop-probe-{sim,device}-build.log`); the Simulator executable SHA-256 is `427717dd3243fed0de9b741cf6b42b33857557b11e13f0a1cf0a543e6024a6dc`.

The exact build was installed in place on iPhone 16 Pro and iPad Pro 11-inch (M4), iOS 18.5. Both used their existing imported ROM and GAME1 save, entered the first field, and produced nonzero PCM. The iPhone run passed display list #7,140 and the iPad run passed #5,520 with no discard, underrun, callback-stall or enqueue-error log (`work/audio-drop-probe-{iphone,ipad}-run.log`; viewed raw captures `work/evidence/{iphone,ipad}-audio-drop-probe-field.png`). This rules out the measured whole-buffer discard path during these particular scenes and intervals; it does not establish clean audible output or exclude a later-scene drop. G4 audio remains **Fail / unresolved** against Chris's reported glitches. Next measure output-callback timing against the four queued 256-frame buffers and capture a reproducible audible glitch timestamp before changing pacing or reserve sizes.

## Audio Queue callback interval probe (2026-09-29)

The output callback now counts intervals of at least 40 ms, recording the longest interval and reporting only from the game thread. At 22,020 Hz, the four 256-frame Audio Queue buffers contain about 46 ms of audio; this threshold flags callbacks arriving near that runway. The clock resets across audio pause/resume and queue recreation. This is telemetry, not a pacing change. Simulator and unsigned device builds passed (`work/audio-callback-gap-{sim,device}-build.log`); the Simulator executable SHA-256 was `bc05ca15ca1968260a9a4aaf0ac2bba55272d6a62a2bb316265a021240b901c5`.

The exact build was installed in place on iPad Pro 11-inch (M4) then iPhone 16 Pro, iOS 18.5. Both used the existing imported ROM and GAME1 save, entered the first field, and visibly continued play (`work/evidence/{ipad,iphone}-audio-callback-gap-field.png`, raw device captures viewed). The iPad run reached display list #4,740 and the iPhone run #6,000 without a logged callback interval of 40 ms, PCM drop, underrun, callback stall or enqueue error (`work/audio-callback-gap-{ipad,iphone}-run.log`). This narrows one output-starvation hypothesis only for those intervals; it cannot establish audible fidelity. G4 audio remains **Fail / unresolved** because Chris reports glitches. Next capture the audible output or exact glitch scene and correlate it with producer PCM and Audio Queue timing; do not alter queue reserve from these negative counters alone.

## System audio capture probe (2026-09-29)

`scripts/capture-system-audio.swift` records the Mac's system audio through ScreenCaptureKit to an AAC `.m4a` file. It captures all output associated with the chosen display, so other audio apps must be quiet. Keep recordings under ignored `work/`; no game audio belongs in Git. The script compiled with `swiftc -parse-as-library` on this Mac.

With the unchanged `bc05ca15ca1968260a9a4aaf0ac2bba55272d6a62a2bb316265a021240b901c5` iPad Simulator app active at GAME1 and then the first field, `work/evidence/ipad-system-output-probe.m4a` and `work/evidence/ipad-field-system-audio.m4a` contained nonzero 48 kHz stereo output. A five-second capture after SquirrelPad termination decoded to all zero samples (`work/evidence/ipad-system-output-silence-control.m4a`). This confirms actual system output during the tested game scenes, but numerical PCM checks and the existing no-drop counters do not establish that the audio sounds clean. An attempted intro capture was mistimed and silent before the game began producing PCM; it is not an intro-audio result.

For the macOS G1 control, temporary logging in the ignored host checkout showed CoreAudio opening the MacBook Air Speakers at 22,020 Hz, nonzero game PCM entering SDL, and queue depth cycling as SDL drained it (`work/macos-audio-control-probe4-run.log`, 75 seconds and 4,491 VIs). Yet a simultaneous later 40-second ScreenCaptureKit capture decoded to all zero samples (`work/evidence/macos-control-late-system-audio.m4a`). The same capture utility recorded a short `afplay` control, so the host capture discrepancy is still unexplained; do not claim audible macOS fidelity. The temporary host logging was removed after the probe. G1 and G4 audio remain open. Next correlate an audible glitch timestamp in the iPad capture with game PCM and callback telemetry, and establish a reliable macOS host audio capture or direct listening route before comparing fidelity.

## macOS control window and process-audio capture (2026-09-29)

The earlier full-display ScreenCaptureKit filter missed Conker's audio, although it captured Simulator and `afplay` output. An exact `ConkerRecomp` application filter added to `scripts/capture-system-audio.swift` produced nonzero stereo from the macOS Metal host with temporary PCM logging. `work/evidence/macos-host-app-filter-audio.m4a` decoded to 1,006,080 frames at 48 kHz, with 1,878,147 nonzero samples. Thus the prior silent file is a capture-filter failure, not proof the host is silent. The temporary logging source was restored; `host/src/audio_output.cpp` now has no diff in the ignored checkout. A fresh host build passed (`work/macos-clean-control-build.log`). Its 20-second process-filtered capture (`work/evidence/macos-clean-control-audio.m4a`) decoded to 1,023,360 frames at 48 kHz, peak 8,577 and 1,167,965 nonzero samples. The recording has not been judged by listening, so audible fidelity remains open.

ScreenCaptureKit listed an onscreen `ConkerRecomp` window titled *Conker's Bad Fur Day: Recompiled*. `screencapture -x -l <current-window-id>` captured the live window while `host/build-macos-metal/ConkerRecomp --rom "$PWD/conker/baserom.us.z64" --seconds 90` ran. Viewed captures show the Nintendo logo and then Conker in the intro (`work/evidence/macos-control-sck-window{,-later}.png`); the host exited normally (`work/macos-sck-window-run.log`). The clean rebuild also showed the intro in a viewed window capture (`work/evidence/macos-clean-control-window.png`). This establishes the first visible macOS control scene and an audio recording route. It does not establish ordinary input to gameplay, save/relaunch, matching iPad scene timing or clean sound. Next use this window/process capture route for a synchronized macOS/iPad scene and trace any audible glitch there before changing game audio.

## Matched opening audio capture (2026-09-29)

The already installed iPad Pro 11-inch (M4), iOS 18.5 app was confirmed byte-for-byte as Simulator executable SHA-256 `bc05ca15ca1968260a9a4aaf0ac2bba55272d6a62a2bb316265a021240b901c5`. With no source change or reinstall, its ordinary **Continue Imported ROM** path played the intro while `work/capture-system-audio work/evidence/ipad-opening-system-audio.m4a 70` recorded output. A raw device screenshot showed the opening credits and a later one showed the Game 1 attract scene (`work/evidence/ipad-opening-audio-{scene,end}.png`, both viewed). The app was terminated and the iPad Simulator shut down. The 48 kHz stereo recording first exceeded 20 PCM RMS units at 21.52 seconds, following launch delay. The unified log retained the playback session category, but did not retain the stderr Audio Queue counters from this launch, so it cannot rule out callback stalls during this recording.

The restored-source macOS Metal host ran for 90 seconds and 5,386 VIs (`work/macos-opening-control-run.log`). The live window capture showed Conker in the corresponding opening (`work/evidence/macos-opening-audio-scene.png`, viewed). `work/capture-system-audio work/evidence/macos-opening-system-audio.m4a 70 ConkerRecomp` recorded its process output; the 48 kHz stereo recording first exceeded the same threshold at 9.09 seconds. Both recordings are ignored local evidence, not staged game assets.

For a controlled numerical comparison, each stereo WAV was averaged to mono and reduced to 10 ms log-RMS windows. Aligning 30 seconds of iPad output starting at 21.50 seconds to macOS starting at 9.07 seconds gave Pearson correlation 0.926. Separate five-second windows through opening second 35 ranged 0.878–0.981 after at most a few 10 ms alignment steps. The 35–40 second window fell to 0.568, then lower later. This supports common opening audio for the first half minute and identifies a later divergence to inspect; it does **not** prove audible quality or attribute the divergence to a port defect. G1 macOS ordinary input/save and G4 glitch reproduction remain **Fail / open**. Next capture the 35–55 second scene on both platforms with time-aligned video and audio telemetry, then identify the first actual mismatch before editing playback pacing.

## Opening divergence was not a gross speed fault (2026-09-29)

A 45-second macOS window recording (`work/evidence/macos-opening-late-video.mov`) and a second recording started 19 seconds after a fresh host launch (`work/evidence/macos-full-opening-video.mov`; timing in `work/macos-full-video-time.txt`) were inspected as frame grids (`work/evidence/macos-{opening-late,full-opening}-contact.png`). The clean host ran 85 seconds and 5,085 VIs (`work/macos-full-video-run.log`). A 109-second raw iPad Simulator video (`work/evidence/ipad-opening-late-video.mov`) and a simultaneous 90-second system-audio capture (`work/evidence/ipad-opening-late-audio.m4a`) followed the ordinary imported-ROM route on the existing exact `bc05ca15ca1968260a9a4aaf0ac2bba55272d6a62a2bb316265a021240b901c5` build. The viewed grid is `work/evidence/ipad-opening-late-contact.png`. The iPad run was console-attached (`work/ipad-opening-video-run.log`): 22,020 Hz output started, nonzero PCM was consumed, and no PCM discard, Audio Queue underrun, >=40 ms callback-gap, callback-stall or enqueue-error line appeared through display list #3,060. The app was terminated and the Simulator shut down.

The videos place the Rareware logo around macOS host second 34–39 and iPad video second 50–55; Game 1 appears around macOS host second 64 and iPad video second 80. This roughly constant 15–16-second difference includes different pre-game launch/capture delays. The interval from logo to Game 1 is about 25–30 seconds on both, so the videos do **not** support the initial impression of a large iPad game-speed slowdown. In the second iPad audio capture, first sound was at 21.72 seconds versus 9.09 seconds in the macOS opening capture. Searching a ±2-second offset for each five-second log-RMS window kept the best inter-recording lag at 12.63–12.66 seconds through opening second 60. Correlation was 0.893–0.990 through second 35, then 0.653–0.751 in later windows. This narrows the mismatch to content/scene-specific audio or capture differences without measurable accumulating drift; it does **not** identify or disprove an audible glitch.

The macOS window is recordable and visibly reaches Game 1, but Computer Use again timed out binding `ConkerRecomp` by name and by bundle path. Ordinary macOS keyboard navigation into gameplay remains **Not run**. G1 input/save and G4 audible quality remain **open**. Next use a reported glitch timestamp or a matched gameplay scene to compare source PCM, Audio Queue output, and system capture; do not change queue pacing based only on this opening comparison.

## Controller bindings disclosure (2026-09-29)

The Settings Controls panel now has a Controller Bindings disclosure row, initially collapsed, following the organization of `ref/harkinianpad/docs/readme/simulator-settings.jpg`. Expanding it shows the existing connection, rumble, and mapping rows; collapsing it brings Touch Layout and Control Size into the first screen on both iPad and iPhone. No game or audio logic changed. The final Release Simulator executable SHA-256 is `fce569de84681e5f2dca276fb36b2e90a0de4a52fe854748e20c561700d976fa`; Simulator and unsigned device Release builds passed (`work/menu-binding-disclosure-release-{sim,device}-build.log`).

The Release build was installed in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5. On both, the default collapsed panel was visible, the row expanded and collapsed, Audio opened, and Close returned to the app. Viewed raw captures are `work/evidence/{ipad,iphone}-menu-binding-disclosure-default.png`. On iPad, the preceding Release build with the same disclosure behavior and an expanded default also passed GAME1 → PLAY → opening field, including opening and closing Settings over GAME1 (`work/menu-binding-disclosure-release-ipad-run.log`; `work/evidence/ipad-menu-disclosure-first-field.png`). The final one-line default change was verified in both menus, not replayed through the field.

An accidentally selected **Debug** Simulator configuration crashed after ROM launch with `dma_dmem_to_rdram` asserting `dmem_addr + wr_len <= 0x1000` in `librecomp/rsp.hpp:109`, called from generated `rsp/audio_ucode.cpp:298` (`work/menu-binding-disclosure-ipad-retry.log`; macOS DiagnosticReports at 05:27 and 05:29). The Release route above passed the corresponding launch and game-select path, but its `NDEBUG` setting does not establish that the out-of-range DMA is safe. Investigate the RSP audio command and whether it relates to Chris's audible glitches. G4 audio quality remains **Fail / unresolved**; no physical-device acceptance was performed.

## RSP DMA address-width fix (2026-09-29)

The reproducible Debug assertion above was traced with a temporary print immediately before the existing check. The failing audio write had raw `SP_MEM_ADDR = 0x06170cc0`, DRAM address `0x000451c0` and transfer length `0x170` (`work/rsp-dma-probe-ipad-run.log`). The RSP's effective 13-bit memory address is `0x0cc0`; its DMEM transfer ends at `0x0e30`, within the `0x1000` boundary. The byte accessor already masks to 12 bits, while `SET_DMA_MEM` had kept all 32 raw bits for the assertion and later bank checks. `patches/n64modernruntime-rsp-dma-address.patch` now masks `SP_MEM_ADDR` to `0x1fff` on write, consistent with the pinned RSPRecomp source's `rsp_mem_mask`; `scripts/setup-source.sh` replays the patch. The diagnostic print was removed before the retained builds. This resolves the observed false assertion; it does not prove every DMA command or explain the reported audible glitches.

The patched **Debug** iPad Pro 11-inch (M4), iOS 18.5 app passed the previous immediate abort, reached GAME1 → PLAY → the first field, and continued through display list #3,540 without that assertion (`work/rsp-dma-address-debug-sim-build.log`, `work/rsp-dma-address-debug-ipad-run.log`, viewed `work/evidence/ipad-rsp-dma-debug-field.png`). The Release Simulator executable SHA-256 is `b4823db40aa5c95c0f61762390c7b140ce0d73b37afcac55d467f5a227ca3a41`. The exact Release build reached the first field on the iPad and iPhone 16 Pro, iOS 18.5, with nonzero PCM consumed and no reported Audio Queue or Metal error through display lists #4,800 and #5,100 (`work/rsp-dma-address-release-{ipad,iphone}-run.log`; viewed `work/evidence/{ipad,iphone}-rsp-dma-release-field.png`). Release Simulator, unsigned device and macOS headless builds passed (`work/rsp-dma-address-{release-sim,release-device,mac-headless}-build.log`); patch reverse-check passed. These short Simulator routes do not establish clean audio or full gameplay. G4 remains **Fail / unresolved**; next obtain a reproducible glitch timestamp in a matched scene and correlate generated PCM, output callback timing, and captured sound.

## Longer iPad audio observation (2026-09-29)

The same Release app was installed in place and run on the iPad Pro 11-inch (M4), iOS 18.5 through GAME1 → PLAY → the first field; touch A/B actions visibly worked in the field (viewed `work/evidence/ipad-audio-field-long-scene.png`). The console-attached run reached display list #15,660 without a logged audio underrun, drop, producer gap or Audio Queue error (`work/audio-long-ipad-run.log`). Two ScreenCaptureKit system-output recordings completed without writer errors. The first (`work/evidence/ipad-audio-long-output.m4a`) lasted 191.38 seconds, including a 62.05-second pre-audio interval. The first-field recording (`work/evidence/ipad-audio-field-long-output.m4a`) lasted 127.8 seconds. Decoded 48 kHz stereo PCM in the first-field recording peaked at 8,274/32,768, had no post-onset 10 ms window below RMS 5 lasting at least 50 ms, and had a maximum adjacent sample change of 2,865. These checks rule out gross silence or clipping in this captured interval, not audible crackle, timing jitter, incorrect mixing, or failures elsewhere. Chris's reported audio glitch remains **unresolved**. A timestamped audible failure and matching PCM/Audio Queue telemetry are needed before another buffering or renderer change.

## Opening-audio control repeat (2026-09-29)

The macOS Metal control was rebuilt against the current RSP DMA patch (`work/macos-current-rsp-control-build.log`; executable SHA-256 `111208d18a4ba0e308a2c696bfbeac42570e4100b3d81cb29e12f656dffaf1e6`). Two ordinary 85-second runs exited normally after 5,085 and 5,093 VIs; their process-filtered ScreenCaptureKit recordings completed without writer errors (`work/macos-current-rsp-control{,-repeat}-{run,capture}.log`). A viewed window capture showed the Rareware opening (`work/evidence/macos-current-rsp-control-scene.png`). The same-build macOS recordings aligned closely for the first 30 seconds of sound, then differed: five-second log-RMS correlation at opening seconds 35, 40, 45 and 50 was 0.594, 0.399, 0.181 and 0.172 after local alignment within 200 ms. The older macOS capture matched the second current macOS run at 0.953, 0.933, 0.936 and 0.928 over those windows. The earlier and current iPad opening captures also matched each other above 0.94 through second 45. Thus the late opening mismatch is present **between macOS runs of the same build** and cannot establish an iOS audio defect. It may reflect different game content or timing; the recordings alone do not identify which. The first current macOS run and current iPad recording matched at 0.695–0.801 in those later windows with their best early alignment. G4 audible quality remains **Fail / unresolved**. Next compare a controlled gameplay scene and capture a specific audible glitch with producer and callback timestamps; do not change game audio based on this variable opening segment.

## Lighter idle touch controls (2026-09-29)

The idle touch-button fill was reduced from 48% to 30% tint opacity and its outline raised from 58% to 72%; the pressed state remains distinct. This brings the overlay closer to the mostly outlined HarkinianPad gameplay reference without changing positions, sizes or input routing. The exact Release Simulator executable SHA-256 is `128765be010cd8252546af0e02af984f33560830e54352d896bb68dba3d28659`; Simulator and unsigned device builds passed (`work/touch-idle-fill-release-{sim,device}-build.log`). Installed in place on iPad Pro 11-inch (M4) then iPhone 16 Pro, iOS 18.5, it reached GAME1 → PLAY → first field with the existing saves. On each Simulator the lighter controls were visually checked, B changed Conker's pose, Start opened the game's pause screen, A resumed, and the three-dot Settings menu opened and closed (`work/touch-idle-fill-{ipad,iphone}-run.log`; viewed raw captures `work/evidence/{ipad,iphone}-touch-idle-fill-field.png`). No Audio Queue, Metal or assertion error was logged in these windows. This is a touch-overlay polish and short input regression check; audio quality and full playability remain open.

## iPhone menu safe-corner placement (2026-09-29)

The compact three-dot button now uses the upper-right safe margin at the same vertical position as iPad, leaving the center of the game image clear. Release Simulator and unsigned device builds passed (`work/menu-safe-corner-release-{sim,device}-build.log`); the Simulator executable SHA-256 is `dd124c4171405150edefc64c2f5f7e2bb95d06580278fd23dcbceafd31ba8c95`. Installed in place on iPhone 16 Pro and iPad Pro 11-inch (M4), iOS 18.5, the button was visible in the upper right over rendered game scenes without overlapping nearby touch controls. Settings opened and closed on both devices, returning to the game (`work/menu-safe-corner-{iphone,ipad}-run.log`; `work/evidence/{iphone,ipad}-menu-safe-corner-game.png`). This checks menu placement and its immediate behavior, not extended play or audio quality.

## Gameplay PCM submission timing (2026-09-29)

The mobile audio adapter now logs only the first three, then every 64th, gap of at least 80 ms between game PCM submissions while active. Each line includes a monotonic timestamp and ring depth; output and game logic are unchanged. Release Simulator and unsigned device builds passed (`work/audio-submission-gap-release-{sim,device}-build.log`); the Simulator executable SHA-256 is `811066c4837de11c0c43410568c85ce0c575b43f7813fb00559d3866b6a86461`. The same build was installed in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5, then followed the ordinary imported-ROM route through GAME1 → PLAY → first field (viewed `work/evidence/{ipad,iphone}-audio-submission-gap-field.png`).

The iPad run reached display list #9,900 and logged one 87 ms submission gap at monotonic 1,246,176,820 ms with 2,704 frames still in the ring; it logged no queue underrun, PCM drop, >=40 ms output-callback gap or enqueue error (`work/audio-submission-gap-ipad-run.log`). A simultaneous 90-second first-field system-output recording completed (`work/evidence/ipad-submission-gap-field-audio.m4a`, `work/audio-submission-gap-field-capture-time.txt`). The gap maps to about 46.1 seconds into that capture; 100 ms windows around it remained nonzero, with mono RMS 30.5–80.2 and no gross sample jump. This specific producer delay was covered by the buffered output, so it does not explain an audible glitch by itself. The iPhone run reached display list #9,060 with no such gap or queue diagnostic (`work/audio-submission-gap-iphone-run.log`). Its 90-second first-field system-output capture completed with nonzero 48 kHz stereo throughout 100 ms windows, peak 4,184/32,768 (`work/evidence/iphone-submission-gap-field-audio.m4a`). These waveform checks cannot judge crackle, voice fidelity or effect delay. G4 audio remains **Fail / unresolved**; correlate a reproducible audible failure with this new timestamped producer trace before changing pacing or reserve.

## macOS control bundle audio-device stall (2026-09-29)

A fresh launch of the ignored `SquirrelPad Control.app` wrapper with the current macOS Metal host executable (SHA-256 `111208d18a4ba0e308a2c696bfbeac42570e4100b3d81cb29e12f656dffaf1e6`) left an onscreen 1440×870 window black after about a minute (`work/evidence/macos-control-bundle-current.png`, viewed). The process sample `work/macos-control-bundle-sample.txt` put the game start thread in `SDL_OpenAudioDevice` → CoreAudio device opening for all 648 samples over two seconds, while the main thread waited inside SDL event pumping on an audio mutex. `system_profiler SPAudioDataType` reported Jump Desktop Audio as the current default output and MacBook Air Speakers as the default system device. This identifies the immediate stall as audio-device initialization in this launch; it does not establish the ultimate SDL/CoreAudio or virtual-device defect.

For an isolated visual/input-control attempt, the ignored wrapper was changed to set `SDL_AUDIODRIVER=dummy` for **that process only**. The next launch reached a visibly rendered Game 1 scene (`work/evidence/macos-control-dummy-audio.png`, viewed); `work/macos-control-dummy-audio-sample.txt` showed normal host event-loop progression instead of the audio-open wait. The bounded 210-second process then exited. This diagnostic route intentionally has no sound and does not pass G1 audio. Computer Use still timed out binding the SDL app window after the hang was removed, so ordinary macOS keyboard input, gameplay and save/relaunch remain **Not run**. No system audio preference, tracked host code or iOS audio path was changed. Next establish an input-capable macOS control route; keep process-local audio-device isolation separate from iOS audio-glitch work.

## Explicit macOS output control (2026-09-29)

`patches/conker-macos-audio-device.patch` lets the macOS SDL host pass the optional `SQUIRRELPAD_MAC_AUDIO_DEVICE` name to `SDL_OpenAudioDevice`; with the variable absent it still opens the default device. `scripts/setup-source.sh` replays the patch. This changes only the host output selection, not game logic or the iOS Audio Queue. With `SQUIRRELPAD_MAC_AUDIO_DEVICE='MacBook Air Speakers' CONKER_TEST_PROFILE=1`, a 35-second Metal run reached 1,935 VIs and exited zero (`work/macos-explicit-device-run.log`); a process sample found SDL in its event pump rather than audio opening (`work/macos-explicit-device-sample.txt`). A 50-second repeat reached 2,990 VIs and exited zero (`work/macos-explicit-device-repeat-run.log`). The patch reverse-check and macOS Metal rebuild passed (`work/macos-explicit-device-build.log`).

A separate 50-second capture run reached 2,991 VIs and yielded 24 seconds of process-filtered system audio (`work/evidence/macos-explicit-speakers-audio.m4a`, `work/macos-explicit-speakers-capture.log`). Decoded 48 kHz stereo contained 1,896,694 nonzero samples out of 2,373,120; this proves output reached the capture path, not that it sounds clean. This capture run exited 134 after the timer requested shutdown with `std::system_error: mutex lock failed: Invalid argument` (`work/macos-explicit-device-capture-run.log`); the two other bounded exits succeeded. Treat teardown as an intermittent separate failure to reproduce. **G1 remains open:** ordinary macOS input/save and audible fidelity are unverified. The temporary VI-timed scene-input probe in the ignored checkout rendered the new-game opening through 300 seconds (`work/evidence/macos-scene-probe-300-late.png`) but produced no save; it is not an ordinary-input pass. Continue the iOS glitch investigation with matched gameplay and timestamped PCM/callback evidence.

The unsuccessful scene-input probe was removed from the ignored checkout, and the macOS Metal host rebuilt (`work/macos-explicit-device-final-build.log`). The adjacent Release Simulator and unsigned device app builds passed (`work/macos-explicit-device-ios-{sim,device}-build.log`). Neither build is a new Simulator gameplay test; the host-only output-selection change needs no new iOS behavior claim.

## Matched saved-field audio control (2026-09-29)

The existing iPad Pro 11-inch (M4), iOS 18.5 EEPROM save was copied into the separate macOS **test** profile; both files initially had SHA-256 `8e70b01c2905fdba2c579978f913b648d2e18d74a309ad40d6a503d9a2ed0628`. The iPad source container was not reset or deleted. A temporary macOS-only VI-timed A-button probe in the ignored source checkout selected GAME1 → PLAY with the copied save. The macOS Metal host then rendered the first-field opening and idle Conker (`work/evidence/macos-same-save-{select,field}.png`, viewed), reached 8,985 VIs in 150 seconds and exited zero (`work/macos-same-save-probe-{build,run}.log`). Process-filtered ScreenCaptureKit recorded 35 seconds of field sound (`work/evidence/macos-same-save-field-audio.m4a`, `work/macos-same-save-field-capture.log`). This is a same-save gameplay control, **not** ordinary macOS keyboard acceptance. A proper local app bundle with resources also reached the SDL event loop, but Computer Use still timed out attaching to it; bundle packaging did not resolve input automation.

The already installed iPad Simulator app executable was confirmed byte-identical to the Release build at SHA-256 `811066c4837de11c0c43410568c85ce0c575b43f7813fb00559d3866b6a86461`. Through the ordinary **Continue Imported ROM → GAME1 → PLAY** touch route, it showed the same saved first-field opening and later gameplay (`work/evidence/ipad-same-save-field.png`, viewed; `work/ipad-same-save-run.log`). A simultaneous 35-second system-output capture completed (`work/evidence/ipad-same-save-field-audio.m4a`, `work/ipad-same-save-field-capture.log`). The captured run logged 22,020 Hz playback and nonzero PCM consumption, with no reported Audio Queue error, underrun, discard, callback gap or >=80 ms producer gap through display list #4,320. The raw `simctl` image is portrait-rotated, as in earlier captures; the live Simulator window showed landscape during the same sequence.

Both 48 kHz stereo recordings were decoded locally and compared as mono (`work/compare-same-save-{audio,wave}.py`). Their best 10 ms log-RMS alignment was 10.17 seconds with correlation 0.758 over 27 seconds. Four-second **sample waveform** windows aligned at offsets 10.17175, 10.17152, 10.17133, 10.17110 and 10.17094 seconds; amplitude-normalized correlations were 0.729, 0.823, 0.841, 0.947 and 0.910. The less than 1 ms offset change across 20 seconds argues against a broad timing drift in this matched field interval. Capture route/system gain differed, so the absolute amplitudes are not a game-volume comparison. This does **not** rule out Chris's audible glitches elsewhere, brief artifacts inside these windows, or effect latency. At the end of both runs, the two test-profile EEPROM files again matched byte-for-byte, now SHA-256 `ec009e9b3c8449d002c8fde59f273ef82ef8f0ee491f58bd2eaf5d905a96fcc2`; this is one shared-save transition, not two distinct in-level save checks.

The temporary macOS scene probe was removed and the normal host rebuilt (`work/macos-same-save-probe-clean-build.log`). **G1 and G4 remain open.** Next isolate a reported audible glitch in a different scene or action with matched source PCM, queue callback and system-output timing; do not infer clean audio from this one aligned field segment. Ordinary macOS input, distinct save/relaunch, iPhone representative audio and physical-device listening still need their own checks.

## Reference-style controller bindings divider (2026-09-29)

The Controls menu now presents Controller Bindings as a thin chevron, label and rule, following `ref/harkinianpad/docs/readme/simulator-settings.jpg` more closely than the former gray card. The expanded bindings content and button action are unchanged. Release Simulator and unsigned device builds passed (`work/menu-divider-release-{sim,device}-build.log`); the exact Simulator executable SHA-256 was `d665d87a2104838b814b3320f0e60ec1fd06ff273566ab1675d064e6b1e9e8db`.

Installed that build in place and checked one Simulator at a time: iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5. On each, the divider fit the menu; Controller Bindings expanded and collapsed, the Audio tab opened, and Close returned to the app. Both used the ordinary Continue Imported ROM → GAME1 → PLAY route to visible first-field gameplay, then opened and closed the menu over gameplay. The iPad B action visibly changed Conker's pose; on iPhone, Start showed PAUSED and A resumed gameplay. Raw captures viewed: `work/evidence/ipad-menu-divider-field.png`, `work/evidence/iphone-menu-divider-{default,field}.png`. The iPhone's 50% master-volume setting remained after the in-place install. These are visual and input regression checks, not audio-fidelity or full-game acceptance. Chris's reported audio glitches, broader menu parity, long play and physical-device touch/controller/audio checks remain open.

## Current-build iPad audio replay (2026-09-29)

The unchanged Release Simulator executable (`d665d87a2104838b814b3320f0e60ec1fd06ff273566ab1675d064e6b1e9e8db`) was installed in place on iPad Pro 11-inch (M4), iOS 18.5. Through the ordinary Continue Imported ROM → GAME1 → PLAY route, it reached the first field; touch stick drags and B/A/Z presses were sent, and the gameplay view was inspected (`work/evidence/ipad-current-audio-field.png`). The console-attached run advanced through display list #9,840 and reported 22,020 Hz playback and nonzero PCM consumption. No underrun, drop, callback-gap, callback-stall or enqueue-error line appeared in the observed console output. The app was terminated and the Simulator shut down.

Two ScreenCaptureKit system-output captures completed (`work/evidence/ipad-current-{long,movement}-audio.m4a`). The 127.88-second first capture had nonzero 48 kHz stereo after 2.5 seconds, no clipped samples and no 100 ms window below RMS 5 after onset. The 63.86-second field/action capture had no clipped samples; it contained three adjacent 100 ms low-level windows at 23.6–23.8 seconds (RMS 1.5–2.6) bounded by a gradual fall and rise. This is a candidate interval to compare with queued PCM or the macOS scene, **not** a verified glitch: the field has quiet ambience, and no matching input/video timestamp or audible judgment was captured. This run does not resolve Chris's glitch report or justify changing the playback reserve. G4 remains **Fail / unresolved**; reproduce the reported sound in a named scene and correlate its timestamp with source PCM, queue output and system capture before editing pacing.

## Source and rights boundary inventory (2026-09-29)

`docs/SOURCE_BOUNDARY.md` maps the pinned iOS source graph to license files in the ignored checkout and distinguishes linked runtime/renderer code from the desktop-only RecompFrontend. The six principal Git revisions were checked against `sources.lock.json`; their recorded license files or header texts were inspected. This is a source-level inventory, not a finished package notice or linked-object audit. It explicitly records that `RecompiledFuncs/` carries code and data derived from the private ROM even when the app bundle has no ROM file. **G0 and G8 remain open:** verify nested linked objects, supply complete required notices, make an independent clean build and audit the exact installable artifact before any distribution decision.

## Audio interruption and background recovery (2026-09-29)

The SwiftUI app now pauses core and touch input on an `AVAudioSession` interruption and reactivates the session before resuming. When an interruption ends in the background, it waits until the scene becomes active. The scene handler passes its new phase directly to the activity check: a probe showed that reading the environment's `scenePhase` in that callback could still return the previous phase and leave the game paused. The candidate with that stale read was not committed.

Release Simulator and unsigned device builds passed (`work/audio-interruption-fixed-{sim,device}-build.log`); the Simulator executable SHA-256 was `f35f303d22298afda36dc1431d7aecdb1baefb072d802288f442851f9b364574`. On iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5, a debugger posted synthetic begin/end notifications around Home and app return. The iPad resumed from game select and touch A advanced to gameplay. The iPhone resumed rendering from the Nintendo logo into the opening sequence. These tests validate the app's notification/state path, but synthetic posts do not simulate a real OS audio interruption or prove audible recovery. G4 audio fidelity remains unresolved, as does device listening.

## Current pinned-input audit (2026-09-29)

The separate ignored `work/CBFD-Recompiled` checkout still has the `sources.lock.json` upstream commit and all six explicitly listed gitlinks. Its linked private ROM resolves to a 67,108,864-byte file with header `80371240` and the pinned SHA-1; only the validation result was recorded, not ROM bytes. `git submodule status --recursive` reported 46 entries with no drift or conflicts. Five decomp/tool submodules remain uninitialized (`conker/tools/{asm-differ,asm-processor,mips_to_c,n64splat}` and `tools/m2c`); the existing generated build works, but an independent generation replay must establish whether those tools are needed. Git's ignore rules covered the ROM, generated functions and captures, and the staged file list was empty. The patched checkout remains intentionally dirty; this audit is read-only and does not substitute for a clean source replay or package audit. **G0 remains in progress.**

## Connected controller in the Settings menu (2026-09-29)

Controls now shows the connected Game Controller above its collapsible bindings, closer to the device-first arrangement in `ref/harkinianpad/docs/readme/simulator-settings.jpg`. The old duplicate status inside the expanded bindings was removed; mapping and game input did not change. Release Simulator and unsigned device builds passed (`work/menu-controller-status-{sim,device}-build.log`), and the exact Simulator executable SHA-256 was `803ccbbfde8ea02241a69528fbaf5c2a12fd6fd652dd00c34007930f920a7437`.

Installed in place on iPad Pro 11-inch (M4) then iPhone 16 Pro, iOS 18.5. Both Settings panels showed the Simulator's connected Gamepad; the bindings expanded, and the iPhone Audio tab still showed its saved 50% volume. Closing the menu restored the launcher; Continue Imported ROM started the game on both. Opening and closing Settings over the running game restored the touch controls on iPhone. The live iPad/iPhone panels were viewed against the reference screenshot; raw captures are `work/evidence/{ipad,iphone}-menu-controller-status.png`. This improves device visibility but does not add the reference's editable bindings, search or other settings. G4 menu/input and audio acceptance remain open.

## Independent source replay and app build (2026-09-29)

A new ignored `work/source-replay` checkout was cloned at pinned commit `c55359c579448fe5c212faf4bb5c2415d6ec7fa8`. With `SQUIRRELPAD_CHECKOUT` pointing there, `scripts/setup-source.sh` fetched the recursive submodules, applied every local patch, checked the private ROM's size/header/SHA-1 and linked it without copying it (`work/source-replay-{clone,setup}.log`). The 46 reported submodule gitlinks had no drift or conflict. Five decomp-only tool gitlinks were uninitialized; they were not needed for the following game-code generation. `python3 recomp/recompile.py --bin <the previously built N64Recomp/RSPRecomp directory>` generated 127 files, and `diff -qr` found no difference from `work/CBFD-Recompiled/RecompiledFuncs` (`work/source-replay-recompile.log`). The generator executables were reused, so this is a source-output replay, not a fresh generator-tool build.

`CMakeLists.txt` now accepts `SQUIRRELPAD_CONKER_SOURCE`, defaulting to the existing checkout. Fresh Xcode configurations pointing at `work/source-replay` built ARM64 Release Simulator and unsigned device apps, with compile paths under the replay checkout (`work/source-replay-app-{sim,device}-{configure,build}.log`). The Simulator executable SHA-256 was `1d428592e115c8f0062020af21f5aeb30e11e6442fa55ebdd950f362a1c3843f`; the unsigned device executable was `fbbd5f04786245c324c567941039a8fb066204c7281d138cbc51e7946d169589`. Both builds reused previously compiled RT64/Plume archives, so G8 still needs an independent full dependency build and artifact audit.

Installed that Simulator executable in place, one device at a time, on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5. Both followed Continue Imported ROM → GAME1 → PLAY to a visibly rendered first field, then touch Start opened PAUSED and A resumed. The field was viewed live and captured at `work/evidence/{ipad,iphone}-source-replay-field.png`. This validates the replay source selection and ordinary short route; it does not establish audio fidelity, save correctness, long play or physical-device performance. **G0 source inputs pass; G1 and G4–G8 remain open.**

The separate native macOS control app launched with MacBook Air Speakers selected, but Computer Use timed out twice while binding its window. A one-second sample (`work/macos-control-native-current-sample.txt`) showed the process waiting for game start while RT64 submitted dummy work. It was terminated after this bounded check. Ordinary macOS launcher input remains unverified under G1.

## Full pinned dependency replay (2026-09-29)

The replay checkout built its own `N64RecompCLI`, `RSPRecomp` and `RecompModTool` (`work/source-replay-tools-{configure,build}.log`). Regeneration with those fresh binaries again produced 127 game files byte-for-byte identical to the current checkout (`work/source-replay-own-tools-recompile.log`, `diff -qr`). Its macOS Metal host then built successfully from the replay checkout and generated 56 Metal shader sources plus `file_to_c` (`work/source-replay-host-{configure,build}.log`). This build was for shader inputs and compilation proof; ordinary macOS play/input/audio remains G1.

`scripts/verify-rt64-ios.sh` now accepts `SQUIRRELPAD_CHECKOUT` and `SQUIRRELPAD_RT64_BUILD_TAG`, preserving its original defaults. With the replay checkout and `-replay` tag, the script recompiled all 56 shaders for each iOS SDK, built separate RT64/Plume/re-spirv/zstd archives and passed the force-loaded ARM64 link probe for Simulator and device (`work/source-replay-rt64-{sim,device}-verify.log`). RT64 archive SHA-256: Simulator `03b086d9a804939dec72e5de21fdcb0fea01d5c6554ab9ce1cfc0294635bc982`, device `dd1ed4954b209679011f1d59a8c8c9aadf3b8967434d84b139b020c0dcae6de6`.

The replay app projects were relinked against these new archives, and both Release builds passed (`work/source-replay-full-{sim,device}-{configure,build}.log`). The link commands contain the replay archive paths. The final app executable hashes were byte-identical to the already installed replay app tested through GAME1 → PLAY → first field and pause/resume on both iOS 18.5 Simulators: Simulator `1d428592e115c8f0062020af21f5aeb30e11e6442fa55ebdd950f362a1c3843f`, device `fbbd5f04786245c324c567941039a8fb066204c7281d138cbc51e7946d169589`. This closes the independent source/dependency *build* check, not G8 packaging or the wider playability gates. Next generate the exact link map, include required third-party notices, audit the installable binary for private contents and obtain a rights decision; physical signing/install still requires devices.

## iOS game-start mod boundary (2026-09-29)

The unsigned device link map for the preceding build (`work/source-replay-device-LinkMap.txt`) included `libLiveRecomp.a(live_generator.o)` and `libLiveRecomp.a(sljitLir.o)`. Source inspection found that iOS had skipped LiveRecomp initialization and mod scanning, but `wait_for_game_started()` still called `ModContext::load_mods()` because Conker registers `mod_game_id = "conker"`. That call can regenerate and patch native functions. `patches/n64modernruntime-ios-mod-load.patch` now excludes that game-start call on iOS while retaining ordinary game initialization, heap setup and saves. It is applied after the existing iOS mod patch by `scripts/setup-source.sh`.

Release Simulator and unsigned device builds passed (`work/ios-mod-load-{sim,device}-build.log`). The Simulator executable SHA-256 was `dde2245e3cb70da036fb15487e0b87d65a6fa9963dded3d8505242939ad76678`. It was installed in place on iPad Pro 11-inch (M4), then iPhone 16 Pro, both iOS 18.5. Each used **Continue Imported ROM → GAME1 → PLAY** to reach the visibly rendered first field; touch Start showed PAUSED and A resumed gameplay. Captures were viewed live and saved at `work/evidence/{ipad,iphone}-ios-mod-load-field.png`; iPad pause is at `work/evidence/ipad-ios-mod-load-paused.png`. Run logs are `work/ios-mod-load-{ipad,iphone}-run.log`. The observed windows advanced display lists without a GPU error or crash. This checks the immediate game-start regression, not later story functions or audio quality.

The new device diagnostic link map (`work/ios-mod-load-device-LinkMap.txt`; build log `work/ios-mod-load-device-linkmap-build.log`) still lists two LiveRecomp objects. It marks `ModContext::load_mods` and `N64Recomp::live_recompiler_init` as dead stripped, but retains a LiveRecomp destructor and sljit executable-memory *free* functions. Those retained symbols do not prove an allocation occurs; they also prevent a claim that the final binary is JIT-free. G2's executable-memory audit and G8's notices/content audit stay open. The map confirms N64Recomp, Rabbitizer and fmt objects and no tomlplusplus archive object in this unsigned build. A repeat invocation of `scripts/setup-source.sh` on the already multiply patched checkout stopped at the earlier upstream runtime patch because reverse application could not recognize overlapping later edits (`work/ios-mod-load-setup.log`); the fresh-checkout replay above passed, and this patch itself passed `git apply --check` before application. Treat setup as a fresh-checkout command until its rerun behavior is repaired.

## Developer-bundle notices and path audit (2026-09-29)

The iOS CMake target now copies 21 exact license texts from the pinned Conker checkout into `ThirdPartyNotices/` in each app bundle. Missing source text fails CMake configuration. Release Simulator and unsigned device builds passed (`work/notices-{sim,device}-{configure,build}.log`). Both bundles contained exactly 24 regular files: the executable, `Info.plist`, `PkgInfo` and 21 notice texts. The Simulator executable stayed byte-identical to the one tested in gameplay above, SHA-256 `dde2245e3cb70da036fb15487e0b87d65a6fa9963dded3d8505242939ad76678`. This verifies resource packaging, not full legal clearance; header-only components and the GPL/ROM-derived boundary still need final review.

The file inventory found no `.z64`, `.v64`, `.n64`, save or generated segment file in either bundle. This does **not** mean the app is ROM-free: generated game functions are compiled into the executable. A byte scan of the unsigned device executable found eight absolute local source paths from compiled diagnostics, one `baserom.us.z64` filename reference and one ROM-header byte sequence. Those strings are a packaging defect to remove in the next build; the header occurrence alone does not establish bundled ROM data. The current unsigned device executable SHA-256 is `189488ac1a4448c3ec85e1e6d686b4f6942b350ec14870e8b1c49f2a9d7f5a0c`.

## Stable diagnostic paths in the developer bundle (2026-09-29)

The iOS CMake build now passes `-ffile-prefix-map` to C, C++, Objective-C and Objective-C++ compilation for the root target and pinned subprojects. This leaves useful relative `__FILE__` diagnostics while removing the eight absolute checkout paths found above. Release Simulator and unsigned device rebuilds passed (`work/path-map-{sim,device}-{configure,build}.log`). A byte scan found zero `/Users/chrissotraidis` occurrences in each rebuilt executable; both bundles still held 21 notices, each byte-identical to its pinned source license text. SHA-256: Simulator `03cd9d4670a877d3979d6be9be72942b7da8612b41e2b14a776e6f4a393a1988`; device `9054e004a93642b5eddc83dd3b785d6b22051f706e82dc8d6b59e8bcd4cd0e7c`.

That exact Simulator build was installed in place, one device at a time, on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5. Both used **Continue Imported ROM → GAME1 → PLAY** and rendered the first field; the viewed raw captures are `work/evidence/{ipad,iphone}-path-map-field.png`, with run logs `work/path-map-{ipad,iphone}-run.log`. The capture windows logged no GPU pipeline error, Audio Queue underrun, PCM drop or callback-gap diagnostic. This is a narrow rebuild regression check and does not establish clean audio, long play, complete notices or distribution rights. The `baserom.us.z64` filename string and ROM-derived native game code remain in the executable by design and require accurate release review.

## Settings panel contrast (2026-09-29)

The Settings panel black fill changed from 78% to 88% opacity so launcher text remains faintly visible beneath the panel while the controls and Audio content read more clearly. This is a visual adjustment only; game logic, bindings and audio buffering are unchanged. Release Simulator and unsigned device builds passed (`work/menu-contrast-{sim,device}-build.log`); the Simulator executable SHA-256 was `79ee71968cd10bb3f8f7b8bfb0a00dfcd39f08c08e34cc19eff9d7aca356e6da`.

The exact Simulator build was installed in place, one device at a time, on iPhone 16 Pro and iPad Pro 11-inch (M4), both iOS 18.5. Controls and Audio tabs were viewed live against `ref/harkinianpad/docs/readme/simulator-settings.jpg`; raw captures are `work/evidence/{iphone,ipad}-menu-contrast-{controls,audio}.png`. On iPhone, the saved 50% volume remained visible; on iPad the saved 116% Control Size and 100% volume remained visible. Close returned to the launcher on both. This improves contrast but leaves substantial reference-menu parity work open, including editable bindings and additional settings. Chris's audio glitch report and full-game/device acceptance remain open.

## Exact-build iPad audio window (2026-09-29)

A first attempt at this check accidentally installed the older default-build executable (`803ccbbfde8ea02241a69528fbaf5c2a12fd6fd652dd00c34007930f920a7437`), so its recording (`work/evidence/ipad-audio-long-20260930.m4a`) is **not** current-build evidence. The iPad Pro 11-inch (M4), iOS 18.5 Simulator was then shut down, booted and installed in place from `work/build-app-replay-iphonesimulator/Release-iphonesimulator/SquirrelPad.app`; the source executable SHA-256 was checked as `79ee71968cd10bb3f8f7b8bfb0a00dfcd39f08c08e34cc19eff9d7aca356e6da`, the Settings-contrast build.

The corrected run used ordinary **Continue Imported ROM → GAME1 → PLAY**, reached the visible first field, and sent B/A/Z touch actions. The console-attached log `work/ipad-audio-current-20260930-run.log` advanced through display list #6,540 with 22,020 Hz playback and nonzero PCM consumption; it contains no Audio Queue underrun, PCM drop, callback gap, callback restart or enqueue error. The field was viewed live and saved at `work/evidence/ipad-audio-current-20260930-field.png`. The simultaneous ScreenCaptureKit recording (`work/evidence/ipad-audio-current-20260930.m4a`, capture log alongside the run log) completed with 6,398 audio buffers and no writer error. Decoded to 48 kHz stereo, its 127.96 seconds contained 23 silent 100 ms windows at the beginning, none after 20 seconds, and no clipped sample. This rules out a long dropout in the observed first-field window, but it neither judges audible quality nor reproduces Chris's glitch. G4 audio remains **Fail / unresolved**; next use a specific scene and timestamp to distinguish producer timing, output pacing and a content difference from the macOS control. No audio code was changed.

## Launcher visibility while Settings is open (2026-09-30)

The ROM launcher panel is now hidden while Settings is open, preventing its title and buttons from bleeding through the Controls and Audio rows. The closed menu restores the launcher. Release Simulator and unsigned device builds passed (`work/menu-hide-launcher-{sim,device}-build.log`); Simulator executable SHA-256 was `549f12c351eb801dc5e4939ca507856e900b9bb988eaa7c05b7802fc5fbceda8`.

Installed that build in place on iPad Pro 11-inch (M4), then iPhone 16 Pro, iOS 18.5. Controls and Audio were viewed against the reference panel; raw captures are `work/evidence/{ipad,iphone}-menu-launcher-hidden-{controls,audio}.png`. Launcher controls disappeared from the accessibility tree while Settings was open, Close restored them, and Continue Imported ROM started the visible opening on both. The iPhone's saved 50% volume remained. Some Simulator-window captures omitted header/border portions; paired raw device captures contained the complete panel. This verifies the launcher/menu transition and clearer content only. Reference-menu parity, audio glitches and story acceptance remain open.

## Exclude live recompilation from the iOS link (2026-09-30)

`patches/n64modernruntime-ios-no-live-recomp.patch` makes iOS `librecomp` exclude the LiveRecomp library and compile out its generated-code and shim ownership/calls. Any accidental attempt to create live code stays invalid or returns `FailedToRecompile`. Desktop builds keep the original implementation. The existing iOS mod scanning, initialization and game-start guards remain. `scripts/setup-source.sh` applies this patch after the game-start guard. Game functions, input, graphics and audio logic did not change.

**Pass:** Release ARM64 Simulator and unsigned device builds (`work/no-live-recomp-{sim,device}-build.log`). Final executable SHA-256: Simulator `6b587c06db9f07562667d6d1a6bc4eb09ab221edb9e20b191cf2058fd578b523`; device `1dfc0262113f48e569063f79a34ee200f0dd9da049db4c396ad3e78217c909a6`. `nm` found no `sljit`, `LiveGenerator`, `ShimFunction`, `live_recompiler` or `jit_write` symbols in either executable (`work/no-live-recomp-{sim,device}-symbols.txt`, both empty). The device map (`work/no-live-recomp-device-LinkMap.txt`) has no LiveRecomp archive objects and marks `protect`, `unprotect`, `patch_func` and `unpatch_func` dead stripped. Imported mmap/mprotect remain for RDRAM: the inspected runtime reserves `PROT_NONE` memory and enables `PROT_READ | PROT_WRITE`, without execution permission. This resolves the previously retained LiveRecomp/sljit link dependency; physical execution is still untested.

**Pass:** Installed the exact Simulator app in place on iPad Pro 11-inch (M4), then iPhone 16 Pro, iOS 18.5, with one Simulator running at a time. Both used Continue Imported ROM → GAME1 → PLAY, rendered the opening dialogue and first field, and passed touch Start pause / A resume. Viewed live and inspected raw captures: `work/evidence/{ipad,iphone}-no-live-recomp-field.png`. Unified logs: `work/no-live-recomp-{ipad,iphone}-run.log`; these do not include all C++ stdout diagnostics, so this check does not establish audio or GPU error-counter acceptance. Existing ROM and saves were preserved. Both Simulators were terminated and shut down after the test.

**Not run / still open:** full-story progression, sustained ordinary touch movement, macOS fidelity control and the reported audio glitches. Next isolate an audible glitch in a reproducible scene and compare the source PCM with the queue output; quiet underrun counters alone do not close audio acceptance. Chris still owns physical-device touch feel, controllers/rumble, speaker/headphone/Bluetooth audio, long play/performance, and signing/rights decisions. No push.


## Editable primary controller bindings (2026-09-30)

The Controller Bindings rows for N64 A and B now open native button-selection menus. Choices are A/B/X/Y/LB/RB/LT/RT; each selected source feeds the existing N64 button mask. Values persist in app preferences, invalid stored choices fall back to the original A/B mapping, and Restore A/B Bindings resets just these mappings. Stick, camera, Z/Start/L/R/D-pad and touch input keep their existing routes. This is an incremental original implementation of the reference's editable binding tags; other binding rows remain fixed.

**Pass:** Release Simulator and unsigned device builds (`work/menu-primary-bindings-{sim,device}-build.log`). Simulator executable SHA-256 `89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`; device `a5ed2f7a2d15a53c13d1de544c4c9398f962bf3fbb2153bb0603e3d803e52c02`. A focused native GameController snapshot check compiled a copy of the current mapper with only private test access relaxed and C output captured: default X produced no N64 button, X→A produced 0x8000, Y→B produced 0x4000, combined LT preserved Z (0x6000), inactive input cleared, a new instance loaded the stored X choice, and reset restored A/B. Log: `work/controller-primary-bindings-test.log`. This tests the mapping boundary, not a physical controller or ordinary gameplay by controller.

**Pass:** Installed the exact app in place on iPad Pro 11-inch (M4) and iPhone 16 Pro, iOS 18.5, sequentially. On iPad, selected X for A, cold-relaunched, reopened bindings and observed X, then used Restore A/B Bindings to return A. On iPhone, selected Y for B, cold-relaunched and observed Y, then reset B. The iPhone Audio tab retained 50% volume; iPad Control Size retained 116%. Both menus were viewed against `ref/harkinianpad/docs/readme/simulator-settings.jpg`; raw captures `work/evidence/ipad-primary-bindings-x.png` and `work/evidence/iphone-primary-bindings-y.png` were inspected. Both native selection menus fit the window and dismissed after selection. Source changes and synthetic check contain no reference code or media.

**Pass, narrow gameplay regression:** each class used Continue Imported ROM → GAME1 → PLAY to the viewed first field, then touch Start paused and touch A resumed. Captures `work/evidence/{ipad,iphone}-primary-bindings-field.png`; console logs `work/menu-primary-bindings-{ipad,iphone}-relaunch.log` contained no underrun, dropped PCM, callback-gap/stall, enqueue or pipeline failure in the observed window. This is not audio-quality proof. Both Simulators were terminated and shut down; default controller mappings were restored without changing the other saved settings.

**Still open:** remaining editable controller actions, live controller gameplay acceptance, sustained touch input and full-story progression, reported audio glitches, and macOS ordinary-input fidelity control. The audio candidate excerpt from an earlier capture could not be listened to by the available tool interface (audio input unsupported), so it was not judged clean or defective. Next exercise live remapped controller input in a gameplay scene and progress beyond the first field using a sustained Simulator input path. Physical touch feel/controller/rumble/audio routes/long play and signing/rights remain with Chris. No push.

## Bounded Simulator controller input (2026-09-30)

Added an opt-in, Simulator-only hidden GameController probe and `scripts/simulator-input.py`. Commands set stick/camera axes and physical A/B/X/Y buttons through the existing controller mapper, expire automatically within ten seconds, and ignore expired fixtures after relaunch. Both a compile option and launch environment switch are required. Device configuration rejects the option. Instructions and the restoration procedure are in `docs/SIMULATOR_INPUT.md`. Game logic and the default app remain unchanged.

**Pass, diagnostic integration:** probe build SHA-256 `7b0aedfb47f8f3d864f9c5b921ef046f3f4b1616abe97af2beab03dbcc509a43` was installed in place on iPad Pro 11-inch (M4), then iPhone 16 Pro, iOS 18.5. Controller A selected PLAY; timed analog commands visibly moved Conker around the opening field, and camera-right changed the view on both. On iPad, Settings mapped X to A; touch Start paused and controller X resumed. Default A/B bindings were restored. Console logs record connection, commands and automatic releases: `work/sim-input-{ipad,iphone}-run.log`. Viewed live and inspected raw captures: `work/evidence/ipad-probe-{before-camera,after-camera,x-paused,x-resumed}.png`, `work/evidence/iphone-probe-{before-movement,after-movement,after-camera}.png`. This proves the sustained test-controller route, not sustained touch feel, a physical controller, or full-story completion. The combined stick/A attempts did not establish a jump or fence crossing; Conker remained in the opening field. B on the outside context pad did not start the next sequence. The next gameplay check must establish the intended approach to Birdy and compare that interaction with the control before changing game code.

**Pass, normal-build boundary:** both normal Release SDK builds succeeded with the probe option OFF (`work/sim-input-normal-build.log`, `work/sim-input-normal-device-build.log`). Executables are byte-identical to the preceding tested build: Simulator `89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`, device `a5ed2f7a2d15a53c13d1de544c4c9398f962bf3fbb2153bb0603e3d803e52c02`. Normal binaries contain no SimulatorInputProbe/GCVirtualController symbols or probe command/log markers. The device probe configuration failed with the intended Simulator-only error (`work/probe-reject-device.log`). Reinstalled the normal app on both Simulators and viewed their Settings; iPad retained 116% size. ROM/save containers were preserved and both Simulators were shut down. No push.

**Unresolved:** reported audio glitches, ordinary sustained touch acceptance, full-story progression, remaining menu parity, and macOS gameplay fidelity. No audio code changed; quiet counters in these windows do not establish clean audio. Physical touch feel, controllers/rumble, audio routes, long play, signing and rights decisions remain with Chris.

### Longer movement run: audio underrun reproduced

A second iPad probe run (`work/story-ipad-run.log`, probe enabled from `ff03890`, build log `work/story-probe-build.log`) used the ordinary saved GAME1 slot and continued walking around the first field's fence perimeter. It still did not reach the Birdy interaction or leave this area; `work/evidence/ipad-story-perimeter-stop.png` records the final position. The route prerequisite was checked against the [GameRevolution walkthrough](https://www.gamerevolution.com/guides/28824-conkers-bad-fur-day-walkthrough): approach Birdy before using the outside context pad. This is navigation guidance, not macOS parity evidence or a diagnosed game defect.

**Fail, audio continuity:** log lines 264–267 show consecutive PCM submission gaps of 101 ms (2,440 frames queued) and 86 ms (1,128 frames queued), followed by `underrun 1` and `reserve refilled 1`. A previous 102 ms gap appears at line 234. There is now a concrete longer-run underrun reproduction on the current probe; this does not identify whether the original reported glitch has the same cause. No audio buffering or game code was changed. Next correlate the late VI/event delivery or producer scheduling with these steady-clock timestamps; do not repeat a short quiet first-field run as audio acceptance or raise the reserve without measuring its latency tradeoff.

The normal Simulator build was restored with the probe option OFF, rebuilt successfully (`work/story-normal-build.log`), and reinstalled in place. Its final executable is `b740c1b1313529543450260eeb38200c05b3bee041485590771ad9341ce7706e`. The restored build was checked for absent probe symbols/markers and launcher/Settings open-close behavior on both Simulators; these narrow checks do not establish gameplay or audio acceptance. Both Simulators are shut down. Full-story verification, menu parity and the audio fix remain agent work; physical-device checks and signing/rights decisions remain with Chris.


## Simulator audio: host stalls versus game computation (2026-09-30)

Chris challenged whether the observed underruns explain the audible glitches or instead reflect the Simulator/host. **Confirmed:** the queue really inserts silence when PCM arrives late. **Not established:** those holes explain every reported glitch, the physical-device behavior, or a single root cause for all audio defects.

A temporary trace counted inserted zero frames separately from legitimate silent game PCM, measured producer mutex wait and queue depth, and timed VI phases. The viewed iPad GAME1 → PLAY → first-field run finished with **3 underruns / 2,736 injected silent frames (124 ms at 22,020 Hz)** over 416.65 seconds (`work/audio-cause-ipad-run.log`, executable `ca9b20e8dab1adb769629484d7144b6c399b6963666215555a0f2e39938645a9`). Its first two underruns injected 1,800 frames (82 ms) during the 215–221 second window. No >=40 ms output-callback gap or long VI phase was logged, and producer mutex wait in that window was zero. Queue depth normally stayed near 3,500–4,100 frames; this is an intermittent late-production failure, not evidence of continuous sample-rate drift. Capture: `work/evidence/ipad-audio-cause-field.png`.

The simultaneous one-second host VM trace (`work/audio-cause-host-memory.jsonl`) showed 13,297 decompressed and 5,614 compressed 16 KiB pages in a second overlapping that cluster, with one-minute load about 23 on this 8-core/16 GiB Mac. Swap-out counts stayed unchanged. This correlation supports investigating host scheduling/memory activity; it does not prove a fault in one process or function.

**Stronger localization:** an independent RSP/game-thread trace reproduced two underruns and 6,504 injected silent frames (295 ms) through 316.27 seconds of startup/game-select (`work/audio-thread-cause-ipad-run.log`, executable `3911517cedbcb1fd5d5310a485b61ce9d9d132a84f628b43e23a8c0cc747a563`). Audio task type 2 took 154.25/156.16 ms wall time but 1.365/1.564 ms thread CPU, immediately preceding 164/230 ms PCM gaps. A later task took **253.24 ms wall / 1.064 ms CPU**, immediately preceding a 317 ms PCM gap and underrun. The callback path is `ultramodern::rsp::run_task` → `recomp::rsp::run_task` → generated `conker_audio_ucode`; inspection found calculations and memory copies, with no explicit sleep or lock wait on the successful path. Most of those task spans occurred outside CPU execution. Scheduling or memory faults in the Simulator process are leading explanations; expensive microcode computation alone is unsupported. This does not prove that the port's allocations or scheduling policy cannot contribute.

A 360-second macOS Metal timing control with explicit MacBook Air Speakers exited zero with 21,562 VIs and no >=80 ms PCM submission gap (`work/audio-cause-mac-run.log`, executable `d8e6d5114285e545bdfa379555c69f561c60ea018963a7228296988273cc13b9`). Three empty-at-submit SDL queue observations do not prove injected silence. Its scene/input route was not visually verified in this run, so this is limited timing evidence, not a matched gameplay/audio-fidelity pass.

**Rejected priority experiment:** actual SP-task QoS read back as default (21). An iOS-only user-initiated (25) candidate applied correctly, but the initial candidate's lower host load invalidated a benefit claim. A same-executable comparison (`9384aef41c707f83e551974e737406fa4adcd71682961f6c20922a617fa8dbae`) then ran the viewed first field with each setting and eight bounded CPU workers for 60 seconds (`work/audio-task-{default,high}-paired-{ipad-run.log,load.jsonl}`). Both load windows had zero underruns/injected silence and no RSP task over 20 ms; the sampled maximum submission gaps were 43.086 ms default and 67.726 ms elevated. CPU load alone did not reproduce the natural failure, and raising priority showed no benefit in this comparison. **The candidate was removed.** Experimental menu binding work was parked as `work/menu-all-bindings.pending.patch` when Chris redirected the investigation to audio.

The Mac's current default output is the virtual Jump Desktop Audio device (`work/audio-cause-host-audio-devices.txt`). Simulator exposes both System (Jump Desktop Audio) and MacBook Air Speakers, and its recent-route preferences contain both. The selected Simulator output was not established, so no virtual-device causation is claimed and no output setting was changed. The agent cannot listen to captures through the available tool interface; waveform/counter checks do not judge crackle or dialogue fidelity.

All temporary timing, CPU-load, input-probe and QoS changes were removed. Original runtime/audio sources were byte-checked against backups; normal Simulator and macOS builds succeeded. Simulator probe is OFF, and its executable has no probe/trace markers. Restored Simulator executable: **`89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`**; macOS executable: `98bf0fc99ece2e96027a61c200f26dc984d0bfaf27afa216f5e3d18bd4e983da`. Installed the normal app in place on iPad and iPhone, checked launcher and Settings open/close, and preserved settings/ROM/saves. Both Simulators are shut down. No audio/game behavior change retained; no push.

**Next agent work:** identify the active Simulator output route and compare source PCM with captured output for a specific reported glitch; distinguish OS scheduling from memory faults with an off-CPU trace rather than another reserve increase or speculative shader optimization. Full-story, touch/menu parity and audio acceptance remain open. **Chris:** physical-device touch/controllers/audio routes/long play, plus signing and rights decisions.

## Active audio route and runnable-thread sampling (2026-09-30)

**Route established:** a read-only Core Audio process query reports SquirrelPad's output running on device 117, **MacBook Air Speakers / `BuiltInSpeakerDevice`**, while the iPad game is running (`work/audio-state-route-verified.txt`). This is the process's current output device, rather than the Mac's default or Simulator's recent-device preferences. Jump Desktop Audio is not the output route in this reproduction. `scripts/audio-output-route.swift` retains the small query for repeatable checks: run `swift scripts/audio-output-route.swift` on macOS 14.2+ while game audio is active; an optional exact bundle ID selects another process. It changes no routing settings. Missing-process behavior was checked and exits 1 (`work/audio-route-absent-test.txt`).

**New localization:** a temporary 10 ms watchdog sampled `THREAD_BASIC_INFO` only after an RSP audio task exceeded 30 ms. The startup/game-select run (visually checked, no verified field selection) used executable **`5eae133d8151e2ac28968e19cf66ab3d630a356fe98c1dc40dca47ad06008198`**. At steady-clock 1326524775/4788/4801, the same active audio task had elapsed 37/50/63 ms; all queries succeeded and reported state 1, suspend count 0, and identical cumulative user/system CPU times (3,502,011/146,382 us). At elapsed 122 ms, state was still 1, with CPU times increased by only 306/11 us. The task completed at 1326524862: **124 ms wall / 864 us thread CPU**, followed by a **108 ms PCM submission gap**, with 2,168 queued frames. No underrun was logged in this approximately five-minute run. The reserve covered this particular stall; it is a late-production precursor, not another reproduced silence event. Evidence: `work/audio-state-ipad-run.log` lines 122–127 and viewed `work/evidence/audio-state-game-select.png`.

Apple's [XNU thread implementation](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/kern/thread.c) reports state 1 for `TH_RUN`, which the [thread definition](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/kern/thread.h) defines as running or on the run queue. The sampled thread remained runnable while accumulating almost no CPU time: **scheduling delay is supported for this captured stall**. No sampled uninterruptible wait was seen. Flags were 1; XNU sets that flag when the kernel stack is absent, so this alone is not proof of user-memory swap I/O. In the overlapping one-second VM interval there were only 23 decompressions, zero compressions, zero swap-ins/outs and three page-ins (`work/audio-state-host-memory.jsonl`); it did not repeat the earlier large compression/decompression burst. Host one-minute load during the 178-sample VM capture was about 4.97–6.50. These samples do not exclude an unsampled fault or establish why macOS delayed the runnable thread.

**Profiling limitation:** System Trace and Time Profiler recognized the Simulator PID but remained in startup beyond their 30/10 second recording limits; stopped both owned `xctrace` processes. No usable recording was exported. DTServiceHub logged Processor Trace service/handshake failures (`work/audio-profiler-startup-errors.log`), without proving those messages are the sole cause. A noninteractive kernel fault-tracer check failed because administrator authentication is required (`work/audio-fault-profiler-check.log`). No system security or audio setting changed.

**Conclusion:** actual underruns and inserted silence were established in the prior runs; most long audio-task time occurred off CPU. This new route/state evidence narrows one late-production event to a runnable thread delayed on the Mac, with built-in speakers active. It supports host/Simulator scheduling as a contributor. It does **not** prove that all reported crackle/dialogue glitches have this cause, that port memory/scheduling choices cannot contribute, or that physical iOS audio is correct. More buffering and the previously rejected priority change remain unsupported fixes.

Removed the temporary watchdog/CPU instrumentation, byte-checked `rsp.cpp` against its backup, rebuilt the normal Simulator app successfully, and recovered the exact original executable hash **`89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`**. No trace/input markers remain. iPad normal launcher and Settings open/close were checked, retaining the 116% Control Size. Experimental source is archived only under ignored `work/audio-state-rsp-candidate.cpp`. No game logic or production audio change retained; no push.

The normal app was also reinstalled in place on iPhone; launcher and Settings open/close passed with Control Size still 100%. Its live Core Audio query likewise reports built-in MacBook Air Speakers (`work/audio-normal-iphone-route.txt`); viewed startup capture: `work/evidence/audio-normal-iphone.png`. Both Simulators were shut down after verification. ROM/saves/settings preserved. Remaining agent work includes connecting a captured audible defect to production/output evidence, full-story gameplay and menu/touch parity. Physical audio/routes, touch feel, hardware controllers, long play and signing/rights remain with Chris.

## RSP vector versus scalar task replay (2026-09-30)

**Hypothesis checked:** reported glitches could include incorrect sample values from ARM's `sse2neon` translation, separately from late production. The runtime provides both vector and scalar RSP implementations. Built two isolated ARM64 macOS replay executables with Xcode's Clang, macOS SDK, C++20 and `-O2`; one uses the current ARM vector headers, the other changes only `Accuracy::RSP::{SISD,SIMD}` to select the existing scalar path. Generated Conker audio code is identical. An initial PATH Clang attempt failed to link against the CommandLineTools SDK; the explicit Xcode compiler/SDK builds both succeeded (`work/rsp-parity/build-{neon,scalar}.log`). x86 execution is unavailable here (`arch -x86_64 /usr/bin/uname -m` returned Bad CPU type), so this is not an x86 control claim.

A temporary, environment-enabled capture in `recomp::rsp::run_task` saved OSTask + incoming 4 KiB DMEM + 16 MiB RDRAM before audio tasks **1, 8, 30, 60, 120, 240, 480, 960 and 1440**. iPad capture executable: **`5f4925e5df95bcc5b64f0b0222892c4982e22e381a8fe5d90dbed7f1614fcbc1`**, `work/rsp-parity/ipad-run.log`; all nine writes succeeded. Private snapshots and outputs are only under ignored `work/rsp-parity/` (and temporary Simulator files), never staged. The capture's screenshot was taken after termination and shows Home, so there is no scene/fidelity acceptance claim from it.

**Pass, limited replay parity:** all 18 replay invocations exited zero (`RspExitReason::Broke`), and the resulting entire 4 KiB DMEM + 16 MiB RDRAM outputs match byte for byte for all nine identical input snapshots. Tasks 1/8/60/240 changed no RAM bytes and are weak coverage by themselves. Task 480 changed **16,787 RAM bytes** and executed both overlay permutations once; task 960 changed **12,310**, and task 1440 changed **13,710**. Overlay B at text offset 0xF70 is identified in upstream `recomp/audio_ucode.toml` as probably the MP3 decoder; observed coverage confirms overlay B executed, not every voice/MP3 route. Detailed input/output hashes, changed-byte counts and overlay counts: `work/rsp-parity/results.json`. Harness/coverage source and copied headers: `work/rsp-parity/{replay.cpp,audio-coverage.cpp,neon/,scalar/}`. Replay command per fixture: `work/rsp-parity/replay-{neon,scalar} work/rsp-parity/task-N.bin work/rsp-parity/task-N-{neon,scalar}.out`.

This does not show a vector/scalar sample divergence in the captured corpus. **No scalar rewrite retained.** Snapshots are not atomic whole-machine states, the replay uses macOS `-O2`, and output is not compared to a simultaneously captured live iOS result or judged by listening. Therefore this does not pass all music/effects/dialogue fidelity, exclude an iOS compiler-specific issue, or explain all audible glitches. Next audio check should correlate live produced/output samples for a particular defect; do not keep rerunning quiet counters or claim all glitches are scheduling solely from this result.

Restored `librecomp/src/rsp.cpp` byte for byte, rebuilt normal Simulator app, verified no capture markers, and recovered executable **`89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`**. Installed in place on iPad; ordinary launcher and Settings open/close passed, preserving 116% Control Size. The unchanged installed iPhone executable has the same hash; no iPhone gameplay rerun in this focused experiment. Both Simulators shut down. Game logic and production audio unchanged, private ROM/saves/settings preserved, no push. Audio acceptance, menu/touch parity and full-story progression remain open agent work. Physical audio routes/listening, touch/controllers/long play and signing/rights remain with Chris.

## Live iOS RSP writes versus replay (2026-09-30)

**Pass, limited live decoder parity:** extended the previous isolated vector/scalar check to compare their DMA-write sequences against the **actual iOS Simulator output**. A temporary environment-enabled capture saved incoming OSTask/DMEM/RDRAM and recorded each selected task's DMA write address, length and bytes immediately after the write, before later game activity could overwrite the same region. This checks live iOS compilation against both macOS replay variants rather than comparing only two offline results. The exact capture executable was **`197a2b9aef997f1d8e65a461e5b22de8ec9768ee8367d9e779bbef90daf602f4`**, on iPad iOS 18.5; log `work/rsp-parity/live-ipad-run.log`. Viewed running intro capture: `work/evidence/rsp-live-parity-ipad.png`. These instrumented runs are not a pacing or audible-quality acceptance test.

| Audio task | Live DMA writes | Written bytes | Nonzero bytes | Overlay calls in replay | Live = vector = scalar |
| --- | ---: | ---: | ---: | --- | --- |
| 480 | 353 | 51,744 | 44,417 | main overlay 2, overlay B 2 | Yes |
| 960 | 206 | 40,576 | 32,186 | neither overlay permutation | Yes |
| 1440 | 277 | 47,584 | 35,029 | neither overlay permutation | Yes |

All six replay invocations exited zero, and **836 DMA writes / 139,904 bytes** match exactly, including address/length/order/payload. No live-versus-replay sample divergence was found in these tasks. Private inputs, output streams and hashes: `work/rsp-parity/live-results.json`, `live-task-{480,960,1440}.{bin,live,neon.dma,scalar.dma}`; none are staged. Replay command now includes the DMA stream: `work/rsp-parity/replay-neon work/rsp-parity/live-task-480.bin work/rsp-parity/live-task-480.neon.out work/rsp-parity/live-task-480.neon.dma` (repeat with scalar and the other task numbers). Current harness writes each DMA's little-endian address/length followed by logical N64 byte order. Two snapshots/replays matching each other would have been weaker; this comparison checks the live DMA payload directly. It still covers only three tasks and does not compare downstream AudioQueue/hardware output or establish clean audio throughout the game.

**Next boundary:** keep vector audio unchanged; focus the remaining reported glitches on live PCM submission, AudioQueue pacing and captured output. Scheduling delays are already demonstrated for a late task, but this decoder check does not prove those delays explain every defect. Full audio listening, music/effects/dialogue routes and full-story gameplay remain unpassed.

Removed both temporary runtime/header hooks, byte-checked them against backups, and rebuilt normal Simulator app successfully (`work/rsp-parity/live-normal-build.log`). Original executable hash recovered: **`89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`**; no live-capture symbol/env/log markers remain. Reinstalled in place on iPad and verified normal launcher with Continue Imported ROM available. iPhone's normal app was untouched; no new iPhone gameplay/audio acceptance claim. Both Simulators shut down, private data preserved, no production audio/game change retained and no push. Physical-device audio/routes, touch feel/controllers/long play, signing and rights decisions remain with Chris.

## Live PCM ring-to-AudioQueue sample verification (2026-09-30)

**Pass, bounded sample transport:** temporary instrumentation captured 500,000 accepted source stereo frames beginning with the first nonzero PCM and the actual buffers produced by `fill_buffer`, immediately before their AudioQueue enqueue. Callback instrumentation only copied into bounded preallocated memory (no callback locks/file IO); the producer dumped the frozen capture after both sides finished. Production ring capacity, buffering, timing and game logic were unchanged. The exact diagnostic executable was **`a755097bfaef0ac66ee52152f9ae305bd1f4302c392393ae78ebc7576021bd50`**, used sequentially on iPad then iPhone iOS 18.5. Viewed running captures: `work/evidence/audio-ring-{ipad,iphone}.png`; logs: `work/audio-ring-{ipad,iphone}-run.log`.

An independent offline comparison verifies consecutive read positions (no skipped/reordered/duplicated consumed frames), both channel values after the required source channel swap, signed integer volume scaling toward zero, and zero padding for every unfilled frame. Each output frame is compared against its recorded source position rather than matching two copies of the ring. Results:

| Destination | Compared stereo frames | AudioQueue buffers | Ring wraps | Recorded gain | Nonzero output samples | Mismatches | Inserted zero frames in capture |
| --- | ---: | ---: | ---: | --- | ---: | ---: | ---: |
| iPad | 499,712 | 1,952 | 15 | 256/256 | 998,614 | 0 | 0 |
| iPhone | 499,712 | 1,952 | 15 | 128/256 | 997,861 | 0 | 0 |

The initial consumed offset was 152 source frames on iPad and 112 on iPhone; a chunk straddling the capture's start and the final chunk crossing its bound are excluded. Each compared interval is about 22.7 seconds at 22,020 Hz. No out-of-order read or sample mismatch was found. A negative control flipped one output-sample byte: the verifier reported exactly one mismatch and exited 1 (`work/audio-ring-negative-result.log`). Private PCM, bounded recorder and verifier stay under ignored `work/audio-ring-{ipad,iphone}.bin`, `work/audio-ring-candidate.cpp`, `work/audio-ring-verify.py`; result metadata: `work/audio-ring-{ipad,iphone}-result.json`. Repeat verification with `python3 work/audio-ring-verify.py work/audio-ring-ipad.bin` (or iPhone).

**Limits:** these quiet captured intervals do not overturn the earlier reproduced underruns. The capture checks buffers handed to AudioQueue, not resampled hardware/captured system output, presentation timing or listening quality. It does not pass every music/effect/voice scene. Keep the ring/sample transform unchanged; focus further audio work on demonstrated late production and defects after this handoff. More short quiet runs alone are not acceptance evidence.

The iPhone's original displayed Master Volume was 50% (gain 128). A later slider experiment changed it to 77% after the capture had finished, so **no volume-transition coverage is claimed**. Returned it through a real touch gesture to displayed 50%, and verified that display after normal-app reinstall/relaunch. The restored slider float is 0.5006422 versus the pre-test 0.500542; both map to the same gain 128. Direct AX `setValue` moved the thumb without updating the binding's percentage; a touch gesture applied the change. This is an automation observation, not a demonstrated ordinary-touch slider defect. Control Size stayed 100% on iPhone; iPad settings were not edited.

Removed all temporary ring capture code, byte-checked `mobile_audio.cpp` against its backup, rebuilt normal app successfully (`work/audio-ring-normal-build.log`), and recovered executable **`89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`** with no capture markers. Normal app reinstalled in place on both Simulators; iPhone launcher/Settings open-close and restored 50% Audio setting verified, iPad normal launcher verified. Both shut down. ROM/saves retained, no production audio/game change retained, no push. Next work remains captured downstream audio/late-production diagnosis and the unmet menu/touch/full-story gates. Chris still owns unavailable physical-device audio/routes, touch feel, controllers/long play and signing/rights.

## Audio attribution and paired system-output check (2026-09-30)

**Question:** are the underruns real, and are they caused by the device? Earlier captured underruns explicitly padded unfilled AudioQueue buffers with silence; that is a measured production failure. The sampled 124 ms audio task used only 864 us CPU and remained runnable on the Mac. This supports host scheduling delay for that task; it does not identify the reason for every reported glitch or establish physical iOS behavior. Both Simulator classes share this Mac's output hardware and scheduler, so two Simulator results are not independent physical-device controls.

**New boundary checked:** recorded the actual AudioQueue submission buffers together with lossless ScreenCaptureKit system-mix audio, rather than checking only the app's ring. Reused the bounded memory recorder from the prior entry; exact diagnostic executable **`a755097bfaef0ac66ee52152f9ae305bd1f4302c392393ae78ebc7576021bd50`**. Used iPad Pro 11-inch (M4), then iPhone 16 Pro, iOS 18.5, one booted at a time. No buffering, sample rate, decoder, game logic or scheduler change. Viewed captures `work/evidence/audio-downstream-{ipad-paired,iphone}.png` show opening/game-select animation; no field/story progression claim. Live Core Audio queries again report **MacBook Air Speakers / BuiltInSpeakerDevice** for the app (`work/audio-downstream-{ipad-paired,iphone}-route.txt`).

The first attempt's diagnostic dump failed because reinstalling changed the app-container UUID; discarded it as a paired comparison. That instrumented run logged an underrun and a 413 ms PCM submission gap (`work/audio-downstream-ipad-run.log`). Instrumentation/capture can perturb scheduling, so it is not a clean performance control. Repeated with the current container path. Paired logs: `work/audio-downstream-{ipad-paired,iphone}-run.log`; capture logs alongside them. Both lossless writers finished with status 2, no error and **zero rejected buffers** (2,932 iPad / 2,930 iPhone). The corrected iPad later logged a 95 ms submission gap with 2,288 frames remaining, without an underrun; no underrun was logged in either paired run.

**Pass, limited sequence/timing comparison:** each app capture contains 499,712 stereo frames / 1,952 output buffers / 15 ring wraps, about **22.694 seconds** at 22,020 Hz. The independent source-to-ring check again found zero sample mismatches or injected zero frames. Compared these submitted samples to the recorded 48 kHz system mix using a 1.8 kHz low-pass, 6 kHz analysis grid and normalized correlation of overlapping half-second windows. This intentionally tests sequence/timing, not bit-exact resampling or subjective audio quality.

| Destination | Compared windows | Initial correlation | Minimum window correlation | Largest fitted timing offset |
| --- | ---: | ---: | ---: | ---: |
| iPad | 110 | 0.984 | 0.826 | 3.5 ms |
| iPhone | 110 | 0.989 | 0.895 | 0.5 ms |

No large missing/repeated segment was detected in these windows. Small timing offsets and lower correlations are not a full fidelity pass; narrowband/periodic material can make a fitted lag ambiguous. Fixed an analysis bug that selected numerical FFT noise in silent regions by excluding negligible-energy candidates; values above 1 were invalid and are not retained as evidence. **Negative control:** inserted 50 ms of silence midway through the recorded analysis signal, shifting subsequent audio; the same analysis detected a 50 ms offset and correlation fell to 0.493. Private recordings, comparison code and metadata remain ignored: `work/audio-downstream-{ipad,iphone}-result.json`, `work/audio-downstream-negative-result.json`, `work/audio-downstream-compare.py`, `work/capture-lossless-system-audio.swift`, and `work/evidence/audio-downstream-*.{caf,wav}`. Reproduce with the bundled Python runtime: `python3 work/audio-downstream-compare.py work/audio-downstream-ipad.bin work/evidence/audio-downstream-ipad-paired.wav`; append `negative` for the control. Lossless recorder is the existing capture utility adapted to CAF/float PCM, with rejected-buffer counting.

**Conclusion:** underruns are established, and delayed production on the Mac is supported as a contributor. Captured decoder, ring and now system-mix checks have not found a large transport divergence in their bounded windows. **Audio acceptance remains unresolved.** These results do not prove that every crackle/repetition/voice defect is an underrun, that the port's resource use cannot contribute, or that physical-device output is correct. The next meaningful reproduction needs the reported scene/defect correlated with these boundaries; repeating quiet short windows alone is insufficient. Asked Chris for the scene and whether the defect is crackle, repetition or silence; the answer remains optional input to narrowing the route.

Parked the unfinished six-button controller-binding change in ignored `work/controller-all-bindings.pending.patch` and restored its temporary Start remap through the menu. It had both SDK builds and native mapper checks, but iPhone/persistence/live-remap acceptance was incomplete; no menu feature is committed by this audio investigation. Removed the audio recorder, byte-checked the original backend, rebuilt normal Simulator app successfully (`work/audio-downstream-normal-build.log`), and recovered executable **`89d0333586c6da1618919ac3f9e6df11712844f99d4cdfd1f943ddeabf780c97`** with no ring-capture or Simulator-input markers. Reinstalled normal app in place on both classes; launcher and Settings open/close checked, iPhone 100% Control Size / 50% volume and iPad 116% Control Size retained. Private ROM/saves preserved. No production/game change retained; no push. Chris still owns physical audio/routes, touch feel, hardware controllers, long play and signing/rights decisions.

## Six editable controller bindings and restore (2026-09-30)

**Progress on G4/menu parity:** completed the previously parked change. A/B/Z/Start/L/R now share one typed binding mapper and the existing blue picker-row UI. The original default mapping is retained: A=A, B=B, Z=either LT or RT, Start=Menu, L=LB, R=RB. `LT / RT` is an explicit selectable binding. Existing A/B preferences retain the same storage key; missing/invalid values fall back to the corresponding action's default. Restore Controller Bindings resets all six. Stick, camera and D-pad mappings are unchanged. No game/audio/renderer logic changed.

**Pass:** Release builds for both SDKs (`work/controller-finish-{sim,device}-build.log`), then a normal Simulator rebuild with `SQUIRRELPAD_SIM_INPUT=OFF` (`work/controller-finish-normal-build.log`). Probe executable **`31a10c6dc9723c1ed67b6bf40683b900a43a2b2948d9e683e29d86a82c4f400f`**; normal Simulator executable **`f8129bf7273e0835c2c2364bede3fb7f8b2afb1535cee182692a1498c76ce66e`**; unsigned device executable **`77d08fb77505571dd4e77afded8bf85b1cc13c7f410fd952ac66cd49d3e536bd`**. Device cache has probe OFF. Normal executable contains neither the Simulator input environment marker nor audio-ring capture markers.

**Pass, focused mapping boundary:** native `GCController.withExtendedGamepad()` snapshot check (`work/controller-finish-mapper.log`) covers all six defaults/remaps/reloads, release of the former input, legacy/invalid preferences, both triggers, combined mask, axes/C/D-pad, inactive clearing and restore. Its mapper copy differs from current production source only by importing Combine and exposing `controller`/`sample` for injection; checked the diff. Earlier stick/D-pad test injection was corrected to use the direction-pad's coherent `setValueForXAxis(_:yAxis:)`, without changing production axis code. This is not a physical-controller test.

**Pass, live Simulator route:** iPad Pro 11-inch (M4), then iPhone 16 Pro, iOS 18.5; one booted at a time. Through Settings pickers, changed iPad Start to X and iPhone Start to Y. Terminated/relaunched each app and re-opened bindings: both choices persisted. Followed Continue Imported ROM → GAME1 → PLAY through the virtual controller bridge. Visually verified first field, remapped X/Y opening PAUSED, and A resuming. iPad touch Start also still opened PAUSED and touch A resumed. Restore Controller Bindings reset Start to Menu; pressing the former X/Y input no longer paused either game. Other five actions' remaps are covered by the native boundary test, not a claim of six live hardware actions. Logs: `work/controller-finish-{ipad,iphone}-{run,relaunch}.log`.

**Visual comparison:** viewed `ref/harkinianpad/docs/readme/simulator-settings.jpg` and live candidate menus on both classes. The change extends the reference-style editable blue binding chips to four previously fixed rows; it does not implement multi-bindings, popout, search or complete reference-menu parity. Viewed raw captures: `work/evidence/controller-finish-{ipad,iphone}-persisted.png`, `controller-finish-iphone-normal-lower.png`, and both `controller-finish-*-remap-paused.png`. Targeted accessibility scrolling brought the phone's lower rows and restore action into view. Coordinate-based scroll/drag attempts did not reliably move content; no ordinary-touch scrolling defect was established from them. Physical scroll/touch feel remains open.

Both test remaps were restored before installing the normal build in place. Normal launcher, binding defaults and Settings open/close checked on both. Control Size remains iPad 116% / iPhone 100%; phone Audio remains 50%. Private ROM/saves preserved. Both Simulators shut down. Small local commit only; no push.

**Still open:** audio acceptance/report correlation, complete menu/touch parity, sustained simultaneous touch movement/buttons, meaningful EEPROM checkpoints/lifecycle and full-story progression. Next available Simulator work is the touch/gameplay route beyond the first field and remaining menu gaps, rather than treating this mapper check as product completion. Chris still owns unavailable physical-device touch feel, controllers/rumble, audio routes/listening, long play/performance and signing/rights.

Audio remains visibly open in this input run's diagnostics: the iPad log records two underruns, including a 201 ms submission gap with zero queued frames; iPhone records 174/102 ms submission gaps without a logged underrun. These are probe-build timing observations during the menu/gameplay checks, not evidence that the binding change caused them or a new fidelity pass. No audio fix was made in this change.

## Birdy interaction and longer audio observation (2026-09-30)

**Pass, bounded gameplay progress:** iPad Pro 11-inch (M4), iOS 18.5, probe executable `1a567b64ab33910cabf90128bdee31adb689162f37284b35589ab82254c6ac90`. Continued GAME1 through ordinary movement around the water-side fence into Birdy's plot. Visually observed his dialogue, the context-button lesson, and touch B triggering the beer and helium actions. Movement used the existing Simulator virtual-controller bridge; context B used the visible touch button. No game-state writes or game logic changes. Viewed live captures and raw `work/evidence/birdy-route-ipad-lesson.png` (Conker on the context pad). Other private captures: `birdy-route-ipad-{entrance,dialogue,beer}.png`; their filenames do not establish checkpoint completion.

**Not passed:** leaving the plot, the outside-pad cure, checkpoint reload and full-story progression. Save file changed to SHA-256 `53b01a98e642aa89a4a643232812414c9c7516c4d3d4ed8d88272994247f59a6`, preserved under `work/birdy-route-save-after/`; elapsed-time writes also change saves, so this hash is not proof that story progress persists. Next gameplay action: replay the Birdy route, visually verify the gate/outside context pad and cure, then cold-relaunch the resulting checkpoint. iPhone replay was not run in this cycle.

**Audio remains open:** one underrun then reserve recovery in `work/birdy-route-ipad-run.log`, between display-list reports 66,360/66,420. Earlier 87/81/100 ms submission gaps retained 2,328–2,680 queued frames. Rechecked production `fill_buffer`: underrun means insufficient queued samples during playback, with the missing remainder zero-filled; it does not count authored silence. Recorded 50 seconds of system audio during scene testing, 2,652 accepted buffers / zero rejected / writer error nil (`work/birdy-route-ipad-capture.log`, `work/evidence/birdy-route-ipad-dialogue.caf`). No paired source PCM or exact underrun timestamp was captured, so no sample-boundary attribution or listening pass is claimed. See `AUDIO_DIAGNOSIS.md` for the evidence and Simulator limits.

**Normal build restored:** probe OFF cache, Release build succeeded (`work/birdy-route-normal-{config,build}.log`), executable `f8129bf7273e0835c2c2364bede3fb7f8b2afb1535cee182692a1498c76ce66e`, no `SimulatorInputProbe` symbols. Installed in place on iPad and visually verified normal launcher / Continue Imported ROM. Private data preserved. No production/audio/game code changed; small local evidence commit only, never pushed. Chris still owns physical-device listening/routes, touch feel, controllers and sustained hardware play when devices are available.

## Timestamped audio starvation diagnostics (2026-09-30)

**Progress on audio diagnosis, not an audio fix:** added the latest starvation event's steady-clock timestamp and cumulative inserted silent-frame count to existing underrun/recovery reports. Clock units match PCM submission-gap reports. The total includes missing samples and recovery silence, excluding authored zeros. Reporting remains on the game's queue-depth query; the callback only updates atomic counters and reads the clock on starvation. Reports are snapshots and can aggregate multiple events. Buffer sizes, pacing, generated PCM, gain and game logic are unchanged.

**Pass, exact buffer boundary:** `scripts/verify-audio-events.cpp` includes the actual production implementation and uses a synthetic AudioQueue buffer without starting a device. Authored all-zero PCM produces zero underruns/inserted frames/timestamp; 64 available frames in a 256-frame buffer insert exactly 192 zeros and record a positive timestamp; the next recovery buffer raises the total to 448 without another underrun or consuming input; replenishing the reserve resumes real samples without adding silence; stop clears diagnostics. Command is in `AUDIO_DIAGNOSIS.md`; result `work/audio-event-test.log`. Initial harness compilation used the wrong command-line-tools SDK and was corrected to Xcode's explicit macOS SDK; final check passes without warnings.

**Pass, builds and adjacent regression:** both Release SDK builds succeeded (`work/audio-event-{sim,device}-build.log`), input probe OFF in both caches. Simulator executable SHA-256 `61656792bfbe6fb6d54933338c1b50b56b6c03796dd71cd0eae2aba27e865026`; unsigned device executable `423b8a344192c87c371ebd7ad0321678f800a184b0d4e759797a65d5aae8c870`. Installed in place, iPad then iPhone on iOS 18.5 with one booted at a time. On each, Continue Imported ROM → touch Start → GAME1/PLAY → touch A reached visible first-field gameplay; touch Start paused and touch A resumed. Logs record 22,020 Hz output and consumption of nonzero PCM. Viewed live frames; private raw captures `work/evidence/audio-event-{ipad,iphone}-gameplay.png`. iPhone installed executable hash checked against the build. Both apps terminated and Simulators shut down; private data preserved.

**Not passed:** these short regression windows had no underrun; live reporting of a naturally occurring event in this exact build and paired submitted-PCM/system-output localization remain unverified. This does not reopen a claim that audio is fixed or that the Simulator alone causes the reported glitches. GAME1 elapsed time retained (iPad 0:51:52, phone 0:06:04), but the loaded field does not establish persistence of the Birdy interaction flags. Full-story/checkpoint and physical-device gates remain open. Next meaningful audio action: repeat the failing scene while recording paired PCM/system output, use the new event timestamp and inserted-frame totals to localize the failure, and change only the boundary that fails. Local commit only; no push.


## Rolling audio failure-capture attempt (2026-09-30)

**Pass, capture boundary only:** temporary environment-enabled instrumentation retained raw input and filled AudioQueue buffers in bounded memory, freezing 64 buffers after starvation. Deliberate starvation verified 1,536 inserted zero frames, eight ring wraps and 1,000 output buffers with zero sample mismatches (`work/audio-flight-synthetic-result.json`). This validates the recorder and verifier, not a natural failure cause. No file writes or allocation were added to the callback. Temporary source/tooling remains private under `work/audio-flight-*`.

**Not reproduced:** iPad Pro 11-inch (M4), iOS 18.5, temporary capture/input-probe executable `f50ae45a0f4fc8bd5f7b12716ffdfdcc7b01add458acfb99653c585496f9884d`; game startup 09:06:42 to termination 09:37:21 local. Startup, field/water movement, background/foreground, pause/quit/reload and an outside context-pad action produced no logged underrun, >=80 ms submission gap, callback gap, dropped PCM or stalled queue (`work/audio-flight-ipad-run.log`). Full Birdy dialogue was not repeated. The app's active output was again MacBook Air Speakers (`work/audio-flight-output-route.txt`). No natural event froze the recorder, so there is no paired failure window. System-mix captures of 600/180/600 seconds completed with zero rejected buffers and no writer error; the last spans temporary and restored normal builds. These are not listening-quality passes. Earlier measured queue starvation remains established; this quiet interval neither explains all reported glitches nor proves hardware would eliminate them. See `AUDIO_DIAGNOSIS.md`.

**Gameplay inconclusive:** ordinary movement reached the outside B pad and touch B produced a visible context action. An initial inference of a cure/jump was too strong and was corrected with Chris. No explicit pill sequence or reliable jump/persistence evidence was established on cold relaunch. The private save backup `work/audio-flight-cure-save/conker.n64.us.1.0.bin` has SHA-256 `c6d1086e69e1f4ae63dd996322b7190d2b60c796f95e054cf9db5458adf16458`; its filename and changed hash do not prove a cure or checkpoint because elapsed-time writes also alter saves. The normal jump video/contact sheet does not establish the action. Full progression and distinct checkpoint acceptance stay open. No iPhone gameplay replay in this focused experiment.

**Pass, restoration:** temporary backend removed and byte-checked against the committed source. Normal input-probe-OFF Release Simulator build succeeded (`work/audio-flight-normal-{config,build}.log`), recovering executable SHA-256 `61656792bfbe6fb6d54933338c1b50b56b6c03796dd71cd0eae2aba27e865026`. Installed in place on iPad and followed Continue → Start → GAME1/PLAY → A to visible first-field gameplay; nonzero PCM consumption at 22,020 Hz is logged (`work/audio-flight-normal-relaunch.log`). App terminated and Simulator shut down; private ROM/saves preserved. No production audio/game logic change retained. Local documentation commit only; never pushed.

**Next discriminating check:** capture a naturally failing identified scene with submitted PCM, inserted-silence timestamps and system output in the same window. More quiet runs cannot establish why Chris hears glitches. Physical audio/routes, touch feel, controllers and sustained hardware play remain with Chris when devices are available; available Simulator diagnosis and story/checkpoint work remain agent work.


## Native AudioQueue starvation captured downstream (2026-09-30)

**Progress classification:** the prior goal turn yielded a verified capture attempt and restored normal build, recorded in local `de8e785`; it was progress, not a live wait. This cycle tests the previously unverified ability to locate real inserted silence in simultaneous system output, rather than repeating a quiet game window.

**Pass, induced live failure:** private native macOS harness `work/audio-live-positive.cpp` includes the previously archived temporary recorder/backend (`work/audio-flight-candidate.cpp`). It feeds deterministic low-pass pseudorandom stereo PCM at 22,020 Hz, gain 50%, explicitly requests `BuiltInSpeakerDevice` on its own AudioQueue, and deliberately withholds production for 350 ms after 330 buffers. No host preference, game logic or production source changed. Command: `xcrun --sdk macosx clang++ -std=c++20 -include cassert -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk work/audio-live-positive.cpp -framework AudioToolbox -framework CoreFoundation -o work/audio-live-positive`; launch with `SQUIRRELPAD_AUDIO_FLIGHT=work/audio-live-positive.bin work/audio-live-positive` while `work/capture-lossless-system-audio work/evidence/audio-live-positive.caf 22` is recording. Both processes exited zero. The harness's initial exit condition relied on stop resetting capture state; corrected its private source to retain/check the capture boolean before stop. Actual capture success is independently established by the dump log, file and verifier below.

The observed production gap was 388 ms, queued frames zero, one underrun, and 3,648 inserted silent frames (165.67 ms), including reserve recovery (`work/audio-live-positive-run.log`). Recorder froze after the event and saved 1,000 output buffers, 256,864 raw frames; `work/audio-ring-verify.py` found seven ring wraps and **zero sample mismatches** (`work/audio-live-positive-ring.json`). System capture accepted 1,138 buffers, rejected zero, writer completed without error. Converted losslessly to 16-bit WAV using `afconvert -f WAVE -d LEI16`; initial analysis with system Python failed for missing NumPy, then succeeded with the bundled Python runtime.

**Pass, silence reaches recorded output:** `work/audio-downstream-compare.py` gives initial correlation 0.997873, minimum 0.945914 across 55 windows, maximum fitted timing offset zero (`work/audio-live-positive-output.json`). Separate `work/audio-live-positive-boundary.py` locates the inserted zeros from each output record's copied-frame count, applies the fitted lag and excludes 15 ms at each edge for resampling. The remaining **135.67 ms of recorded output is exactly zero**; preceding/following signal RMS is 0.0381/0.0366 (`work/audio-live-positive-boundary.json`). Thus the test detects a real downstream silent interval caused by intentional producer starvation. This is not a speaker/listening judgment, a natural game reproduction or proof of Simulator/device causation.

**No production change:** normal app/source untouched; Simulators remain shut down, private ROM/saves preserved. Local evidence commit only; no push. Next audio action remains a paired capture of a naturally failing identified game scene using this now-positive-validated method. Full story/checkpoints, menu/touch parity and physical-device gates remain open. Chris still owns unavailable physical audio routes/listening, touch feel, controllers and sustained hardware play.


## Natural rolling starvation capture and Birdy context action (2026-09-30)

**Progress:** the prior turn validated induced starvation against actual system output (`e118be6`). This run captures the first natural rolling sample window. Temporary recorder plus Simulator probe build succeeded (`work/audio-birdy-flight-{config,build}.log`), executable `f50ae45a0f4fc8bd5f7b12716ffdfdcc7b01add458acfb99653c585496f9884d`. iPad Pro 11-inch (M4), iOS 18.5, built-in speaker route confirmed (`work/audio-birdy-flight-route.txt`). Initial launch omitted the probe runtime environment, so its movement command did not apply; corrected with `SIMCTL_CHILD_SQUIRRELPAD_SIM_INPUT=1`. An asynchronous launch helper exited before starting the guest; switched to a retained console session, confirmed `[sim input] connected=true`. The actual probe run is `work/audio-birdy-flight-ipad-probe-run.log`, game startup 10:09:29 local, terminated 10:42:23. No deliberate starvation or game-state writes were used.

**Pass, bounded localization:** natural event at steady-clock 1,344,761,492 ms, followed by 235 ms submission gap / zero queued frames. Rolling dump contains 262,144 raw input frames and 1,000 filled buffers; verifier found eight ring wraps, **zero copied-sample mismatches** and **992 inserted zero frames** (45.05 ms). Event buffer 935 copied 32 / padded 224 frames; buffers 936–938 copied zero / padded 256 each; buffer 939 resumed real PCM. Mean output-fill spacing 11.627 ms versus expected 11.626, maximum 21.455 ms across the window (`work/audio-birdy-flight-{ring,boundary}.json`). This identifies late production for this natural event, rather than a transport-value mismatch or long callback gap. It does not identify why production was delayed or prove a physical-device cause.

**Additional failures:** six further underrun reports clustered in the later Birdy testing sequence, including 326/156 ms submission gaps; final cumulative inserted silence 17,040 frames, including recovery (~774 ms). The rolling recorder had frozen the first event, so it contains no sample window for this later cluster. System recordings completed with zero rejected buffers / no writer errors: 600 seconds, 31,975 buffers (`work/evidence/audio-birdy-flight.caf`), and 90 seconds each, 4,798 / 4,791 buffers (`audio-birdy-flight-{context,dialogue}.caf`). File times and event-clock mapping establish that they missed the exact natural event intervals; do not claim paired downstream localization. Capture/video sessions completed, and console session exited zero after app termination. A later host load/VM snapshot is not event-time evidence.

**Gameplay, limited:** GAME1 → PLAY, field/water movement and C-Up/side camera actions were viewed. Eventually followed the visible open gate into Birdy's plot and placed Conker on his pad; touch B visibly triggered the beer scene. Several earlier pad/action attempts did not establish a context action and do not prove an input defect. Neither full lesson replay, the cure sequence, jump persistence nor a new distinct checkpoint was verified. Viewed live screenshots; private video `work/evidence/audio-birdy-flight-context.mov` was finalized, but is not a frame-by-frame jump acceptance result. Route guidance consulted [GameFAQs Hungover walkthrough](https://gamefaqs.gamespot.com/n64/196973-conkers-bad-fur-day/faqs/59267); its instructions are route guidance, not evidence that this app completed them.

**Restored:** production backend byte-restored, probe OFF, normal Release build succeeded (`work/audio-birdy-flight-normal-{config,build}.log`); no probe/flight symbols remain. Rebuilt binary SHA `aa48dba71d0331dc2c905a054cf5b85aec527a7b41bd57584b8cb484a0f9ab19` differs from prior normal binary despite identical source/size. Comparison found UUID/signature differences plus 61 bytes in linker stubs; a UUID/signature-only equality assertion failed, so no byte-identical rebuild claim. To restore the exact known app, copied the preserved normal iPhone bundle to private `work/audio-birdy-normal-original.app` and installed it in place on iPad, recovering installed executable SHA `61656792bfbe6fb6d54933338c1b50b56b6c03796dd71cd0eae2aba27e865026`. No app data was copied or erased. Launcher / Continue Imported ROM visually checked; terminated and shut down iPad. Phone app unchanged; no phone gameplay replay or new device SDK build. Private ROM/saves/settings preserved. No production/game/audio change retained; local evidence commit only, never pushed.

**Next:** continuous system-output capture spanning the identified scene, with safe repeated capture of natural starvation windows; then repair only a measured failing boundary. Audio fidelity, story/checkpoints, menu/touch parity and hardware gates remain open. Chris still owns unavailable physical audio/routes/listening, touch feel, controllers and sustained hardware play.


## Repeated audio recorder and continuous game capture (2026-09-30)

**Progress, no audio fix:** private recorder safely rearms after each producer-side
dump, with callback-owned counter reset and numbered files. Two-event synthetic
and three-event clustered checks pass with zero copied-sample mismatches. Actual
native AudioQueue positive control pauses production twice for 350 ms: two events,
11,648 total inserted zeros, split 3,904/7,744 across two valid captures. The final
log's obsolete `capture=0` field reports the reset dump flag; serial/files and exit
assertion establish two captures, and the private harness print was corrected.
Paired system recording: 2,044 accepted buffers, zero rejected, writer completed
without error. Raw-to-filled PCM matches exactly; downstream correlation minima
0.9283/0.9300, maximum fitted offsets 0.167/0 ms. Silence centers excluding 15 ms
edges: 147.29/321.67 ms exact zeros, with nonzero adjacent RMS. These deliberately
induced native failures validate repeated measurement, not natural causation.
Evidence: `work/audio-repeat-live-{1,2}-{output,boundary}.json` and numbered `.bin`
files; `work/evidence/audio-repeat-live.{caf,wav}`. Initial synthetic stimulus did
not exhaust the recovered reserve a second time; extended withholding corrected
the test. No production change followed from that test correction.

**Not reproduced, continuous natural test:** temporary capture/input-probe Release
build succeeded, executable SHA-256
`d3173a7122fa514cb803bbdcc156fca5decf4b89c95f2097171d837d7925d67e`.
iPad Pro 11-inch M4 / iOS 18.5; retained console from 11:09:37 to 11:19:45 local.
Continue Imported ROM → touch Start → GAME1/PLAY → first field, ordinary movement
and camera/buttons to Birdy's plot/pad were viewed. Full lesson/beer scene not
established by these frames; no new cure/checkpoint claim. No logged underrun,
>=80 ms submission gap, callback gap, dropped PCM or stalled queue; no numbered
natural dump. System capture started before launch and stopped on request at
~610 seconds, rather than its 1,800-second cap: 30,558 accepted buffers, zero
rejected, writer status completed / nil error (`work/audio-repeat-game-capture.log`).
Actual output MacBook Air Speakers (`work/audio-repeat-game-route.txt`); route
query emitted the existing Swift CFString pointer warning but returned the app's
active output. Private screenshot `work/evidence/audio-repeat-game-birdy.png`
and viewed live frames establish only the route shown. Quiet interval does not
invalidate previous natural starvation or pass listening quality.

**Restored:** backend byte-equal to HEAD; normal probe-OFF Release build succeeded
(`work/audio-repeat-normal-{config,build}.log`). Installed preserved exact normal
bundle in place, verified installed executable SHA
`61656792bfbe6fb6d54933338c1b50b56b6c03796dd71cd0eae2aba27e865026`;
viewed launcher / Continue Imported ROM, terminated and shut down iPad. All capture,
console and build sessions completed. Phone unchanged; no new phone or device SDK
acceptance claim. Private ROM/saves/settings preserved. Local evidence commit only,
never pushed. Full story, checkpoint, menu/touch fidelity and hardware gates stay open.

**Conclusion:** measured natural underruns are real late-production holes. Prior
thread evidence supports host scheduling as a contributor, not a complete device
attribution. This turn proves repeated paired failure measurement works; it does
not prove that all Chris's glitches are underruns or that real hardware cures them.
Next: capture a natural failure with continuous downstream output plus event-time
producer state, then repair only the failing boundary. Chris still owns physical
listening/routes, touch feel, controllers and sustained hardware play when available.


## Combined producer and output capture; process telemetry (2026-09-30)

**Progress:** the previous turn verified repeated paired starvation capture.
This turn combined that private backend recorder with the existing RSP wall/CPU
and Mach thread-state tracer. Temporary probe-ON Release build succeeded,
SHA-256 `86802cb5850b341f6101fe0f1a15bb2c17fca5ad54f20cd21b089ca276fff4c2`.
iPad M4 / iOS 18.5, retained console 11:35:58–11:48:03 local; Continue ROM,
GAME1/PLAY and first-field/camera/analog movement viewed. No logged underrun,
>=80 ms submission gap, >=20 ms RSP task or >=30 ms sampled active task; no
natural numbered PCM dump. Continuous system recording accepted 36,416 buffers,
rejected zero and completed without error on stop-file request. Active app output
was MacBook Air Speakers. This quiet ~12-minute run does not identify the natural
failure cause or establish dialogue/story progress. Private evidence:
`work/audio-combined-{run,capture}.log`, `work/evidence/audio-combined.caf`.

**Pass, new read-only diagnostic:** added `scripts/audio-process-watch.cpp`.
The prototype sampled exact game PID 43895 for 119.959 seconds: 591 samples,
flags consistently `0x1404030`, zero page-in delta, 328,005 fault delta.
No failure occurred in that sampled window; neither flags nor process-wide
faults establish causation. Initial prototype CPU fields labeled ns held raw
Mach ticks. Checked XNU's implementation and corrected the committed sampler's
conversion through `mach_timebase_info`; the old private JSON CPU fields need
conversion before use. Busy-process check measured 0.819 CPU seconds within a
1.285-second parent CPU interval (sample endpoints cover less than the full
interval), rejecting the unconverted tick scale. Missing args return 2, absent
PID returns 1; bounded live sampling returns 0. Compile with `-Wall -Wextra`
was clean. Evidence: `work/audio-combined-process.jsonl`,
`work/audio-process-watch-final-test.log`. No sampling is added to game callbacks.

**macOS control remains incomplete:** current replay Metal host ran 180 seconds,
10,784 VIs, exit 0 (`work/audio-native-control-new.log`). Raw CLI executable
could not be selected by Computer Use; a private bundle carrying the current
binary still timed out on window inspection. Its `open -W` session completed,
and no Conker process remained. These results are not visual/audio/input parity.

**Restored:** backend byte-restored to HEAD; external runtime RSP source restored
to its pre-experiment bytes; probe OFF normal Release build passed
(`work/audio-combined-normal-{config,build}.log`). Installed preserved exact
normal app in place, executable `61656792bfbe6fb6d54933338c1b50b56b6c03796dd71cd0eae2aba27e865026`,
viewed launcher / Continue Imported ROM, terminated and shut down iPad. All
sessions terminal; phone unchanged. No game, buffer, priority or routing change;
private data preserved. Local commit only, no push. Next audio measurement must
capture a natural event with producer state, process telemetry and continuous
output together. Full story/menu/checkpoint and hardware gates remain open;
Chris still owns physical audio/routes, touch feel, controllers and long play.


### 2026-09-30 — stop repetitive audio investigation after Chris's correction

**Priority change:** Chris questioned whether the intermittent measured underruns
represent a meaningful audible problem and called out two days of repeated loops.
The measurements establish sample starvation in some intervals; they do not
establish his symptom or a physical-device cure. Stop routine quiet captures and
speculative audio tuning. Next work is ordinary gameplay and reference-menu
fidelity. Reopen audio diagnosis for a specific reproducible audible defect.
Audio acceptance remains **unverified**, and the full G0–G8 objective stays open.

**Stopped/restored:** the temporary combined trace was terminated. Its SCK capture
reached its 1,200-second limit (60,027 accepted buffers, zero rejected, writer
completed without error); process telemetry also reached its 1,200-second limit.
The app outlived those bounded captures while awaiting user input, so they do not
cover its later events. The console has 86/96 ms submission gaps with queued
reserve and no logged underrun. Only GAME1 selection was visibly inspected; this
is not a gameplay or listening-quality pass. Private evidence is
`work/audio-cause2-{run,capture}.log` and `work/audio-cause2-process.jsonl`.

Production audio and RSP sources were restored byte-for-byte. Probe-OFF Release
build passed (`work/audio-cause2-normal-build.log`). Installed the preserved normal
bundle in place on iPad M4 / iOS 18.5; executable SHA-256
`61656792bfbe6fb6d54933338c1b50b56b6c03796dd71cd0eae2aba27e865026`.
The ordinary launcher and Continue Imported ROM were inspected. No audio behavior
change retained, no private data reset, and no push.


### 2026-09-30 — allow removing a controller binding

**Pass, narrow reference behavior:** the reference Settings screenshot
(`ref/harkinianpad/docs/readme/simulator-settings.jpg`) offers binding removal.
Added **Unbound** to the six gamepad binding pickers. It emits no button and
uses the existing persistence/reset path; game logic, touch mapping, controller
axes and audio are unchanged. This is single-binding removal, not the reference's
multiple bindings or complete menu parity.

Release Simulator and unsigned device builds passed:
`work/menu-unbound-{sim,device}-build.log`. Simulator executable SHA-256
`1f8a3e154f83289fa2858bb802604b9200efa9c7e8b57c14ac26fce9f443fd1d`;
unsigned device `01af861e1fab22726d1737671e48367d890b0007575f1b594e6a88559664442e`.
Probe stays OFF. A current-source native GameController snapshot test checks all
six actions: unbinding releases an already held action, persists on reload, and
restore emits the held default again. Existing remap, two-trigger, combined mask,
axis/C/D-pad and inactive-clear checks also passed
(`work/menu-unbound-mapper.log`). Test copy only imports Combine and exposes
controller/sample for injection; this is no physical-controller acceptance.

Installed the same app in place on iPad M4, then iPhone 16 Pro, iOS 18.5, one
Simulator at a time. Each ordinary menu selected Z → Unbound, then retained it
after termination/relaunch. Inspected live and raw screenshots against the
reference: `work/evidence/menu-unbound-{ipad,iphone}-persisted.png`. Compact
scrolling reached the Z row and its picker; the longer label fit. Restored each
Z binding to its original LT / RT through the picker. iPhone Audio retained 50%
volume and X returned to the launcher. iPad Continue started the game core;
Settings hid the complete touch overlay and X restored all 14 buttons plus stick.
This turn does not claim a first-field or full-game route. Both apps terminated
and Simulators shut down; ROM/saves and other settings preserved.

**Still open:** full story/checkpoint routes, macOS visible control, wider menu
fidelity and physical acceptance. Next work is ordinary gameplay progression;
no routine audio investigation without a reproducible audible defect. Chris
still owns hardware touch feel, controllers, listening/routes and long play
when devices are available. Local commit only; never push.


### 2026-09-30 — fix macOS AppKit / SDL initialization order

**Pass, reproduced boundary:** native Conker's CUA window inspection repeatedly
timed out (-10005), despite a live process. A read-only process sample
(`work/macos-window-control-sample.txt`) found the main thread in
`recomp::start`'s sleep/update loop. A minimal SDL window was inspectable, including
a 1600×900 resizable Metal window. Adding `[NSApplication sharedApplication]`
before SDL initialization reproduced the timeout in that minimal app. This
local test used installed SDL2-compat 2.32.70 on macOS 27.0 / Apple M1. The first
standalone compile picked the incompatible command-line-tools 27.0 SDK; explicit
Xcode macOS 26.5 SDK compilation succeeded. Private reproductions:
`work/sdl-window-check.cpp`, `work/sdl-nfd-window-check.mm`.

Conker initializes its native file dialog before SDL; on macOS that calls the
same AppKit method. Added `patches/conker-macos-window-init.patch` and its source
replay entry: macOS initializes the file dialog immediately after SDL video
initialization. Other platforms retain their original order. No generated game
code, renderer, mobile input or audio behavior changed. Replaying the patch on
pre-change file copies matched both current host files byte-for-byte; reverse
apply check also passed.

**Pass, actual window:** `cmake --build work/source-replay/host/build-macos-metal
-j 4` completed (`work/macos-window-init-build.log`). Native executable SHA-256
`b29abfae13b01b0a8cca9cf51aeb2dd1b2271cc93c9f1d829f91beee63b795fc`.
Copied it into the existing private control bundle and launched with the verified
private ROM and `--seconds 600`; retained open session exited zero. CUA now read
the native window immediately. Live screenshots in this turn showed the moving
N64 intro, GAME1 file-select scene, and native General settings; Escape opened
and closed Settings. Closed the native window through CUA; process is terminal.
The old build's inspection timed out on the same machine/bundle before replacement.

**Not passed:** Space taps, including repeated taps, did not select GAME1. The
Controls-tab coordinate click also did not change tabs. These observations do not
identify a game-core defect or prove ordinary macOS input to gameplay. Next check
the native input/profile boundary now that its window is visible; keep G1 open.
No listening-quality or save/relaunch control claimed.

**Adjacent build pass:** normal probe-OFF Simulator and unsigned device builds
passed (`work/macos-window-init-{sim,device}-build.log`). Simulator executable
`6f57ea000511e08fea591fff9117780d1fdc9ae2ae1476caca79689dd58b652e`;
device `01af861e1fab22726d1737671e48367d890b0007575f1b594e6a88559664442e`
(unchanged from the binding-removal build). No Simulator installed/launched this
turn; both remain shut down with private data preserved. Full gameplay/menu and
hardware gates remain open. Local commit only; never push.


### 2026-09-30 — narrow native keyboard selection failure

**Progress, diagnosis only:** started the inspectable native control from the
previous startup fix. A temporary host-only trace logged Space/Enter state
transitions after SDL event handling and changes in the existing N64 input
callback. Through CUA, Return produced N64 mask 0x1000 then release, with game
input enabled. Space taps, including a 30-tap attempt, produced no recorded
0x8000 A mask (`work/macos-input-trace-run.log`). The traced process completed
its 180-second limit, 9,667 VIs, exit zero. This does not establish whether
Space is unbound or its brief state missed the polling window. No first-field
or ordinary gameplay acceptance claimed.

A separate minimal SDL event test received CUA Space, Return and X as SDL
scancodes 44, 40 and 27 (`work/sdl-key-delivery.log`). Thus the UI tool can deliver
Space to SDL; next inspect the actual loaded profile and compare event timing
with N64 polling, rather than changing the game. Capitalized `Space` was rejected
by CUA and a blank key was rejected; those invalid calls are not key-delivery
evidence. The baseline window was closed early and its test PID explicitly
terminated while its --seconds timer remained alive; no save state was reset.

**Restored:** host frontend byte-restored; an initial Ninja no-op was caught
because restoring the backup timestamp left a newer object file. Invalidated the
frontend object via source timestamp, rebuilt it and relinked successfully
(`work/macos-input-normal-build.log`), then independently verified the executable
contains no `[native input]` marker. Updated the private native control bundle
with that normal executable. All test processes terminal, Simulators shut down;
mobile app/code and private ROM/saves untouched. No permanent input/game/audio
behavior change, no push. G1 and full G6 remain open.


### 2026-09-30 — distinguish native key taps from game input faults

**Progress:** previous conversational audio-status reply changed no authoritative
state. Revalidated the next native input check rather than repeating audio work.
Both the default and test-profile paths were inspected without changing private
preferences: default has no controls file and uses defaults; the test profile
assigns Space (44) to A and Return (40) to Start. A temporary SDL-event trace with
explicit `CONKER_TEST_PROFILE=1` confirmed the actual loaded bindings. CUA emitted
key-down/up pairs with identical SDL timestamps; both keys already reported state
zero when handling those events (`work/native-key-timing-run.log`). Thus brief
automated taps can miss game polling; no production keyboard or game change is
justified by this test. The bounded host exited zero at 180 seconds, 10,169 VIs.
No ordinary macOS gameplay or save-control pass claimed.

Restored both host/frontend and RecompFrontend/input-events sources from exact
backups, rebuilt after invalidating source timestamps, and independently checked
the rebuilt executable contains no `[key timing]` marker
(`work/native-key-timing-restored-build.log`). Updated the private control bundle
with the normal executable. Native process terminal; no audio tuning.

The existing normal mobile build `1f8a3e154f83289fa2858bb802604b9200efa9c7e8b57c14ac26fce9f443fd1d`
was launched in place on iPad M4 / iOS 18.5. Continue Imported ROM and touch
Start/A reached GAME1, PLAY and the first field. Viewed raw capture:
`work/evidence/ordinary-touch-ipad-field.png`. Brief CUA stick drags did not
establish further story progression; no Birdy interaction, new checkpoint or
full-story pass claimed. Terminated the app without erasing private data.


### 2026-09-30 — removable binding chips and compact section reveal

**Pass, small menu improvement:** compared the live menu and raw Simulator
captures with `ref/harkinianpad/docs/readme/simulator-settings.jpg`. Each of the
six editable controller binding chips now has a labeled × removal action with a
44-point target. It uses the existing `setBinding(.unbound, for:)` path; the
button disappears when unbound and returns when reassigned. No game, touch
mixer, controller mapper or audio change. This closes the extra-picker-step
difference for removing a single binding; multiple bindings, other reference
settings and full menu parity are still open.

The first iPhone candidate left the first binding at the bottom edge when
expanding the group. Added a compact-only ScrollViewReader reveal of the group
heading on expansion. Final screenshots show the heading and first binding rows
in the iPhone viewport; iPad keeps its previous expansion position. This verifies
automatic reveal, not manual touch-scroll feel or physical usability.

**Final exact builds:** Simulator and unsigned device Release builds both exited
zero (`work/menu-remove-chip-final-{sim,device}-build.log`). Executable SHA-256:
Simulator `f33ebdfc39bd39f392b7778ee93f81e0dd4a282fb694e52807cd2348dabf2598`;
device `7d6cd937ebf45d0a329964a5a0909da208dcd586958290bd8f2302379d243941`.
No physical install, source replay or package-completion claim.

Installed this same normal probe-OFF Simulator app in place, one destination at
a time, on iPhone 16 Pro / iOS 18.5 and iPad M4 / iOS 18.5. On each, tapped
Remove A binding, terminated and relaunched, reopened Controller Bindings and
verified A remained Unbound with no remove action. Restored A via its Picker
and verified the A chip and removal action returned. Existing iPad 116% and
iPhone 100% control sizes remained. Private ROM/save data and other bindings
were preserved; no blanket reset or container erase. Viewed raw captures:
`work/evidence/menu-remove-chip-final-ipad-persisted.png`,
`work/evidence/menu-remove-chip-final-iphone-persisted.png`,
`work/evidence/menu-remove-chip-final-iphone-restored.png`.

Next product work remains story progression and checkpoint/relaunch fidelity,
plus the remaining reference-menu gaps. Do not turn this focused menu pass into
full G4/G5/G6 acceptance. Chris still owns physical touch feel, controllers, audio
routes/listening, sleep/interruptions and sustained-device play when hardware is
available. Audio diagnosis remains deferred per his direction.

Adjacent UI regression checks passed on the final build: after expanding
bindings, Audio displayed its full pane on both classes (iPad volume 100%,
iPhone volume 50%, unchanged). Close returned to the launcher on both. These
were UI checks, with no audio recording/tuning or listening-quality claim. All
native/build/launch sessions are terminal; both Simulators shut down.

### 2026-09-30 — audio priority correction and bounded route attempt

Chris questioned the prolonged audio investigation. Audio remains unverified;
diagnostic starvation events have not established his audible symptom or a
Simulator-only cause. No further audio tuning or recording is justified without
a specific reproducible audible defect. This is not an audio acceptance pass.

An opt-in Simulator controller probe reached the outside Birdy context pad on
iPad M4 / iOS 18.5. B presses did not establish a visible cure sequence or a new
checkpoint. A gameplay video was captured, but no reviewed jump or save/relaunch
pass is claimed. This diagnostic route does not satisfy ordinary-touch or story
acceptance. Private save data was preserved; no fixture reset or game-logic
change was made. Restored `SQUIRRELPAD_SIM_INPUT=OFF`, rebuilt successfully
(`work/checkpoint-normal-restore-build.log`) and installed the normal app in
place. Executable SHA-256 matches the verified menu build:
`f33ebdfc39bd39f392b7778ee93f81e0dd4a282fb694e52807cd2348dabf2598`.
Launch session is terminal and the iPad Simulator is shut down. Continue ordinary
gameplay and reference-menu work; no production code changed in this attempt.

### 2026-09-30 — visible controls while editing; opacity relaunch check

**Pass, narrow reference behavior:** HarkinianPad's
`docs/customizable-touch-controls.md` and
`patches/shipwright-ios-touch-control-transparency.patch` restore visible controls
to full opacity while editing, without changing the stored gameplay opacity.
Reproduced SquirrelPad's mismatch on iPad: at 25%, the editor's controls were
also faded. Changed only the overlay opacity expression to use 100% while
`editingLayout` is true. No input mappings, game logic, audio or saved-value
writes changed.

**Pass, exact builds:** Simulator and unsigned device Release builds exited zero
(`work/editor-opacity-{sim,device}-build.log`); both caches have
`SQUIRRELPAD_SIM_INPUT=OFF`. Executable SHA-256:
Simulator `b51a9e38ec9a938f52e80bdd4c517673383dd8bd655b44c35635b342ace4fbb4`;
device `d3e1aa5da1a2e55cb82de3e17fbd6ff494fb94cb334c3cc5cb9e3de1b24c53fe`.
Installed in place, one destination at a time, on iPad M4 and iPhone 16 Pro,
both iOS 18.5. Started through Continue Imported ROM, changed Control Opacity
to approximately 25% through the slider, and opened Edit Layout. Visually
inspected full-strength labels, outlines and stick; Done restored the faded
overlay and independent menu button. Compared these screenshots with the
reference's documented editor-opacity behavior and corresponding patch.
This is not an exact-artwork or complete editor-parity pass.

**Pass, persistence:** terminated and relaunched each app; Controls still showed
25%. The editor had not overwritten the saved preference. Viewed captures and
saved raw images under `work/evidence/editor-opacity-`: `ipad-before.png`,
`{ipad,iphone}-after.png`, `{ipad,iphone}-done.png`, and
`{ipad,iphone}-persisted.png`. AX `setValue` alone moved the slider thumb without
updating the SwiftUI value; actual touch adjustment and the displayed percentage
were required for this check. Do not treat thumb position alone as persistence
evidence.

Restored opacity 100% and transparency off through the UI. After termination,
iPad preferences exactly matched its pre-test backup. iPhone preferences matched
apart from an explicit empty `LayoutPhone` override written by Done (same default
positions). Existing control sizes (iPad 116%, phone 100%), controller mappings,
volume and private data were preserved. Audio pane displayed normally on both;
no audio listening/recording/tuning was performed. Both Simulators shut down.

**Not run/open:** full story, meaningful checkpoint/relaunch fidelity, complete
reference editor/menu parity and physical acceptance. Next reference work:
compare selected-control feedback and individual size/visibility editing with
the reference; keep gameplay progression and save acceptance open. Chris still
owns physical touch feel, controllers, audio routes/listening and long play.


### 2026-09-30 — touch editor selection and tap-position protection

**Pass, narrow reference behavior:** compared the local HarkinianPad
`docs/customizable-touch-controls.md` and selection implementation in
`patches/shipwright-ios-customizable-touch-controls.patch`. The reference names
and highlights the selected control. SquirrelPad now shows an amber outline,
selected accessibility trait, and control name with a drag instruction. Reset,
Done, and a new editing session clear selection. This uses an outline instead
of the reference's glow; complete artwork/editor parity is not claimed.

**Fix:** a tap previously wrote its endpoint as a new control center. Editing
now selects on touch and moves only after more than two points of drag travel.
An off-center tap leaves the control in place. Gameplay button masks, stick
axes, runtime and game logic are unchanged.

**Pass, builds:** Simulator and unsigned device Release builds exited zero,
`work/editor-selection-{sim,device}-build.log`; both caches remain
`SQUIRRELPAD_SIM_INPUT=OFF`. Executable SHA-256:
Simulator `eab1c1a08e141851d2dc8894d097255df0059135be175839926b3251048d63f6`;
device `c08e3f05ed9c5687ec3763866fba6a65303b6df23fa5f135af6735bc46f8f8e5`.

**Pass, viewed integration:** installed in place on iPad M4, then iPhone 16 Pro,
both iOS 18.5, one Simulator at a time. Continue Imported ROM → three-dot menu
→ Controls → Edit Layout. Selected A and Control Stick, inspected the amber
outline and readable header, tapped A off-center without displacement, dragged
A visibly, then Reset restored its default position and cleared selection.
Selected A with another off-center tap and Done restored the ordinary overlay
and permanent menu with no selection highlight. Normal A opened the game slot
preview and B returned on both destinations. A stale iPhone AX target caused
no-op attempts; a fresh full accessibility tree resolved them. This is not a
new game-input defect or a full gameplay/multitouch acceptance pass.

Before/after and regression captures were visually inspected through Simulator
and saved under ignored `work/evidence/editor-selection-`: `{ipad,iphone}-before.png`,
`{ipad,iphone}-A.png`, `ipad-drag.png`, `iphone-stick.png`, and
`{ipad,iphone}-normal-input.png`. Preference backups are
`work/editor-selection-{ipad,iphone}-preferences-before.plist`. After Reset,
selection-only taps, Done and termination, both complete preference dictionaries
exactly matched their backups. No private ROM/save reset, mappings or volume
change. Both Simulators are shut down. Local commit only; never pushed.

**Open:** individual control resizing/visibility and Z latch remain reference
gaps; full story and meaningful checkpoint/relaunch acceptance remain open.
Next UI step is per-control 70–150% resizing with separate phone/tablet storage,
without replacing existing position profiles. Audio investigation stays deferred;
no recordings/tuning were performed. Chris still owns physical touch feel,
controller hardware, audio routes/listening and long play.

### 2026-09-30 — individual touch-control size and persistence

**Pass, narrow reference behavior:** compared HarkinianPad's local customizable
controls documentation and patch. The selected button or stick now has a
70–150% Size slider, applied on top of the existing global size. Selection is
required; selecting another control displays that control's own size. Phone
and tablet sizes use separate persisted dictionaries without changing position
profiles. Reset Layout clears positions and individual sizes; Restore Defaults
also clears both size profiles. Gameplay input, runtime and game logic unchanged.
The percentage has sufficient width to stay on one line. Complete reference
artwork, visibility editing and three-dot menu parity remain open.

**Pass, builds:** Simulator and unsigned device Release builds exited zero;
`work/editor-size-{sim,device}-build.log`. Input probe remains OFF. SHA-256:
Simulator `c6edcad86ecf30d063a6a04b051eeb1aee099d9a0aac690dd386b7184fba28f3`;
device `c10b8d19fc32d9d7bfc8db44f74397224cd0635f3a089aac95615c027107bdc8`.
Final installed executables on both Simulators match the Simulator hash.

**Pass, viewed integration:** iPad M4 and iPhone 16 Pro, iOS 18.5, one at a time.
Actual slider touches visibly resized A to 70% and 150%; B retained 100%.
Done, app termination, cold relaunch and reopening the editor restored iPad A
at 70% and iPhone A at 150%, matching saved preferences and rendered sizes.
On iPhone, enlarged A opened the game-slot preview and B returned. This is
menu input acceptance, not full gameplay acceptance. Raw Simulator captures:
`work/evidence/editor-size-ipad-persisted-70.png`,
`work/evidence/editor-size-iphone-persisted-150.png`, plus range/input captures
under that same prefix. No running-reference screenshot comparison is claimed.

**Evidence correction:** a desktop capture appeared to omit A's label. Raw
Simulator screenshots of the original accepted build show the label present.
Speculative label-rendering changes were reverted; no app defect established.
AX thumb movement alone also did not update slider state: actual touch,
displayed percentage, saved preferences and relaunch were required evidence.

Reset and Done restored original settings on both. Complete preference
comparisons differ only by a new empty size dictionary for each device class.
ROM, saves, mappings, global size and volume preserved. Final normal build
restored on iPhone; both Simulators shut down. Local commit only, never pushed.

**Open:** full story progression, meaningful checkpoint/relaunch fidelity,
macOS ordinary-play/save control, remaining reference menu/editor gaps and
physical acceptance. Audio counters have not established a repeatable audible
ordinary-play defect or its cause. Audio experiments remain deferred; no audio
tuning or recordings in this step. Chris retains physical touch feel,
controller hardware, audio routes/listening and long play.
