import SwiftUI

// Shared by the launcher and pause menu, with native controls and familiar blue actions.
enum SquirrelPadTheme {
    static let background = Color(red: 0.025, green: 0.04, blue: 0.09)
    static let panel = Color(red: 0.055, green: 0.075, blue: 0.13)
    static let accent = Color(red: 0.24, green: 0.48, blue: 1)
    static let secondary = Color.white.opacity(0.68)
}

struct AcornMark: View {
    var size: CGFloat

    var body: some View {
        Image("Acorn")
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct SquirrelPadButtonStyle: ButtonStyle {
    var primary = false
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(minHeight: 46)
            .background(primary ? SquirrelPadTheme.accent : .white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 12))
            .opacity(enabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}

struct SquirrelPadLauncher: View {
    let size: CGSize
    let hasROM: Bool
    let paused: Bool
    let message: String
    let play: () -> Void
    let chooseROM: () -> Void
    let settings: () -> Void
    @State private var showHelp = false
    @State private var drifting = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private let gold = Color(red: 1, green: 0.76, blue: 0.34)

    private var compact: Bool { size.height < 560 }
    private var wide: Bool { size.width > 650 }
    private var inset: CGFloat { compact ? 64 : wide ? 64 : 28 }

    var body: some View {
        ZStack {
            Image("Woodland")
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .scaleEffect(drifting ? 1.035 : 1, anchor: .trailing)
                .clipped()
                .accessibilityHidden(true)
            LinearGradient(stops: [
                .init(color: Color(red: 0.015, green: 0.05, blue: 0.065).opacity(0.86), location: 0),
                .init(color: .black.opacity(wide ? 0.28 : 0.55), location: 0.52),
                .init(color: .clear, location: 1)
            ], startPoint: .leading, endPoint: .trailing)
            LinearGradient(colors: [.black.opacity(0.24), .clear, .black.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)
            ScrollView {
                VStack(alignment: .leading, spacing: compact ? 16 : 32) {
                    header
                    Spacer(minLength: compact ? 0 : 28)
                    hero
                        .frame(maxWidth: wide ? min(560, size.width * 0.58) : .infinity, alignment: .leading)
                    Spacer(minLength: compact ? 0 : 28)
                    HStack(spacing: 18) {
                        Label("Touch or controller", systemImage: "gamecontroller")
                        if hasROM && !compact {
                            Label("ROM on this device", systemImage: "checkmark.circle")
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.65))
                }
                .padding(.horizontal, inset)
                .padding(.vertical, compact ? 18 : 36)
                .frame(maxWidth: .infinity, minHeight: size.height, alignment: .leading)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .onAppear { updateMotion() }
        .onChange(of: reduceMotion) { _, _ in updateMotion() }
        .onChange(of: scenePhase) { _, _ in updateMotion() }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Label("Your own US ROM", systemImage: "doc.badge.plus")
                            .font(.title2.bold())
                        Text("Copy your Conker’s Bad Fur Day ROM to Files, then choose it in SquirrelPad. The supported file is the 64 MiB US release in big-endian format, usually named .z64.")
                        Text("After import, tap Play Conker whenever you return. Progress is saved by the game; use its normal save points.")
                        Label("Keep your progress", systemImage: "externaldrive")
                            .font(.headline)
                        Text("Install updates over the existing app. Deleting SquirrelPad also deletes its imported ROM, settings, and saves.")
                        Text("Touch controls and a connected game controller are configured in Settings → Controls.")
                    }
                    .padding(24)
                }
                .navigationTitle("Setup help")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showHelp = false } } }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            AcornMark(size: compact ? 32 : 40)
            Text("SquirrelPad")
                .font(.system(size: compact ? 18 : 22, weight: .bold, design: .rounded))
            Spacer(minLength: 12)
            Button(action: settings) {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
            .accessibilityIdentifier("squirrelpad-launcher-settings")
            Button { showHelp = true } label: {
                Label("Help", systemImage: "questionmark.circle")
            }
        }
        .buttonStyle(LauncherUtilityStyle())
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: compact ? 12 : 22) {
            HStack(spacing: 8) {
                Circle().fill(gold).frame(width: 6, height: 6)
                Text(paused ? "GAME PAUSED" : hasROM ? "READY TO PLAY" : "WELCOME TO SQUIRRELPAD")
                    .font(.system(size: compact ? 10 : 12, weight: .bold))
                    .tracking(2)
            }
            .foregroundStyle(gold)
            (Text("Conker’s\n").foregroundStyle(.white) + Text("Bad Fur Day").foregroundStyle(gold))
                .font(.system(size: compact ? 44 : wide ? 72 : 50, weight: .black, design: .rounded))
                .tracking(compact ? -1.5 : -2.5)
                .lineSpacing(-4)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            Text(paused ? "A little breather. Then back to the trouble."
                 : hasROM ? "A very bad day. A very good time."
                 : "Bring your own US ROM. We’ll take it from here.")
                .font(.system(size: compact ? 14 : 18))
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            if !message.isEmpty && !paused {
                Label(message, systemImage: "exclamationmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(gold)
                    .padding(12)
                    .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("squirrelpad-import-message")
            }
            HStack(spacing: compact ? 16 : 22) {
                Button(action: paused || hasROM ? play : chooseROM) {
                    HStack(spacing: 12) {
                        Image(systemName: paused || hasROM ? "play.fill" : "folder.fill")
                        Text(paused ? "Resume Game" : hasROM ? "Play Conker" : "Choose ROM")
                        Spacer(minLength: 16)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: compact ? 235 : 270)
                }
                .buttonStyle(LauncherPlayStyle())
                .accessibilityIdentifier("squirrelpad-play")
                if hasROM && !paused {
                    Button(action: chooseROM) {
                        Label("Change ROM", systemImage: "folder")
                    }
                    .buttonStyle(LauncherUtilityStyle())
                    .accessibilityLabel("Choose another ROM")
                }
            }
            .padding(.top, compact ? 0 : 6)
        }
    }

    private func updateMotion() {
        // One slow compositor animation; never animate while inactive or with Reduce Motion.
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) { drifting = false }
        guard !reduceMotion, scenePhase == .active else { return }
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            drifting = true
        }
    }
}

private struct LauncherPlayStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.15, green: 0.095, blue: 0.025))
            .padding(.horizontal, 22)
            .frame(minHeight: 54)
            .background(LinearGradient(colors: [Color(red: 1, green: 0.82, blue: 0.46),
                                                Color(red: 1, green: 0.65, blue: 0.22)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3)))
            .shadow(color: .orange.opacity(configuration.isPressed ? 0.1 : 0.2), radius: 20, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct LauncherUtilityStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 14)
            .frame(minWidth: 44, minHeight: 44)
            .background(.black.opacity(configuration.isPressed ? 0.5 : 0.25),
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.12)))
    }

}

struct SettingsCard<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: symbol)
                .font(.headline)
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
    }
}
