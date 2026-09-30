import Foundation
import GameController

@_silgen_name("squirrelpad_controller_set_state")
private func setControllerState(_ buttons: UInt16, _ x: Float, _ y: Float)
@_silgen_name("squirrelpad_controller_clear")
private func clearControllerState()

enum GamepadButton: String, CaseIterable {
    case a = "A", b = "B", x = "X", y = "Y"
    case leftShoulder = "LB", rightShoulder = "RB"
    case leftTrigger = "LT", rightTrigger = "RT"
    case bothTriggers = "LT / RT", menu = "Menu"

    func isPressed(on pad: GCExtendedGamepad) -> Bool {
        switch self {
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
    private var controller: GCController?
    private var active = false
    private var observers: [NSObjectProtocol] = []

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
        clearControllerState()
    }

    func setActive(_ value: Bool) {
        active = value
        if value {
            reconcile()
            sample()
        } else {
            clearControllerState()
        }
    }

    private func reconcile() {
#if SQUIRRELPAD_SIM_INPUT
        let next = SimulatorInputProbe.shared.controller ?? GCController.controllers().first { $0.extendedGamepad != nil }
#else
        let next = GCController.controllers().first { $0.extendedGamepad != nil }
#endif
        guard controller !== next else { return }
        controller?.extendedGamepad?.valueChangedHandler = nil
        clearControllerState()
        controller = next
        connectedName = next.map { $0.vendorName ?? "Game Controller" }
        rumbleAvailable = next?.haptics != nil
        next?.extendedGamepad?.valueChangedHandler = { [weak self, weak next] _, _ in
            DispatchQueue.main.async { [weak self, weak next] in
                guard let self, self.controller === next else { return }
                self.sample()
            }
        }
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
        if cy > 0.5 { buttons |= 0x0008 }
        if cy < -0.5 { buttons |= 0x0004 }
        if cx < -0.5 { buttons |= 0x0002 }
        if cx > 0.5 { buttons |= 0x0001 }
        setControllerState(buttons, pad.leftThumbstick.xAxis.value,
                           pad.leftThumbstick.yAxis.value)
    }
}
