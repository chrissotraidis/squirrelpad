# Controllers and displays

Reviewed 2026-10-08.

## Setup

Put a compatible Xbox or PlayStation controller in pairing mode, then select it
in **iOS Settings → Bluetooth**. Supported USB controllers can also connect by
data cable. SquirrelPad uses Apple's GameController framework and detects
connection/disconnection automatically; no app-specific pairing is needed.
See [Apple's pairing instructions](https://support.apple.com/111099).

**Settings → Controls** shows the selected controller and editable bindings.
Defaults: left stick moves, A/B map to N64 A/B, either trigger maps to Z,
LB/RB map to L/R, Menu maps to Start, and right stick maps to C buttons (or the
optional free camera). D-pad maps directly. The first connected extended
gamepad controls player one; this is not four-player controller support.
Use touch for the launcher and native settings. Touch controls automatically
hide on controller connection and return on disconnect; **Hide with Controller**
is enabled by default. Layout editing still shows controls. Settings displays
received buttons and sticks so detection and working input can be checked separately.

**Controller Rumble** is enabled by default. **Test Rumble** sends a short pulse
to the selected controller and is disabled when iOS does not expose a compatible
haptic engine. Capability can vary by controller model, firmware and connection;
an Xbox name alone does not prove rumble support. Rumble stops on pause,
backgrounding, audio interruption, disconnect or disabling the option.

For HDMI, connect a video-capable adapter and cable and select the TV input.
Use system display mirroring, including on iPads configured for an extended
desktop. The game and native UI mirror together; touch controls hide automatically
when using a gamepad. Audio follows the system output route. There is no
separate TV-only scene or independent controller screen.
See Apple's [iPad display guide](https://support.apple.com/guide/ipad/ipadf1276cde/ipados).

## Implementation and checks

- The former host rumble callback was a no-op and port one reported no pak.
  The mobile host now exposes a virtual Rumble Pak and forwards motor requests
  through an atomic bridge to the controller's Core Haptics engine. Hardware
  output is gated by capability, preference and app activity. Keeping the
  virtual pak present supports controllers connected after the game starts.
- Input handlers sample reports on the main queue, with a 60 Hz polling fallback
  independent of rumble support. Player one is assigned explicitly and handlers
  reattach on resume. Native input retains
  short button presses until the next game poll and discards pending input on
  pause/disconnect/backgrounding. Hiding the touch overlay also clears held touch
  input and discards gesture state. Existing binding preferences are preserved.
- The Metal view follows its window's screen scale instead of assuming the
  built-in display. The app leaves mirroring to iOS; it does not claim an
  external-display scene or disable Metal drawable capture.
- Native regressions cover short presses, cleared axes/buttons, sustained and
  short rumble requests, non-player-one rejection and suppression after pause.
  These tests do not operate a Bluetooth radio, physical motors or HDMI output.
- Earlier baseline: both Release SDK builds and bundle audits passed (32 files, 26 notices),
  along with all eight native/patch tests. Simulator showed the controller
  card, a working rumble preference switch and a disabled Test Rumble button
  for its non-haptic gamepad, then rendered the game intro. The signed iPad
  build was installed in place and launched; all eight core data files matched
  the independently verified backup. No physical controller or HDMI result is
  claimed by these checks.

### Controller handoff follow-up (2026-10-08)

The Xbox report exposed missing touch auto-hide and a controller path relying
solely on callbacks. Auto-hide is now on by default; input also polls without
requiring haptics, rebinds on resume and clears on background/disconnect. The
original physical input failure has not yet been reproduced under instrumentation.

Nine tests pass, including the shipping Swift adapter exercised with Apple's
mutable GameController snapshots: buttons/sticks, missing-callback fallback,
menu pause/resume, background/resume, second-controller stability, disconnect
and reconnect. Both Release SDK builds and bundle audits pass. The development
build was installed in place on the iPad; all nine core files matched independent
backups, including the GAME2 save. Hardware launch, the new default-on setting,
and touch menu/resume were checked. Live Xbox input and hot-plug acceptance still
need the user's controller test; these checks do not certify the reported failure
as resolved.

Physical acceptance remains open: pair an Xbox controller, check all default
buttons/sticks, Test Rumble and an actual in-game rumble event, reconnect and
background/resume. Then check HDMI game picture and audio, opening the native
menu, and unplug/replug without losing the running session. Record the exact
controller, adapter and device combination before marking it verified.
