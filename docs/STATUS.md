# SquirrelPad evidence ledger

Updated 2026-10-02. Work the lowest unmet goal in [GOAL_LOOP.md](GOAL_LOOP.md). The private ROM, generated game code, builds, logs, saves and gameplay captures stay under ignored `ref/` or `work/`.

**Current continuation:** preserved iPad 18.5 `605FB671…` GAME2 completed
Birdy's lesson, beer and cure in-session, then saved through the game's Quit
flow. Cold reload retained PLAY / $0 / 0:57:01 and upright Conker with sleeping
Birdy (diagnostic controller build). GAME1 retains $0 / 0:48:50. Continue
GAME2 toward the river and the next actual checkpoint; preserve both slots
and never select ERASE. Normal build is restored; both Simulators are off.

| Gate | State | Measured result and remaining test |
| --- | --- | --- |
| G0 pinned inputs | Pass for source inputs | `sources.lock.json` pins Conker and its submodules. A fresh ignored checkout replayed every patch and regenerated 127 game files byte-for-byte identical to the existing output from the verified private US ROM. `docs/SOURCE_BOUNDARY.md` inventories the source/licensing boundary; independent tool/renderer builds and package audit remain G8. |
| G1 macOS control | In progress | ARM64 N64RecompCLI/RSPRecomp/RecompModTool built; `python3 recomp/recompile.py` emitted 127 files. Headless host ran 15 seconds, 895 VIs and 446 display lists, exit 0. `patches/rt64-metal-sdk-scope.patch` fixed the RecompFrontend shader command; the macOS Metal rebuild passed and its host ran 120 seconds, 7174 VIs, exit 0 on Apple M1. A later macOS startup-order fix made the native window inspectable: moving intro, GAME1 file select and native Settings were viewed through CUA on 2026-09-30. Escape opened/closed Settings; ordinary keyboard selection subsequently reached the first field (see the 2026-10-01 macOS entry). Sustained ordinary movement and save/relaunch remain open. A bounded event trace found CUA key-down/key-up share a timestamp and SDL reports the key released when polling; loaded A/Start bindings are correct. This is an automation timing limitation, not a demonstrated input-mapping defect. Audio fidelity and save/relaunch remain unverified. |
| G2 mobile core and renderer | In progress | The Conker core, RSP audio path, runtime and RT64 Metal archives compile/link into an ARM64 `iphonesimulator` app and an unsigned ARM64 `iphoneos` app. Both SDK-specific RT64 closures force-link without desktop surface symbols. Metal blobs target iOS 17.0 and Metal 3.1; iOS 18.5 Simulator loaded them. iOS excludes mod scanning, LiveRecomp initialization and the game-start `load_mods` call. The latest iOS link excludes LiveRecomp entirely; neither final executable contains LiveGenerator, ShimFunction or sljit symbols, and the device map marks native mod protect/patch functions dead stripped. Runtime RDRAM still uses non-executable mmap/mprotect. Physical execution remains unverified. Both iPad and iPhone Simulators reached gameplay with the touch input bridge. This is not physical-device or audio proof. |
| G3 Simulator frame | Partial | The iPad Pro 11-inch (M4) and iPhone 16 Pro, both iOS 18.5, reached moving intro, game select and the **first playable field** on RT64 Metal. Fresh iPad Pro 13-inch (M5) and iPhone 17 Pro iOS 26.5 runs rejected invalid and wrong-checksum files, imported the pinned US ROM through Files, reached the first field, and loaded a saved GAME1 slot after cold app relaunch. Touch Start/A paused/resumed in that field. Captures: `work/evidence/ipad26-fresh-import-relaunch-first-field.png`, `work/evidence/iphone26-fresh-import-relaunch-first-field.png`. macOS fidelity comparison, long play and audio quality remain open. |
| G4 touch input and audio | Partial | The continuous stick and 14 N64 touch buttons feed Conker's mobile input callback for player 0. A separate GameController state maps extended-gamepad buttons and sticks into the same callback; a hidden virtual controller supplied combined A, C-right and left-stick input in the first playable field on both Simulators, then cleared on disconnect. Individual actions, controller title navigation and physical hardware remain unverified. On both Simulators, touch Start opened the game's pause screen and A resumed at the first field. Short stick/C taps changed the picture but do not establish sustained analog feel. The three-dot menu opened/closed and hid/restored the controls in the iPad field. Opacity, control size, D-pad/C-button visibility and separate iPad/iPhone touch positions persisted across full app relaunch; Restore Defaults returned the defaults. The iOS Audio Queue consumed nonzero stereo PCM on both Simulators. After Chris reported heavy glitches, a five-buffer reserve reduced measured restarts in separate Simulator runs, but did not eliminate them and adds about 100 ms of nominal buffering. A later queue-depth trace confirmed real underruns and the restored iPad build still restarted twice through display list #4620; intermittent sample starvation remains measured, but its relationship to the audible complaint and its practical severity are unverified. Routine audio diagnosis is deferred following Chris's 2026-09-30 correction. Pausing the queue with scene inactivity removed the immediate resume underrun in two short cycles on each Simulator; this does not establish general audio quality. Audible quality, interruptions/routes, simultaneous touches and controller play remain open; Settings now pauses game time. |
| G5–G6 gameplay | Partial | Populated **GAME1** slots survived app reinstall on each Simulator and loaded the first field. On iPad, a new **GAME2** slot was created, and after cold relaunch it showed **PLAY** with a nonzero play time. The mobile VI gate stops display-list progression on Home. The iOS runtime patch froze `osGetTime()` and timer-message enqueues through two ten-second gameplay background cycles on each Simulator; both resumed rendering and touch Start/A. A subsequent Audio Queue pause change removed the immediate resume underrun in two more short cycles on each Simulator. Distinct in-level save fidelity, sleep/wake, long play and full-story G6 remain open. |
| G7 hardware | Awaiting devices | `xcrun devicectl list devices` found no connected iPad or iPhone on 2026-09-26. Both physical acceptance rows remain open. |
| G8 package | In progress | A separate checkout builds its own recompiler tools, generated game code, macOS shader inputs and both iOS RT64 archive closures. Both SDK app bundles carry 24 upstream notice texts, including three previously omitted header notices, and the latest executables have no absolute home path strings. The app contains ROM-derived executable code. Full notice/rights review, signing, installable handoff and hardware install remain. |

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

### 2026-09-30 — current bundle boundary and omitted header notices

**Progress:** previous turn committed individual touch sizes as `787e4c2` and
proved relaunch persistence on both classes. This step addresses G8 package
accuracy, without claiming the lower gameplay gates are complete. Audio stays
deferred; no audio or gameplay code changed.

**Fail, corrected:** the existing 21-notice bundle omitted concurrentqueue,
its lightweightsemaphore attribution/license, and sse2neon, although current
device compiler dependency files include those headers. Added three verbatim
pinned header excerpts under `Support/Notices/` and bundled them through CMake.
Independently compared each excerpt with the controlled source headers. All
manifest source commit pins match `work/source-replay`.

**Pass, exact builds:** final Simulator and unsigned device Release builds
exited zero (`work/package-notices-{iphonesimulator,iphoneos}-final-build.log`).
The first build regenerated the Xcode projects after loading the old resource
list, leaving 21 notices despite a successful exit. An actual bundle inspection
caught this; rebuilding the regenerated projects produced 24 texts. The new
bundled bytes match the source notice files. Both ARM64 executable hashes are
unchanged from the preceding accepted size build: Simulator `c6edcad86ecf30d063a6a04b051eeb1aee099d9a0aac690dd386b7184fba28f3`,
device `c10b8d19fc32d9d7bfc8db44f74397224cd0635f3a089aac95615c027107bdc8`.

**Pass, bounded content audit:** full `nm -a` output contains no LiveGenerator,
ShimFunction or sljit symbol matches on either SDK. Neither bundle contains a
local home path in a byte scan; filename inventories contain no ROM/save/key or
provisioning-profile input. Exact inventories and notice hashes are in ignored
`work/package-notices-audit.json`. These scans do not prove exhaustive license
coverage or distribution rights; ROM-derived executable code remains present.
Updated `docs/SOURCE_BOUNDARY.md` to supersede the older LiveRecomp-containing
binary observations and document the current evidence accurately.

**Pass, in-place packaging installs:** iPhone 16 Pro then iPad M4 / iOS 18.5,
one Simulator at a time. Each installed container contains 24 notices and the
same accepted executable hash. Preference dictionaries remain as after the
previous restored test: only the new empty class-specific size key differs from
the pre-sizing backups. No ROM/save reset. Both Simulators shut down. No visual
or new gameplay claim from this resource-only change; no physical installation.

**Open / next:** G1 ordinary macOS gameplay/save control, G5 distinct in-level
save fidelity, G6 full iPad story/representative iPhone play, remaining reference
menu/editor gaps, and G7 physical acceptance remain incomplete. G8 still needs
reproducible developer setup instructions and final clean replay/signing review.
Next concrete handoff action: derive a root README's build commands from the
verified replay commands in this ledger and the current CMake caches/scripts;
check them against the actual source and output paths before committing. Chris
retains physical touch feel, controllers, audio listening/routes and long play.

### 2026-09-30 — developer setup instructions

**Progress:** previous goal turn produced local commit `94d0dd8`, corrected
missing runtime header notices and verified installed bundle contents. This
turn adds the missing root `README.md` required by G8: prerequisites, exact ROM
identity, pinned source/patch preparation, private game generation, macOS shader
inputs, both SDK renderer/app commands and sequential in-place Simulator use.
It also describes data locations, editing behavior, unsigned-device limitations,
source boundaries and the remaining full-product gates. No app/source behavior
change, audio experiment, private data reset or push.

**Pass, command validation:** all six README shell blocks pass `bash -n`.
Replayed the README's actual mobile `for sdk` configure/build block against the
current controlled checkout and verified archives, rather than transcribing
older default build paths. Both Release builds exited zero;
`work/readme-mobile-build.{sh,log}`. CMake caches confirm ARM64, correct SDK,
source/renderer paths and input probe OFF. All source pins match the manifest.
Both bundles still contain 24 notices; executable hashes remain Simulator
`c6edcad86ecf30d063a6a04b051eeb1aee099d9a0aac690dd386b7184fba28f3`, device
`c10b8d19fc32d9d7bfc8db44f74397224cd0635f3a089aac95615c027107bdc8`.
README bootstrap/generation/macOS commands were checked against current scripts,
target definitions and the recorded replay; they were not rerun from a fresh
clone this turn. No independent clean-replay or physical signing pass claimed.

**Not run/open:** full story, meaningful distinct checkpoint/save acceptance,
macOS ordinary-play/save control, reference-menu completion and G7 hardware.
Both Simulators remain shut down; no new runtime or visual claim. G8 still needs
final independent replay/signing/notice review. Next product action remains the
first in-level story checkpoint: preserve the existing EEPROM before loading
the first field, and establish the Birdy lesson/cure interaction with viewed
ordinary input before claiming a save fixture. Do not repeat audio counters or
unbounded blind movement attempts. Physical touch feel, controllers, audio
routes/listening and sustained-device play remain for Chris.

### 2026-09-30 — stop speculative audio work

**Audio unconfirmed:** Chris challenged the prolonged investigation. Queue
counters have not established a repeatable audible ordinary-play defect or
proved a Simulator/device cause. Stop audio tuning, counter sweeps and recording
loops unless a specific audible reproduction supplies a falsifiable target.
This is neither an audio pass nor evidence that a physical device fixes it.

**Bounded gameplay diagnostic:** GAME1 loaded on iPad M4 / iOS 18.5. Brief
automated touch drags showed no clear displacement; sustained opt-in virtual
controller input moved Conker into the garden. Viewed raw capture:
`work/evidence/checkpoint-controller-garden.png`. Birdy/pad interaction attempts
did not establish a new logical checkpoint. Do not classify this as a game bug:
controller mapping and existing slot progression have not been ruled out. No
meaningful save/relaunch pass or ordinary touch-playability pass claimed.
Existing EEPROM was backed up before the attempt in ignored
`work/ordinary-checkpoint-before.bin`; no save or game-logic edits.

**Next:** focus on ordinary gameplay/save acceptance and the reference menu.
Physical touch feel, controller hardware, audio listening/routes and sustained
play remain for Chris. No further audio experiment in this turn.

**Restored:** probe OFF Release rebuild succeeded; in-place iPad install
completed and installed executable hash matched the built normal binary,
`60529bc5a861f83da1600f896eaf1370350669fe9a3015027bf3d1dc3e3287bc`.
This rebuild's hash differs from the previously recorded normal build; no
tracked app source changed, and no binary equivalence claim is made. Cache
confirms probe OFF and `nm` found no SimulatorInputProbe symbols. Build log:
`work/checkpoint-normal-final-build.log`. No runtime acceptance claim for this
restoration. iPad shut down after installation; iPhone remained shut down.

### 2026-09-30 — individual touch-control Hide/Show

**Progress:** preceding turn restored the normal build and committed the audio
uncertainty correction (`4b68214`). This turn confirms the saved iPad controller
map does not override B: only A=A and Z=LT/RT are stored, so B uses its default.
Ordinary A eventually opened GAME1 and loaded the first field; brief automated
coordinate taps/drags remained insufficient for a sustained gameplay claim.
No controller mapping, game logic or audio behavior changed.

**Implemented:** the reference's `docs/customizable-touch-controls.md` and
`patches/shipwright-ios-customizable-touch-controls.patch` expose per-button
Hide/Show, dimmed hidden controls in the editor, a protected stick, device-class
profiles and Reset. SquirrelPad now implements that missing behavior through
its existing three-dot menu → Edit Layout flow. Hidden buttons are absent from
gameplay but selectable at 40% opacity in the editor; no selection and Stick
disable/dim Hide. Done persists sorted hidden IDs separately for phone/tablet;
Reset clears the current profile's hidden overrides along with positions/sizes.
The existing global D-pad/C switches still govern gameplay, while the editor
shows all controls so users can recover individual overrides. README updated.
This is a behavioral comparison to the reference source/docs, not a side-by-side
run of HarkinianPad or a complete menu-parity claim.

**Pass, final builds:** ARM64 Simulator and unsigned-device Release builds exit
zero; `work/hide-controls-{simulator,device}-final-build.log`. Both caches have
probe OFF and all controlled source pins match `sources.lock.json`. Final
Simulator executable SHA256:
`00f8ff7b956b53b4318155b961889458f0b6678b76ee851b05c43bbfb8151eb1`;
unsigned device executable:
`eb0f30bd637a17ca346da42509090cfe0ea8bdf8d3d264e9be8fc561542c1648`.
Both installed Simulator executables match the final Simulator hash.

**Pass, iPad M4 and iPhone 16 Pro / iOS 18.5:** on the exact final Simulator
build, select B → Hide → Done → terminate → relaunch → Continue Imported ROM
leaves B absent from the overlay and accessibility tree. Reopen the editor:
B is dimmed/selectable and Show restores it. Stick keeps Hide disabled; the
final disabled action is visibly dimmer. Hide followed by Reset restores B on
both classes. iPhone C-group OFF leaves C controls editable, while Done keeps
them absent from gameplay until the group switch is restored. Menu access
returns after Done. Viewed native screenshots and raw captures:
`work/evidence/hide-controls-ipad-final-editor.png`,
`work/evidence/hide-controls-ipad-final-relaunch.png`,
`work/evidence/hide-controls-iphone-editor.png`,
`work/evidence/hide-controls-iphone-relaunch.png`. Editor captures show readable
Size/Show/Reset/Done without clipping. Existing layout/preferences restored
through the UI: only each new class-specific empty hidden-ID key (`[]`) differs
from the private before-test backups. No ROM/save reset; both Simulators shut
down. No ordinary sustained movement, new logical checkpoint or full-story pass.

**Open / next:** G1 ordinary macOS gameplay/save comparison, G5 meaningful
checkpoint saves, G6 full iPad story/representative phone play, remaining menu
parity and G7/G8 device/signing acceptance. Do not resume audio counter tuning
without a specific audible reproduction. The next gameplay diagnostic must
check actual game-consumed B and the existing GAME1 progression before
classifying the Birdy interaction as a port defect; remapping has been ruled
out by the current preference/source inspection. Physical touch feel,
controller hardware, audio routes/listening and long play remain for Chris.

### 2026-10-01 — B delivery verified at the runtime callback

**Progress:** previous goal turn produced `6c08b3a`, implementing and verifying
individual Hide/Show. Current worktree began clean; disk had 28 GiB available.
This turn tested the next gameplay hypothesis rather than repeating audio work.

**Pass, bounded input boundary:** a temporary transition-only trace in
`Support/Conker/mobile_input.cpp` logged the actual player-0 callback output.
`ultramodern/src/input.cpp::osContGetReadData` copies that mask into the N64 pad
data without remapping. On iPad M4 / iOS 18.5, ordinary touch Start produced
`1000 → 0000`. A brief automated touch A did not appear in this trace, while
one-second and half-second virtual-controller A produced `8000 → 0000` and
visibly opened GAME1/PLAY/the first field. Touch B produced
`buttons=4000 touch=4000 controller=0000` and release; one-second physical B
through the virtual controller produced
`buttons=4000 touch=0000 controller=4000` and release. C-left/right similarly
reached the callback as `0002`/`0001`. Exact console:
`work/story-b-callback-run.log`; build `work/story-b-probe-build.log`.
This rules out dropped B at this boundary in this run. It does not prove the
previous pad's context condition, actual game action, or all brief touch taps.

**Not achieved, checkpoint:** GAME1 preview still displayed $0 and 1:55:56.
The bounded route attempt moved around the wall/water/fence but did not
establish the Birdy lesson/cure or a distinct logical save. Viewed raw final
capture `work/evidence/story-b-route-stop.png`. No game defect classified; no
flags decoded or edited. Before-test EEPROM preserved in
`work/story-b-save-before.bin`, 2048 bytes, SHA256
`e2156766ee0b6138e7952ca6f98def8c979842b551dd3d0dda1436e3c900e334`.
Afterward it was still 2048 bytes, SHA256
`dfa3be74bf72d8eafd59060747dda9be5770ba797bc39da5566d0b0240449e2f`;
a byte change alone is not meaningful checkpoint evidence. No save restoration
or reset performed.

**Restored:** temporary input source byte-restored; Simulator probe explicitly
OFF; Release rebuild exited zero (`work/story-b-normal-build.log`). Restored
executable contains neither trace marker nor trace environment name. In-place
iPad installation completed and installed bytes match the restored build:
SHA256 `620e0700afbcac6f2a8a32976905773d3a5437bed48ab977e3109d7554fa2285`.
No executable-equivalence claim to the prior build hash. Traced app/console
terminal, iPad shut down, iPhone remained shut down. No retained app/game/audio
source changes; local evidence commit only, never push.

**Next / open:** stop treating B mapping/delivery as the demonstrated cause of
the Birdy failure. Compare the saved route/context with the native macOS control
before changing game behavior. Separately, a temporary touch-setter timestamp
trace can distinguish a missing automated gesture from a press/release that
falls between game polls; callback absence alone does not justify a latch fix.
Full story, meaningful checkpoint saves, remaining menu/reference parity, final
replay/signing and physical acceptance remain open. Chris retains physical touch
feel, controller hardware, audio listening/routes and sustained play. Audio
diagnosis remains deferred without a specific audible reproduction.

### 2026-10-01 — Brief touch delivery separated from automated drag timing

**Previous turn: no progress toward app completion.** It acknowledged Chris's
correction about speculative audio investigation. Audio remains deferred unless
there is a specific reproducible audible defect; no audio change this turn.
Current checkout began clean at `4fc66e7`, with 29 GiB available. Read the full
objective and preserve G0–G8, including story/checkpoints and device acceptance.

**Pass, bounded diagnosis:** temporary monotonic timestamps at the touch setter
and player-0 callback distinguish actual touch edges from callback observations.
Probe OFF, iPad M4 / iOS 18.5. Eleven CUA `click` presses (Start/A/B) lasted
31.617–54.625 ms; all eleven were sampled as pressed and then released.
One CUA four-pixel A `drag` generated a 7.535 ms press/release, both between
polls: previous poll 1394213691394 us; press 1394213693371; release
1394213700906; next poll 1394213724860 with mask zero. Thus the prior missing
brief automated press can have a concrete polling explanation. This single
synthetic drag does not establish missed ordinary finger input or justify
extending every touch press. No input latch or game-logic fix retained.
Use CUA clicks for button taps; do not use very short drags as equivalent
button acceptance evidence or repeat this diagnostic without a new symptom.

**Visible behavior:** touch navigation reached the first field; Start visibly
paused it and A returned to gameplay. Final ordinary gameplay capture
`work/evidence/touch-edge-gameplay.png` visually inspected. This is bounded
navigation/resume evidence, not sustained touch play or a meaningful checkpoint.
Console `work/touch-edge-run.log`; diagnostic build
`work/touch-edge-build.log` exited zero. No controller or iPhone run needed for
this nonretained diagnostic; those acceptance rows remain open.

**Restored:** source byte-matches `work/touch-edge-original.cpp`; forced normal
Release rebuild exited zero (`work/touch-edge-restored-build.log`). Probe OFF;
executable lacks both trace markers/environment name. In-place installed bytes
match restored executable SHA256
`620e0700afbcac6f2a8a32976905773d3a5437bed48ab977e3109d7554fa2285`.
Launch console terminal; iPad shut down, iPhone stayed shut down. No ROM, save
or settings reset; no retained app source changes. Commit evidence locally only.

**Next:** return to ordinary gameplay/context and macOS comparison before
classifying Birdy's interaction as a port defect. G5 meaningful saves and G6
full story remain unproven, alongside remaining reference-menu parity and
final developer package acceptance. Chris owns physical touch feel, controllers,
audio listening/routes and sustained hardware play. The app is not complete.

### 2026-10-01 — Persistent three-dot menu matches reference placement

**Progress:** previous turn `2df2b89` distinguished sampled button clicks from
sub-frame automated drags and restored the normal build. Current work began
clean; objective read in full, disk 29 GiB. Audio investigation remains deferred.

**Changed:** HarkinianPad's `docs/touch-controls-design.md` specifies an
independent permanent three-dot button: upper right on iPad, top center in
phone gameplay, bottom center while the phone menu is open. SquirrelPad hid
that button when Settings opened and used the right corner on phone.
The existing toggle now remains available outside layout editing and follows
those positions. The first phone screenshot exposed an overlap with the panel;
the final compact panel reserves 24 more points below itself and the button
sits four points farther above the Home indicator. No game/input/audio changes.
Comparison is to reference documentation/source, not a live reference app run.

**Pass:** final Simulator and unsigned device Release builds exited zero:
`work/persistent-menu-{sim,device}-final-build.log`. Probe remains OFF and input
trace absent. Executable SHA256: Simulator
`e64ab51e3fdd4f2caabb95043f1b3c3b0c2eadc7bc5ca993b307027b01287eba`,
unsigned device
`db45189f42a6c8953fdec0f3450488c3bd9bd091be2cfc7d148398c1c4d7e80b`.
Final Simulator installed sequentially on iPhone 16 Pro then iPad M4 / iOS 18.5;
iPad installed bytes independently matched the final build. Both ordinary
Continue paths launched game rendering. On both, three-dot open/close works,
opening Settings removes gameplay controls, touch disabled still permits
open/close, enabling restores controls, entering editor removes permanent menu,
and Done restores it. Phone's existing Close menu button also works. Touch
Controls preference restored to on, no layout manipulation/reset or save reset.

**Viewed captures:** `work/evidence/persistent-menu-ipad-final.png`,
`work/evidence/persistent-menu-iphone-final.png`, and
`work/evidence/persistent-menu-iphone-final-closed.png`; corresponding live CUA
screenshots inspected. Final phone button clears the panel and Home indicator;
Controls/Audio navigation/header remain readable. Automated wheel/drag attempts
did not visibly scroll the compact panel; no ordinary swipe acceptance claim.
Accessibility activation reached Edit Layout. Further ordinary scroll verification
remains open, as does full reference parity. Both Simulators shut down after
checks; local commit only, never push.

**Open:** ordinary macOS gameplay comparison, meaningful save checkpoints,
full iPad story and representative iPhone gameplay, final replay/signing, and
physical acceptance. Chris retains touch feel, controller hardware, audio
listening/routes and sustained hardware play. App completion remains unproven.

### 2026-10-01 — Independent source replay and signing preflight

**Progress:** previous turn `e8a17d9` implemented and verified persistent menu
placement. Current work began clean; full objective read, 29 GiB free. No audio
investigation resumed. All Simulators remain shut down.

**Blocked by input, signing only:** `security find-identity -v -p codesigning`
reports **0 valid identities found** on this Mac. No signed iOS installable
handoff can be claimed from the unsigned device output. Chris needs to make a
valid development signing identity/profile available before signing/install
acceptance; no certificate/account/keychain change attempted. This does not
block the remaining source/Simulator work or close the overall goal.

**Pass, fresh replay:** ran `scripts/setup-source.sh` with
`SQUIRRELPAD_CHECKOUT=$PWD/work/source-final-replay` and the existing private
ROM symlink target. New network clone/submodules and tracked patches succeeded
(`work/final-replay-setup.log`); all seven manifest revisions independently
matched. Existing patched checkout/builds untouched. ROM validated, linked
privately; no ROM/save/profile copied to Git.

Fresh N64RecompCLI, RSPRecomp and RecompModTool built, then `recompile.py`
completed: `work/final-replay-generator-{configure,build}.log` and
`work/final-replay-generation.log`. All **127** generated files byte-match the
existing source replay, including the same relative inventory; private hash
inventory `work/final-replay-generation-comparison.json`.

Fresh macOS host configure/build exited zero using the full Xcode SDK and
parallel 4: `work/final-replay-host-{configure,build}.log`. Executable is
Mach-O arm64, SHA256
`7e3a7bd8a2c94099e7891e6e2fa91b8d140b74b110164d2f6b06172797100d64`;
56 Metal source inputs produced. No ordinary macOS runtime/gameplay/save pass
claimed by this build. Disk afterward 26 GiB available.

**Running, not passed:** fresh mobile renderer replay launched with
`SQUIRRELPAD_CHECKOUT=$PWD/work/source-final-replay` and
`SQUIRRELPAD_RT64_BUILD_TAG=-final-replay`. Simulator `verify-rt64-ios.sh`
followed by device script under `set -e`; live exec session **44279**. Simulator
configure completed; archive compilation still live on last poll. Logs:
`work/final-replay-rt64-{simulator,device}.log`, internal build log
`work/build-rt64-iphonesimulator-final-replay/build.log`. Continue polling this
handle; do not restart because this ledger exists or because observation times
out. If terminal success, build both apps in fresh `work/build-app-final-<sdk>`
directories using this source and corresponding fresh archives, probe OFF,
then perform package audit and sequential Simulator acceptance. Final mobile
replay/install/signing, meaningful checkpoints, full story and physical checks
remain open. Never push.

### 2026-10-01 — Fresh mobile builds, bundle audit and first-field replay

**Progress:** previous turn `9d5d5b0` completed fresh source/tools/generation
and host build, leaving renderer session 44279 running. Re-polled that exact
handle: terminal exit zero; no restart. Both fresh renderer SDKs succeeded,
including 56 Metal shader compilations per SDK and ARM64 force-loaded closure
checks. Logs `work/final-replay-rt64-{simulator,device}.log`.

**Pass, independent build:** configured new `work/build-app-final-<sdk>` Xcode
projects against `work/source-final-replay` and the respective
`work/build-rt64-<sdk>-final-replay` archives. Probe OFF. Both Release builds
terminal exit zero, confirmed BUILD SUCCEEDED; logs
`work/final-replay-app-{simulator,device}-{configure,build}.log`.
No existing app objects/renderer archives reused. Simulator executable SHA256
`1759aaa2035b5b0acf49bb4135d95ebcfb9561ae51965493b76f15984726eed6`;
unsigned device executable
`8c446ce78107d56106159ed146ed37457f6a2fc59a709805620916af570de03c`.
Disk remains 26 GiB available. No app/game/audio source edits.

**Pass, bounded audit:** each bundle contains 27 files, including 24 third-party
notices, byte-identical across SDKs. ARM64, identifier
`com.chrissotraidis.squirrelpad`, version 0.1.0. Full file inventories/hashes and
`nm -a` output recorded privately by `work/final-replay-audit.py` in
`work/final-replay-package-audit.json` and SDK symbol logs. No flagged
ROM/save/key/profile files; no Simulator-input/touch trace markers or personal
home-path string in executables; no LiveGenerator, ShimFunction or sljit_emit_
symbols. These specific scans do not prove exhaustive secret absence or complete
license compliance. Compiled game/RSP/TLB code remains ROM-derived; app is not
therefore rights-cleared or freely distributable. Device output remains unsigned.

**Pass, bounded ordinary replay:** installed the same fresh Simulator bundle
in place on iPad M4 then iPhone 16 Pro / iOS 18.5, one booted at a time.
Independently verified installed executable bytes match on both. Continue
Imported ROM → moving intro → touch Start → GAME1/PLAY → touch A reached the
first field. Touch Start visibly paused it; A visibly resumed. Three-dot
Settings opened/closed and removed/restored gameplay controls; persisted
Control Size remained 116% on iPad, 100% on phone. Existing ROM/saves/preferences
not reset. No new meaningful checkpoint or sustained movement acceptance.
Live CUA screenshots inspected; private captures:
`work/evidence/final-replay-{ipad,iphone}-{settings,gameplay}.png`.
Both apps terminated and Simulators shut down; all build handles terminal.

**Still open:** signed developer install (no valid signing identity found last
preflight), remaining notice/licensing review, macOS ordinary gameplay/save
comparison, two meaningful in-level checkpoints/reloads, full iPad story and
representative iPhone chapters, remaining menu/swipe acceptance, physical touch
feel/controllers/audio routes/long play. Fresh build reproducibility now has
independent evidence; it does not close all of G8 or redefine full completion.
Next return to ordinary gameplay context and control comparison; do not repeat
fresh builds or audio diagnostics without a new concrete failure. Local commit
only, never push.

### 2026-10-01 — Stop speculative audio diagnosis; restore ordinary build

Chris questioned whether the prolonged audio investigation established a real
problem. It did not establish a reproducible audible ordinary-play defect,
its severity, or a Simulator/device cause. Earlier queue counters are evidence
about queue behavior only. Audio diagnosis stays deferred until a specific
audible reproduction exists; no audio source or configuration changed.

Before stopping this session, a bounded existing Simulator controller probe
reached the first field and moved Conker against a rock wall. Camera attempts
did not establish a route to Birdy. No meaningful checkpoint accepted. The
save changed from SHA256 `5cf41c680e7d9cd507da32f612738b5e209425212f4bb3dbcc7dd456c0271846`
to `c4378506ed44a8685ac0ac5760e55a3ebc72d03a598a3d29359c248cab5c9d50`;
this byte change does not establish checkpoint flags. User data preserved.
Private log: `work/checkpoint-replay-run.log`.

The macOS host mouse-button input branches are TODO in
`RecompFrontend/recompinput/src/input_state.cpp`; no input workaround added.
Ordinary macOS gameplay/save comparison remains unverified.

Cleanup passed: probe disabled in the final Simulator CMake cache; normal
Release rebuild exited zero (`work/checkpoint-normal-restore-build.log`).
Reinstalled the preserved exact normal bundle in place and verified installed
executable SHA256 `1759aaa2035b5b0acf49bb4135d95ebcfb9561ae51965493b76f15984726eed6`.
Probe launch session 78200 and rebuild session 11152 are terminal. iPad shut
down; phone unchanged. No game logic or app source changed; no push.

Remaining app work is gameplay/checkpoint acceptance and remaining touch/menu
behavior, not further speculative audio tuning. Chris still supplies signing
credentials and eventual physical touch/controller/audio-route/long-play checks.

### 2026-10-01 — Settings slider accessibility and cold relaunch

**Progress:** previous turn restored the normal build and stopped speculative
audio investigation. Current worktree began clean; objective read, 26 GiB free.
No audio investigation or game/input changes this turn.

**Fixed:** Controls Size and Opacity sliders exposed no accessible name and
only a normalized number. Added explicit names and percentage accessibility
values matching their visible text. Four SwiftUI modifiers; bindings/ranges,
layout and persistence unchanged.

**Pass:** both final Release SDK builds exited zero, probe OFF. Logs:
`work/settings-slider-labels-{sim,device}-build.log`. Executable SHA256:
Simulator `b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`;
unsigned device `8a3ce7e18d52f5b7625b2ec60626aa91dc214a3ca7da0a78090f2c646e16f15c`.
Installed the same Simulator bundle in place on iPad M4 then iPhone 16 Pro,
iOS 18.5, one booted at a time. Accessibility trees identify Control Size with
116 percent on iPad and 100 percent on phone; enabling transparency identifies
Control Opacity with 100 percent on both. Restored transparency OFF.
Viewed screenshots confirm unchanged menu geometry and persistent three-dot
placement against the reference's documented placement. No live reference
app comparison claimed. iPhone binding expansion scrolls its header to the
top; collapse exposes Touch Layout. Private captures:
`work/evidence/settings-slider-labels-ipad.png` and
`work/evidence/settings-slider-labels-iphone-{before,relaunch}.png`.

**Pass, phone persistence regression:** AX setValue alone moved the native
slider without updating the SwiftUI text/model; that is not persistence proof.
After a pointer gesture, visible Size and accessible percentage both changed
to 108 percent. Terminate/launch, reopen Settings: both still 108 percent.
Restored displayed Size to 100 percent with another pointer gesture. No ROM,
save or other layout profile reset. Both Simulators terminated/shut down.

**Unverified:** native automated swipe/wheel still did not visibly move the
Settings content. Programmatic binding-header scroll works; an ordinary swipe
defect is not established. No speculative scrolling or macOS mouse workaround
added. Full gameplay/checkpoint, macOS control and physical gates remain open.
Local commit only; never push. Next acceptance work remains meaningful game
progress/save reload and sustained input, without resuming audio diagnostics.

### 2026-10-01 — GAME1 garden approach, no new checkpoint

**Progress:** prior turn `6262093` fixed slider accessibility and verified a
phone setting across relaunch. Clean checkout, 26 GiB free; objective read.
This turn used the existing opt-in controller probe against that revision;
no game, audio or production source changes. Probe build terminal exit zero,
`work/birdy-route-{configure,build}.log`; launch `work/birdy-route-run.log`.
Preserved exact normal bundle privately as `work/route-normal-6262093.app`.

**Pass, bounded navigation only:** GAME1 still displayed $0 / 1:55:56 before
PLAY. Initial diagonal-left/forward approach hit the closed fence/rock corner;
backed away, traversed the water side, then combined diagonal stick with A to
enter the plot. Visually inspected Birdy, vegetables, sign and inner B pad.
This does not establish that the entry used a jump rather than the opening.
Touch B and bounded controller B attempts at several pad positions produced
no observed lesson or beer sequence. Approaching Birdy directly also did not
establish dialogue. Left the pad toward the water-side boundary; no outside
pad cure or new checkpoint reached. Private captures viewed live:
`work/evidence/birdy-route-current-{plot,stop}.png`.

The older 2026-09-30 ledger explicitly records dialogue, lesson, beer and helium
actions on this saved slot, but not the cure/reload. This run's missing replay
does not establish a port or input defect. Repeating GAME1's first-pad presses
without establishing its saved progression is not the next useful test.
Route guidance checked against the linked GameRevolution walkthrough above;
it is guidance only, not app acceptance proof.

Save preserved before/after without editing/resetting:
`c4378506ed44a8685ac0ac5760e55a3ebc72d03a598a3d29359c248cab5c9d50` →
`d3f150befb163aa0911fd6b73871682a9515bec0465a194e657a948f00f04515`.
Elapsed-time writes can explain byte changes; no logical checkpoint claimed.

**Cleanup passed:** launch session 98283 terminal; probe OFF; normal Release
rebuild terminal exit zero (`work/birdy-route-restore-{configure,build}.log`,
session 32576). Reinstalled preserved ordinary bundle in place and verified
installed executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`.
iPad shut down, phone unchanged; user data retained. Local commit only, no push.

**Next:** inspect the game selector for an actually unused slot before creating
a fresh game; preserve all occupied slots. Use that fresh route to distinguish
initial Birdy behavior from GAME1's earlier progress, then verify an actual
checkpoint/relaunch. No further speculative audio investigation. Full story,
macOS gameplay/save control, physical acceptance and signed install remain open.


### 2026-10-01 — Fresh Files import and initial save reload

**Progress:** the preceding audio reply was a status correction, not a new
implementation or acceptance result. Revalidated the clean worktree at
`56d15fc` and read the full objective. No audio investigation or source changes.

All original iPad slots were occupied: GAME2 $0 / 0:04:25, GAME3 $0 / 0:06:04.
Created a separate iPad M4 / iOS 18.5 Simulator, SquirrelPad Fresh Save Control,
`605FB671-1720-4C19-A3BE-AE425323D052`, without resetting existing containers.
Installed the ordinary `6262093` app, executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`.
The supported private ROM and synthetic invalid fixtures were made available in
Documents; import itself used the ordinary Files picker.

**Pass, iPad ordinary import:** missing-ROM launcher had no Continue option.
A 20-byte fixture visibly produced the unsupported-size/header error. Selecting
the supported US ROM through Files started the moving intro. Touch Start/A
reached empty GAME1 and started the opening story; visually inspected advancing
story scenes and the hungover field. Touch Start paused/resumed both the story
and field. No sustained analog gameplay or listening-quality claim.

**Pass, initial cold save reload:** a 2048-byte EEPROM existed before termination,
SHA256 `39f3fe40697564b55f152fdbbaeaa131eff5faa5ad9a3032f018765545cb1bd9`.
Cold launch displayed Continue Imported ROM. A synthetic 64 MiB file with the
correct big-endian header but no game data produced the checksum-mismatch error;
the stored supported ROM retained SHA1 `4cbadd3c4e0729dec46af64ad018050eada4f47a`.
Continue, touch Start/A showed GAME1 $0 / 0:06:03 with PLAY, then loaded the
hungover field directly. This is an initial save, not the two distinct progressed
checkpoints required by G5. The fresh profile is retained for that next route.

Private viewed captures: `work/evidence/fresh-import-{invalid,newgame,field,
checksum,saved-slot,reload}.png`. Unified runtime log:
`work/fresh-import-runtime.log`; no pipeline/GPU failure matched the bounded
search, which is not a comprehensive rendering acceptance pass.

**Cleanup:** Simulator probe OFF in CMake; Release rebuild terminal exit zero,
`work/fresh-import-normal-{configure,build}.log`. Fresh profile always ran the
normal preserved executable; no probe installed there. Original iPad save still
`d3f150befb163aa0911fd6b73871682a9515bec0465a194e657a948f00f04515` and normal
executable hash verified directly while shut down. Fresh app terminated and
Simulator shut down; phone unchanged. Disk 22 GiB. Local evidence commit only.

**Next:** continue fresh GAME1 through Birdy's lesson and cure, then establish a
progressed checkpoint/reload; repeat fresh import on phone. Full story, ordinary
macOS comparison and remaining matrix rows stay open. Chris retains signing
identity and eventual physical touch/controller/audio-route/long-play checks.

### 2026-10-01 — Fresh Birdy lesson, beer and cure; bounded reload

**Progress:** the preceding audio reply was a status correction, not acceptance
progress. Revalidated `84afae2`, clean worktree, pinned sources and full objective;
22 GiB available. No audio investigation, game logic or production source edits.
The fresh iPad M4 / iOS 18.5 profile `605FB671-1720-4C19-A3BE-AE425323D052`
was live with the bounded controller bridge. Probe executable SHA256
`44b6881c80791b2a115540df5d50233dd2d85009b8f5bad8a8c9179e4807a2d0`;
configure/build logs `work/fresh-birdy-{configure,build}.log`, terminal exit zero.
Pre-route private save retained as `work/fresh-birdy-save-before.bin`, SHA256
`3834cb866ed8a3d00e2a4ff0f8b4a6c3ce05b53291f96d75283fc4ec8651a41e`.

**Pass, bounded fresh route:** sustained movement used
`scripts/simulator-input.py` with runtime opt-in, not held finger acceptance.
Following the waterside perimeter to the rear torch entered the tilled corridor;
approaching Birdy triggered the introduction. Moving onto the inner B pad
triggered his context-sensitive lesson. Ordinary on-screen B produced the beer
interaction; Birdy subsequently leaned asleep against his sign. Walking past
Birdy through the fence gap reached the outer B pad. Centering and ordinary
on-screen B started the cure animation; after it, Conker stood upright. Viewed
captures: `work/evidence/fresh-birdy-{dialogue,lesson,beer,cured}.png`.
This closes the earlier navigation uncertainty; no game patch was needed.

**Partial, cold reload:** pre-termination EEPROM was 2048 bytes, SHA256
`b8bcc9d8e7857b2b368c79330f7da989bf4f8fb578af93770c72dbc314573c5b`,
retained privately as `work/fresh-birdy-cured-save.bin`. Terminated the app and
consumed console session 20769 (exit zero). Installed the preserved ordinary
`6262093` build in place; verified executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`.
Cold launch offered Continue Imported ROM; touch Continue/Start/A showed GAME1
$0 / 0:46:56 with Birdy preview. Touch A loaded the field entrance. Updated slot
metadata survived, but this observation did not prove the cured movement state
persisted. A short touch-A observation did not settle that question. Do not call
this a distinct progressed checkpoint or a port save bug. Viewed reload capture:
`work/evidence/fresh-birdy-normal-reload.png`; save after reload SHA256
`0404f5e4aee175176325da04408d08173dafcca05571455d01433adc7ede2e76`.
The displayed time includes substantial idle time and is not a speed benchmark.

**Cleanup:** CMake probe OFF; ordinary Release rebuild terminal exit zero,
`work/fresh-birdy-normal-{configure,build}.log`. Preserved ordinary executable
installed and verified. Fresh app terminated and Simulator shut down; other
profiles unchanged. No push. Audio remains unconfirmed and deferred.

**Next:** replay the now-known lesson/cure route as needed, reach an actual level
transition, then cold-reload and compare visible progress. Two distinct progressed
save fixtures, full story, phone chapters and ordinary macOS comparison remain
open. Chris retains signing identity and eventual physical touch/controller,
audio-route and sustained-play acceptance.


### 2026-10-01 — Reproducible native macOS control bundle

**Progress:** previous turn restored the normal Simulator bundle and stopped
speculative audio diagnosis; it did not advance gameplay acceptance. Read full
objective, current pins and clean `04a4a8d`; disk 22 GiB. Audio remains deferred.

**Pass, local comparison packaging:** current replay host SHA256
`7e3a7bd8a2c94099e7891e6e2fa91b8d140b74b110164d2f6b06172797100d64`.
An absolute ROM argument was necessary after the host changed its directory.
The shell-launched comparison bundle timed out during CUA window inspection.
The same executable, launched directly through CFBundleExecutable with assets
under Contents/Resources, exposed its window immediately. This is a local test
bundle observation, not a mobile renderer/input fix. Added
`scripts/package-macos-control.py` and README command: native executable copy,
local assets link, no shell launcher, no ROM/save copy, refuses existing output.
It is a comparison aid with ROM-derived code, not a distributable package.

**Pass, bounded runtime:** macOS 27.0 / Apple M1. Direct native bundle launcher
responded to Return; viewed moving intro and GAME1 pub file-select scene.
Escape opened/closed Settings. Pointer clicks selected Controls and its keyboard
view, confirming Space=A, Return=Start and WASD movement. Two brief Space taps
did not visibly select GAME1. The state-polling source and short automated taps
do not establish a production mapping failure; G1 gameplay/save control remains
open. No input workaround, game logic or audio change. Private viewed capture:
`work/evidence/macos-keyboard-file-select.png`.

**Pass, helper replay:** ran packaging command against
`work/source-final-replay/host/build-macos-metal`; exact executable hash and
resolved resource path matched. CUA inspected the resulting
`SquirrelPad macOS Control.app` launcher; capture
`work/evidence/macos-packaged-launcher.png`. Ordinary Exit quit the generated
bundle. Re-running helper refused overwrite with exit 2, private log
`work/macos-package-overwrite.log`. Temporary shell/raw tests had been stopped;
one earlier keyboard test ignored TERM and was forcibly stopped at file select.
No Simulator booted this turn; mobile saves and normal installed builds retained.

**Next:** use the ordinary mobile flow to complete the fresh phone import row,
then gameplay/checkpoint and touch/menu acceptance. Full iPad story, two distinct
progressed checkpoints, macOS gameplay/save comparison and hardware/signing
remain open. Chris retains signing and eventual physical touch/controller,
audio-route and sustained-play checks. Local commit only, never push.


### 2026-10-01 — Fresh iPhone 18.5 import and initial save/reload

**Progress:** previous turn supplied a verified native macOS packaging helper;
G1 gameplay remains open. Revalidated full objective, clean `f629eb3`, pins and
21 GiB available. No speculative audio work or source change this turn.

**Pass, bounded ordinary flow:** created fresh iPhone 16 Pro / iOS 18.5 profile
`AE64D60E-CE76-42D7-A50E-9E2179F23805` without erasing existing profiles.
Installed `work/route-normal-6262093.app`; installed executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`.
Probe OFF, no save/config injected. Boot/install/launch exited zero;
`work/fresh-phone-boot.log`. Initial launcher had Choose ROM and no Continue.
Ordinary Files rejected a short invalid fixture, then a 64 MiB correct-header
fixture with wrong checksum. Exact pinned-US-SHA1 ROM imported through Files.
Touch Start/A selected empty GAME1 and NEW GAME. Viewed moving opening story
through throne/pub/Panther/wakeup into first field. Touch Start/A paused/resumed
both opening and field. A short stick drag did not prove sustained movement.

**Pass, initial cold reload:** first-field EEPROM 2048 bytes, SHA256
`39f3fe40697564b55f152fdbbaeaa131eff5faa5ad9a3032f018765545cb1bd9`,
private fixture `work/fresh-phone-first-field-save.bin`. Cold terminate/launch
retained Continue Imported ROM; touch Start/A showed GAME1 $0 / 0:06:03 PLAY,
then loaded field directly without story replay. Save after reload SHA256
`3834cb866ed8a3d00e2a4ff0f8b4a6c3ce05b53291f96d75283fc4ec8651a41e`.
Three-dot Settings hid all gameplay controls; X restored 14 buttons and stick.
Viewed private captures `work/evidence/fresh-phone-{invalid,checksum,field,
saved-slot,reload}.png`. Unified log `work/fresh-phone-runtime.log` has no matches
for the five recorded GPU/pipeline error terms in this bounded window; this is
not comprehensive renderer acceptance. Original profiles remained shut down.
Fresh app terminated and phone shut down; private fixtures/save retained.

**Open / next:** progress fresh iPad beyond the river tutorial to a real level
transition and cold-reload checkpoint; continue touch/menu comparison. Full
story, representative phone chapters, two distinct progressed saves and ordinary
macOS gameplay remain open. Chris retains signing identity and eventual physical
touch/controller, audio-route and long-play checks. Local commit only; no push.

### 2026-10-01 — Bounded Simulator trigger/shoulder commands

**Progress:** preceding reply corrected the audio claim without implementing
anything. Read full objective, clean `58cca06`, pins and 20 GiB free. No audio
investigation. The baseline iPad close-icon edge tap already closed Settings;
discarded the proposed hit-area edit rather than claim an established defect.

**Pass, diagnostic boundary:** added physical LB/RB/LT/RT names to the opt-in
virtual controller and CLI. Existing mappings, game logic and production UI
are unchanged. Apple documents these configured elements at
https://developer.apple.com/documentation/gamecontroller/gcvirtualcontroller/configuration/elements.
Probe Release build exited zero (`work/trigger-probe-{configure,build}.log`);
installed executable SHA256 on both fresh 18.5 profiles:
`f0049d11ffeea3e21d861c3006982c3cadba275ff8509f6c9853f5710a33d7cc`.
iPad ran first, then shut down before iPhone boot. Both connected without error;
command/release logs `work/trigger-probe-{ipad,phone}-run.log`.

**Partial visual evidence:** preserved iPad GAME1 loaded through ordinary
Start/A. LT showed a lower crouched posture; timeout returned upright. RB
changed the view in the captured sequence. Viewed private captures
`work/evidence/trigger-ipad-{standing,held-lt,released}.png` and video contact
sheet `trigger-ipad-contact.png`. Z+A jump/tutorial success is **not proven**.
Phone GAME1 loaded normally; LT/RT/RB commands expired, but viewed images do
not establish distinct crouch/camera behavior in that early scene. Settings hid
14 gameplay buttons plus stick and X restored them; viewed
`work/evidence/trigger-phone-{settings,return}.png`. This helper is not touch
or hardware acceptance. No level transition or new checkpoint claimed.

**Pass, restoration:** normal OFF configure/Release build exited zero
(`work/trigger-normal-{configure,build}.log`). Reinstalled preserved normal app
on both profiles, executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`;
both terminated and shut down. Pre-play private EEPROM backups retained:
`work/trigger-probe-save-before.bin` and `work/trigger-phone-save-before.bin`.
No saved preferences reset. Local commit only, never push.

**Next:** use bounded held Z/A and shoulder commands to test the river tutorial
and the next real transition; retain ordinary touch/menu checks. Full story,
distinct progressed checkpoint reloads and macOS gameplay comparison remain
open. Chris still supplies signing and eventual physical touch/controller,
audio-route and sustained-play acceptance. Audio remains unverified/deferred.

### 2026-10-01 — Normal iPhone background/foreground recovery

**Progress:** preceding turn restored the normal iPad app and disabled the
probe; it did not advance gameplay. Read the full objective, clean `43fb1f8`,
source pins and 20 GiB available. Audio remains unverified/deferred at Chris's
direction. No game, input or audio implementation changed.

**Pass, bounded recovery:** fresh iPhone 16 Pro / iOS 18.5 profile
`AE64D60E-CE76-42D7-A50E-9E2179F23805`, normal executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`,
probe OFF. Ordinary Continue/Start/A loaded preserved GAME1 ($0 / 0:06:03)
into the first field. Simulator Home backgrounded gameplay at 10:14:26 UTC;
opening its Home-screen icon returned to the same field at 10:16:02 UTC.
Touch Start then visibly paused and resumed the game. Repeated Home/icon
transition at 10:17:32–10:18:05 UTC returned to the field again. `launchctl list`
confirmed the original PID 19771 during both background intervals. Viewed
private screenshots `work/evidence/lifecycle-phone-{slot-before,before-home,
home,return,pause-after-return,second-return}.png`. Runtime log:
`work/lifecycle-phone-runtime.log`. This establishes basic recovery, not precise
game-clock suspension, held-input release, audio or interruption acceptance.

**Preserved:** private before/after EEPROM fixtures
`work/lifecycle-phone-save-{before,after}.bin`, respective SHA256
`6b63cde4fe5b166f9b0f2a9974b2e793e8392fd35e08425d5aa2b743b0a9d23a` /
`f1d7f1f817e8df68dfdb144ea60fc546d7db6a70527961dd90141bfa24e2df3f`.
The hashes differ; they do not prove a new gameplay checkpoint. No save or
preference reset. App terminated and Simulator shut down; none remains booted.

**Open / next:** complete the iPad river tutorial and checkpoint reload, then
repeat phone input/lifecycle at progressed checkpoints. Full story, macOS
ordinary gameplay comparison and the remaining G4/G5 matrix remain open.
Chris retains signing and eventual physical touch/controller, audio-route and
long-play checks. Local evidence commit only; never push.

### 2026-10-01 — Cold-reload tutorial observation; audio work deferred

**Progress:** preceding turn restored and hash-verified the normal app. Read the
full objective, clean `12f62ef`, source pin and 19 GiB free. No audio experiment,
game logic, save implementation or production input change. Historical audio
procedures are explicitly marked as evidence rather than an active task queue.

**Partial observation:** fresh iPad M4 / iOS 18.5 profile
`605FB671-1720-4C19-A3BE-AE425323D052`, existing opt-in probe executable
`f0049d11ffeea3e21d861c3006982c3cadba275ff8509f6c9853f5710a33d7cc`.
Continue/Start and bounded controller commands loaded GAME1 $0 / 0:46:56.
Short movement reached the outer B pad. Conker stood upright before ordinary
touch B; the observed B window did not replay the cure sequence. LT+A and A
captures showed airborne movement. These observations weaken the hypothesis
that reload requires the cure again; they do not prove every saved ability,
jump height, helicopter behavior or a distinct progressed checkpoint. No save
patch is justified. Viewed private captures `work/evidence/river-cure-{menu,
pad-on,highjump-check,normaljump-check}.png`; log `work/cure-reload-check.log`.
The later movement attempt did not reach the island or a level transition.

**Preserved/restored:** 2048-byte EEPROM retained privately at
`work/cure-reload-save-after.bin`, SHA256
`ac70f827ffa8cdad2544a6f7f1ad2d15103d5bb4f0c76675dae9c1199f246f22`.
Terminated runtime, consumed console session (exit zero), reinstalled normal
app in place and verified executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`.
Probe config remains OFF; Simulator shut down. Saves/preferences retained.

**Next:** establish ordinary macOS gameplay with the same checkpoint before
attributing navigation or save behavior to the port. Do not repeat speculative
cure/save fixes or audio counter sweeps. Full story and remaining acceptance
remain open. Chris retains signing and eventual physical touch/controller,
audio-route and long-play checks. Local commit only; never push.

### 2026-10-01 — Same-checkpoint macOS comparison; no save fix warranted

**Progress:** previous turn restored the original macOS frontend and rebuilt it;
audio remains unverified/deferred, not an established blocker. Read the full
objective, clean `48c31f0`, pins and 19 GiB free. No production code changed.

**Pass, diagnostic comparison only:** isolated private macOS profile copied the
preserved 2048-byte iPad tutorial EEPROM, with ordinary profiles left intact.
Existing private probe executable SHA256
`4e6b0df14a0b55599ee993ca5d867bcbe26b0f58252ba9319fe13a06171f9a2a`
used expiring direct N64 callback commands (not ordinary keyboard acceptance).
Ordinary Return started the game; held L skipped the intro; two separately
observed A commands selected GAME1 $0 / 0:46:56 and loaded the field. Conker
stood upright, matching the iPad cold-reload observation. Bounded analog
movement reached the outer pad approach and river bank. Viewed private captures
`work/evidence/macos-checkpoint-{title2,slot,field,movement,bank}.jpg`; log
`work/macos-checkpoint-probe-run2.log`. This further weakens a port-specific
cure/save regression; no save or game logic change is justified.

**Not proved:** river crossing, helicopter action, new checkpoint, full story,
ordinary macOS keyboard gameplay, or audio. The 180-second process ended
(exit zero); the final river-attempt capture showed the launcher and does not
prove the attempted action. No ConkerRecomp process remains. Original frontend
bytes match the pre-experiment backup; restored build exited zero, executable
SHA256 `30c7fdc86d28622325eeebfabe89611bdd3fc6c9f7e5b4f8e01eac1a593f0bd3`.
Private probe remains isolated under ignored work/. No Simulator state changed.

**Next:** continue visible ordinary iPad gameplay from the preserved checkpoint;
use this macOS scene control before attributing navigation to a port defect.
Chris retains signing and physical touch/controller, audio-route and long-play
acceptance. Audio tuning stays deferred unless an audible defect is reproduced.

### 2026-10-01 — Current normal build on iPadOS 26.5

**Progress:** previous turn produced the same-checkpoint macOS comparison.
Read the full objective, clean `59b67e9`, pins and 19 GiB free. No audio, game
logic or production input change. Normal iPad 18.5 replay loaded the tutorial
slot through ordinary L/A and paused through Start. Brief automated stick
drags did not establish sustained movement; existing sub-frame timing evidence
still applies. No input fix is justified by those attempts.

**Pass, bounded compatibility/recovery:** installed normal executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`
in place on iPad Pro 13-inch (M5), iPadOS 26.5,
`68016FEA-1887-4E05-A7F4-B26EC8572B8A`, probe OFF. Preserved pre-install
EEPROM/preferences privately under `work/pad26-compat-before/`; no reset.
Continue Imported ROM, touch L, A, A loaded existing GAME1 $0 / 0:06:03
into the first field. Rotating the initially portrait Simulator gave landscape.
Touch Start paused; three-dot Settings hid gameplay controls; X restored
controls and touch A resumed. Home backgrounded the app; it was confirmed
backgrounded at 11:21:06 UTC, and its ordinary Home icon returned to the
same field by 11:22:40 UTC. Original PID 24243 persisted through both checks.
Viewed private screenshots `work/evidence/pad26-normal-{slot,field,pause,menu,
resume,return}.jpg`; runtime `work/pad26-normal-compat.log`.

**Limits / next:** this passes current-build startup, preserved import/save
loading, pause/menu return and basic recovery on the newer iPad runtime. It
does not establish exact game-clock suspension, held-input release, sustained
stick play, distinct checkpoint fidelity, audio or full story. Repeat the
current-build compatibility route on iPhone 17 Pro / iOS 26.5. Full-story
progress remains open. Both runtime console sessions exited zero; iPads shut
down, preferences/saves retained. Chris still supplies signing and eventual
physical touch/controller, audio-route and long-play acceptance. Never push.

### 2026-10-01 — Current normal build on iPhone 17 Pro / iOS 26.5

**Progress:** previous turn verified current-build basic recovery on iPadOS 26.5.
Read the full objective, clean `139f320`, pins and 18 GiB free. No implementation
change or audio experiment. Installed normal executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`
in place on iPhone 17 Pro / iOS 26.5,
`7B639924-AD8F-4D5C-AD29-71F47C768A0D`, probe OFF. Preserved private
pre-install EEPROM/preferences under `work/phone26-compat-before/`.

**Pass, bounded compatibility/recovery:** ordinary Continue Imported ROM, L
and A navigation retained GAME1 $0 / 0:06:03 and loaded its first field.
Start visibly paused; three-dot Settings hid gameplay controls; X restored them
and A resumed. Home backgrounded gameplay, confirmed at 11:29:41 UTC; ordinary
Home icon returned to the same field by 11:31:15 UTC. PID 25191 persisted
through both checks. Viewed private captures `work/evidence/phone26-normal-
{details,field,pause,menu,resume,return}.jpg`; log
`work/phone26-normal-compat.log`. C-left produced only a small view change,
insufficient to pass camera acceptance. No reset or save replacement.

**Open / next:** current normal build now has basic startup/preserved-save/menu
return/recovery observations on both 26.5 device classes. Do not repeat these
checks without a new regression. Return to sustained input and tutorial
progression: swim to the small island before attempting the learned high jump
and helicopter route. Full story, distinct progressed checkpoint reloads,
precise game-clock suspension, simultaneous touch and audio acceptance remain
open. Console session exited zero; phone shut down, none booted. Chris retains
signing and eventual physical touch/controller, audio-route and long-play
acceptance. Local commit only; never push.

### 2026-10-01 — Tutorial route observation method corrected

Read the full objective, clean `2e379ae`, pins and 18 GiB free. Previous turn
restored the normal app after the user's audio correction. Audio is unverified
and deferred: no tuning, capture or counter sweep in this turn.

On iPad M4 / iOS 18.5 `605FB671-1720-4C19-A3BE-AE425323D052`, installed
the existing private controller probe in place, preserving saves/preferences.
GAME1 $0 / 0:46:56 loaded; short stick/A commands visibly entered surface
swimming, and C commands changed the camera. Island arrival, the jump lesson
and a new checkpoint were **not achieved**. No input, save or game-logic defect
was established; no implementation was changed.

The observation method allowed gameplay to continue while captures were being
inspected. Added a documented capture-then-ordinary-Start-pause procedure.
Visually confirmed PAUSED between the final measured commands and during later
inspection; the location remained at the same bank/wall while animation could
continue. This is a harness correction, not gameplay acceptance. Viewed private
captures `work/evidence/river-short-{select,bank,turn,forward,water,swim,look,
lookleft,away,behind,upstream,along,offwall,left,channel,cross,controlled,chase}.png`
and `river-short-paused.jpg`; log `work/river-short-route.log`.

Terminated runtime (console session exit zero), restored the normal app in
place and verified executable SHA256
`b6cc43ee9ab0088d85fb2def757e227382fba29995e4c828b10fbab5f30d6f51`;
iPad shut down. Next: reload the preserved tutorial checkpoint and use paused
observations from the island-facing bank, rather than repeating unpaused river
holds. Full story and distinct progressed saves remain open. Chris retains
signing and physical touch/controller, audio-route and long-play checks.

### 2026-10-01 — Original app icon packaged and verified

Added an original acorn icon, its editable Swift generator and the Xcode asset
catalog setting. The opaque 1024x1024 PNG uses no game/reference artwork.
Normal Release builds (Simulator input probe OFF) succeeded for both
iphonesimulator and unsigned iphoneos; both packaged plists name AppIcon.
Simulator executable SHA256:
`2fe63a72a2b982168e7a32fdf7b67f2122a37d86aca21aa3c9a6ab97a23d312d`.

Installed in place, preserving existing data. Visually verified the icon on
iPad M4 / iOS 18.5 Home and iPhone / iOS 18.5 Spotlight, then opened the app
through each icon and verified its ROM launcher. Viewed private screenshots
`work/evidence/app-icon-pad-{home,launch}.jpg` and
`work/evidence/app-icon-phone-{search,launch}.jpg`. Both Simulators shut down.
This is icon/startup verification, not new gameplay acceptance.

The preceding paused tutorial navigation attempt did not reach the island or
establish a bug; no game logic or input change was warranted. Full story and
distinct progressed checkpoint reloads remain open. Audio remains unverified
and deferred following Chris's correction: counters alone do not demonstrate
an audible defect or its cause. No audio changes or additional audio sweep.
Chris retains signing and eventual physical touch/controller, audio-route and
long-play checks. Local commit only; never push.

### 2026-10-01 — Bounded tutorial navigation did not close progression

Previous turn: progress (original icon, both SDK builds and inspected icon
launches). Read the full objective; clean `9be94dc`, upstream/runtime/RT64 pins
unchanged, 18 GiB free. Audio remains deferred; no audio experiment.

Built the existing opt-in controller probe, SHA256
`73010fecab2d1b3f4dc9c325e0e3d9d6b1dd7f3859044ab9d7b8927f19354293`,
and installed in place on iPad M4 / iOS 18.5
`605FB671-1720-4C19-A3BE-AE425323D052`. Preserved GAME1 $0 / 0:46:56
loaded. Short bank/alignment commands, forward holds of 2 and 10 seconds,
then a 5-second diagonal command showed bank, surface swimming and a wall
location. Ordinary Start visibly paused between observations. Island lesson
and a new checkpoint: **Not achieved**. No reproducible port defect established;
no input or game-logic patch. This is diagnostic navigation, not ordinary-touch
story acceptance.

Private logs: `work/tutorial-route-{config,build,run}.log`; inspected captures:
`work/evidence/river-guided-{bank,align,long,cross}.png` and the paused CUA
views. The walkthrough locates the lesson after reaching the island before the
waterfall: https://gamefaqs.gamespot.com/n64/196973-conkers-bad-fur-day/faqs/13734
Do not infer a broken trigger from failing to reach that location.

Terminated runtime (console exit zero), restored normal icon build SHA256
`2fe63a72a2b982168e7a32fdf7b67f2122a37d86aca21aa3c9a6ab97a23d312d`,
disabled the probe configuration and shut down iPad. No reset/save replacement.
Next action: establish actual stick direction/travel from a fixed camera on
dry land against the macOS control before another river attempt. Full story,
distinct progressed checkpoint reloads and physical/signing gates remain open.

### 2026-10-01 — Refresh stale macOS comparison bundles explicitly

Previous turn: no story progress; bounded navigation remained inconclusive.
Read full objective, clean `0e69d0b`, pins unchanged and 18 GiB free.
The packaged normal macOS control had executable SHA256 `7e3a7bd8…`, while
the current host was `30c7fdc8…`. Added `--refresh` to the packaging script,
with an ownership check and printed executable hash; documented closing the
app before refreshing. Default overwrite refusal remains.

**Pass, packaging:** refreshed bundle exactly matches host SHA256
`30c7fdc86d28622325eeebfabe89611bdd3fc6c9f7e5b4f8e01eac1a593f0bd3`.
Launcher visibly started and ordinary Exit closed it (session exit zero).
Viewed `work/evidence/direction-refreshed-launcher.jpg`; logs
`work/direction-refresh-result.log` and `work/direction-refreshed-control.log`.
Default repeat packaging rejected; a disposable unrelated-bundle fixture was
rejected with exit 2 before creating MacOS files.

**Not achieved:** fixed-camera movement comparison. Initial old diagnostic
executable was the wrong control; discarded its keyboard observations. The
verified normal executable showed intro/slot menu, but brief automated taps
did not establish slot selection or movement. These misses do not prove an
input defect. Diagnostic and temporary normal processes required termination
(exit 137); refreshed launcher subsequently exited cleanly. None remain.
No Simulator or production game/input/audio changes.

Next: use the correctly refreshed normal control for acceptance; establish a
held-input observation before attempting movement parity. Upstream
`host/src/conker_config.cpp` identifies R as camera centering, so use R when
establishing a reproducible camera rather than assuming C-down centers it.
Full story and checkpoint acceptance remain open; audio stays deferred.

### 2026-10-01 — Bounded axis-direction comparison

Previous goal turn: no product progress; acknowledged the audio correction and
closed the idle diagnostic launcher (exit zero). Revalidated clean `fa87284`,
the full objective, upstream/runtime/RT64 pins and 17 GiB free. Audio deferred.

Corrected this run's profile selection: macOS uses `APP_FOLDER_PATH`, not the
iOS-only `SQUIRRELPAD_DATA_DIR`. The first run showed an empty slot and was
discarded before starting a new game. Documented the selector in README.
The correctly isolated profile displayed GAME1 $0 / 0:46:56 and loaded the
upright field. Private macOS probe SHA256 `4e6b0df1…` used expiring direct N64
commands: R (`16`) for 0.5 seconds, positive Y for 0.7, positive X for 0.7.
Both axes visibly moved Conker in their expected screen-relative directions.

**Pass, diagnostic direction only:** installed existing Simulator probe SHA256
`73010fec…` in place on iPad M4 / iOS 18.5
`605FB671-1720-4C19-A3BE-AE425323D052`, launched with
`SIMCTL_CHILD_SQUIRRELPAD_SIM_INPUT=1`, and used ordinary Continue Imported ROM.
Same displayed checkpoint loaded. `scripts/simulator-input.py` commands RB/0.5s,
Y=1/0.7s and X=1/0.7s moved forward/right; ordinary touch Start visibly paused.
No simple axis-sign divergence established. Cameras differed; this is not exact
trajectory, timing, ordinary held-touch or full-story acceptance. No input patch.

Viewed private captures `work/evidence/direction-{mac,pad}-{centered,y-positive,
x-positive}.jpg`; logs `work/direction-calibration-{macos,pad}.log`. Mac probe
processes terminated (exit 137); Simulator console ended zero. Restored normal
icon app SHA256 `2fe63a72…` in place and shut down iPad; no Simulator remains
booted. No game/save reset or audio tuning. Clarification to the prior entry:
the old probe forwards ordinary input when its command environment is absent;
brief keyboard misses did not demonstrate suppression by that probe.

Next: continue ordinary gameplay toward the island lesson with confirmed axis
directions; record a newly reached checkpoint and cold reload before claiming
progression/save acceptance. Full story, meaningful save fidelity and physical
signing/device gates remain open. Local commits only; never push.

### 2026-10-01 — Tutorial attempt: jump works, island not reached

Previous turn: progress in diagnostic axis evidence/profile setup, no story
progress. Read full objective; clean `0411fff`, runtime/RT64 pins unchanged,
17 GiB free. Audio remains deferred. Existing iPad M4 / iOS 18.5 probe build
`73010fec…` installed in place; normal ROM Continue and touch A loaded GAME1
$0 / 0:46:56. Preserved 2048-byte EEPROM in ignored
`work/island-route-save-before.bin`, SHA256
`ecc47d1349c2309c25f0493a2d5ae3052bee9bc3d159e98866d5fbb40b9bf272`.

**Pass, diagnostic inputs only:** short stick commands reached the river;
C-down restored the field view after an initial wall approach; A/0.5s visibly
jumped on land. Stick X=-1 plus A/1s moved into water. Ordinary touch Start
paused and ordinary touch A resumed. **Not achieved:** island lesson, new
checkpoint or full-story progression. No reproducible port defect established;
no game/input/save patch. These controller-probe actions do not prove ordinary
held-touch acceptance.

Inspected `work/evidence/river-island-{bank,back,camera,right,water,approach,
bank2,straight,swim,land-camera,jump,turnback,wall-exit,stick-a}.png`.
Recorded `work/evidence/island-wall-observation.mov`; inspected its sampled
`island-wall-contact.png`: the bounded backward command moves out from the
wall to the water edge; it does not show a respawn. Do not infer a death or a
broken trigger from endpoint images. Log: `work/island-route-run.log`.

Terminated probe (console exit zero), restored normal icon build `2fe63a72…`
in place, shut down iPad; no reset or save replacement. Next route attempt
must use a short continuous video of the crossing and inspect its trajectory,
rather than another sequence of endpoint guesses. Full-story/save-fidelity
requirements remain open; Chris retains signing and eventual physical checks.
Local evidence commit only; never push.

### 2026-10-01 — Keep customized touch targets inside safe bounds

Previous goal turn: no product progress; acknowledged that audio counters do
not establish an audible defect. Audio remains unverified/deferred. Read the
full objective, clean `d2ac697`, upstream/runtime/RT64 pins unchanged; 17 GiB
free. Worked on the reference's concrete layout behavior, not another audio
experiment or unsuccessful endpoint navigation loop.

**Fixed:** `TouchControlsView` now clamps each rendered control's full scaled
bounds inside the current window safe area, with 4-point padding. The stick's
input center uses that same bounded center. Previously only normalized center
percentages were constrained, so large controls could extend off-screen or
into unsafe areas. Reference: HarkinianPad's
`clampControlToSafeBounds:` and `docs/customizable-touch-controls.md`.
No reference code/art copied; no game, audio or button-mask changes.

The first iPhone screenshot exposed an adjacent regression: clamped wide
shoulder buttons overlapped the default Start/C-up targets. Moved default
phone Start and the C cluster inward by 0.057 normalized width, retaining
C-cluster relative spacing; saved custom positions remain intact. The final
phone screenshot shows separated Start/R and C-up/L. Individually selecting
Start and C-up in the editor selected the intended control.

**Pass, scoped UI checks:** incremental Release arm64 Simulator and unsigned
device builds, normal input-probe OFF. Logs:
`work/safe-bounds-build-{simulator,device}.log`, both BUILD SUCCEEDED/exit zero.
Final Simulator executable SHA256
`c8ae9699f106136bf3ff24ddda2b015f2b6bf7843f1493982b23ed63fa3400dc`;
unsigned device executable
`53e9e499be8d7d06cbe95e31acbd7f623fea76a7c698728794d98788ac45ac41`.
Installed the final same Simulator build in place on iPad M4 iOS 18.5
`605FB671…` and iPhone 16 Pro iOS 18.5 `AE64D60E…`, one at a time.
Preserved imported ROM and EEPROM; used ordinary ROM Continue and three-dot
menu/editor flows. Both normal apps remain installed, both Simulators shut down.

**Pass, intermediate build `c436c252…`, identical tablet code:** on iPad,
selected L, changed Size to displayed 150% (actual 1.498), dragged it to the
bottom-right edge, Done, terminated/relaunched, ROM Continue, reopened editor:
L retained its position and displayed 150%. Its full outline stayed above the
home indicator. Viewed `work/evidence/safe-bounds-pad-{editor,relaunch}.jpg`.
Reset only this controlled tablet layout through editor Reset/Done. Final
build rechecked preserved defaults:
`work/evidence/safe-bounds-pad-final-default.jpg` (viewed).

**Pass, final phone build:** saved L at bottom-right, terminated, updated in
place, relaunched and continued ROM: full outline remained in safe bounds.
Viewed `work/evidence/safe-bounds-phone-relaunch.jpg`. Reset only the controlled
phone layout via editor Reset/Done; viewed `safe-bounds-phone-default.jpg`.
**Not verified:** phone 150% slider resize. Automation's slider setValue could
change the AX value without changing the bound percentage, and fast drags did
not establish a resize. Do not count that as successful input or a product bug.
Phone edge persistence passed at approximately 100% size instead.

This closes a touch-layout clipping defect, not full G4/G5/G6. Arbitrary custom
control overlap is still possible (as in the reference); full story, sustained
ordinary multitouch and distinct progressed saves remain open. Next: establish
ordinary sustained stick/button acceptance before using it for story progress;
avoid repeating unobserved endpoint guesses. Chris retains signing and eventual
physical touch feel, controllers, audio routes and long play. Local commit only;
never push. No physical-device acceptance claimed.

### 2026-10-01 — Reset touch gesture state on focus loss

Previous turn: progress, verified safe-bound layout fix `6f63ae7`. Read full
objective and current sources; clean checkout, upstream/runtime/RT64 pins
unchanged, 17 GiB free. Audio remains unverified/deferred; no audio measurement,
tuning or diagnosis in this turn.

**Code finding / safeguard:** native touch state was cleared on inactive scene
and interruption, but the SwiftUI overlay stayed mounted with local `held` and
stick-offset state. A cancelled gesture does not necessarily run `onEnded`.
Now the overlay is present only while scenePhase is active and no interruption
is pending. Removing it invokes the existing `onDisappear` button/stick cleanup;
return recreates neutral local gesture state. This is a five-line shell change,
not a reproduced claim of a Simulator stuck-input incident. Button masks,
analog math, renderer, game logic and audio implementation are unchanged.

**Pass:** incremental Release builds for arm64 iphonesimulator and unsigned
iphoneos, both exit zero / BUILD SUCCEEDED, probe OFF in both caches. Logs:
`work/touch-focus-build-{simulator,device}.log`. Executable SHA256:
Simulator `f6b8419e39a1b340483718691ab66d9fc83e1e03c2b9f3e629fab9e08aae1b70`;
device `0b520ebdf37db953b10d4b3f51470e0839de539d77cad7089912aaa9691a1387`.

**Pass, scoped ordinary UI/lifecycle regression:** same normal Simulator build,
in-place install, iPad M4 iOS 18.5 `605FB671…`, then iPhone 16 Pro iOS 18.5
`AE64D60E…`. Used ordinary ROM Continue, Start, A to load preserved GAME1.
iPad slot $0 / 0:46:56, iPhone slot $0 / 0:06:03. No save replacement/reset.
Home via Simulator toolbar removed the touch controls from app accessibility
state; inspected Home screen; tapped app icon to return. Controls reappeared
with neutral visuals, same scene returned, ordinary Start produced PAUSED;
ordinary A resumed, three-dot Settings opened on both classes. iPhone's first
field cutscene was still running at Home; it returned there, subsequently
reached the field and paused. This is not exact game-clock suspension proof.

Viewed private captures:
`work/evidence/touch-focus-{pad,phone}-{before,home,return-pause,settings}.jpg`.
Terminated normal apps and shut down each Simulator; normal apps remain
installed and private ROM/EEPROM/settings preserved. No macOS change; this
lifecycle view boundary is specific to UIKit.

**Not run / still open:** a sustained touch held across focus loss, simultaneous
ordinary multitouch, interruption delivery, exact game-time matrix, distinct
progressed checkpoints, full story, physical device checks. The view lifecycle
and post-return input checks establish this safeguard's adjacent behavior;
they do not close full G4/G5/G6. Next work should return to the lowest unfinished
control gate: ordinary macOS keyboard gameplay/save/relaunch with an isolated
preserved profile, before more speculative input changes or island guesses.
Chris retains signing and eventual touch feel, controllers, audio routes and
long-play hardware checks. Local commit only; never push.

### 2026-10-01 — Ordinary macOS keyboard loads preserved GAME1

Previous turn: progress, touch focus safeguard `9cb0420`. Read full objective,
current source/ledger and 17 GiB free. Clean checkout. No audio sweep or
implementation change. User questioned continued small checks during this run;
remaining high-value work is story progress, distinct checkpoint reloads and
sustained ordinary combined input, not more startup/counter checks.

**Pass, scoped normal keyboard route:** macOS bundle and host executable both
SHA256 `30c7fdc86d28622325eeebfabe89611bdd3fc6c9f7e5b4f8e01eac1a593f0bd3`.
Launched normal bundle executable with
`APP_FOLDER_PATH="$PWD/work/macos-checkpoint-comparison"`, no input-probe
environment or callback override. Ordinary Return started the launcher;
12 brief ordinary Return presses reached game selection (intro timing means
this does not prove which individual press skipped it). One Space press had
no visible selection effect; 12 Space presses opened GAME1 $0 / 0:46:56,
another 12 chose Play and visibly loaded the upright first field.
This establishes normal keyboard-to-game loading, and rules out complete
suppression. It does not establish reliable duration or sustained gameplay.

Viewed private `work/evidence/ordinary-mac-{return-retry,a-once,a-retry,play,
field,right,forward,pause,exit-menu,exit-action}.jpg`. Brief D/W and Return
press batches after loading showed no clear movement/pause effect. **Not
verified:** sustained movement, pause by keyboard, new save or cold relaunch.
Current SDL mapper polls keyboard state; brief automation presses can miss
polling. No reproducible mapping defect established and no input code patch.

Ordinary Escape opened frontend Settings, mouse exit icon opened confirmation,
Quit terminated the exact run normally (exec console exit zero). No forced
kill required; post-exit CUA procNotFound is consistent with the ended process.
Log `work/ordinary-mac-control.log`; isolated existing EEPROM SHA256
`ac70f827ffa8cdad2544a6f7f1ad2d15103d5bb4f0c76675dae9c1199f246f22`.
Normal user profile untouched, no reset/new-game selection. No Simulator run.

Next: actual story progression with trajectory evidence and two genuinely
different progressed save reloads; qualify sustained ordinary combined input.
Avoid interpreting failed short automation presses as broken game logic or
rewriting polling solely for automation. Full G1/G4/G5/G6 and physical/signing
acceptance remain open. Audio deferred; local evidence commit only, never push.

### 2026-10-01 — GitHub synchronization and bounded movement recording

User explicitly authorized updating GitHub, superseding the earlier local-only
restriction for this synchronization. Verified origin is
`chrissotraidis/squirrelpad`, private, initially without remote refs. Tracked
files and object paths contain no ROM, EEPROM, generated game source, build
or gameplay captures. Pushed main at `e64cc01`; no visibility change or binary
release. This entry is included in the subsequent source synchronization.

**Pass, diagnostic scope only:** iPad M4 iOS 18.5 `605FB671…`, cached opt-in
Simulator probe executable `73010fec…`, ordinary Continue / Start / A loaded
preserved GAME1 $0 / 0:46:56. Private EEPROM copied before movement to
`work/river-current-save-before.bin`, 2048 bytes, SHA256
`3b067f30720d15471faee8c69614a46d1474afe273750841cd72f6c01b4c6b1e`.
Bounded X/Y and C Down commands visibly changed position/camera. Combined
X=1 plus A, 0.8 seconds, captured Conker airborne beside Birdy's fence.
This is controller-probe integration evidence, not ordinary multitouch proof.

Viewed private captures `work/evidence/river-current-{start,bank,away,
river,edge,water,combined}.png` and sampled contact sheet
`river-current-contact.png` from `river-current-trajectory.mov`. Recording
includes idle time and sideways frames; showed wall / first-field movement,
not a successful river crossing. No respawn or new port defect established.
Log: `work/river-current-run.log`. **Not passed:** island lesson, new checkpoint,
two distinct progressed save reloads, full story. No game/input/audio changes.

Restored normal Simulator app `f6b8419e…` in place, launched without probe
environment, then terminated and shut down the Simulator. Private data
preserved. Next work: establish a reproducible bank-to-island route with
camera-relative direction observations before another crossing attempt;
compare macOS if a reproducible divergence appears. Audio remains deferred.
Chris retains signing and eventual physical touch/controller/audio/long-play
checks. Story progression remains ours; it is not a physical-device blocker.

### 2026-10-01 — River trajectory compared with isolated macOS control

Previous goal turn: progress (GitHub synchronized, combined jump evidence);
full objective re-read. Clean `e60a6dc`, 16 GiB free; upstream `c55359c…`,
RT64 `43373749…`. No implementation patch or audio tuning.

**Observed, diagnostic scope:** iPad 18.5 `605FB671…`, probe `73010fec…`,
preserved GAME1 $0 / 0:46:56. Used R .5s, X=-1 1s, X=1 3s, Y=-1 1s,
two released C Down .2s pulses to establish the river/grass/platform landmark.
Then X=.45/Y=.9 1.5s; X=-.65/Y=.75+A .8s entered water; Y=1 for 1s,
2s and 6s. Recording `work/evidence/river-landmark-swim.mov` (28.49s)
and viewed sampled contact sheet show swimming and downstream drift to the
sloped bank, including neutral-input time. Y=1+A 1s exited onto that slope.
No island lesson or new checkpoint; no respawn asserted. Viewed
`river-landmark-{initial,left,right,wide,approach,enter,swim,upstream,long,
exit-water}.png`, contact sheet; log `work/river-landmark-run.log`.

**Scoped macOS comparison:** copied isolated existing profile into
`work/macos-river-landmark` (normal profile untouched), installed exact
pre-test EEPROM from `work/river-current-save-before.bin` (`3b067f30…`).
Launched cached comparison bundle `4e6b0df…` with APP_FOLDER_PATH and opt-in
SQUIRRELPAD_COMPARISON_INPUT, ordinary Return launcher, bounded Start/A menu
commands. Same visible slot. Initial camera/position after command sequence
was not identical, so this is not exact trajectory parity. At visually
matched river bank, same diagonal+A entry and Y=1 1s/2s/6s sequence also
ended in water at the downstream sloped bank. Viewed private
`river-mac-landmark-{wide,enter,bank,swim}.jpg`; log
`work/macos-river-landmark.log`. This does not establish an iOS-only movement
defect. It also does not prove that the tutorial cure flag is set or persisted.

Guide consulted: https://www.gamerevolution.com/guides/28824-conkers-bad-fur-day-walkthrough
(paraphrased route only). StrategyWiki fetch returned 403; no claim from it.

Restored normal `f6b8419e…` Simulator build in place and shut down iPad;
macOS quit UI did not terminate the comparison process; stopped the verified
exact test PID 40410 with SIGKILL after SIGTERM also left it live (console
exit 137). Exit behavior of this private comparison bundle is not passed.
No reset/erase or normal
save replacement.
**Next:** qualify current tutorial cure/context-pad state after load and verify
its interaction before another swim; use the same saved state on macOS if a
divergence appears. Full story and distinct progressed reload gates remain
open. Audio deferred; physical/signing checks remain Chris's. Local evidence
commit only in this continuation; prior explicit GitHub sync already completed.

### 2026-10-01 — Cure-pad revisit and requested GitHub refresh

User requested the repository be current on GitHub and continued testing.
Fetched origin; private repository, local main ahead by the previous macOS
comparison evidence commit. This request authorizes the source/evidence sync.

**Observed, diagnostic scope:** iPad 18.5 `605FB671…`, opt-in probe
`73010fec…`, preserved GAME1. Pre-test EEPROM backup
`work/cure-revisit-before.bin`, 2048 bytes, SHA256
`6e900594b2375deeae2aab54db347a6419b9f483185f8c64357edd1b05f0dd49`.
Reached outer context pad upright; ordinary B and bounded probe B did not
replay cure animation. Consistent with an already cured state, but no internal
flag or persistence proof. Viewed `river-cure-{initial,approach,pad,center,
onpad,b-result,bank,swim-held,forward-held,backaway}.png` privately.

Forward-held capture (Y=1 for 10s, screenshot delay 2s) showed Conker against
a wall, not swimming. Y=-1 for 3s visibly moved away. Capturing during held
input therefore did not establish a crossing or an input defect. No new
checkpoint, story-progress pass, game-logic patch or audio change. Log:
`work/cure-revisit-run.log`. Avoid treating these navigation attempts as
completion evidence.

**Pass, restoration only:** installed normal `f6b8419e…` in place, launched
without probe environment, ordinary Continue Imported ROM displayed game
intro with controls (viewed CUA screenshot). Subsequent saved capture
`github-sync-normal-restored.jpg` caught a black transition and is not
a gameplay proof. Terminated normally and shut down iPad; no erase or save
replacement. iPhone not rerun in this check; no source change.

Next meaningful acceptance remains tutorial island/hover progression, two
distinct progressed cold-save reloads, and sustained ordinary combined input.
Full story remains open. Chris: eventual signing and physical touch feel,
controllers, audio routes and long play. Audio investigation stays deferred
until a reproducible audible fault warrants it.

### 2026-10-01 — Verify delivered Simulator stick values

Previous turn: progress (requested GitHub sync and cure-pad evidence). Full
objective re-read; clean `a8eb54d`, 16 GiB free; upstream `c55359c…`, runtime
`cdf5abb…`, frontend `b1a1477…`, RT64 `43373749…` rechecked.

**Not passed:** iPad island crossing. Probe `73010fec…`, ordinary preserved
GAME1 load, shorter X/Y pulses and jump combinations reached river-bank
landmarks but returned to first-field bank/wall. Viewed private
`river-island-{start,rightbank,upbank,resetbank,leftbank,entry,water,
swim-diagonal,wide,bank-align,edge-align,cross-hold,swim-straight,wall-away,
camera-reset,behind,heading}.png`. `water` shows airborne river entry;
`swim-straight` shows wall, not successful swimming. No new checkpoint or
port defect established. Log `work/island-route-current.log`. R was mistakenly
used as a camera reset in this attempt; the game manual specifies C Down
for following behind, R for looking/aiming. Subsequent C Down + Y=1 trial
also did not establish a crossing. No game logic or audio changes.

**Pass, diagnostic input scope:** added readback on the next 50ms probe poll
after commands and release. Only `SimulatorInputProbe.swift` changed; default
OFF / Simulator-only build guard and production input paths unchanged.
An API-range concern prompted actual measurement: Apple's setPosition page
documents 0…1, but on this iOS 18.5 runtime the existing signed inputs
read back exactly, and zero reads neutral. Therefore do not remap coordinates
from that documentation alone. Sources consulted:
https://developer.apple.com/documentation/gamecontroller/gcvirtualcontroller/setposition(_:fordirectionpadelement:)
https://www.videogamemanual.com/n64/Conker%27s%20Bad%20Fur%20Day%20%28USA%29.pdf

Final opt-in arm64 Simulator build passed, executable SHA256
`b054ccc52123555c4a72c6fbebf19aef23dbcdd6ffae8a3bf463dc45148dcccb`.
Build logs `work/probe-axis-{build,final-build}.log`. Sequential iPad
`605FB671…` then iPhone `AE64D60E…`, both iOS 18.5, launcher context only:
commands (-.6,1)/camera(.8,-1), then (1,-1)/camera(-1,1), each 1s,
read back exactly. After each expiry both stick pairs read (0,0). Logs
`work/probe-axis-{pad,phone}-final.log`. This verifies probe delivery/release,
not ordinary multitouch or story gameplay. Both consoles exited 0.

Restored normal `f6b8419e…` app in place on both and shut down each Simulator;
no erase/save replacement. No device rebuild necessary for this excluded
probe source. Next: use verified delivery to qualify a camera-stable river
approach and island lesson, then progressed save reloads; avoid sign changes
or gameplay patches without a reproducible divergence. Full story remains
open. Chris retains eventual signing/physical checks. Local commit only in
this continuation; requested prior GitHub sync is already complete.


### 2026-10-01 — Paused river observations and final GitHub refresh

**Diagnostic observation, not a story pass:** iPad 18.5 `605FB671…`,
opt-in probe executable `b054ccc…`, preserved GAME1. Source input trace
(`host/src/main.cpp` → `Support/Conker/mobile_input.cpp` → runtime input)
confirmed no extra Y-axis inversion; no mapping change justified.
`work/heading-route.log` records the run. Viewed private captures
`river-heading-{field,approach,orbit,orbit-right,target,forward,forward-two,
water,swim,swim-left,slope-back}.png` and `heading-paused-step1` through
`step8.jpg`. Surface swimming was visible, followed by bank/wall endpoints.
The island lesson and a new checkpoint were not reached.

Neutral time between tool observations lets the river current move Conker.
Using the existing three-dot Settings pause between short diagnostic trials
made observations easier to compare. A brief Start click did not visibly
pause this attempt; it is not a pause pass. Direct bounded probe commands,
close Settings, capture, and reopen Settings still leave several seconds of
movement, so captures do not prove exact trajectories or ordinary multitouch.
No port defect, game-logic change or audio change established.

**Pass, normal restoration:** terminated the probe (console exited 0),
installed normal Simulator executable `f6b8419e…` in place, launched without
probe environment and selected Continue Imported ROM. Viewed private
`heading-normal-restored.jpg` shows rendered N64 intro with touch controls.
Terminated normally and shut down iPad. Saves and ROM access preserved;
no erase or save replacement. iPhone was not rerun in this route; its
stick delivery/release check is recorded above.

User's requested GitHub refresh includes the diagnostic readback commit and
this evidence update. Repository remains private; ROMs, generated game code,
saves, builds and gameplay captures remain ignored. No release published.
Full story and progressed save reloads remain our open Simulator work.
Chris still needs eventual signing and physical touch feel, controllers,
audio routes and long play. Audio remains unverified/deferred.

### 2026-10-01 — In-game Quit write and normal cold reload

**Pass, session-time persistence; story checkpoint still open:** preserved
GAME1 on iPad 18.5 `605FB671…`, probe build `b054ccc…`. Ordinary Start
visibly opened PAUSED. A short ordinary stick drag did not select QUIT;
bounded probe left selected QUIT, ordinary A opened confirmation, probe
left selected Y, and ordinary A confirmed. Viewed private captures
`camera-follow-{quit-selected,game-quit,quit-confirmed}.jpg` show the sequence.
Slot time advanced from `0:46:56` to `0:48:50`, still $0/Hungover.

EEPROM remains 2048 bytes. Before Quit SHA256
`e28e8069028d725d8fcde0e4c56889ce7a9b6a776ac01992f9764239a0448026`;
after confirmation SHA256
`e6fe3ff0adf39910f51a812ab9c8979c348720c2145bd6a7c3b596b0fb4a279b`,
four changed bytes. Opening confirmation alone did not change the file.
Private fixtures `work/camera-follow-save-{before,after-quit,after-confirm}.bin`.
These changes do not establish a checkpoint flag.

Terminated probe (console exit 0), installed normal `f6b8419e…` in place,
launched without probe environment, continued imported ROM, and navigated
to GAME1 with ordinary controls. Viewed `quit-reload-normal-pad-slot.jpg`
retains `0:48:50`; viewed `quit-reload-normal-pad-field.jpg` shows upright
Conker in the playable first field. Log `work/quit-reload-normal-pad.log`.
After PLAY the file hash differed at offsets 416, 417, 422 and 466; no
byte-identical reload claim. Snapshot `work/quit-reload-normal-pad-save.bin`.
Normal console exited 0 and iPad shut down. No erase or save replacement.

**Not passed:** further camera/swimming trials in `work/camera-follow-route.log`
did not reach the island lesson or a new checkpoint. No reproducible port
defect justified a game/input/audio change. iPhone not rerun in this check.
Next acceptance work remains distinct progressed saves and story progression;
this session-time check does not close G5 or G6. Chris retains signing and
physical touch feel, controllers, audio routes and long play.

### 2026-10-01 — Controller binding menu persistence on both classes

**Pass, menu/persistence scope:** normal Simulator executable `f6b8419e…`,
probe OFF. Sequential iPhone 18.5 `AE64D60E…` then iPad 18.5 `605FB671…`;
other class shut down. In launcher Settings → Controls → Controller Bindings,
changed Z from LT / RT to RT using the picker. Terminated and relaunched the
app, reopened the list, and visually verified RT on both. Private viewed
captures `work/evidence/binding-{phone,pad}-rt-{before,cold}.jpg`.
On both, Remove Z changed the row to Unbound and removed its X action;
Restore Controller Bindings returned Z to LT / RT. Original mappings restored.
Phone Unbound capture: `work/evidence/binding-phone-unbound.jpg`.

Logs `work/binding-persistence-{phone-retry,phone-cold,pad,pad-cold}.log`.
Initial phone launch was denied by SpringBoard immediately after boot;
retrying the same launch succeeded without reinstall/reset. All successful
console sessions exited 0, and both Simulators shut down. Ordinary scrolling
gestures did not establish a lower-list scrolling pass; the accessibility
Restore action brought lower rows into view and reset the mapping. This
does not prove touch scrolling or gameplay/controller execution of RT.

Reference check: the newer customizable-controls patch places Z left at
tablet normalized (.193089,.612859), matching our default, despite the older
design document's right-side Z description. No speculative layout change.
No source, game logic or audio change required by these results.
Still open: ordinary combined input, progressed checkpoints/full story,
controller gameplay, and physical acceptance. Chris retains signing and
physical touch feel, controllers, audio routes and long play.

### 2026-10-01 — Reproducible current developer-bundle audit

**Pass, scoped G8 tooling:** added `scripts/audit-app.py`, documented its
command in README, and refreshed the stale executable hashes in
`docs/SOURCE_BOUNDARY.md`. Ran against normal final Simulator `f6b8419e…`
and unsigned device `0b520ebd…`, using `work/source-final-replay` as the
source context. Both pass: ARM64, correct SDK platform, 30 files and 24
byte-matching notices, matching declared source revisions, no excluded
LiveRecomp/probe symbols, no flagged private names/content or symlinks.
Private reports: `work/package-audit-final-{sim,device}.json`.

**Verified rejection:** existing Simulator probe `b054ccc…` exits 1 for
SimulatorInputProbe symbols (`work/package-audit-probe-rejected.json`).
Temporary copies rejected wrong SDK, deliberately altered RT64 notice,
non-ROM `.z64` filename fixture and symlink, each exit 1. Test copies were
created and removed only inside the owned temporary audit directory.
The audit also checks bundle ID and the exact original ROM digest even if
renamed. Its source revision check measures the supplied checkout, not proof
that an arbitrary app was compiled from that checkout.

Manually inspected non-notice inventory: Info.plist, PkgInfo, executable,
two AppIcon PNGs and Assets.car. `xcrun assetutil --info` reports AppIcon as
the only named catalog asset on both SDKs; metadata retained in
`work/package-audit-assets-{iphonesimulator,iphoneos}.json`.
No app source/game/audio changed, so no runtime rebuild required. Both
Simulators remain shut down. This is not signing, rights clearance, a general
secret scan, story completion or a physical-device pass. Original G1/G4/G5/G6
acceptance and G7 hardware remain open. Next: gameplay and meaningful save
progress, with the audit command available for subsequent final bundles.

### 2026-10-01 — Gameplay landscape reversal on both Simulator classes

**Pass, bounded orientation case:** normal Simulator executable `f6b8419e…`,
probe OFF, sequential iPad 18.5 `605FB671…` then iPhone 18.5 `AE64D60E…`.
Ordinary Continue Imported ROM → Start/L → GAME1 PLAY → first field.
Simulator Device → Orientation → Landscape Right reversed the device bezel;
game and controls remained upright. Start visibly opened PAUSED, A resumed,
three-dot Settings opened without gameplay controls and Close restored them.
On phone, returned to Landscape Left with Settings open, then Close restored
the compact controls and first-field rendering. No source/input/game/audio
change required; not a sustained-motion or held-input rotation pass.

Private viewed captures: `orientation-pad-{before,right,paused,menu}.jpg`,
`orientation-phone-{right,paused,menu,left-restored}.jpg` under work/evidence.
Logs `work/memory-warning-pad.log` (name reflects the initially planned check)
and `work/orientation-phone.log`. Both consoles exited 0 and both Simulators
shut down. Existing slots/ROM preserved; no erase/reinstall/save replacement.

**Not run:** this installed Simulator's inspected Device/Features menus and
simctl command list did not expose memory-warning injection. No warning was
sent, so continued rendering is not memory-pressure evidence. The bundle's
Info.plist declares Landscape Left/Right for phone and tablet; unsupported
portrait rejection was not exercised. Neither this orientation result nor
the package audit closes story completion or progressed-save fidelity.
Next remains gameplay progression and the outstanding lifecycle/input cases.
Chris retains signing and physical touch feel, controllers, audio routes and
long play.

### 2026-10-01 — GitHub sync and normal-build menu lifecycle recheck

**Pass, bounded menu lifecycle:** at Chris's explicit GitHub update request,
synced the three local verified commits through `83a54b0` to private
`chrissotraidis/squirrelpad` main. Restored normal Simulator executable
`f6b8419e…` over the iPad's private probe in place, preserving its app data.
Sequential iPad 18.5 `605FB671…`, then iPhone 18.5 `AE64D60E…`: cold launch,
Continue Imported ROM, moving intro, three-dot Settings, Home, foreground
return to the same process, and Close restored visible touch controls.
Home was visually checked on each class; this is an intro/menu check,
not gameplay-time, held-input, audio or progressed-save acceptance.

Viewed private captures `work/evidence/sync-{pad,phone}-menu-foreground.jpg`
and `sync-{pad,phone}-menu-closed.jpg`. Logs `work/sync-normal-{pad,phone}.log`;
both console sessions exited 0 and both Simulators shut down. The normal
bundle audit passed again (30 files, 24 notices), report
`work/sync-package-audit.json`. No app/game/audio code changed.

**Unverified:** iPhone content scroll and touch drag did not visibly expose
the lower settings rows (`sync-phone-menu-{scroll,drag}.jpg`). This does not
establish whether the cause is automation delivery or app scrolling; ordinary
lower-row access needs a focused reproduction before changing gestures.

**Previous private route trial, no progression pass:** `work/landing-route-pad.log`
and viewed `landing-pad-{approach,bank,camera-reset,backaway,z-crouch}.jpg`
show movement to a land wall and back to Birdy's fence, without reaching the
island. The camera reset and LT crouch attempts had no clear visible result.
Probe stick readback does not establish actual button delivery. Do not infer
a game-logic defect or a new checkpoint from these trials. Probe is now
removed from the installed iPad app; normal build is restored.

Next: qualify lower iPhone menu access, then ordinary combined input and
meaningful story/checkpoint progression. Full story and distinct progressed
saves remain open. Chris retains signing and physical touch feel, controllers,
audio routes and long play; routine speculative audio tuning stays deferred.

### 2026-10-01 — Lower settings access and visibility application

**Pass, accessibility/menu scope:** normal Simulator `f6b8419e…`, probe OFF,
sequential iPhone 18.5 `AE64D60E…` then iPad 18.5 `605FB671…`.
On phone, accessibility selection of offscreen D-pad Buttons and C Buttons
scrolled each row into view and changed it to Off. A coordinate tap on the
visible D-pad switch returned it to On. A later coordinate tap on C did not
change it; Restore Defaults restored both and brought the bottom actions
into view. Original default volume and touch settings restored.
Viewed `work/evidence/menu-lower-phone-{dpad-off,c-off,restored}.jpg`.
This proves accessibility access and bounded toggle behavior, not general
finger scrolling or consistent coordinate delivery.

On iPad, changed both visibility switches Off in launcher Settings, then
Continue Imported ROM: D-pad and C controls were absent from the intro
image and accessibility tree. Reopened Settings, restored both switches On,
closed menu: both control groups reappeared. Other settings preserved.
Viewed `menu-lower-pad-{off,hidden-controls,restored-controls}.jpg`.
Logs `work/menu-scroll-phone.log`, `work/menu-lower-pad.log`; both console
sessions exited 0 and both Simulators shut down. Saves/ROM preserved.

**Unverified drag delivery:** phone coordinate clicks switched Controls/Audio
correctly. Dragging the standard volume slider from (1320,450) to (880,450)
left its value at 0.9996789, rather than about half. Volume restored to 1.
Together with prior failed content drags this makes automation drag delivery
suspect; it does not prove an app scrolling defect. The source already uses
a vertical SwiftUI ScrollView; no speculative gesture replacement warranted.
No app/game/audio source change or rebuild. Next remains a qualified sustained
ordinary input path and story progression with meaningful checkpoint reloads.
Full G4/G5/G6 and hardware gates remain open. Chris retains signing and real
hardware touch feel, controllers, audio routes and long play.

### 2026-10-01 — Qualify private button readback before route diagnosis

**Pass, probe instrumentation:** added individually pressed button readback to
SimulatorInputProbe's existing following-poll axis snapshot, using the ordinary
GamepadButton predicates. No game, production input or audio behavior changed.
Probe-only build passed (`work/probe-buttons-build.log`), executable SHA-256
`c599ad449d69db6d91313f21ff32ba78d8b477892cdb1b5b4c1c09d0e2ce50f6`.
Sequential iPad 18.5 `605FB671…` then iPhone 18.5 `AE64D60E…` launcher commands
LT+A for 1 second read back `buttons=A,LT`, then empty buttons and neutral axes
after expiry. Logs `work/probe-buttons-{pad,phone}.log`. This measures virtual
controller values, not the final N64 mask or ordinary simultaneous touch.

**Bounded iPad gameplay observation:** ordinary Continue → Start/L → preserved
GAME1 ($0, 0:48:50) → PLAY → upright first field. An immediate A/.8-second
command/capture shows Conker airborne (`probe-buttons-pad-a-immediate.jpg`).
LT/3-second command followed by immediate LT+A/.8-second command/capture shows
a lowered pose (`probe-buttons-pad-lt{,-a}-immediate.jpg`); high-jump completion
and crouch acceptance remain unproven. Matching readbacks show LT then A,LT and
neutral release. Earlier separate command/capture calls with 10-second holds
showed standing Conker (`probe-buttons-pad-lt.jpg`, `probe-buttons-pad-lt-a.jpg`),
so those delayed stills do not prove no jump occurred. All captures under
`work/evidence` were viewed. No island or new checkpoint reached. Phone
readback was in launcher only; phone gameplay was not replayed.

Initial immediate capture attempt used an old app-container URL and failed
ENOENT before input. Re-resolved the current container using simctl and retried
successfully. In-place installation can change the container URL; always resolve
it anew instead of retaining a prior absolute fixture path.

Audit correctly rejected the probe (`work/probe-buttons-audit-rejected.json`);
normal `f6b8419e…` still passes (`work/probe-buttons-normal-audit.json`). Both
consoles exited 0, normal app reinstalled in place on both, Simulators shut down.
No save replacement/erase. Next: use immediate, qualified captures for the
river/island route, then ordinary checkpoint reload; do not patch game logic
from delayed screenshots. Full gameplay and physical gates remain open.
Chris retains signing and physical touch feel, controllers, audio routes and
long play.

### 2026-10-01 — Slider cold-relaunch check and requested GitHub sync

**Pass, settings persistence:** normal Simulator build `f6b8419e…`, probe OFF,
sequential iPad 18.5 `605FB671…` then iPhone 18.5 `AE64D60E…`. Changed Control
Size from 100% to 108%, terminated the process, launched again without probe
environment, and reopened Settings. Each displayed 108% after cold relaunch.
iPad slider readback stayed 0.6994012; phone stayed 0.6984586 before the
accessibility click used to expose the offscreen row. That click slightly
changed the phone value to 0.6974952 while still displaying 108%. Viewed
`work/evidence/sync-slider-{pad,phone}-{changed,cold}.jpg`.

**Automation limitation:** `setValue` alone moved the native slider thumb but
left the app's percentage unchanged. A coordinate tap at the new thumb
position applied the change. On phone, accessibility clicking the offscreen
slider exposed it. This is a qualified combined automation path, not general
finger-drag acceptance; no app persistence fix was needed. Returned both
sliders to displayed 100% without resetting unrelated settings. Saves/ROM
preserved; both normal apps installed and both Simulators shut down. Cold
logs `work/sync-slider-{pad,phone}-cold.log`; console sessions exited 0.
Normal package audit passed again: 30 files, 24 notices,
`work/sync-slider-package-audit.json`. No production/game/audio source changed.

**Private route observation, no checkpoint pass:** probe `c599ad44…` on iPad
continued from preserved GAME1 into the first field. Short camera-relative
pulses reached visible surface swimming. Viewed `island-short-01.jpg` through
`island-short-04.jpg`, `island-short-camera.jpg`, and
`island-short-{05-water,06-entry,07-bank,08-swim,09-upstream,10-left}.jpg`
under `work/evidence`; filenames 05/06 describe intended actions, not successful
water entry. The final left-only pulse read back -1,0 then neutral and visibly
changed swimming direction. Island lesson and new story checkpoint were not
reached. Log `work/island-immediate-pad.log`; console exited 0. Normal app
restored in place afterward. These diagnostic actions do not close ordinary
combined-touch or full-story acceptance.

GitHub synchronization is explicitly requested in this turn. Publish the two
verified local commits plus this evidence entry to existing `origin/main`;
private captures, logs, ROM, generated code and saves remain ignored. Next:
qualify sustained ordinary input and meaningful story/checkpoint progression.
Chris retains signing and physical touch feel, controllers, audio routes and
long play. Full G4/G5/G6 and device acceptance remain open; audio tuning deferred.

### 2026-10-01 — Second river route fails to reach a checkpoint

Previous goal turn: progress, cold slider persistence and requested remote sync
at `9374e0f`. Read the complete objective; pins remain Conker `c55359c…`, RT64
`43373749…`; 15 GiB free. No source or game/audio change in this trial.

**Fail, route objective:** iPad 18.5 `605FB671…`, private controller build
`c599ad44…`, installed in place with retained data. Re-resolved the container
before commands. Ordinary Continue/Start/L/A reached preserved GAME1 $0 /
0:48:50, then PLAY loaded the first field. Early capture `island-second-start.jpg`
was the black loading transition, not a loaded-field pass; reopened Settings
and captured `island-second-field.jpg` once visible.

Bounded axis pulses (seconds): (1,.25)/1.5; (-.8,.6)+A/1.2;
(.5,1)/1.2; (-.35,1)/2; (.3,1)+A/1.5; (.2,1)/2;
(-1,0)/2; (0,-1)/1.5; C Down/.4; (1,-.5)/2; (0,1)+A/2;
(1,0)/1; finally (0,-1) with held C Down/1. Viewed
`work/evidence/island-second-01.jpg` through `island-second-10.jpg`,
`island-second-11-land.jpg`, `island-second-camera.jpg`, and
`island-second-held-camera.jpg`. Surface swimming and returning to the original
field are visible. Island lesson, new story progress and progressed-save reload
were not achieved. Log `work/island-second-pad.log`; readbacks include axes,
buttons and neutral expiry. This does not establish a broken input mapper.

**Next action changed:** stop repeating this pulse sequence. Two captures and
accessibility observations between command and menu pause leave neutral game
movement between the pictured position and the actual paused position. A single
immediate capture shortens that interval but has not yet established a reliable
navigation method. Match the camera/input sequence against the macOS control
before another river trial; qualify ordinary sustained input separately. Do not
change game logic from this failed diagnostic route. Consulted N64 manual search
text and controls reference for camera/swimming behavior; no new behavior claim
or gameplay acceptance derives from them:
https://www.videogamemanual.com/n64/Conker%27s%20Bad%20Fur%20Day%20%28USA%29.pdf
and https://strategywiki.org/wiki/Conker%27s_Bad_Fur_Day/Controls .
The manual full-file fetch failed; its search text alone was available.

Restored normal `f6b8419e…` in place, launched without probe environment, viewed
`island-second-normal-restored.jpg` with Continue Imported ROM retained, then
terminated and shut down. Both console sessions exited 0. Saves/ROM were not
replaced or erased. Full G1/G4/G5/G6 remain open. Audio tuning deferred; Chris
retains signing and physical touch feel, controllers, audio routes and long play.
Local evidence commit; the previous requested GitHub synchronization is complete.

### 2026-10-01 — Stationary camera centering comparison

**Pass, narrow camera behavior:** normal iPad 18.5 `605FB671…`, executable
`f6b8419e…`, launched without probe environment. Retained ROM and GAME1
$0 / 0:48:50 loaded the first field. Ordinary touch C Down centered the
camera behind Conker. Viewed `work/evidence/camera-pad-before.jpg` and
`camera-pad-cdown.jpg`. Early Start/L/A attempts during intro did not visibly
activate the slot; after opening and closing Settings, A exposed PLAY and
another A loaded the field. This does not establish the reason for the early
missed actions. No container/save replacement, source change or audio tuning.

**Diagnostic control:** isolated macOS profile `work/macos-camera-20261001`
used a copy of the same primary EEPROM fixture (`65b0fbe2…`), preserving the
original. Cached private macOS executable `4e6b0df1…`: mask 4 with neutral
axes for one second visibly centered the camera; mask 4 with x=1/y=0 for
0.6 seconds ended with Conker in profile near the river bank. Viewed
`camera-mac-cdown.jpg` and `camera-mac-held-cdown.jpg`; log
`work/macos-camera-20261001.log`. Native Settings Quit confirmation exited
console session 92039 with code 0. This cached diagnostic is not exact-build
ordinary-input or identical-trajectory fidelity acceptance.

No iOS-only camera defect was demonstrated. Next: qualify sustained ordinary
movement and simultaneous input before another river crossing attempt. Story
progress, progressed checkpoint reload and full G4/G5/G6 remain open. Normal
iPad app terminated and Simulator shut down; both classes retain normal builds.
Chris retains signing, physical touch feel, controller hardware, audio routes
and long play. Latest human request authorizes updating existing GitHub main;
sync these text evidence records only, leaving private assets ignored.

### 2026-10-01 — Ordinary stick drag remains unqualified

Previous turn made narrow progress: stationary camera comparison and requested
GitHub synchronization at `489cdf0`. Full objective reread; clean checkout,
11 GiB available, source pins unchanged. Normal Simulator executable hash
rechecked as `f6b8419e39a1b340483718691ab66d9fc83e1e03c2b9f3e629fab9e08aae1b70`.

**Not achieved, sustained ordinary movement/release:** iPad 18.5 `605FB671…`
launched without probe environment. Continue Imported ROM, Settings open/close,
Start/L and A/A reached retained GAME1 $0 / 0:48:50 and the first field.
Viewed `work/evidence/touch-drag-pad-{before,after,long}.jpg`. Native UI drags
from (306,989) to (378,989), then to (700,989), did not establish translation;
endpoint stick was centered and field position appeared unchanged. No timed
hold, simultaneous touch or in-gesture capture is exposed by this UI API.
These results cannot distinguish automation delivery/timing from a touch defect,
and do not pass movement or release. Avoid repeating this same drag experiment.

Added a normal-build manual Simulator check to `docs/SIMULATOR_INPUT.md` and
requested the short observation from Chris. Diagnostic controller work may
continue independently, but cannot close ordinary touch acceptance. Console
log `work/touch-drag-pad.log`; no error/assert/failed/fault text matched the
bounded log search (not exhaustive GPU/stability acceptance). Terminated and
shut down iPad; console 82971 exited 0. Normal app/save/ROM retained, no source
or game/audio change. Full story, progressed saves and device gates stay open.
This continuation's evidence and instructions are committed locally.

### 2026-10-01 — Reject failed temporary EEPROM writes

Previous turn produced an ordinary-touch test boundary and manual Simulator
check at `f849f00`; movement remains unqualified. Full objective reread, clean
tracked checkout before this work; Conker/RT64 pins unchanged. Investigated
save failure handling independently, without modifying any user's save fixture.

**Reproduced failure:** `update_save_file()` checked the temporary stream only
when opening it, then ignored write/close failures. The unpatched runtime
writer, with the existing Apple atomic rename helper, installed a **512-byte**
first EEPROM and reported **zero errors** when a child process's file-size
limit rejected its 2,048-byte write. `work/save-write-before.log` records the
failed control. This is an injected short-write reproduction, not an observed
Simulator disk-full event or an explanation for gameplay/audio behavior.

**Fix and focused pass:** `patches/n64modernruntime-save-write-check.patch`
explicitly closes the stream and checks its state before finalization. Failed
writes use the existing error path and leave the live save/backup untouched.
Added replay to `scripts/setup-source.sh`. `scripts/verify-save-write.py`
compiles the actual runtime writer function plus actual `files.cpp`, substituting
only save context and error-dialog callback. Synthetic 2,048-byte fixtures,
512-byte child file-size limits: first save stays absent, replacement preserves
the complete live save and distinct previous backup, and unrestricted retry
installs the new revision with the expected backup. Final harness passed;
`work/save-write-after.log`. No ROM or Simulator save is accessed by the test.
Patch applied cleanly and reverse-check passed on the patched runtime.

**Build/package pass:** incremental normal builds both exited 0, including
compilation of modified `pi.cpp`: `work/save-write-{sim,device}-build.log`.
Simulator probe stays OFF. Package audits passed (30 files, 24 notices), reports
`work/save-write-{sim,device}-audit.json`. Executable SHA-256:

- Simulator: `3e215625cafd772fbca0cca0c073337f34ede0104ce0059815c22a8f4b73e31c`
- Unsigned device: `0ddc68be67679731ed766459e754e026913ae9c564a696e036756191783034d1`

**iPad ordinary regression pass:** installed in place on iPad 18.5 `605FB671…`;
Continue Imported ROM / Start / L / A reached preserved GAME1 $0 / 0:48:50
and first field. Terminated, cold launched and repeated selection to visible
field. Viewed `save-write-pad-field.jpg` and `save-write-pad-cold-field.jpg`
under `work/evidence/`; logs `work/save-write-pad-{run,cold}.log`. Live and
backup each 2,048 bytes, no `.temp` at inspection; hashes in
`work/save-write-pad-files.json`. Both console sessions exited 0, then shutdown.

This closes a concrete write-error handling defect, not full save acceptance.
Power-loss durability, actual iOS fault injection, meaningful progressed
checkpoint reload and full-story play remain open. No game or audio change.

**iPhone ordinary regression pass:** after iPad shutdown, installed in place
on iPhone 18.5 `AE64D60E…`; retained GAME1 $0 / 0:06:03 loaded first field.
Terminated, cold launched and loaded the same slot/field again. Viewed
`work/evidence/save-write-phone-field.jpg` and `save-write-phone-cold-field.jpg`.
Logs `work/save-write-phone-{run,cold}.log`, both consoles exited 0. Live and
backup each 2,048 bytes, no `.temp` at inspection; hashes in
`work/save-write-phone-files.json`. Phone terminated/shut down; both classes
now retain the updated normal app. This proves first-field save compatibility
across update/relaunch, not distinct progressed checkpoints. Changes committed
locally; Chris's manual Simulator stick observation and physical-device gates
remain open. Next: resume gameplay/input acceptance from this updated build.

### 2026-10-01 — GitHub refresh and normal-build menu smoke checks

Chris explicitly requested updating GitHub, superseding the earlier local-only
instruction for this update. Fetched origin; main had two unpublished commits
(`f849f00`, `33b5520`), with no incoming changes or tracked work in progress.
Replayed `python3 scripts/verify-save-write.py
work/source-final-replay/tools/N64ModernRuntime`: **PASS**, short first and
replacement writes preserved live/backup, and unrestricted retry succeeded.
No game or audio tuning was changed.

Restored the normal Simulator app in place on iPad 18.5 `605FB671…`, replacing
the private diagnostic build without uninstalling or erasing its data. Normal
executable remains SHA-256 `3e215625cafd772fbca0cca0c073337f34ede0104ce0059815c22a8f4b73e31c`.
Launched without the diagnostic environment; Continue Imported ROM rendered
the animated intro. Three-dot Settings opened; Controls and Audio sections
were visually inspected, and closing Settings restored the visible controls
and changing intro frames. Viewed captures include
`work/evidence/github-refresh-pad-audio.png` and
`work/evidence/github-refresh-pad-resumed.png`.

After iPad termination/shutdown, cold launched the retained normal app on
iPhone 18.5 `AE64D60E…`. Continue Imported ROM rendered the startup sequence;
Controls/Audio section switching and menu dismissal passed the bounded visual
check. Viewed captures `work/evidence/github-refresh-phone-audio.png` and
`work/evidence/github-refresh-phone-resumed.png`. The compact Controls pane
showed content below the visible viewport; automation scroll/swipe attempts
did not establish access to the lower rows. **Lower-row touch scrolling remains
unqualified**, not a proven application defect. Both Simulators terminated
and shut down with normal builds and retained data.

The preceding private camera-centered river trial reached surface swimming
but returned to the original bank, without a new checkpoint. Its paused-route
captures/log remain private under `work/evidence/centered-route-*.jpg` and
`work/centered-route-pad.log`. It does not close ordinary touch or story gates.
Next: directly qualify the cure interaction in the same gameplay session
before another river attempt, and establish ordinary held-stick/release and
compact Settings scrolling. Full story, distinct progressed checkpoint saves,
physical touch/controllers/audio routes and long play remain open.

### 2026-10-01 — Bounded Simulator input with pause at expiry

Previous turn made progress by publishing the save fix and normal-build menu
checks. Full objective reread; clean `ec10b7f` before this change. Revalidated
the scrolling boundary against source and earlier lower-row/slider checks:
there is no established ScrollView defect warranting a gesture replacement.

Another preserved GAME1 route reached the outer B pad, where ordinary B did
not replay the cure animation, then returned to the river-edge wall without
a checkpoint. This repeats earlier observations and establishes no cure/save
defect or story progress. Log `work/cure-qualified-route-pad.log`, console
exited 0. Inspection still required a later Start action after command expiry.

**Change:** optional `--pause-after` in `scripts/simulator-input.py` and the
Simulator-only probe. At expiry the probe neutralizes its virtual controller,
then pulses the existing Start touch bridge for 200 ms. This removes the
later inspection action from movement duration. It is explicitly for unpaused
gameplay; it must not be used in the launcher, cutscenes or a paused game.
Default commands retain their previous behavior. No game, production input,
menu or audio implementation changed. Instructions in `docs/SIMULATOR_INPUT.md`.

**Pass, diagnostic scope:** Xcode Release Simulator build exited 0,
`work/probe-expiry-pause-build.log`; executable SHA-256
`b2c4386aa82a16bee11726b3b73efae8f9dc484a3bb83b2f40b2e15f5617ed87`.
On iPad 18.5 `605FB671…`, a neutral 0.5-second command with the option visibly
entered PAUSED. Ordinary A resumed gameplay. A default neutral command did
not pause. A `(0.65, 0.7)` 0.65-second command moved Conker and automatically
entered PAUSED. Log timestamps show release and Start pulse together, followed
by neutral virtual-controller readback. Viewed private captures
`expiry-neutral-paused.png`, `expiry-default-unpaused.png` and
`expiry-movement-paused.png` under `work/evidence/`; runtime log
`work/probe-expiry-pause-pad.log`, console exited 0. This verifies the diagnostic
pause boundary, not ordinary held-touch acceptance or full input fidelity.

Normal Simulator/device bundles remain unchanged, probe OFF. Both audits
passed again (30 files, 24 notices), reports
`work/probe-expiry-{normal,device}-audit.json`. Normal Simulator SHA remains
`3e215625…`, device `0ddc68be…`. Restored the normal iPad app in place,
launched without probe environment and visually confirmed retained ROM
launcher; terminated/shut down. Phone retains its normal app, shut down.
No save/container reset or private files committed. Local commit only.

Next: use the verified expiry-pause boundary for a measured river route,
with separate observed heading/camera adjustments; avoid repeated speculative
cure/save changes. Full story, progressed saves, ordinary touch/menu swipes
and hardware acceptance remain open. Chris still owns signing and physical
touch feel, controllers, audio routes and sustained device play.

### 2026-10-01 — Requested GitHub sync and cold-relaunch settings checks

Chris requested another GitHub update, authorizing publication of the pending
`6942c65` diagnostic change and this evidence entry. Fetched origin; no incoming
commits or tracked edits. No production game/input/audio source change this cycle.

The preceding diagnostic river route reached surface swimming by a wall, with
no island/checkpoint proof. Combining A and movement from PAUSED opened Quit
confirmation: that resume shortcut failed and must not be treated as qualified.
Ordinary A canceled the selected No; D-pad Right did not establish Continue
selection. Terminated the diagnostic process and restored the normal app in
place, preserving ROM/save data. The existing instruction to use pause-after
only from visually confirmed unpaused gameplay remains applicable.

**PASS:** actual EEPROM writer fault harness rerun:
`python3 scripts/verify-save-write.py work/source-final-replay/tools/N64ModernRuntime`.
Short first/replacement writes preserved live/backup; normal retry succeeded.

**PASS, bounded settings check:** normal Simulator executable SHA-256
`3e215625cafd772fbca0cca0c073337f34ede0104ce0059815c22a8f4b73e31c`.
iPad iOS 18.5 `605FB671…`: retained ROM launcher, Continue Imported ROM,
three-dot Controls menu, ordinary Transparent Controls toggle from off to on,
terminate/cold launch, reopen menu: value remained on, visually inspected.
Restored off. Shut down iPad before booting iPhone iOS 18.5 `AE64D60E…`.
iPhone repeated the toggle/cold-relaunch check: accessibility value remained on;
post-relaunch screenshot showed the upper Controls pane with toggle below the
viewport. Restored off through ordinary toggle and verified value zero.
Viewed private captures and observations indexed by
`work/evidence/oct01-update-{pad,phone}-setting-{before,after}.png`.
Both normal apps terminated/shut down; no uninstall/container reset.

**NOT QUALIFIED:** iPad Control Size accessibility setValue changed the native
slider thumb/value transiently, but app percentage stayed 100%; the next state
refresh restored the original slider value. Ordinary pointer tap did not
establish an app value change. This does not pass slider persistence or prove
a production slider defect. Do not replace SwiftUI gestures on this evidence.

Next exact acceptance action: in the normal app, change Control Size with a
real held pointer drag, confirm its percentage changes, then cold relaunch and
compare that percentage on both classes. Ordinary held-stick/release and
simultaneous stick/button, compact menu scrolling, progressed saves and full
story remain open. Physical touch feel/controllers/audio routes/long play and
signing remain Chris's follow-up. No audio tuning or private assets published.

### 2026-10-01 — Files cancellation on the current normal build

Previous goal turn was progress: GitHub synchronized and cold-relaunch switch
persistence verified. Full objective reread; clean `cc54407` at start, 11 GiB
available. No production source change or rebuild this cycle.

**NOT QUALIFIED:** one iPad pointer drag from the actual Control Size thumb
(100%) to approximately 110% left the app percentage and accessibility value
unchanged. Together with the preceding proxy-only setValue result, this leaves
ordinary slider interaction/persistence open. Stop repeating that same drag;
next slider acceptance needs a manual Simulator held-pointer observation.
No gesture replacement justified by the available evidence.

**PASS, cancellation scope:** normal executable `3e215625…`, iPad 18.5
`605FB671…`, then iPhone 18.5 `AE64D60E…`, sequentially. Ordinary Choose ROM
presented Files; Cancel returned to the launcher without a new error and kept
Continue Imported ROM available. Continuing rendered game startup on both
classes; iPad also showed the animated Conker intro. UI observations visually
inspected. Private captures `work/evidence/picker-cancel-pad-intro.png` and
`picker-cancel-phone-startup.png`. No new ROM selected, imported data reset,
or save replacement. Both normal apps terminated and Simulators shut down.
This does not qualify successful replacement/import, gameplay or lifecycle.

Next autonomous test: replay invalid/wrong-revision selection through Files on
the current normal build and verify the retained imported ROM remains usable.
Full story, progressed checkpoint persistence, held touch/simultaneous input,
compact scrolling and physical-device gates remain open. Local evidence commit;
no further publish this cycle. Chris still owns physical touch feel, controller,
audio-route, signing and sustained-device checks.

### 2026-10-01 — Rejected import preserves existing ROM and EEPROM

Previous turn was progress (ordinary Files cancellation on both classes).
Full objective reread; clean `0b6a2fd`, 11 GiB free. Current normal build,
probe excluded, executable `3e215625…`; no rebuild/source/audio change.

**PASS:** iPad 18.5 `605FB671…`, then iPhone 18.5 `AE64D60E…`, one at a time.
Through ordinary Files selection, the existing 20-byte Invalid fixture produced
unsupported-size/header error; the synthetic 64 MiB Wrong Revision fixture
produced checksum-mismatch error. Viewed both error screens on each class.
Continue Imported ROM stayed available. Before restarting the game, compared
SHA-256/size snapshots: stored supported ROM, live 2048-byte EEPROM and backup
all unchanged after both rejected imports on each class. Private snapshot pairs
`work/invalid-recovery-{pad,phone}-{before,after}.json`; assertions passed.
Continue then rendered game startup on both. Viewed captures and UI observations
`work/evidence/invalid-recovery-{pad,phone}-{size,checksum,startup}.png`.
No ROM replacement/save reset; normal apps terminated and Simulators shut down.
This closes this bounded update/rejected-import regression, not full G3/G5/G6.

Asked Chris for a manual Simulator slider/held-stick observation because native
automation has not delivered a qualifying held gesture; no reply yet. Do not
repeat the same unsuccessful drag or treat diagnostic controller movement as
ordinary touch acceptance. No further import smoke repetition needed absent
an import change. Next: return to the preserved first-field gameplay route;
qualify pause-menu Continue using a neutral resume action before movement,
then pursue an actual island/checkpoint. Full story and distinct progressed
save/reload remain open. Chris's physical touch/controller/audio/signing/long
play gates remain open. Local evidence commit only, no push this cycle.

### 2026-10-01 — Requested GitHub refresh and bounded follow-up checks

Chris renewed authorization to update GitHub. Fetched origin: no incoming
commits; main started two evidence commits ahead. No production source change,
audio tuning, rebuild, container reset or private asset publication this cycle.

**PASS, diagnostic scope:** iPad 18.5 `605FB671…`, probe executable
`b2c4386…`: neutral A alone (0.3 seconds) from visibly selected Continue resumed
gameplay repeatedly; movement was issued separately with expiry pause. Recorded
the safe sequence in SIMULATOR_INPUT.md. River approach reached water, but a
later view returned to the original bank; no island lesson/checkpoint achieved.
On the outer B pad, diagnostic B and one ordinary touch B did not establish a
cure animation or lightbulb. This is an unqualified route, not evidence of a
save/input defect. Viewed private captures `neutral-resume-unpaused.png` and
`neutral-resume-context-pad.png` under work/evidence. Restored the normal app
in place and visually confirmed the retained-ROM launcher before shutdown.

**PASS:** actual EEPROM fault harness rerun against source-final-replay:
short first/replacement writes preserved live and backup; normal retry passed.

**PASS, bounded UI scope:** normal executable `3e215625…`, iPhone 18.5
`AE64D60E…`: three-dot menu opened; Audio selection showed its volume pane;
Close returned to the retained-ROM launcher; Continue rendered game startup.
Viewed private captures `oct01-sync-phone-audio-pane.png` and
`oct01-sync-phone-menu-startup.png`. Normal app terminated; both Simulators off.
**NOT QUALIFIED:** scroll and swipe in compact Controls left the viewport
unchanged; an Audio slider track click left 100% unchanged. These attempts do
not pass scrolling/slider persistence or justify gesture rewiring. Manual
Simulator gesture observation remains pending. No gameplay return claim from
this launcher-only menu check.

Next: qualify ordinary held-stick/slider/menu swipe in the Simulator, then
advance a measured gameplay route and cold-reload an actual new checkpoint.
Full story acceptance remains open. Chris still owns signing and eventual
physical touch feel, controllers, audio routes and sustained-device play.
Publish this evidence and the two pending import evidence commits to origin/main.

### 2026-10-01 — Uninterrupted swimming and live displacement control

Previous turn made progress: GitHub synchronized at `c67c1c1` and bounded menu
checks recorded. Full objective reread; clean main, 11 GiB free. No source/game
logic/audio change, rebuild or save replacement this cycle.

**FAIL, route only:** preserved iPad 18.5 `605FB671…`, diagnostic executable
`b2c4386…`. GAME1 retained $0 / 0:48:50. An observed river/island heading followed
by stick (0.2,1) for eight seconds, without A or a mid-water pause, ended beside
the river wall. A later centered view followed by pure positive Y for six
seconds also returned beside the wall. Neither reached the island lesson or
checkpoint. This rules out mid-water pause/resume as the sole explanation; it
does not establish an input, cure or save defect. Held C-Down (right-stick Y -1,
0.5 seconds) did not visibly recenter that swimming view; held side-camera
commands changed the view. Private log `work/uninterrupted-river-route.log` and
viewed `work/evidence/uninterrupted-river-wall.png` plus live UI observations.

**PASS, diagnostic displacement scope:** read-only LLDB snapshots, no expression
execution or game-memory writes. Resolved the host's `crash_rdram` pointer;
read gObjects slot zero at RDRAM + 0xCC2D0, xyz floats at +0x14/+0x18/+0x1C.
Offsets match pinned datasyms and struct127 in the private source checkout.
With Settings freezing gameplay, position was
(2721.351074, -127.640625, 1201.913940). Closed Settings, sent pure negative Y
for 0.5 seconds, viewed swimming response, reopened Settings: position was
(2691.574707, -120.665382, 1148.980103). This measures displacement across that
interval, including neutral time before reopening Settings, not pure stick
velocity. Both snapshots had zero final xz velocity. Sending positive Y while
Settings remained open left the next position/velocity snapshot identical.
The three successful-read snapshots and assertions are private under
`work/river-displacement-{before,after,menu-held}.log`. Debugger attachment itself
pauses the process; the held-menu result is bounded and is not game-time or
ordinary touch acceptance. Input release was logged after detach.

Restored normal executable `3e215625…` in place, visually confirmed retained-ROM
launcher, terminated and shut down iPad. Phone stayed off with the normal app.
No new checkpoint/full-story result. Local evidence commit only.

Next: use live displacement snapshots to calibrate short pure X/Y movement on
land with a fixed observed camera, then navigate toward the island; do not
repeat long diagonal/wall trials or infer lost cure state from them. Ordinary
held touch/slider/menu scrolling still awaits a qualifying Simulator gesture.
Chris's signing and eventual physical touch/controllers/audio/long-play gates
remain open; the full goal remains active.

### 2026-10-01 — Short land-axis calibration

Previous turn was progress: uninterrupted swimming ruled out pause/resume as
the sole route failure and established read-only position snapshots. Full
objective reread; clean `d006331`, 9.3 GiB available. No rebuild, game/input/audio
source change or private save replacement. Preserved iPad 18.5 `605FB671…`,
diagnostic executable SHA-256 `b2c4386…`, GAME1 $0 / 0:48:50.

**PASS, diagnostic scope:** held C-Down for 0.5 seconds established the initial
land view. Native Settings froze each endpoint; read-only LLDB used the same
pinned gObjects slot-zero offsets as the preceding entry. Initial xyz:
(2149, -52.714844, 1926). Pure positive Y, 0.5 seconds: endpoint
(2076.319580, -56.792969, 1895.894653), delta xz (-72.680, -30.105).
Pure positive X, 0.5 seconds: endpoint
(2112.803711, -45.726563, 1827.497925), delta xz (36.484, -68.397).
Viewed forward/right responses; all successful-read snapshots had zero final
xz velocity. These roughly perpendicular displacements do not support a simple
axis inversion. The camera visibly shifted after the right turn, so its frame
cannot be assumed fixed throughout subsequent long input commands. Snapshot
intervals include neutral time before menu opening; they are not speed tests.
Private `work/land-axis-{before,positive-y,positive-x}.log`, runtime
`work/land-axis-calibration.log`. Saved primary controller bindings were defaults.

**NOT QUALIFIED:** held C-Down after the right turn changed the land view toward
the river. Short forward commands reached the bank; A+forward attempts followed
by 0.8 seconds forward entered water, where the view turned toward shore again.
No island lesson/new checkpoint or demonstrated cure state. Viewed private
`work/evidence/land-axis-water-entry.png` and intermediate UI observations.
No axis/sign or game logic patch justified by these results.

Normal executable `3e215625…` restored in place, retained-ROM launcher visually
confirmed; iPad terminated/shut down, phone stayed off. Local evidence commit.
Next: inspect unused game slots before creating a fresh tutorial control;
preserve existing slots, never choose ERASE. Qualify Birdy's lesson and actual
cure in that same session before the crossing. Repeating the current saved
slot's wall route would not answer the remaining tutorial-state question.
Ordinary touch gestures/full story/progressed saves remain open. Chris still
owns signing and eventual physical touch/controllers/audio/long-play checks.

### 2026-10-01 — Requested GitHub sync and fresh GAME2 control

Full objective reread; clean main at `16fb03f`, 9.7 GiB available. At Chris's
explicit request, fetched origin and pushed the two pending evidence commits;
remote main verified at `16fb03f`. No game/input/audio source changes or rebuild.

**PASS, initial save/control scope:** preserved iPad 18.5 `605FB671…`, retained
diagnostic executable `b2c4386…`. Viewed GAME1 $0 / 0:48:50, backed out without
playing or erasing it, selected GAME2 with a short negative-X controller pulse,
and visually confirmed NEW GAME. Retained private 2048-byte pre-route EEPROM
`work/new-game2-save-before.bin`, SHA256
`9d2094c8037668cd4df58cad1d9bdd8844c02684acd1197191820f6127e10cd4`.
Ordinary touch A created GAME2; observed advancing opening story and initial
field. Short controller land commands approached the fence/torch, but did not
trigger Birdy's lesson, beer or cure. No swimming attempted in this slot.

Cold installed normal executable `3e215625…` in place, viewed retained-ROM
launcher and GAME1 with unchanged displayed $0 / 0:48:50. Ordinary stick drag
and D-pad tap did not select GAME2; neither establishes held-touch behavior or
a mapping defect. Reinstalled the retained diagnostic app in place, cold
launched, selected GAME2 with a negative-X pulse, and viewed PLAY / $0 /
0:06:03. Ordinary A loaded its initial field. This establishes initial slot
creation/reload and preserved GAME1 metadata, not two distinct progressed
checkpoints or ordinary held-touch acceptance. Post-route EEPROM retained at
`work/new-game2-save-after.bin`, SHA256
`02fe97b80609533b1801f7f8a7c467e6cb3d40c9fe039025e2a132a0f6041b65`.

Private logs `work/fresh-slot-inspection.log`, `work/new-game2-reload.log`;
both console sessions exited zero after termination. Viewed captures under
`work/evidence/new-game2-{unused,field,torch,game1-retained,reloaded-slot,
reloaded-field}.png`. Normal app restored again in place, retained-ROM launcher
viewed, then iPad terminated/shut down. Phone stayed off with normal app.
No private evidence/assets staged. Publish this evidence under Chris's current
GitHub-update authorization.

Next: load GAME2, qualify Birdy's lesson and cure in the same session before
the river; do not repeat GAME1's wall route. Full story, progressed save
fidelity and ordinary held-touch/menu gestures remain open. Chris retains
signing and eventual real-device touch feel, controllers, audio and long play.


### 2026-10-02 — GitHub parity and native C-Down delivery check

Reread full objective; main `abb4839` clean and fetched origin/main identical
(0 ahead / 0 behind); 9.3 GiB available. No source change or rebuild.
Preserved iPad 18.5 `605FB671…`, diagnostic executable `b2c4386…`, GAME2.
Short land commands traversed the starting fence and waterside perimeter;
Birdy introduction/lesson/beer/cure did not trigger. No river crossing,
new checkpoint, ordinary held-touch or full-story acceptance claim.

**PASS, native controller delivery/release scope:** held camera-Y -1 with
neutral movement; read-only LLDB memory snapshot of the exact executable's
native `controller_buttons` atomic returned 4 (`0x0004`, C-Down), movement
axes [0,0], read_error success. After expiry a second snapshot returned mask
0 and axes [0,0], read_error success. Both attaches detached normally;
no inferior expressions, game-memory writes or game-logic modifications.
An initial unqualified symbol-name lookup failed and detached; the successful
reads located the atomic using symbol-table offsets relative to crash_rdram.
This establishes host input delivery and release, not game-side camera rules.
Stationary held C-Down visibly settled behind Conker after the sideways turn.
It does not support an input-mapping patch for the current navigation issue.

Private logs `work/game2-birdy-route.log`,
`work/game2-camera-{held,released}-mask.log`; viewed endpoint captured at
`work/evidence/game2-camera-route-stop.png`. Normal executable `3e215625…`
restored in place; retained-ROM launcher visually confirmed. iPad terminated
and shut down; phone stayed off. Private assets/evidence remain ignored.

Next: use the opposite fence entrance to qualify Birdy in GAME2, with neutral
C-Down settling after a turn before choosing the next movement direction.
Avoid repeating the wall-end fence attempt or speculative camera rewiring.
Progressed save/reload, full story and ordinary held gestures remain open.
Chris still owns signing and eventual physical touch/controllers/audio/long play.


### 2026-10-02 — GAME2 Birdy lesson, cure and cold save reload

**Progress; partial G5/G6.** Main `b5bce31` was clean and synchronized with
GitHub at the start; 9.3 GiB available, pins unchanged. No source changes or
rebuild. Preserved iPad iOS 18.5 `605FB671-1720-4C19-A3BE-AE425323D052`,
diagnostic executable SHA-256
`b2c4386aa82a16bee11726b3b73efae8f9dc484a3bb83b2f40b2e15f5617ed87`.

**PASS, in-session tutorial scope:** the actual entrance is around the far
waterside fence end, by the torch near the water cave. Earlier attempts used
the wrong end. Traversing that gap reached awake Birdy and the inner B pad.
Initial B attempts at the pad edge did not trigger interaction. A short
centering movement (`--x 0.6 --y -1 --seconds 2`) triggered the lesson;
“TING NOISE…” was visibly shown. After the lesson, ordinary on-screen B
triggered the beer animation; Birdy subsequently slept against the sign.
Exit past Birdy (`x=-0.4,y=1,2s`, then `x=-0.8,y=0.5,3s`), approach the
outer pad (`x=0.2,y=1,3s`) and center (`x=-0.6,y=0.4,0.7s`). Ordinary B
triggered the cure animation and dialogue, followed by upright gameplay.
These commands are view-dependent route notes, not a deterministic replay.
This does not support speculative touch/input/game-logic rewiring.

**PASS, one tutorial save/reload scope:** bounded river movement reached
water but did not establish the far bank or a level transition. Ordinary
Start opened Pause; controller X=-1 for 0.2s selected Quit, ordinary A opened
confirmation, a separate X=-1 for 0.2s selected Y, and ordinary A returned
to GAME2 PLAY with $0 / 0:57:01 and a Birdy thumbnail. Private EEPROM fixture
`work/game2-birdy-saved.bin` is 2,048 bytes, SHA-256
`858f2a2769450ab625c01806a5a46c97569fb60ea53708dfdda51a65f762af0c`;
20 bytes differ from the initial GAME2 fixture `02fe97b8…`.

Cold terminate and in-place normal-build install retained Continue Imported
ROM, moving intro and GAME1 $0 / 0:48:50. Brief native D-pad and stick-drag
attempts did not select GAME2; held-touch selection remains unqualified.
Reinstalled the same diagnostic build in place and cold-launched with
`SIMCTL_CHILD_SQUIRRELPAD_SIM_INPUT=1`. From the room selector, separate
controller X=-1 / 0.2s steps reached GAME2; ordinary A opened PLAY, still
$0 / 0:57:01, and ordinary A loaded upright Conker in the tutorial with
Birdy still sleeping. This qualifies that tutorial-state reload in the
diagnostic build, not normal-build GAME2 navigation or two later checkpoints.

Private logs `work/game2-entrance-control.log`,
`work/game2-birdy-reload.log`; viewed captures
`work/evidence/game2-{far-entrance,birdy-awake,birdy-lesson,cured,birdy-cold-reload}.png`.
Read-only LLDB object snapshots detached normally with no writes; the first
used an incorrect stride and is unqualified. The corrected 0x32C-stride
snapshot read successfully but identified no Birdy trigger/flag; no gameplay
conclusion depends on it.

Normal executable `3e215625…` restored in place again; retained-ROM launcher
visually verified, iPad terminated/shut down. Phone stayed off with normal
build. Private ROM, fixtures, screenshots and logs remain ignored.

Next: load saved GAME2 (room selector left from GAME1), preserve the now
qualified cured state, cross toward the grassy far-bank route and reach the
next actual checkpoint. Do not repeat fence discovery or retune audio from
these observations. Full story, second distinct progressed save, phone
chapters and ordinary held/simultaneous gestures remain open. Chris still
owns signing and eventual physical touch feel, controllers, audio routes
and sustained real-device play.

### 2026-10-02 — saved tutorial payload checked against cold-loaded RDRAM

**Progress, diagnostic persistence evidence only.** Previous turn's river
navigation produced no crossing, checkpoint or confirmed port defect; its
normal-build restoration was housekeeping. Revalidated clean main `8f458ea`,
unchanged source pins and 8.1 GiB available. No source change or rebuild.

Read the pinned game's `func_15006590` loader in the private generated
`work/source-final-replay/RecompiledFuncs/funcs_10.c`: each record starts at
EEPROM byte `32 + 128*i`; its checksum is the 16-bit sum seeded with 0xCC
of bytes 2..127 weighted by `1 << (offset & 3)`. After validating the record,
the loader copies 27 bytes from record offset 7 to `D_800D2E4C`. This is a
source-derived state boundary, not an interpretation of individual flags.

Both private 2,048-byte fixtures from the preceding entry have valid
checksums for populated records 1, 2 and 3. Between initial GAME2 and the
Birdy save, record 2's 27-byte payload changed at offsets 0 and 0x17;
record 1 changed at offset 0. Thus the difference includes persisted game
state, rather than only play-time metadata. Record 0 is unqualified; no
assumption is made about its purpose or the logical slot-to-record mapping.

**PASS, payload restoration scope:** preserved iPad iOS 18.5 `605FB671…`,
same opt-in diagnostic executable `b2c4386a…`, cold launch followed by
Continue, Start after the intro, controller X=-1 for 0.2s to GAME2, ordinary
A to PLAY and A to load. Metadata remained $0 / 0:57:01; upright tutorial
gameplay was visually inspected. Read-only LLDB attached to PID 6534,
read the pointer at RDRAM+0xD2E4C, then its 27 logical bytes using N64
word-swapped byte addressing (`offset ^ 3`), and detached normally. No
inferior expressions or game-memory writes. The live payload matched both
populated tutorial fixture payloads byte-for-byte; SHA-256
`e3bc91a95e1b10e09b4cdfc13ad3f18495d81ad29df9f6c815eccbc5e18944e0`.

Private evidence: `work/game2-payload-reload.log`,
`work/game2-payload-lldb.log`, and viewed
`work/evidence/game2-payload-cold-reload.png` (raw Simulator orientation
remains rotated relative to its landscape window). Restored normal
executable `3e215625…` in place, visually verified retained-ROM launcher,
terminated/shut down iPad; phone stayed off. Private data remains ignored.

**Not run:** the individual cure-bit meaning, river crossing and later
checkpoint. Payload equality is not full save fidelity or full-story proof.
Next trace the consumers of payload bits at offsets 0 and 0x17, or qualify
the cure through ordinary interaction before another river attempt. Do not
patch persistence/input from the prior navigation difficulty; no defect was
reproduced. Full iPad story, representative phone chapters, ordinary held
and simultaneous touch, and the physical/signing gates remain open.

### 2026-10-02 — video resolves the apparent missing jump

**Progress, isolated diagnostic input evidence.** Previous turn proved
27-byte state-payload restoration, changing the next check from persistence
repair to functional interaction. Revalidated clean `84ecf1b`, unchanged
pins and 8.1 GiB available. No source change or rebuild.

The generated flag reader `func_1509FE0C` dispatches property 0x1A to
`D_800D2E4C[index >> 3] & (1 << (index & 7))`; its setter
`func_1509F850` similarly uses a variable index. The bounded source search
did not identify semantic names for saved bits 0, 1 or 191. Do not label
those bits as beer/cure based only on correlation.

Preserved iPad 18.5 `605FB671…`, diagnostic executable `b2c4386a…`,
opt-in cold load of GAME2 at $0 / 0:57:01. C-Down 0.2s followed by
stick x=0.6,y=0.8 for 3s reached a wall-side river edge. X=-1+A for 1s
and Y=1+A for 3s did not establish swimming/crossing in the subsequent
screenshots. Return Y=-1 for 2s, then another 0.5s centered the outer
B pad. Ordinary B did not replay the cure animation in that observation;
this alone is not flag semantics or proof of a successful river route.

**PASS, isolated A jump in the diagnostic controller build:** short A
0.2s was sampled and then neutralized in `work/game2-river-jump.log`.
The post-input screenshots showed standing Conker, so recorded a second
A pulse with `simctl io … recordVideo --force work/game2-jump-pad.mov`.
The recording completed normally (32.65s). A viewed full-duration contact
sheet sampled too sparsely to resolve the action; a viewed 0.25s contact
sheet covering 14..19.75s shows Conker leave the pad at 15.25s, rise at
15.50s, and land by 16s. Therefore the apparent absent jump was a capture
timing problem, not a reproduced A-mapping failure. Private captures:
`work/evidence/game2-jump-pad-{contact,dense}.png`. Saved primary controller
bindings were empty/default. No input or game-logic patch is justified.

**Not run:** ordinary simultaneous touch, river crossing, next checkpoint
and later chapters. Additional navigation returned inside Birdy's enclosure
without new progression; do not repeat those long lateral commands as a
qualified route. Normal `3e215625…` restored in place, retained-ROM launcher
visually verified, iPad terminated/shut down; phone stayed off.

Next work the lower open G1 macOS gameplay/save control and compare its
river approach before further Simulator navigation. Keep the full-story
gate open; neither a video jump nor diagnostic payload equality closes it.
Chris still owns signing and eventual physical touch/controllers/audio/
sustained-play checks.

### 2026-10-02 — bounded route attempt; normal Simulator ready for held touch

**No gameplay progress.** Previous turn clarified the open gates but did not
advance them. Re-read the full objective, clean `b62e187`, unchanged source
pins and 8.9 GiB available. No source changes or rebuild.

Preserved iPad 18.5 `605FB671…`: normal `3e215625…` retained-ROM launcher,
Start to GAME1; one ordinary left stick drag did not establish GAME2
selection. This is not proof of a broken stick. CUA exposes short key
presses and drag, with no hold duration or simultaneous touches.

Installed existing diagnostic `b2c4386a…` in place, explicitly enabled its
controller probe, and loaded GAME2 $0 / 0:57:01 through separate left/A/A
actions. Used the green landing beneath the log and closed door as the
route landmark, following the opening-chapter sequence in
[Nemesis's walkthrough](https://www.gamerevolution.com/guides/28824-conkers-bad-fur-day-walkthrough).
The control reference specifies stick-only surface swimming:
[Rare Replay game help](https://dlassets-ssl.xboxlive.com/public/content/367297b7-c6a3-4496-83ad-cb70c52ce8cd/GameManual/2e5e2560-e901-414b-87fa-081a07f24c6c/en-SA/index.html).

**FAIL, route progression:** bounded 1–5s stick commands, C-Right heading
checks and separate pause/resume actions reached water and returned to the
starting bank. No island lesson, switch, new checkpoint or demonstrated
port defect. The final `x=-0.8,y=1,5s,pause-after` returned by the outer
B pad/fence. Private log `work/green-island-route-20261002.log`; viewed final
capture `work/evidence/green-island-route-20261002-final.png`. Do not repeat
these commands as a qualified route or patch game logic from this failure.

Terminated diagnostic run (console exit 0), restored normal `3e215625…`
in place without the probe environment, and used ordinary Start/A to load
GAME1's first field. Visually verified gameplay. The iPad is intentionally
left running there for a requested brief manual Simulator hold/release
check; iPhone remains off. This does not require physical hardware.
Current EEPROM is 2,048 bytes, SHA-256
`b85620c752aa13a537edd7dfa5aab4c9ee25263346a864fbbcaa0e97473483ac`.
This current file hash alone is not new save/reload acceptance.

**Not run:** ordinary held/simultaneous touch acceptance, later checkpoint
save/reload, full story, representative phone chapters and physical/signing
gates. Next qualify a two-second ordinary stick hold and release in this
prepared normal Simulator. A failure needs a timed capture before any
input change. Automated drag and diagnostic controller evidence cannot
close that ordinary-touch gate. Keep the full goal active.

### 2026-10-02 — Current artifact audit and acceptance handoff

Previous turn made no gameplay progress. Revalidated clean `f2bf211`, unchanged
pins, 7.8 GiB available, and live normal iPad process 11120 at its installed
bundle path; the requested manual hold check has no response yet. No runtime
change, rebuild, new audio experiment or repeated river attempt.

**PASS, current scoped package audit:** ran `scripts/audit-app.py` separately
against normal final Simulator and unsigned device bundles with source context
`work/source-final-replay`. Both commands exited 0: ARM64, correct SDK, 30 files,
24 matching notices, no audit failures. Reports:
`work/package-audit-20261002-{simulator,device}.json`. Exact executables remain
`3e215625…` and `0ddc68be…`. Checked report contents as well as command output.

**Completed handoff artifact:** `docs/ACCEPTANCE.md` now gives the current
artifact identities and all G0–G8 evidence/remaining requirements, linked from
README. Corrected SOURCE_BOUNDARY's stale source path and older executable
hashes. Prior independent replay is dated evidence, not a claim that the latest
incremental state already has final clean-build/signing/full-story acceptance.
The matrix keeps ordinary touch, distinct progressed saves, later chapters,
current-build secondary-runtime coverage and physical/signing gates open.

**Not run:** new gameplay/checkpoint proof or manual held input. The normal iPad
Simulator remains prepared in first-field gameplay for that observation; phone
remains off. Next actions are in ACCEPTANCE.md. No source/input/save/audio
changes and no publication; package audit is not a substitute for gameplay.

### 2026-10-02 — Compact scroll failure qualified against native Settings

Previous turn was a status restatement: **no progress**. Read the complete
objective, clean `d63966b`, unchanged pins and 7.8 GiB available. No source
change or rebuild. Only the phone 18.5 Simulator was booted during the control.
Installed normal executable verified as `3e215625…`.

**Evidence changes the next action:** the compact Controls pane did not move
after CUA `drag([1050,653],[1050,355])`; the lower Control Size row remained
clipped. The same API in Apple's Settings app also failed to move the list
with `drag([500,1250],[500,700])`. Both visually inspected screenshots showed
the pointer at the drag start. Apple's exposed accessibility `Scroll Down`
action did move its list, revealing Apps and Developer; `Scroll Up` returned
it toward the top. This is evidence of an automation-path limitation, not
proof that SquirrelPad's ScrollView is broken. SquirrelPad's current tree
does not expose an equivalent scroll action. Do not rewire gestures from this
failed drag alone. Ordinary compact scrolling remains **Not verified**.

Private captures: `work/evidence/native-settings-drag-control-20261002.png`
and `work/evidence/compact-controls-drag-control-20261002.png`; live UI
screenshots also inspected for the successful native accessibility control.
No settings, controller mappings, ROM or save fixtures changed by this check.

Terminated the phone app and shut down the phone before booting the preserved
iPad. Launched normal iPad process 13335, verified installed `3e215625…`, and
used ordinary Start/A to restore GAME1 first-field gameplay. Visually verified
the field and left it running for the pending ordinary held-input observation. The next useful input check is a manual Simulator stick hold and
release plus an ordinary swipe through compact Settings; diagnostic movement
and accessibility actions do not substitute for those gestures. Full-story,
progressed saves, audible quality and device/signing gates remain open.
