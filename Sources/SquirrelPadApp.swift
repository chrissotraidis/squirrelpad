import AVFAudio
import CryptoKit
import SwiftUI
import UIKit
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
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                NSLog("[mobile audio] session category: %@", AVAudioSession.sharedInstance().category.rawValue)
            } catch {
                NSLog("[mobile audio] session category failed: %@", error.localizedDescription)
            }
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
    @StateObject private var controllerInput = ControllerInput()
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
    @AppStorage("SquirrelPad.ControlSizesTablet") private var tabletControlSizes = ""
    @AppStorage("SquirrelPad.ControlSizesPhone") private var phoneControlSizes = ""
    @AppStorage("SquirrelPad.HiddenControlsTablet") private var tabletHiddenControls = ""
    @AppStorage("SquirrelPad.HiddenControlsPhone") private var phoneHiddenControls = ""
    @State private var importing = false
    @State private var menuOpen = false
    @State private var editingLayout = false
    @State private var editingCompact = false
    @State private var editedPositions: [String: CGPoint] = [:]
    @State private var editedControlSizes: [String: Double] = [:]
    @State private var editedHiddenControls: Set<String> = []
    @State private var selectedControl: String?
    @State private var settingsSection: SettingsSection = .controls
    @State private var bindingsExpanded = false
    @State private var audioInterrupted = false

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                let compact = geometry.size.height < 560
                let menuSize: CGFloat = compact && !menuOpen ? 32 : compact ? 44 : 38
                let menuSideMargin = compact ? compactMenuSideMargin() : 28
                ZStack {
                    Color.black
                    RT64Surface(renderer: renderer)
                        .frame(width: 240, height: 135)
                        .scaleEffect(compact
                            ? min(geometry.size.width / 240, geometry.size.height / 135)
                            : max(geometry.size.width / 240, geometry.size.height / 135))
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    if session.running && touchEnabled && (!menuOpen || editingLayout) {
                        TouchControlsView(opacity: editingLayout ? 1.0 : (touchTransparency ? touchOpacity : 1.0),
                                          scale: controlScale,
                                          showDpad: showDpad, showCButtons: showCButtons,
                                          editing: editingLayout,
                                          selectedControl: selectedControl,
                                          onSelect: { selectedControl = $0 },
                                          layout: editingLayout && editingCompact == compact
                                              ? editedPositions : savedLayout(compact: compact),
                                          controlSizes: editingLayout && editingCompact == compact
                                              ? editedControlSizes : savedControlSizes(compact: compact),
                                          hiddenControls: editingLayout && editingCompact == compact
                                              ? editedHiddenControls : savedHiddenControls(compact: compact),
                                          onMove: { id, center in
                                              if editingLayout && editingCompact == compact {
                                                  editedPositions[id] = center
                                              }
                                          })
                    }
                    if !session.running && !menuOpen {
                        importPanel
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2)
                    }
                    if menuOpen {
                        Color.black.opacity(0.28)
                            .onTapGesture { menuOpen = false }
                        controlsPanel(compact: compact, size: geometry.size,
                                      sideMargin: menuSideMargin)
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2 - (compact ? 28 : 0))
                    }
                    if editingLayout {
                        VStack(spacing: 8) {
                            HStack(spacing: 14) {
                                Text(selectedControl.map { "\($0 == "Stick" ? "Control Stick" : $0) · Drag to move" }
                                     ?? "Tap a control to select")
                                Button("Reset Layout") {
                                    editedPositions = [:]
                                    editedControlSizes = [:]
                                    editedHiddenControls = []
                                    selectedControl = nil
                                }
                                Button("Done") { finishLayoutEdit() }
                            }
                            HStack(spacing: 10) {
                                Text("Size")
                                Slider(value: Binding(
                                    get: { selectedControl.flatMap { editedControlSizes[$0] } ?? 1 },
                                    set: { value in
                                        if let id = selectedControl { editedControlSizes[id] = value }
                                    }), in: 0.7...1.5)
                                    .frame(width: compact ? 180 : 240)
                                    .disabled(selectedControl == nil)
                                    .accessibilityLabel("Selected Control Size")
                                Text(selectedControl.map {
                                    "\(Int(((editedControlSizes[$0] ?? 1) * 100).rounded()))%"
                                } ?? "—")
                                    .monospacedDigit()
                                    .fixedSize(horizontal: true, vertical: false)
                                    .frame(width: 64, alignment: .trailing)
                                Button(selectedControl.map { editedHiddenControls.contains($0) ? "Show" : "Hide" } ?? "Hide") {
                                    guard let id = selectedControl, id != "Stick" else { return }
                                    if editedHiddenControls.contains(id) {
                                        editedHiddenControls.remove(id)
                                    } else {
                                        editedHiddenControls.insert(id)
                                    }
                                }
                                .frame(minWidth: 44)
                                .disabled(selectedControl == nil || selectedControl == "Stick")
                                .opacity(selectedControl == nil || selectedControl == "Stick" ? 0.45 : 1)
                                .accessibilityLabel("Selected Control Visibility")
                                .accessibilityValue(selectedControl.map { editedHiddenControls.contains($0) ? "Hidden" : "Visible" } ?? "No selection")
                            }
                        }
                        .font(.system(size: compact ? 14 : 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 18))
                        .position(x: geometry.size.width / 2, y: compact ? 54 : 60)
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
                                  y: compact && menuOpen ? geometry.size.height - 36 : 32)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(.black)
            .ignoresSafeArea()
            .statusBarHidden()
            .onAppear {
                setMasterVolume(Float(masterVolume))
                updateCoreActivity()
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.n64ROM, .data]) { selection in
                switch selection {
                case .success(let url): session.importROM(url)
                case .failure(let error): session.message = "Could not choose ROM: \(error.localizedDescription)"
                }
            }
            .onChange(of: menuOpen) { open in
                if open { clearTouchInput() }
                updateCoreActivity()
            }
            .onChange(of: editingLayout) { _ in updateCoreActivity() }
            .onChange(of: touchEnabled) { enabled in if !enabled { clearTouchInput() } }
            .onChange(of: showDpad) { _ in clearTouchInput() }
            .onChange(of: showCButtons) { _ in clearTouchInput() }
            .onChange(of: masterVolume) { value in setMasterVolume(Float(value)) }
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    clearTouchInput()
                    editingLayout = false
                }
                reactivateAudioIfNeeded(whileActive: phase == .active)
                updateCoreActivity(phase: phase)
            }
            .onChange(of: session.running) { running in
                if !running {
                    clearTouchInput()
                    editingLayout = false
                }
                updateCoreActivity()
            }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { note in
                guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
                switch type {
                case .began:
                    clearTouchInput()
                    audioInterrupted = true
                    updateCoreActivity()
                case .ended:
                    reactivateAudioIfNeeded(whileActive: scenePhase == .active)
                    updateCoreActivity()
                @unknown default:
                    break
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

    private func compactMenuSideMargin() -> CGFloat {
        let insets = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?.safeAreaInsets ?? .zero
        return max(32, max(insets.left, insets.right) + 8)
    }

    private func controlsPanel(compact: Bool, size: CGSize, sideMargin: CGFloat) -> some View {
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

                ScrollViewReader { scrollProxy in
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
                                HStack {
                                    Text("Game Controller")
                                    Spacer()
                                    Text(controllerInput.connectedName ?? "Not connected")
                                        .foregroundStyle(.white.opacity(0.68))
                                }
                                .font(.subheadline)
                                Divider().overlay(.white.opacity(0.4))
                                Button { bindingsExpanded.toggle() } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: bindingsExpanded ? "chevron.down" : "chevron.right")
                                        Text("Controller Bindings")
                                        Rectangle()
                                            .fill(.white.opacity(0.4))
                                            .frame(height: 1)
                                    }
                                    .font(.headline)
                                    .padding(.vertical, 5)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityValue(bindingsExpanded ? "Expanded" : "Collapsed")
                                .id("controller-bindings")
                                .onChange(of: bindingsExpanded) { expanded in
                                    if compact && expanded {
                                        withAnimation {
                                            scrollProxy.scrollTo("controller-bindings", anchor: .top)
                                        }
                                    }
                                }
                                if bindingsExpanded {
                                    if controllerInput.connectedName != nil {
                                        Text(controllerInput.rumbleAvailable ? "Rumble available" : "Rumble unavailable")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.68))
                                    }
                                    VStack(spacing: compact ? 5 : 7) {
                                        ForEach(ControllerInput.bindings.indices, id: \.self) { index in
                                            let binding = ControllerInput.bindings[index]
                                            HStack(spacing: 8) {
                                                Text(binding.n64)
                                                    .frame(width: compact ? 86 : 120, alignment: .leading)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 7)
                                                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 4))
                                                if let action = ControllerAction(rawValue: binding.n64) {
                                                    HStack(spacing: 0) {
                                                        Picker("\(binding.n64) gamepad binding", selection: Binding(
                                                            get: { controllerInput.binding(for: action) },
                                                            set: { controllerInput.setBinding($0, for: action) }
                                                        )) {
                                                            ForEach(GamepadButton.allCases, id: \.self) { button in
                                                                Text(button.rawValue).tag(button)
                                                            }
                                                        }
                                                        .pickerStyle(.menu)
                                                        .tint(.white)
                                                        .padding(.horizontal, 4)
                                                        if controllerInput.binding(for: action) != .unbound {
                                                            Button {
                                                                controllerInput.setBinding(.unbound, for: action)
                                                            } label: {
                                                                Image(systemName: "xmark")
                                                                    .font(.system(size: 12, weight: .bold))
                                                                    .frame(width: 44, height: 44)
                                                            }
                                                            .buttonStyle(.plain)
                                                            .accessibilityLabel("Remove \(binding.n64) binding")
                                                        }
                                                    }
                                                    .background(.blue.opacity(0.68), in: RoundedRectangle(cornerRadius: 4))
                                                } else {
                                                    Text(binding.gamepad)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 7)
                                                        .background(.blue.opacity(0.68), in: RoundedRectangle(cornerRadius: 4))
                                                }
                                                Spacer(minLength: 0)
                                            }
                                            .font(.system(size: compact ? 14 : 17))
                                        }
                                        Button("Restore Controller Bindings") { controllerInput.restoreBindings() }
                                            .font(.subheadline)
                                            .padding(.top, 4)
                                    }
                                }
                                Divider().overlay(.white.opacity(0.4))
                                Text("Touch Layout")
                                    .font(.headline)
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
                                    tabletControlSizes = ""
                                    phoneControlSizes = ""
                                    tabletHiddenControls = ""
                                    phoneHiddenControls = ""
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
                }
                .frame(height: size.height - (compact ? 144 : 128))
            }
        }
        .foregroundStyle(.white)
        .frame(width: size.width - sideMargin * 2,
               height: size.height - (compact ? 88 : 56))
        .background(Color.black.opacity(0.88), in: RoundedRectangle(cornerRadius: 14))
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

    private func updateCoreActivity(phase: ScenePhase? = nil) {
        let active = (phase ?? scenePhase) == .active && !menuOpen && !editingLayout && !audioInterrupted
        setCoreActive(active)
        controllerInput.setActive(active && session.running)
    }

    private func reactivateAudioIfNeeded(whileActive: Bool) {
        guard audioInterrupted, whileActive else { return }
        guard session.running else {
            audioInterrupted = false
            return
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            audioInterrupted = false
        } catch {
            NSLog("[mobile audio] interruption resume failed: %@", error.localizedDescription)
        }
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
        editedControlSizes = savedControlSizes(compact: compact)
        editedHiddenControls = savedHiddenControls(compact: compact)
        selectedControl = nil
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
        if let data = try? JSONEncoder().encode(editedControlSizes),
           let text = String(data: data, encoding: .utf8) {
            if editingCompact { phoneControlSizes = text } else { tabletControlSizes = text }
        }
        if let data = try? JSONEncoder().encode(editedHiddenControls.sorted()),
           let text = String(data: data, encoding: .utf8) {
            if editingCompact { phoneHiddenControls = text } else { tabletHiddenControls = text }
        }
        editingLayout = false
        selectedControl = nil
    }

    private func savedControlSizes(compact: Bool) -> [String: Double] {
        let stored = compact ? phoneControlSizes : tabletControlSizes
        guard let data = stored.data(using: .utf8),
              let values = try? JSONDecoder().decode([String: Double].self, from: data) else { return [:] }
        return values.filter { $0.value.isFinite }.mapValues { min(max($0, 0.7), 1.5) }
    }

    private func savedHiddenControls(compact: Bool) -> Set<String> {
        let stored = compact ? phoneHiddenControls : tabletHiddenControls
        guard let data = stored.data(using: .utf8),
              let values = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return Set(values).subtracting(["Stick"])
    }
}
