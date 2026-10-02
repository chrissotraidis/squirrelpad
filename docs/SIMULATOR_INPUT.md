# Bounded Simulator controller probe

## Ordinary touch check before diagnosing movement

Use the normal app first, with no `SQUIRRELPAD_SIM_INPUT` environment switch.
The current preserved iPad test destination can be opened without reinstalling
or erasing its data:

```sh
xcrun simctl boot 605FB671-1720-4C19-A3BE-AE425323D052
open -a Simulator
xcrun simctl launch 605FB671-1720-4C19-A3BE-AE425323D052 com.chrissotraidis.squirrelpad
```

Choose Continue Imported ROM, use Start/L to reach GAME1, then A to expose
PLAY and A to load the field. Wait for the visible field before testing input.
Press and hold the blue stick off-center for two seconds, then release it.
Record whether Conker moves, whether the stick returns to center, and whether
movement stops. Repeat after opening and closing the three-dot menu. Preserve
the existing save; do not choose ERASE. Capture a short video if movement fails.

The native automation API currently exposes drag without a hold duration or
simultaneous touches. Two automated drags on 2026-10-01 did not establish
movement. Their endpoint screenshots do not prove a broken stick or a passed
release check. Use a manual Simulator observation to qualify this touch path;
the diagnostic controller below establishes a different input path.

## Diagnostic controller

Use this diagnostic when UI automation cannot hold the touch stick. It feeds a hidden `GCVirtualController` through the ordinary controller mapper. It does not change game logic or replace touch/hardware acceptance. Normal builds exclude the probe source. Device configurations reject the option.

Configure the existing Simulator project:

```sh
cmake -S . -B work/build-app-replay-iphonesimulator -DSQUIRRELPAD_SIM_INPUT=ON
xcodebuild -project work/build-app-replay-iphonesimulator/SquirrelPad.xcodeproj \
  -target SquirrelPad -configuration Release -sdk iphonesimulator -jobs 4 \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

Install in place on one booted Simulator. Launch with the explicit environment switch:

```sh
SIMCTL_CHILD_SQUIRRELPAD_SIM_INPUT=1 xcrun simctl launch --console <UDID> com.chrissotraidis.squirrelpad
```

Use the ordinary ROM/menu flow to the desired scene, then send a measured command:

```sh
python3 scripts/simulator-input.py <UDID> --y 0.75 --seconds 2
python3 scripts/simulator-input.py <UDID> --camera-x 0.8 --seconds 0.5
python3 scripts/simulator-input.py <UDID> --y 0.75 --button A --seconds 0.3
python3 scripts/simulator-input.py <UDID> --button LT --seconds 1
python3 scripts/simulator-input.py <UDID> --button LT --button A --seconds 0.3
python3 scripts/simulator-input.py <UDID> --y 0.75 --seconds 1 --pause-after
```

Axes are -1...1; buttons are physical gamepad A/B/X/Y, LB/RB and LT/RT and respect saved controller mappings. By default LT/RT map to N64 Z, LB to L and RB to R. Repeat `--button` to combine inputs. Duration is 0.05...10 seconds. A new command replaces all axes/buttons, and timeout releases them. Commands are written atomically into the app's Documents directory; expired files are ignored after relaunch. Logs identify connection, command and release. Use screenshots/video to verify actual movement, not just command logs. Settings/background still disable controller input through the ordinary activity path.

For navigation from **unpaused gameplay**, `--pause-after` neutralizes the
virtual controller at expiry and sends a 200 ms pulse through the existing N64
Start touch bridge. Visually confirm the in-game PAUSED screen before inspecting
the route, then resume through Continue before another command.
Resume only when Continue is visibly selected: send neutral A separately
(`--button A --seconds 0.3`, with no movement axes), observe unpaused gameplay,
then issue movement. This separated action was verified on the preserved iPad
route on 2026-10-01. Combining resume A with movement previously selected Quit;
do not reuse that shortcut. A water resume can also change the camera view, so
recheck heading before moving.
Do not use this
option from the launcher, a cutscene or an already paused game: Start may have
a different effect there. This diagnostic action is separate from virtual
controller readback and does not qualify ordinary touch or controller acceptance.
Without this option, use ordinary touch Start and confirm PAUSED after the short
command. The game otherwise runs during inspection, so the captured location
can become stale. Pause preserves the location; animation may continue.
Refresh Simulator accessibility indices after UI changes. A command/release log
proves delivery only, and a failed route does not establish an input or save bug.
The `sampled` line reads back axes and individually pressed buttons from the
virtual controller on the following poll, including neutral state after expiry.
It is not a readback of the final N64 input mask or proof of a gameplay action.

After testing, terminate/shut down the Simulator and restore the normal build:

```sh
cmake -S . -B work/build-app-replay-iphonesimulator -DSQUIRRELPAD_SIM_INPUT=OFF
xcodebuild -project work/build-app-replay-iphonesimulator/SquirrelPad.xcodeproj \
  -target SquirrelPad -configuration Release -sdk iphonesimulator -jobs 4 \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

Reinstall that normal app in place. Record its hash separately from the probe build. Keep the command fixture and gameplay captures private and outside Git.
