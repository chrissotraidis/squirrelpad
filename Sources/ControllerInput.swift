import Foundation
import GameController

@_silgen_name("squirrelpad_controller_set_state")
private func setControllerState(_ buttons: UInt16, _ x: Float, _ y: Float)
@_silgen_name("squirrelpad_controller_clear")
private func clearControllerState()

@MainActor
final class ControllerInput: ObservableObject {
    private var controller: GCController?
    private var active = false
    private var observers: [NSObjectProtocol] = []

    init() {
        let center = NotificationCenter.default
        for name in [Notification.Name.GCControllerDidConnect,
                     Notification.Name.GCControllerDidDisconnect] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.reconcile() }
            })
        }
        reconcile()
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
        let next = GCController.controllers().first { $0.extendedGamepad != nil }
        guard controller !== next else { return }
        controller?.extendedGamepad?.valueChangedHandler = nil
        clearControllerState()
        controller = next
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
        if pad.buttonA.isPressed { buttons |= 0x8000 }
        if pad.buttonB.isPressed { buttons |= 0x4000 }
        if pad.leftTrigger.isPressed || pad.rightTrigger.isPressed { buttons |= 0x2000 }
        if pad.buttonMenu.isPressed { buttons |= 0x1000 }
        if pad.leftShoulder.isPressed { buttons |= 0x0020 }
        if pad.rightShoulder.isPressed { buttons |= 0x0010 }
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
