import CryptoKit
import SwiftUI
import UniformTypeIdentifiers

private extension UTType {
    static let n64ROM = UTType(importedAs: "com.chrissotraidis.squirrelpad.n64-rom", conformingTo: .data)
}

@_silgen_name("squirrelpad_run_core")
private func runConkerCore(_ rom: UnsafePointer<CChar>, _ dataDirectory: UnsafePointer<CChar>, _ seconds: Int32) -> Int32
@_silgen_name("squirrelpad_vi_count")
private func conkerVICount() -> UInt32
@_silgen_name("squirrelpad_set_active")
private func setCoreActive(_ active: Bool)

@MainActor
private final class GameSession: ObservableObject {
    @Published var message = "Select your US Conker's Bad Fur Day ROM."
    @Published var running = false
    @Published private(set) var storedROM: URL?

    init() {
        if let support = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask, appropriateFor: nil, create: false) {
            let candidate = support.appendingPathComponent("Conker/baserom.us.z64")
            if FileManager.default.fileExists(atPath: candidate.path) { storedROM = candidate }
        }
    }

    func importROM(_ url: URL) {
        guard !running else { return }
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            guard data.count == 67_108_864, Array(data.prefix(4)) == [0x80, 0x37, 0x12, 0x40] else {
                message = "That file is not the supported 64 MiB big-endian US ROM."
                return
            }
            let digest = Insecure.SHA1.hash(data: data).map { String(format: "%02x", $0) }.joined()
            guard digest == "4cbadd3c4e0729dec46af64ad018050eada4f47a" else {
                message = "ROM checksum does not match the supported US revision."
                return
            }
            let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directory = support.appendingPathComponent("Conker", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let imported = directory.appendingPathComponent("baserom.us.z64")
            if url.standardizedFileURL != imported.standardizedFileURL {
                try data.write(to: imported, options: .atomic)
            }
            storedROM = imported
            message = "ROM verified. Starting the native game core…"
            running = true
            let romPath = imported.path
            let dataPath = directory.path
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                guard self.running else { return }
                let count = conkerVICount()
                self.message = count > 0
                    ? "Native core is running (\(count) VIs). Gameplay display is still in development."
                    : "Native core started, but has not produced a VI yet."
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let result = romPath.withCString { rom in
                    dataPath.withCString { storage in runConkerCore(rom, storage, 0) }
                }
                DispatchQueue.main.async {
                    self.running = false
                    self.message = result == 0 ? "Native core check finished. Gameplay display is still in development." : "Native core check failed (code \(result))."
                }
            }
        } catch {
            message = "ROM import failed: \(error.localizedDescription)"
        }
    }
}

@main
struct SquirrelPadApp: App {
    @StateObject private var session = GameSession()
    @StateObject private var renderer = RendererStatus()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("SquirrelPad.TouchControls") private var touchEnabled = true
    @AppStorage("SquirrelPad.TouchTransparency") private var touchTransparency = false
    @AppStorage("SquirrelPad.TouchOpacity") private var touchOpacity = 1.0
    @State private var importing = false
    @State private var menuOpen = false

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                let compact = geometry.size.height < 560
                let menuSize: CGFloat = compact && !menuOpen ? 32 : compact ? 44 : 38
                ZStack {
                    Color.black
                    RT64Surface(renderer: renderer)
                        .frame(width: 240, height: 135)
                        .scaleEffect(compact
                            ? min(geometry.size.width / 240, geometry.size.height / 135)
                            : max(geometry.size.width / 240, geometry.size.height / 135))
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    if session.running && touchEnabled && !menuOpen {
                        TouchControlsView(opacity: touchTransparency ? touchOpacity : 1.0)
                    }
                    if !session.running {
                        importPanel
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2)
                    }
                    if menuOpen {
                        Color.black.opacity(0.78)
                            .onTapGesture { menuOpen = false }
                        controlsPanel(compact: compact, size: geometry.size)
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2 - (compact ? 16 : 0))
                    }
                    Button(action: toggleMenu) {
                        Text("•••")
                            .font(.system(size: compact ? 17 : 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: menuSize, height: menuSize)
                            .background(.black.opacity(0.42), in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 2))
                            .padding(compact && !menuOpen ? 6 : 0)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Menu")
                    .accessibilityIdentifier("squirrelpad-menu")
                    .position(x: compact ? geometry.size.width / 2 : geometry.size.width - 32,
                              y: compact ? (menuOpen ? geometry.size.height - 48 : 20) : 32)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(.black)
            .ignoresSafeArea()
            .statusBarHidden()
            .fileImporter(isPresented: $importing, allowedContentTypes: [.n64ROM, .data]) { selection in
                switch selection {
                case .success(let url): session.importROM(url)
                case .failure(let error): session.message = "Could not choose ROM: \(error.localizedDescription)"
                }
            }
            .onChange(of: menuOpen) { open in if open { clearTouchInput() } }
            .onChange(of: touchEnabled) { enabled in if !enabled { clearTouchInput() } }
            .onChange(of: scenePhase) { phase in
                if phase != .active { clearTouchInput() }
                setCoreActive(phase == .active)
            }
            .onChange(of: session.running) { running in if !running { clearTouchInput() } }
        }
    }

    private var importPanel: some View {
        VStack(spacing: 18) {
            Text("SquirrelPad").font(.largeTitle.bold())
            Text(session.message).multilineTextAlignment(.center)
            Button("Choose ROM") { importing = true }
                .buttonStyle(.borderedProminent)
            if let storedROM = session.storedROM {
                Button("Continue Imported ROM") { session.importROM(storedROM) }
            }
            Text(renderer.message).font(.caption.monospaced())
            if session.running { ProgressView() }
        }
        .foregroundStyle(.white)
        .padding(28)
        .frame(maxWidth: 420)
        .background(.black.opacity(0.76), in: RoundedRectangle(cornerRadius: 18))
    }

    private func controlsPanel(compact: Bool, size: CGSize) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text("Settings")
                    .font(.system(size: compact ? 20 : 26, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 6))
                Spacer()
                Button("Close") { menuOpen = false }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Close menu")
                    .padding(.trailing, compact ? 0 : 50)
            }
            .padding(.horizontal, compact ? 18 : 28)
            .frame(height: compact ? 54 : 70)

            Rectangle().fill(.white.opacity(0.55)).frame(height: 2)

            HStack(alignment: .top, spacing: 0) {
                Text("Controls")
                    .font(.system(size: compact ? 17 : 22, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal, compact ? 12 : 22)
                    .padding(.top, 24)
                    .frame(width: compact ? 158 : 230)

                Rectangle().fill(.white.opacity(0.6)).frame(width: 2)

                ScrollView {
                    VStack(alignment: .leading, spacing: compact ? 16 : 24) {
                        Text("Controls")
                            .font(.system(size: compact ? 23 : 29, weight: .semibold))
                        Toggle("Touch Controls", isOn: $touchEnabled)
                            .tint(.blue)
                        Text("Show the N64 controls on the game screen.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.68))
                        Divider().overlay(.white.opacity(0.4))
                        Toggle("Transparent Controls", isOn: $touchTransparency)
                            .tint(.blue)
                            .disabled(!touchEnabled)
                        if touchTransparency {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Control Opacity")
                                    Spacer()
                                    Text("\(Int((touchOpacity * 100).rounded()))%")
                                        .monospacedDigit()
                                }
                                Slider(value: $touchOpacity, in: 0.25...1.0)
                                    .tint(.blue)
                            }
                            .disabled(!touchEnabled)
                        }
                        Button("Restore Defaults") {
                            touchEnabled = true
                            touchTransparency = false
                            touchOpacity = 1.0
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(compact ? 20 : 30)
                }
                .frame(height: size.height - (compact ? 156 : 128))
            }
        }
        .foregroundStyle(.white)
        .frame(width: size.width - (compact ? 32 : 56),
               height: size.height - (compact ? 100 : 56))
        .background(Color.black.opacity(0.93), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.35)))
    }

    private func toggleMenu() {
        if !menuOpen { clearTouchInput() }
        menuOpen.toggle()
    }
}
