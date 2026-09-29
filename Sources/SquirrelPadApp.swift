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
@_silgen_name("squirrelpad_audio_set_volume")
private func setMasterVolume(_ volume: Float)

private enum SettingsSection {
    case controls
    case audio
}

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
    @AppStorage("SquirrelPad.ControlScale") private var controlScale = 1.0
    @AppStorage("SquirrelPad.ShowDpad") private var showDpad = true
    @AppStorage("SquirrelPad.ShowCButtons") private var showCButtons = true
    @AppStorage("SquirrelPad.MasterVolume") private var masterVolume = 1.0
    @AppStorage("SquirrelPad.LayoutTablet") private var tabletLayout = ""
    @AppStorage("SquirrelPad.LayoutPhone") private var phoneLayout = ""
    @State private var importing = false
    @State private var menuOpen = false
    @State private var editingLayout = false
    @State private var editingCompact = false
    @State private var editedPositions: [String: CGPoint] = [:]
    @State private var settingsSection: SettingsSection = .controls

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

                    if session.running && touchEnabled && (!menuOpen || editingLayout) {
                        TouchControlsView(opacity: touchTransparency ? touchOpacity : 1.0,
                                          scale: controlScale,
                                          showDpad: showDpad, showCButtons: showCButtons,
                                          editing: editingLayout,
                                          layout: editingLayout && editingCompact == compact
                                              ? editedPositions : savedLayout(compact: compact),
                                          onMove: { id, center in
                                              if editingLayout && editingCompact == compact {
                                                  editedPositions[id] = center
                                              }
                                          })
                    }
                    if !session.running {
                        importPanel
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2)
                    }
                    if menuOpen {
                        Color.black.opacity(0.28)
                            .onTapGesture { menuOpen = false }
                        controlsPanel(compact: compact, size: geometry.size)
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2 - (compact ? 16 : 0))
                    }
                    if editingLayout {
                        HStack(spacing: 14) {
                            Text("Drag controls to move them")
                            Button("Reset Layout") { editedPositions = [:] }
                            Button("Done") { finishLayoutEdit() }
                        }
                        .font(.system(size: compact ? 14 : 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.82), in: Capsule())
                        .position(x: geometry.size.width / 2, y: compact ? 42 : 48)
                    } else {
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
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(.black)
            .ignoresSafeArea()
            .statusBarHidden()
            .onAppear { setMasterVolume(Float(masterVolume)) }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.n64ROM, .data]) { selection in
                switch selection {
                case .success(let url): session.importROM(url)
                case .failure(let error): session.message = "Could not choose ROM: \(error.localizedDescription)"
                }
            }
            .onChange(of: menuOpen) { open in if open { clearTouchInput() } }
            .onChange(of: touchEnabled) { enabled in if !enabled { clearTouchInput() } }
            .onChange(of: showDpad) { _ in clearTouchInput() }
            .onChange(of: showCButtons) { _ in clearTouchInput() }
            .onChange(of: masterVolume) { value in setMasterVolume(Float(value)) }
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    clearTouchInput()
                    editingLayout = false
                }
                setCoreActive(phase == .active)
            }
            .onChange(of: session.running) { running in
                if !running {
                    clearTouchInput()
                    editingLayout = false
                }
            }
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
                Button { menuOpen = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 5))
                }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close menu")
                    .padding(.trailing, compact ? 0 : 48)
            }
            .padding(.horizontal, compact ? 18 : 28)
            .frame(height: compact ? 54 : 70)

            Rectangle().fill(.white.opacity(0.55)).frame(height: 2)

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 8) {
                    settingsTab("Controls", section: .controls, compact: compact)
                    settingsTab("Audio", section: .audio, compact: compact)
                }
                .padding(.horizontal, compact ? 12 : 22)
                .padding(.top, 24)
                .frame(width: compact ? 158 : 230)

                Rectangle().fill(.white.opacity(0.6)).frame(width: 2)

                ScrollView {
                    VStack(alignment: .leading, spacing: compact ? 10 : 24) {
                        if settingsSection == .controls {
                            Text("Controls")
                                .font(.system(size: compact ? 23 : 29, weight: .semibold))
                            Toggle("Touch Controls", isOn: $touchEnabled)
                                .tint(.blue)
                            Text("Show the N64 controls on the game screen.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.68))
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Control Size")
                                    Spacer()
                                    Text("\(Int((controlScale * 100).rounded()))%")
                                        .monospacedDigit()
                                }
                                Slider(value: $controlScale, in: 0.8...1.2)
                                    .tint(.blue)
                            }
                            .disabled(!touchEnabled)
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
                            Divider().overlay(.white.opacity(0.4))
                            Text("Button Visibility")
                                .font(.headline)
                            Toggle("D-pad Buttons", isOn: $showDpad)
                                .tint(.blue)
                            Toggle("C Buttons", isOn: $showCButtons)
                                .tint(.blue)
                            Button("Edit Layout") { beginLayoutEdit(compact: compact) }
                                .buttonStyle(.borderedProminent)
                                .disabled(!touchEnabled || !session.running)
                            Button("Restore Defaults") {
                                touchEnabled = true
                                touchTransparency = false
                                touchOpacity = 1.0
                                controlScale = 1.0
                                showDpad = true
                                showCButtons = true
                                tabletLayout = ""
                                phoneLayout = ""
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Text("Audio")
                                .font(.system(size: compact ? 23 : 29, weight: .semibold))
                            HStack {
                                Text("Master Volume")
                                Spacer()
                                Text("\(Int((masterVolume * 100).rounded()))%")
                                    .monospacedDigit()
                            }
                            Slider(value: $masterVolume, in: 0...1)
                                .tint(.blue)
                                .accessibilityLabel("Master Volume")
                            Button("Restore Default Volume") { masterVolume = 1.0 }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(compact ? 14 : 30)
                }
                .frame(height: size.height - (compact ? 156 : 128))
            }
        }
        .foregroundStyle(.white)
        .frame(width: size.width - (compact ? 160 : 56),
               height: size.height - (compact ? 100 : 56))
        .background(Color.black.opacity(0.78), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.35)))
    }

    private func settingsTab(_ title: String, section: SettingsSection, compact: Bool) -> some View {
        Button(title) { settingsSection = section }
            .buttonStyle(.plain)
            .font(.system(size: compact ? 17 : 22, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(settingsSection == section ? Color.blue : Color.clear,
                        in: RoundedRectangle(cornerRadius: 6))
    }

    private func toggleMenu() {
        if !menuOpen { clearTouchInput() }
        menuOpen.toggle()
    }

    private func savedLayout(compact: Bool) -> [String: CGPoint] {
        let stored = compact ? phoneLayout : tabletLayout
        guard let data = stored.data(using: .utf8),
              let values = try? JSONDecoder().decode([String: [Double]].self, from: data) else { return [:] }
        var positions: [String: CGPoint] = [:]
        for (id, point) in values where point.count == 2 && point[0].isFinite && point[1].isFinite {
            positions[id] = CGPoint(x: min(max(point[0], 0), 1), y: min(max(point[1], 0), 1))
        }
        return positions
    }

    private func beginLayoutEdit(compact: Bool) {
        clearTouchInput()
        editedPositions = savedLayout(compact: compact)
        editingCompact = compact
        menuOpen = false
        editingLayout = true
    }

    private func finishLayoutEdit() {
        let values = editedPositions.mapValues { [Double($0.x), Double($0.y)] }
        if let data = try? JSONEncoder().encode(values),
           let text = String(data: data, encoding: .utf8) {
            if editingCompact { phoneLayout = text } else { tabletLayout = text }
        }
        editingLayout = false
    }
}
