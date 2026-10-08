import Foundation
import GameController
import CoreHaptics

@_silgen_name("squirrelpad_controller_set_state")
private func setControllerState(_ buttons: UInt16, _ x: Float, _ y: Float)
@_silgen_name("squirrelpad_controller_clear")
private func clearControllerState()
@_silgen_name("squirrelpad_rumble_enable")
private func enableGameRumble(_ enabled: Bool)
@_silgen_name("squirrelpad_rumble_requested")
private func gameRumbleRequested() -> Bool

@_silgen_name("squirrelpad_controller_camera")
private func setCameraState(_ x: Float, _ y: Float)

enum GamepadButton: String, CaseIterable {
    case unbound = "Unbound"
    case a = "A", b = "B", x = "X", y = "Y"
    case leftShoulder = "LB", rightShoulder = "RB"
    case leftTrigger = "LT", rightTrigger = "RT"
    case bothTriggers = "LT / RT", menu = "Menu"

    func isPressed(on pad: GCExtendedGamepad) -> Bool {
        switch self {
        case .unbound: return false
        case .a: return pad.buttonA.isPressed
        case .b: return pad.buttonB.isPressed
        case .x: return pad.buttonX.isPressed
        case .y: return pad.buttonY.isPressed
        case .leftShoulder: return pad.leftShoulder.isPressed
        case .rightShoulder: return pad.rightShoulder.isPressed
        case .leftTrigger: return pad.leftTrigger.isPressed
        case .rightTrigger: return pad.rightTrigger.isPressed
        case .bothTriggers: return pad.leftTrigger.isPressed || pad.rightTrigger.isPressed
        case .menu: return pad.buttonMenu.isPressed
        }
    }
}

enum ControllerAction: String, CaseIterable {
    case a = "A", b = "B", z = "Z", start = "Start", l = "L", r = "R"

    var defaultButton: GamepadButton {
        switch self {
        case .a: return .a
        case .b: return .b
        case .z: return .bothTriggers
        case .start: return .menu
        case .l: return .leftShoulder
        case .r: return .rightShoulder
        }
    }

    var mask: UInt16 {
        switch self {
        case .a: return 0x8000
        case .b: return 0x4000
        case .z: return 0x2000
        case .start: return 0x1000
        case .l: return 0x0020
        case .r: return 0x0010
        }
    }
}

@MainActor
final class ControllerInput: ObservableObject {
    static let bindings: [(n64: String, gamepad: String)] = [
        ("Stick", "Left stick"), ("A", "A"), ("B", "B"),
        ("Z", "LT / RT"), ("Start", "Menu"),
        ("L", "LB"), ("R", "RB"),
        ("C buttons", "Right stick"), ("D-pad", "D-pad")
    ]

    private static let bindingsKey = "SquirrelPad.PrimaryControllerBindings"
    @Published private var buttonBindings: [String: String] = [:]

    func binding(for action: ControllerAction) -> GamepadButton {
        GamepadButton(rawValue: buttonBindings[action.rawValue] ?? "") ?? action.defaultButton
    }

    func setBinding(_ button: GamepadButton, for action: ControllerAction) {
        buttonBindings[action.rawValue] = button.rawValue
        UserDefaults.standard.set(buttonBindings, forKey: Self.bindingsKey)
        sample()
    }

    func restoreBindings() {
        buttonBindings = [:]
        UserDefaults.standard.removeObject(forKey: Self.bindingsKey)
        sample()
    }

    @Published private(set) var connectedName: String?
    @Published private(set) var rumbleAvailable = false
    @Published private(set) var rumbleMessage = "Connect a controller to check rumble support."
    @Published var rumbleEnabled = UserDefaults.standard.object(forKey: "SquirrelPad.ControllerRumble") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(rumbleEnabled, forKey: "SquirrelPad.ControllerRumble")
            stopRumble()
            enableGameRumble(active && foreground && rumbleEnabled && rumbleAvailable)
        }
    }
    private var controller: GCController?
    private var active = false
    private var foreground = true
    private var observers: [NSObjectProtocol] = []
    private var rumbleTimer: Timer?
    private var hapticEngine: CHHapticEngine?
    private var hapticPlayer: CHHapticAdvancedPatternPlayer?
    private var rumbling = false
    private var rumbleFailed = false
    private var testUntil: TimeInterval = 0
    private var pulseUntil: TimeInterval = 0

    init() {
        buttonBindings = UserDefaults.standard.dictionary(forKey: Self.bindingsKey) as? [String: String] ?? [:]
        let center = NotificationCenter.default
        for name in [Notification.Name.GCControllerDidConnect,
                     Notification.Name.GCControllerDidDisconnect] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.reconcile() }
            })
        }
        reconcile()
#if SQUIRRELPAD_SIM_INPUT
        SimulatorInputProbe.shared.start { [weak self] in self?.reconcile() }
#endif
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        controller?.extendedGamepad?.valueChangedHandler = nil
        rumbleTimer?.invalidate()
        hapticEngine?.stop(completionHandler: nil)
        clearControllerState()
    }

    func setActive(_ value: Bool) {
        active = value
        if value {
            reconcile()
            sample()
        } else {
            clearControllerState()
            stopRumble()
        }
        enableGameRumble(value && foreground && rumbleEnabled && rumbleAvailable)
    }

    func setForeground(_ value: Bool) {
        guard foreground != value else { return }
        foreground = value
        if value {
            rumbleFailed = false
            reconcile()
            startRumbleTimer()
        } else {
            enableGameRumble(false)
            stopRumble()
            rumbleTimer?.invalidate()
            rumbleTimer = nil
            hapticEngine?.stop(completionHandler: nil)
        }
    }

    func testRumble() {
        guard foreground, rumbleEnabled, rumbleAvailable else { return }
        rumbleFailed = false
        testUntil = ProcessInfo.processInfo.systemUptime + 0.35
        updateRumble()
    }

    private func stopRumble() {
        testUntil = 0
        pulseUntil = 0
        try? hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        rumbling = false
    }

    private func startRumbleTimer() {
        guard foreground, rumbleAvailable, rumbleTimer == nil else { return }
        let timer = Timer(timeInterval: 1.0 / 60, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.updateRumble() }
        }
        RunLoop.main.add(timer, forMode: .common)
        rumbleTimer = timer
    }

    private func updateRumble() {
        let requested = gameRumbleRequested()
        guard foreground, rumbleEnabled, rumbleAvailable, !rumbleFailed else { return }
        let now = ProcessInfo.processInfo.systemUptime
        if active && requested { pulseUntil = now + 0.04 }
        let wanted = now < testUntil || (active && now < pulseUntil)
        guard wanted != rumbling else { return }
        do {
            if wanted, let engine = hapticEngine {
                try engine.start()
                if hapticPlayer == nil {
                    let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ], relativeTime: 0, duration: 1)
                    let pattern = try CHHapticPattern(events: [event], parameters: [])
                    let player = try engine.makeAdvancedPlayer(with: pattern)
                    player.loopEnabled = true
                    player.loopEnd = 1
                    hapticPlayer = player
                }
                try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
                rumbleMessage = "Rumble supported by this controller."
            } else {
                try hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
            }
            rumbling = wanted
        } catch {
            stopRumble()
            rumbleFailed = true
            hapticPlayer = nil
            rumbleMessage = "Rumble could not start. Try Test Rumble again or reconnect."
            NSLog("[controller] haptics failed: %@", error.localizedDescription)
        }
    }

    private func reconcile() {
        let connected = GCController.controllers().filter { $0.extendedGamepad != nil }
        // Connecting a second pad must not steal player one from the current pad.
        let selected = connected.first { $0 === controller } ?? connected.first
#if SQUIRRELPAD_SIM_INPUT
        let next = SimulatorInputProbe.shared.controller ?? selected
#else
        let next = selected
#endif
        guard controller !== next else { return }
        controller?.extendedGamepad?.valueChangedHandler = nil
        clearControllerState()
        stopRumble()
        rumbleTimer?.invalidate()
        rumbleTimer = nil
        hapticEngine?.stop(completionHandler: nil)
        hapticPlayer = nil
        hapticEngine = next?.haptics?.createEngine(withLocality: .default)
        rumbleFailed = false
        controller = next
        connectedName = next.map { $0.vendorName ?? "Game Controller" }
        rumbleAvailable = hapticEngine != nil
        rumbleMessage = next == nil ? "Connect a controller to check rumble support."
            : rumbleAvailable ? "Rumble supported by this controller."
            : "This controller or connection does not expose rumble to iOS."
        hapticEngine?.resetHandler = { [weak self, weak next] in
            Task { @MainActor in
                guard let self, self.controller === next else { return }
                self.hapticPlayer = nil
                self.rumbling = false
                self.rumbleFailed = false
            }
        }
        hapticEngine?.stoppedHandler = { [weak self, weak next] _ in
            Task { @MainActor in
                guard let self, self.controller === next else { return }
                self.rumbling = false
                self.hapticPlayer = nil
            }
        }
        next?.handlerQueue = .main
        next?.extendedGamepad?.valueChangedHandler = { [weak self, weak next] _, _ in
            // Read this event before the next report can overwrite a short press.
            MainActor.assumeIsolated {
                guard let self, self.controller === next else { return }
                self.sample()
            }
        }
        enableGameRumble(active && foreground && rumbleEnabled && rumbleAvailable)
        startRumbleTimer()
        NSLog("[controller] connected=%@ rumble=%@", connectedName ?? "none", String(rumbleAvailable))
        sample()
    }

    private func sample() {
        guard active, let pad = controller?.extendedGamepad else {
            clearControllerState()
            return
        }
        var buttons: UInt16 = 0
        for action in ControllerAction.allCases {
            if binding(for: action).isPressed(on: pad) { buttons |= action.mask }
        }
        if pad.dpad.up.isPressed { buttons |= 0x0800 }
        if pad.dpad.down.isPressed { buttons |= 0x0400 }
        if pad.dpad.left.isPressed { buttons |= 0x0200 }
        if pad.dpad.right.isPressed { buttons |= 0x0100 }
        let cx = pad.rightThumbstick.xAxis.value
        let cy = pad.rightThumbstick.yAxis.value
        setCameraState(cx, cy)
        if cy > 0.5 { buttons |= 0x0008 }
        if cy < -0.5 { buttons |= 0x0004 }
        if cx < -0.5 { buttons |= 0x0002 }
        if cx > 0.5 { buttons |= 0x0001 }
        setControllerState(buttons, pad.leftThumbstick.xAxis.value,
                           pad.leftThumbstick.yAxis.value)
    }
}
