# Bounded Simulator controller probe

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
```

Axes are -1...1; buttons are physical gamepad A/B/X/Y, LB/RB and LT/RT and respect saved controller mappings. By default LT/RT map to N64 Z, LB to L and RB to R. Repeat `--button` to combine inputs. Duration is 0.05...10 seconds. A new command replaces all axes/buttons, and timeout releases them. Commands are written atomically into the app's Documents directory; expired files are ignored after relaunch. Logs identify connection, command and release. Use screenshots/video to verify actual movement, not just command logs. Settings/background still disable controller input through the ordinary activity path.

After testing, terminate/shut down the Simulator and restore the normal build:

```sh
cmake -S . -B work/build-app-replay-iphonesimulator -DSQUIRRELPAD_SIM_INPUT=OFF
xcodebuild -project work/build-app-replay-iphonesimulator/SquirrelPad.xcodeproj \
  -target SquirrelPad -configuration Release -sdk iphonesimulator -jobs 4 \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

Reinstall that normal app in place. Record its hash separately from the probe build. Keep the command fixture and gameplay captures private and outside Git.
