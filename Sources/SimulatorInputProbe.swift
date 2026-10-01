// Compiled only by the explicit Simulator probe option, never by device builds.
import Foundation
import GameController

@MainActor
final class SimulatorInputProbe {
    static let shared = SimulatorInputProbe()
    var controller: GCController? { virtual?.controller }
    private var virtual: GCVirtualController?
    private var timer: Timer?
    private var sequence: Int64 = 0
    private var releaseAt: TimeInterval = 0
    private let file = URL.documentsDirectory.appendingPathComponent("squirrelpad-sim-input.json")
    private let buttonElements = ["A": GCInputButtonA, "B": GCInputButtonB,
                                  "X": GCInputButtonX, "Y": GCInputButtonY,
                                  "LB": GCInputLeftShoulder, "RB": GCInputRightShoulder,
                                  "LT": GCInputLeftTrigger, "RT": GCInputRightTrigger]

    private struct Command: Decodable {
        var sequence: Int64
        var x: Float = 0
        var y: Float = 0
        var cameraX: Float = 0
        var cameraY: Float = 0
        var buttons: [String] = []
        var seconds: Double
        var expiresAt: Double
    }

    func start(onConnect: @escaping @MainActor () -> Void) {
        guard ProcessInfo.processInfo.environment["SQUIRRELPAD_SIM_INPUT"] == "1", virtual == nil else { return }
        let config = GCVirtualController.Configuration()
        config.elements = Set(buttonElements.values).union([GCInputLeftThumbstick, GCInputRightThumbstick])
        config.isHidden = true
        virtual = GCVirtualController(configuration: config)
        virtual?.connect { error in
            Task { @MainActor in
                NSLog("[sim input] connected=%@ error=%@", String(self.controller != nil), String(describing: error))
                onConnect()
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in self.poll() }
        }
    }

    private func poll() {
        guard controller != nil else { return }
        if releaseAt != 0 && ProcessInfo.processInfo.systemUptime >= releaseAt {
            release()
        }
        guard let data = try? Data(contentsOf: file),
              let command = try? JSONDecoder().decode(Command.self, from: data),
              command.sequence != sequence else { return }
        sequence = command.sequence
        let remaining = command.expiresAt - Date().timeIntervalSince1970
        guard remaining > 0 else { return }
        virtual?.setPosition(CGPoint(x: CGFloat(command.x), y: CGFloat(command.y)), forDirectionPadElement: GCInputLeftThumbstick)
        virtual?.setPosition(CGPoint(x: CGFloat(command.cameraX), y: CGFloat(command.cameraY)), forDirectionPadElement: GCInputRightThumbstick)
        for (name, element) in buttonElements {
            virtual?.setValue(command.buttons.contains(name) ? 1 : 0, forButtonElement: element)
        }
        releaseAt = ProcessInfo.processInfo.systemUptime + min(remaining, 10)
        NSLog("[sim input] seq=%lld stick=%.2f,%.2f camera=%.2f,%.2f buttons=%@ duration=%.2f",
              sequence, command.x, command.y, command.cameraX, command.cameraY,
              command.buttons.joined(separator: ","), command.seconds)
    }

    private func release() {
        virtual?.setPosition(.zero, forDirectionPadElement: GCInputLeftThumbstick)
        virtual?.setPosition(.zero, forDirectionPadElement: GCInputRightThumbstick)
        for element in buttonElements.values { virtual?.setValue(0, forButtonElement: element) }
        releaseAt = 0
        NSLog("[sim input] released seq=%lld", sequence)
    }
}
