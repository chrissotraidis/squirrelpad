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

    private var compact: Bool { size.height < 560 }
    private var wide: Bool { size.width > 650 }

    var body: some View {
        ZStack {
            LinearGradient(colors: [SquirrelPadTheme.background,
                                    Color(red: 0.065, green: 0.08, blue: 0.19)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            ScrollView {
                VStack(spacing: compact ? 18 : 32) {
                    if wide {
                        HStack(spacing: compact ? 32 : 56) {
                            identity.frame(maxWidth: .infinity)
                            actions.frame(maxWidth: .infinity)
                        }
                    } else {
                        identity
                        actions
                    }
                    HStack(spacing: 18) {
                        Button(action: settings) { Label("Settings", systemImage: "slider.horizontal.3") }
                        Button { showHelp = true } label: { Label("Setup help", systemImage: "questionmark.circle") }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(SquirrelPadTheme.secondary)
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                }
                .frame(maxWidth: 850)
                .padding(.horizontal, wide ? 44 : 28)
                .padding(.vertical, compact ? 24 : 48)
                .frame(maxWidth: .infinity, minHeight: size.height)
            }
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
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

    private var identity: some View {
        VStack(spacing: compact ? 10 : 18) {
            AcornMark(size: compact ? 112 : 164)
            VStack(spacing: 6) {
                Text("SquirrelPad")
                    .font(.system(size: compact ? 32 : 42, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text("Conker’s Bad Fur Day")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(SquirrelPadTheme.secondary)
            }
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: compact ? 14 : 20) {
            Label(paused ? "GAME PAUSED" : hasROM ? "READY TO PLAY" : "GET STARTED",
                  systemImage: paused ? "pause.circle.fill" : hasROM ? "checkmark.circle.fill" : "doc.badge.plus")
                .font(.caption.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(Color(red: 1, green: 0.73, blue: 0.34))
            Text(paused ? "Pick up where you left off." : hasROM ? "Your game is ready." : "Start with your ROM.")
                .font(.system(size: compact ? 23 : 28, weight: .semibold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text(paused ? "Your current session is paused and ready to resume."
                 : hasROM ? "Your imported copy is saved on this device."
                 : "Choose your own US copy of Conker’s Bad Fur Day from Files to begin.")
                .font(.subheadline)
                .foregroundStyle(SquirrelPadTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !message.isEmpty && !paused {
                Label(message, systemImage: "exclamationmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("squirrelpad-import-message")
            }
            Button(action: paused || hasROM ? play : chooseROM) {
                HStack {
                    Label(paused ? "Resume Game" : hasROM ? "Play Conker" : "Choose ROM",
                          systemImage: paused || hasROM ? "play.fill" : "folder")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(SquirrelPadButtonStyle(primary: true))
            .accessibilityIdentifier("squirrelpad-play")
            if hasROM && !paused {
                Button(action: chooseROM) { Text("Choose another ROM").frame(maxWidth: .infinity) }
                    .buttonStyle(SquirrelPadButtonStyle())
            }
        }
        .padding(compact ? 22 : 28)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.08)))
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
