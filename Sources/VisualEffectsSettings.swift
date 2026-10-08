import SwiftUI

@_silgen_name("squirrelpad_set_visual_effects")
private func setVisualEffects(_ color: Int32, _ glow: Int32, _ clarity: Int32, _ crt: Int32)

@MainActor
final class VisualEffectsSettings: ObservableObject {
    @Published var enabled: Bool { didSet { apply() } }
    @Published var color: Double { didSet { apply() } }
    @Published var glow: Double { didSet { apply() } }
    @Published var clarity: Double { didSet { apply() } }
    @Published var crt: Double { didSet { apply() } }

    init() {
        let defaults = UserDefaults.standard
        enabled = defaults.bool(forKey: "SquirrelPad.Visual.Enabled")
        func amount(_ key: String, _ fallback: Double) -> Double {
            let value = defaults.object(forKey: "SquirrelPad.Visual." + key) as? Double ?? fallback
            return value.isFinite ? min(100, max(0, value)) : fallback
        }
        color = amount("Color", 65)
        glow = amount("Glow", 35)
        clarity = amount("Clarity", 40)
        crt = amount("CRT", 0)
        apply()
    }

    func apply() {
        let defaults = UserDefaults.standard
        defaults.set(enabled, forKey: "SquirrelPad.Visual.Enabled")
        for (key, value) in [("Color", color), ("Glow", glow), ("Clarity", clarity), ("CRT", crt)] {
            defaults.set(value, forKey: "SquirrelPad.Visual." + key)
        }
        func active(_ value: Double) -> Int32 {
            enabled && value.isFinite ? Int32(min(100, max(0, value))) : 0
        }
        setVisualEffects(active(color), active(glow), active(clarity), active(crt))
    }

    func enhanced() {
        color = 65; glow = 35; clarity = 40; crt = 0; enabled = true
    }
    func television() {
        color = 25; glow = 20; clarity = 0; crt = 75; enabled = true
    }
}

struct VisualEffectsCard: View {
    @ObservedObject var settings: VisualEffectsSettings
    let running: Bool

    var body: some View {
        SettingsCard(title: "Picture lab", symbol: "camera.filters") {
            HStack {
                Text("A new look, the same bad day.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                Spacer()
                Text("EXPERIMENTAL").font(.caption2.bold())
                    .foregroundStyle(SquirrelPadTheme.accent)
            }
            Toggle("Visual effects", isOn: $settings.enabled)
                .accessibilityIdentifier("squirrelpad-visual-effects")
            HStack(spacing: 12) {
                Button("Original") { settings.enabled = false }
                Button("Enhanced") { settings.enhanced() }
                Button("CRT") { settings.television() }
            }
            .buttonStyle(SquirrelPadButtonStyle())
            if settings.enabled {
                Divider()
                effect("Rich color", description: "Deeper color and a little more contrast.", amount: $settings.color, restore: 65)
                effect("Soft glow", description: "A gentle halo around bright areas.", amount: $settings.glow, restore: 35)
                effect("Clarity", description: "Adds definition to edges and fine detail.", amount: $settings.clarity, restore: 40)
                effect("CRT scanlines", description: "Subtle scanlines and darker corners for a television feel.", amount: $settings.crt, restore: 75)
            }
            Text("These filters affect the game picture, including its text. They do not replace textures or add AI detail. Touch controls keep their original appearance.")
                .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
            Label(running ? "Resume to see your changes" : "Applies when you play", systemImage: "play.circle")
                .font(.caption).foregroundStyle(SquirrelPadTheme.accent)
            if settings.enabled {
                Text("Switch Visual effects off to compare with the original. Your adjustments are kept.")
                    .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
            }
        }
    }

    private func effect(_ title: String, description: String, amount: Binding<Double>, restore: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(title, isOn: Binding(get: { amount.wrappedValue > 0 }, set: { amount.wrappedValue = $0 ? restore : 0 }))
            if amount.wrappedValue > 0 {
                HStack {
                    Slider(value: amount, in: 0...100, step: 5)
                        .accessibilityLabel(title + " strength")
                    Text("\(Int(amount.wrappedValue))%")
                        .font(.caption.monospacedDigit()).frame(width: 42, alignment: .trailing)
                }
            }
            Text(description).font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
        }
    }
}
