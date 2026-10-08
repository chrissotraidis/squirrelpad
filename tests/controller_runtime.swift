// Exercise the shipping adapter with Apple's mutable controller snapshots.
import Foundation
import GameController

private var buttons: UInt16 = 0
private var stickX: Float = 0
private var stickY: Float = 0
private var cameraX: Float = 0
private var cameraY: Float = 0

@_cdecl("squirrelpad_controller_set_state")
func setState(_ mask: UInt16, _ x: Float, _ y: Float) {
    buttons = mask; stickX = x; stickY = y
}
@_cdecl("squirrelpad_controller_clear")
func clearState() { buttons = 0; stickX = 0; stickY = 0; cameraX = 0; cameraY = 0 }
@_cdecl("squirrelpad_controller_camera")
func camera(_ x: Float, _ y: Float) { cameraX = x; cameraY = y }
@_cdecl("squirrelpad_rumble_enable") func rumble(_ enabled: Bool) {}
@_cdecl("squirrelpad_rumble_requested") func requested() -> Bool { false }

@main struct ControllerRegression {
    @MainActor static func settle() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.08))
    }
    @MainActor static func main() {
        let first = GCController.withExtendedGamepad()
        let second = GCController.withExtendedGamepad()
        let pad = first.extendedGamepad!
        var connected = [first]
        let input = ControllerInput(controllers: { connected })
        assert(input.isConnected && first.playerIndex == .index1)
        assert(!input.rumbleAvailable)
        input.setActive(true)
        pad.buttonA.setValue(1)
        pad.leftThumbstick.setValueForXAxis(0.75, yAxis: -0.5)
        pad.rightThumbstick.setValueForXAxis(-0.8, yAxis: 0.9)
        settle()
        assert(buttons & 0x800a == 0x800a && stickX == 0.75 && stickY == -0.5)
        assert(cameraX == -0.8 && cameraY == 0.9)
        assert(input.inputStatus.contains("A") && input.inputStatus.contains("Left stick"))

        // A missing event callback must not strand held buttons or stick movement.
        pad.valueChangedHandler = nil
        pad.buttonA.setValue(0)
        pad.buttonB.setValue(1)
        settle()
        assert(buttons & 0xc000 == 0x4000)
        input.setActive(false)
        assert(buttons == 0 && stickX == 0 && cameraX == 0)
        pad.buttonB.setValue(0)
        pad.buttonX.setValue(1)
        settle()
        assert(buttons == 0 && input.inputStatus.contains("X"))
        input.setActive(true)
        assert(pad.valueChangedHandler != nil)
        assert(stickX == 0.75)
        input.setForeground(false)
        settle()
        assert(buttons == 0 && stickX == 0 && cameraX == 0)
        pad.buttonA.setValue(1)
        settle()
        assert(buttons == 0)
        input.setForeground(true)
        settle()
        assert(buttons & 0x8000 != 0 && stickX == 0.75)

        // A second pad does not take player one; disconnect clears its held input.
        connected = [second, first]
        NotificationCenter.default.post(name: .GCControllerDidConnect, object: second)
        settle()
        assert(first.playerIndex == .index1 && buttons & 0x8000 != 0)
        connected = []
        NotificationCenter.default.post(name: .GCControllerDidDisconnect, object: first)
        settle()
        assert(!input.isConnected && input.connectedName == nil)
        assert(buttons == 0 && stickX == 0 && cameraX == 0)
        assert(pad.valueChangedHandler == nil && first.playerIndex == .indexUnset)
        pad.buttonB.setValue(1)
        settle()
        assert(buttons == 0)
        connected = [second]
        NotificationCenter.default.post(name: .GCControllerDidConnect, object: second)
        settle()
        second.extendedGamepad!.buttonMenu.setValue(1)
        settle()
        assert(input.isConnected && buttons == 0x1000)
        input.setActive(false)
        assert(buttons == 0)
        print("Controller input, polling fallback, pause/resume, background, and reconnect passed.")
    }
}
