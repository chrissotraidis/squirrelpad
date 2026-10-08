import SwiftUI

@_silgen_name("squirrelpad_set_enhancements")
private func setEnhancements(_ flags: UInt32, _ speed: Float, _ cash: Int32)
@_silgen_name("squirrelpad_set_mix")
private func setMix(_ music: Float, _ effects: Float, _ speech: Float)
@_silgen_name("squirrelpad_crosshair_raise")
private func crosshairRaise() -> Float
@_silgen_name("squirrelpad_skip_progress")
private func skipProgress() -> Float
@_silgen_name("squirrelpad_save_serial")
private func saveSerial() -> UInt64

@MainActor
final class EnhancementSettings: ObservableObject {
    @Published var flags: UInt32 { didSet { apply() } }
    @Published var cameraSpeed: Double { didSet { apply() } }
    @Published var cash: Int { didSet { apply() } }
    @Published var saveIndicator: Bool { didSet { apply() } }
    @Published var music: Double { didSet { apply() } }
    @Published var effects: Double { didSet { apply() } }
    @Published var speech: Double { didSet { apply() } }
    init() {
        let d = UserDefaults.standard
        flags = UInt32(clamping: d.object(forKey: "SquirrelPad.EnhancementFlags") as? Int ?? 8)
        cameraSpeed = min(3, max(0.5, d.object(forKey: "SquirrelPad.CameraSpeed") as? Double ?? 1))
        cash = min(2, max(0, d.integer(forKey: "SquirrelPad.CashHUD")))
        saveIndicator = d.object(forKey: "SquirrelPad.SaveIndicator") as? Bool ?? false
        music = min(1, max(0, d.object(forKey: "SquirrelPad.MusicVolume") as? Double ?? 1))
        effects = min(1, max(0, d.object(forKey: "SquirrelPad.EffectsVolume") as? Double ?? 1))
        speech = min(1, max(0, d.object(forKey: "SquirrelPad.SpeechVolume") as? Double ?? 1))
        apply()
    }
    func option(_ bit: Int) -> Binding<Bool> {
        Binding(get: { self.flags & (1 << bit) != 0 }, set: { enabled in
            if enabled { self.flags |= 1 << bit } else { self.flags &= ~(1 << bit) }
        })
    }
    func apply() {
        let d = UserDefaults.standard
        d.set(Int(flags), forKey: "SquirrelPad.EnhancementFlags")
        d.set(cameraSpeed, forKey: "SquirrelPad.CameraSpeed")
        d.set(cash, forKey: "SquirrelPad.CashHUD")
        d.set(saveIndicator, forKey: "SquirrelPad.SaveIndicator")
        d.set(music, forKey: "SquirrelPad.MusicVolume")
        d.set(effects, forKey: "SquirrelPad.EffectsVolume")
        d.set(speech, forKey: "SquirrelPad.SpeechVolume")
        setEnhancements(flags, Float(cameraSpeed), Int32(cash))
        setMix(Float(music), Float(effects), Float(speech))
    }
}

struct AdventureSettings: View {
    @ObservedObject var settings: EnhancementSettings
    var body: some View {
        VStack(spacing: 20) {
            SettingsCard(title: "Camera & aiming", symbol: "viewfinder") {
                Toggle("Right-stick free camera", isOn: settings.option(0))
                Text("Use a connected controller’s right stick to orbit and aim. Fixed cameras and cutscenes keep the game’s framing. Touch C-buttons remain available.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                Toggle("Invert camera horizontally", isOn: settings.option(1))
                Toggle("Invert camera vertically", isOn: settings.option(2))
                HStack { Text("Camera speed"); Spacer(); Text(String(format: "%.1f×", settings.cameraSpeed)) }
                Slider(value: $settings.cameraSpeed, in: 0.5...3, step: 0.1).accessibilityLabel("Camera speed")
                Toggle("Invert stick aiming vertically", isOn: settings.option(3))
                Toggle("Aiming crosshair", isOn: settings.option(4))
                Text("The crosshair follows the upstream calibration for barn knives. Other weapons need further playtesting.")
                    .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
            }
            SettingsCard(title: "Adventure comforts", symbol: "leaf") {
                Toggle("Skip intro on launch", isOn: settings.option(5))
                Text("Applies on the next cold launch. Goes straight to the file menu.")
                    .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                Toggle("Show save confirmation", isOn: $settings.saveIndicator)
                Picker("Cash display", selection: $settings.cash) {
                    Text("Off").tag(0); Text("On change").tag(1); Text("Always").tag(2)
                }
                Toggle("Keep health visible", isOn: settings.option(12))
                Toggle("Reduce motion blur", isOn: settings.option(11))
            }
            SettingsCard(title: "Accessibility assists", symbol: "accessibility") {
                Toggle("Toggle R-look", isOn: settings.option(7))
                Toggle("Toggle crouch", isOn: settings.option(8))
                Toggle("Hold L to walk", isOn: settings.option(9))
                Toggle("Push up to swim upward", isOn: settings.option(10))
                Toggle("Longer tail spin", isOn: settings.option(13))
                Toggle("Easier ledge grabs", isOn: settings.option(14))
                Text("Optional changes to the original controls and movement. Ledge assists catch straight edges; corners keep the original limitations.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
            }
        }
    }
}

struct AudioMixSettings: View {
    @ObservedObject var settings: EnhancementSettings
    var body: some View {
        volume("Music", value: $settings.music)
        volume("Sound effects", value: $settings.effects)
        volume("Speech", value: $settings.speech)
        Text("Music includes some ambience. Speech controls streamed dialogue; short voice sounds follow effects. Changes take effect as the game updates each voice.")
            .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
        Button("Restore Audio Mix") { settings.music = 1; settings.effects = 1; settings.speech = 1 }
            .buttonStyle(SquirrelPadButtonStyle())
    }
    private func volume(_ title: String, value: Binding<Double>) -> some View {
        VStack {
            HStack { Text(title); Spacer(); Text("\(Int((value.wrappedValue * 100).rounded()))%").monospacedDigit() }
            Slider(value: value, in: 0...1).accessibilityLabel(title + " volume")
        }
    }
}

struct AdventureOverlay: View {
    @ObservedObject var settings: EnhancementSettings
    @State private var raise: Float = -1
    @State private var progress: Float = 0
    @State private var serial: UInt64 = 0
    @State private var savedUntil = Date.distantPast
    private let tick = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    var body: some View {
        GeometryReader { g in
            ZStack {
                if raise >= 0 {
                    Circle().fill(.red).frame(width: 8, height: 8)
                        .overlay(Circle().stroke(.black.opacity(0.8), lineWidth: 1))
                        .position(x: g.size.width / 2, y: g.size.height / 2 - CGFloat(raise) * min(g.size.height, g.size.width * 0.75) / 2)
                }
                VStack {
                    if settings.saveIndicator && Date() < savedUntil {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .padding(9).background(.black.opacity(0.7), in: Capsule())
                    }
                    Spacer()
                    if progress > 0 {
                        HStack {
                            ProgressView(value: progress).frame(width: 70)
                            Text("Hold L to skip")
                        }.padding(10).background(.black.opacity(0.7), in: Capsule())
                    }
                }.padding(.vertical, 24)
            }
        }
        .foregroundStyle(SquirrelPadTheme.accent)
        .allowsHitTesting(false)
        .onAppear { serial = saveSerial() }
        .onReceive(tick) { _ in
            raise = crosshairRaise(); progress = skipProgress()
            if savedUntil != .distantPast && Date() >= savedUntil { savedUntil = .distantPast }
            let current = saveSerial()
            if current != serial { savedUntil = Date().addingTimeInterval(2); serial = current }
        }
    }
}
