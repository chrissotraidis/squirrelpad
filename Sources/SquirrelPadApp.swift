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
@_silgen_name("squirrelpad_set_active")
private func setCoreActive(_ active: Bool)
@_silgen_name("squirrelpad_audio_set_volume")
private func setMasterVolume(_ volume: Float)

@_silgen_name("squirrelpad_set_graphics")
private func setGraphics(_ resolution: Int32, _ filtering: Int32, _ textureSmoothing: Bool)

@_silgen_name("squirrelpad_set_mods")
private func setMods(_ flags: UInt32)

private enum SettingsSection {
    case general
    case enhancements
    case controls
    case audio
    case about
}

@MainActor
private final class GameSession: ObservableObject {
    @Published var message = ""
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
            DispatchQueue.global(qos: .userInitiated).async {
                let result = romPath.withCString { rom in
                    dataPath.withCString { storage in runConkerCore(rom, storage, 0) }
                }
                DispatchQueue.main.async {
                    self.running = false
                    self.message = result == 0 ? "The game has closed. You can start it again." : "The game stopped (code \(result))."
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
    @StateObject private var texturePacks = TexturePackStore()
    @State private var importingTexturePack = false
    @AppStorage("SquirrelPad.Mods.Health") private var infiniteHealth = false
    @AppStorage("SquirrelPad.Mods.Lives") private var infiniteLives = false
    @AppStorage("SquirrelPad.Mods.Cash") private var maxCash = false
    @AppStorage("SquirrelPad.Mods.Skip") private var skipCutscenes = false
    @AppStorage("SquirrelPad.Mods.SkipBlocked") private var skipBlocked = false
    @StateObject private var renderer = RendererStatus()
    @StateObject private var controllerInput = ControllerInput()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("SquirrelPad.TouchControls") private var touchEnabled = true
    @AppStorage("SquirrelPad.TouchTransparency") private var touchTransparency = false
    @AppStorage("SquirrelPad.TouchOpacity") private var touchOpacity = 1.0
    @AppStorage("SquirrelPad.ControlScale") private var controlScale = 1.0
    @AppStorage("SquirrelPad.ShowDpad") private var showDpad = true
    @AppStorage("SquirrelPad.ShowCButtons") private var showCButtons = true
    @AppStorage("SquirrelPad.ResolutionScale") private var resolutionScale = 2
    @AppStorage("SquirrelPad.DisplayFilter") private var displayFilter = 2
    @AppStorage("SquirrelPad.TextureSmoothing") private var textureSmoothing = true
    @AppStorage("SquirrelPad.MasterVolume") private var masterVolume = 1.0
    @AppStorage("SquirrelPad.LayoutTablet") private var tabletLayout = ""
    @AppStorage("SquirrelPad.LayoutPhone") private var phoneLayout = ""
    @AppStorage("SquirrelPad.ControlSizesTablet") private var tabletControlSizes = ""
    @AppStorage("SquirrelPad.ControlSizesPhone") private var phoneControlSizes = ""
    @AppStorage("SquirrelPad.HiddenControlsTablet") private var tabletHiddenControls = ""
    @AppStorage("SquirrelPad.HiddenControlsPhone") private var phoneHiddenControls = ""
    @State private var importing = false
    @State private var menuOpen = false
    @State private var showingLauncher = true
    @State private var confirmResetTouch = false
    @State private var editingLayout = false
    @State private var editingCompact = false
    @State private var editedPositions: [String: CGPoint] = [:]
    @State private var editedControlSizes: [String: Double] = [:]
    @State private var editedHiddenControls: Set<String> = []
    @State private var selectedControl: String?
    @State private var settingsSection: SettingsSection = .general
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
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .allowsHitTesting(false)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    // Discard local gesture state when focus is lost, as well
                    // as clearing the native input state in the lifecycle handler.
                    if session.running && !showingLauncher && touchEnabled && (!menuOpen || editingLayout)
                        && scenePhase == .active && !audioInterrupted {
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
                    if (!session.running || showingLauncher) && !menuOpen {
                        SquirrelPadLauncher(size: geometry.size,
                                            hasROM: session.storedROM != nil,
                                            paused: session.running,
                                            message: session.message,
                                            play: {
                                                if session.running { showingLauncher = false }
                                                else if let rom = session.storedROM { session.importROM(rom) }
                                            },
                                            chooseROM: { importing = true },
                                            settings: { menuOpen = true })
                    }
                    if menuOpen {
                        SquirrelPadTheme.background.opacity(0.88)
                            .onTapGesture { menuOpen = false }
                        controlsPanel(compact: compact, size: geometry.size,
                                      sideMargin: menuSideMargin)
                            .position(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2)
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
                    } else if session.running && !showingLauncher && !menuOpen {
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
            .preferredColorScheme(.dark)
            .tint(SquirrelPadTheme.accent)
            .confirmationDialog("Restore all touch controls?", isPresented: $confirmResetTouch, titleVisibility: .visible) {
                Button("Restore Defaults", role: .destructive) { restoreTouchDefaults() }
            } message: {
                Text("This resets control sizes, visibility, and your phone and tablet layouts. Your game saves are kept.")
            }
            .onAppear {
                applyGraphics()
                applyMods()
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
            .onChange(of: showingLauncher) { _ in
                clearTouchInput()
                updateCoreActivity()
            }
            .onChange(of: editingLayout) { _ in updateCoreActivity() }
            .onChange(of: touchEnabled) { enabled in if !enabled { clearTouchInput() } }
            .onChange(of: showDpad) { _ in clearTouchInput() }
            .onChange(of: showCButtons) { _ in clearTouchInput() }
            .onChange(of: resolutionScale) { _ in applyGraphics() }
            .onChange(of: displayFilter) { _ in applyGraphics() }
            .onChange(of: textureSmoothing) { _ in applyGraphics() }
            .onChange(of: infiniteHealth) { _ in applyMods() }
            .onChange(of: infiniteLives) { _ in applyMods() }
            .onChange(of: maxCash) { _ in applyMods() }
            .onChange(of: skipCutscenes) { _ in applyMods() }
            .onChange(of: skipBlocked) { _ in applyMods() }
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
                showingLauncher = !running
                if running { menuOpen = false }
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

    private func compactMenuSideMargin() -> CGFloat {
        let insets = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?.safeAreaInsets ?? .zero
        return max(32, max(insets.left, insets.right) + 8)
    }

    private func controlsPanel(compact: Bool, size: CGSize, sideMargin: CGFloat) -> some View {
        let panelHeight = min(760, size.height - (compact ? 40 : 80))
        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                AcornMark(size: 38)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Settings").font(.system(size: compact ? 22 : 26, weight: .bold, design: .rounded))
                    Text(session.running ? "Conker’s Bad Fur Day · Paused" : "SquirrelPad")
                        .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                }
                Spacer()
                Button { menuOpen = false } label: {
                    Label(session.running && !showingLauncher ? "Resume" : "Done",
                          systemImage: session.running && !showingLauncher ? "play.fill" : "checkmark")
                }
                .buttonStyle(SquirrelPadButtonStyle(primary: true))
                .accessibilityIdentifier("squirrelpad-close-settings")
            }
            .padding(.horizontal, compact ? 18 : 24)
            .frame(height: 76)
            .background(alignment: .trailing) {
                Image("Woodland").resizable().scaledToFill()
                    .frame(height: 76).clipped().opacity(0.10)
                    .allowsHitTesting(false).accessibilityHidden(true)
            }
            Divider()
            HStack(alignment: .top, spacing: 0) {
                ScrollView {
                    VStack(spacing: 8) {
                        settingsTab("General", symbol: "gearshape", section: .general, compact: compact)
                        settingsTab("Enhancements", symbol: "sparkles", section: .enhancements, compact: compact)
                        settingsTab("Controls", symbol: "gamecontroller", section: .controls, compact: compact)
                        settingsTab("Audio", symbol: "speaker.wave.2", section: .audio, compact: compact)
                        settingsTab("About", symbol: "info.circle", section: .about, compact: compact)
                    }
                    .padding(compact ? 10 : 16)
                }
                .frame(width: compact ? 178 : 224)
                Divider()
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if settingsSection == .general {
                                generalSettings
                            } else if settingsSection == .enhancements {
                                enhancementSettings
                            } else if settingsSection == .controls {
                                SettingsCard(title: "Touch controls", symbol: "hand.tap") {
                                    Toggle("Show Touch Controls", isOn: $touchEnabled)
                                        .tint(SquirrelPadTheme.accent)
                                    Text("Use the on-screen N64 controls. Layouts are saved separately for iPhone and iPad.")
                                        .font(.subheadline)
                                        .foregroundStyle(SquirrelPadTheme.secondary)
                                    Button("Edit Touch Layout") { beginLayoutEdit(compact: compact) }
                                        .buttonStyle(SquirrelPadButtonStyle(primary: true))
                                        .disabled(!touchEnabled || !session.running || showingLauncher)
                                    Button("Restore Touch Defaults") { confirmResetTouch = true }
                                        .buttonStyle(SquirrelPadButtonStyle())
                                    if !session.running || showingLauncher {
                                        Text("Start or resume the game to move and resize controls.")
                                            .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                                    }
                                }
                                SettingsCard(title: "Size & appearance", symbol: "slider.horizontal.3") {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text("Control Size")
                                            Spacer()
                                            Text("\(Int((controlScale * 100).rounded()))%")
                                                .monospacedDigit()
                                        }
                                        Slider(value: $controlScale, in: 0.8...1.2)
                                            .tint(SquirrelPadTheme.accent)
                                            .accessibilityLabel("Control Size")
                                            .accessibilityValue("\(Int((controlScale * 100).rounded())) percent")
                                    }
                                    .disabled(!touchEnabled)
                                    Divider()
                                    Toggle("Transparent Controls", isOn: $touchTransparency)
                                        .tint(SquirrelPadTheme.accent)
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
                                                .tint(SquirrelPadTheme.accent)
                                                .accessibilityLabel("Control Opacity")
                                                .accessibilityValue("\(Int((touchOpacity * 100).rounded())) percent")
                                        }
                                        .disabled(!touchEnabled)
                                    }
                                    Divider()
                                    Text("Button Visibility")
                                        .font(.headline)
                                    Toggle("D-pad Buttons", isOn: $showDpad)
                                        .tint(SquirrelPadTheme.accent)
                                    Toggle("C Buttons", isOn: $showCButtons)
                                        .tint(SquirrelPadTheme.accent)
                                }
                                SettingsCard(title: "Game controller", symbol: "gamecontroller") {
                                    HStack {
                                        Text("Connected controller")
                                        Spacer()
                                        Text(controllerInput.connectedName ?? "Not connected")
                                            .foregroundStyle(.white.opacity(0.68))
                                    }
                                    .font(.subheadline)
                                    Divider()
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
                                                        .background(SquirrelPadTheme.accent.opacity(0.3), in: RoundedRectangle(cornerRadius: 4))
                                                    } else {
                                                        Text(binding.gamepad)
                                                            .padding(.horizontal, 10)
                                                            .padding(.vertical, 7)
                                                            .background(SquirrelPadTheme.accent.opacity(0.3), in: RoundedRectangle(cornerRadius: 4))
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
                                }
                            } else if settingsSection == .audio {
                                SettingsCard(title: "Game audio", symbol: "speaker.wave.2") {
                                    HStack {
                                        Text("Master Volume")
                                        Spacer()
                                        Text("\(Int((masterVolume * 100).rounded()))%")
                                            .monospacedDigit()
                                    }
                                    Slider(value: $masterVolume, in: 0...1)
                                        .accessibilityLabel("Master Volume")
                                    Text("Adjust game audio without changing your device volume.")
                                        .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                                    Button("Restore Default Volume") { masterVolume = 1.0 }
                                        .buttonStyle(SquirrelPadButtonStyle())
                                }
                            } else {
                                aboutSettings
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(compact ? 14 : 24)
                    }
                    .id(settingsSection)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .foregroundStyle(.white)
        .frame(width: min(1050, size.width - sideMargin * 2), height: panelHeight)
        .background(SquirrelPadTheme.panel, in: RoundedRectangle(cornerRadius: 24))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(SquirrelPadTheme.accent.opacity(0.20)))
        .shadow(color: .black.opacity(0.35), radius: 28, y: 12)
    }

    private var generalSettings: some View {
        VStack(spacing: 20) {
            SettingsCard(title: "Conker’s Bad Fur Day", symbol: "gamecontroller.fill") {
                Label(session.running ? "Game paused" : session.storedROM != nil ? "ROM ready" : "No ROM imported",
                      systemImage: session.running ? "pause.circle" : "doc")
                    .foregroundStyle(SquirrelPadTheme.secondary)
                if session.running {
                    Text("Return to the launcher to pause here. Resume Game brings you back to this session.")
                        .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                    Button("Return to Launcher") {
                        showingLauncher = true
                        menuOpen = false
                    }
                    .buttonStyle(SquirrelPadButtonStyle())
                } else {
                    Text("Import your own supported US ROM from Files.")
                        .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                    Button(session.storedROM == nil ? "Choose ROM" : "Choose another ROM") { importing = true }
                        .buttonStyle(SquirrelPadButtonStyle(primary: true))
                    if !session.message.isEmpty {
                        Text(session.message).font(.subheadline).foregroundStyle(.orange)
                    }
                }
            }
            SettingsCard(title: "Your progress", symbol: "externaldrive") {
                Text("Use the game’s normal save system. Pausing keeps your current session in memory; it does not create a save state.")
                Text("Install updates over SquirrelPad to keep your imported ROM, saves, and settings.")
                    .foregroundStyle(SquirrelPadTheme.secondary)
            }
            .font(.subheadline)
        }
    }

    private func applyMods() {
        let flags: UInt32 = (infiniteHealth ? 1 : 0) | (infiniteLives ? 2 : 0) |
            (maxCash ? 4 : 0) | (skipCutscenes ? 8 : 0) | (skipBlocked ? 16 : 0)
        setMods(flags)
    }

    private func applyGraphics() {
        setGraphics(Int32(clamping: resolutionScale), Int32(clamping: displayFilter), textureSmoothing)
    }

    private var enhancementSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("A sharper adventure").font(.system(.title2, design: .rounded, weight: .bold))
                Text("Keep the N64 character. Make it your own.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
            }
            SettingsCard(title: "Render quality", symbol: "sparkles") {
                Text("Internal resolution").font(.subheadline.weight(.semibold))
                Picker("Internal resolution", selection: $resolutionScale) {
                    Text("1× · Original").tag(1)
                    Text("2× · Balanced").tag(2)
                    Text("3× · Sharp").tag(3)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("squirrelpad-resolution")
                Text("Renders 3D geometry at \(resolutionScale)× the original resolution. Higher settings use more power; textures retain their original detail.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                Divider()
                Text("Screen filter").font(.subheadline.weight(.semibold))
                Picker("Screen filter", selection: $displayFilter) {
                    Text("Pixel").tag(0)
                    Text("Smooth").tag(1)
                    Text("Crisp").tag(2)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("squirrelpad-display-filter")
                Text("Pixel keeps hard edges. Smooth softens the picture. Crisp balances clean edges with the original pixel detail.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                Divider()
                Toggle("N64 texture filtering", isOn: $textureSmoothing)
                Text("Use the original three-point texture filter. Turn it off for smoother bilinear filtering.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                Label(session.running ? "Changes apply when you resume" : "Ready for your next game",
                      systemImage: "checkmark.circle")
                    .font(.caption).foregroundStyle(SquirrelPadTheme.accent)
                Button("Restore Balanced Settings") {
                    resolutionScale = 2
                    displayFilter = 2
                    textureSmoothing = true
                }
                .buttonStyle(SquirrelPadButtonStyle())
            }
            SettingsCard(title: "A little extra mischief", symbol: "wand.and.stars") {
                Toggle("Skip unseen cutscenes", isOn: $skipCutscenes)
                Text("Press L during a cutscene. The opening uses Start after a short lead-in.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                if skipCutscenes {
                    Toggle("Also skip protected scenes", isOn: $skipBlocked)
                    Text("Experimental: some scripted scenes may not continue correctly when skipped.")
                        .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                }
                Divider()
                Toggle("Infinite health", isOn: $infiniteHealth)
                Toggle("Nine lives", isOn: $infiniteLives)
                Toggle("Full wallet · $9,999", isOn: $maxCash)
                Text("Adapted from the upstream Conker mods. Changes apply on resume. Lives and cash can be saved by the game; switching a mod off does not undo saved changes.")
                    .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                Button("Turn Off All Mods") {
                    infiniteHealth = false; infiniteLives = false; maxCash = false
                    skipCutscenes = false; skipBlocked = false
                }.buttonStyle(SquirrelPadButtonStyle())
            }
            SettingsCard(title: "Texture packs", symbol: "photo.stack") {
                if texturePacks.hasPack {
                    Text(texturePacks.name).font(.headline).lineLimit(2)
                    Toggle("Use imported textures", isOn: $texturePacks.enabled)
                        .disabled(texturePacks.importing)
                }
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(texturePacks.statusText).font(.caption).foregroundStyle(SquirrelPadTheme.accent)
                }
                Text("Import an RT64 .rtz pack from Files. PNG textures, RT64 hash v5; one pack at a time. Switch it off to restore the original artwork.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                Button(texturePacks.importing ? "Checking Pack…" : "Import Texture Pack") { importingTexturePack = true }
                    .buttonStyle(SquirrelPadButtonStyle())
                    .disabled(texturePacks.importing)
                    .fileImporter(isPresented: $importingTexturePack, allowedContentTypes: [.data, .zip]) { selection in
                        switch selection {
                        case .success(let url): texturePacks.importPack(url)
                        case .failure(let error): texturePacks.message = "Could not choose pack: \(error.localizedDescription)"
                        }
                    }
                if !texturePacks.message.isEmpty {
                    Text(texturePacks.message).font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                }
                Link("Find the upstream HD Icons pack ↗", destination: URL(string: "https://github.com/DahSidiAbdallah/ConkerBFDReloaded/releases")!)
                    .font(.subheadline.weight(.semibold))
                Text("HD Icons by dahmedvall95, with artwork by GameBeast92. Packs are downloaded separately; desktop .nrm code mods are not imported.")
                    .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                projectLink("Enhancement compatibility", subtitle: "Supported packs & upstream credits", symbol: "book", path: "/blob/main/docs/ENHANCEMENTS.md")
            }
        }
    }

    private var aboutSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 18) {
                AcornMark(size: 76)
                VStack(alignment: .leading, spacing: 6) {
                    Link("SquirrelPad", destination: URL(string: "https://github.com/chrissotraidis/squirrelpad")!)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .accessibilityHint("Opens the SquirrelPad project on GitHub")
                    Text("A little mischief. A bigger screen.")
                        .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                    Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0") · iPhone & iPad")
                        .font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                }
            }
            .padding(.vertical, 8)
            SettingsCard(title: "The project", symbol: "leaf.fill") {
                projectLink("SquirrelPad on GitHub", subtitle: "Source, setup & FAQ", symbol: "chevron.left.forwardslash.chevron.right", path: "")
                Divider()
                projectLink("Report a Problem", subtitle: "Open an issue on GitHub", symbol: "bubble.left", path: "/issues/new")
                Divider()
                projectLink("Releases", subtitle: "Builds & release notes", symbol: "arrow.down.circle", path: "/releases")
            }
            SettingsCard(title: "Built together", symbol: "heart") {
                Text("An independent port of Conker’s Bad Fur Day. Bring your own game data.")
                    .font(.subheadline).foregroundStyle(SquirrelPadTheme.secondary)
                HStack(spacing: 20) {
                    Link("CBFD-Recompiled", destination: URL(string: "https://github.com/sciaschi/CBFD-Recompiled")!)
                    Link("N64Recomp", destination: URL(string: "https://github.com/N64Recomp/N64Recomp")!)
                    Link("RT64", destination: URL(string: "https://github.com/rt64/rt64")!)
                }
                .font(.subheadline).frame(minHeight: 44)
                DisclosureGroup("Renderer details") {
                    Text(renderer.message).font(.caption.monospaced())
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 12)
                }
            }
        }
    }

    private func projectLink(_ title: String, subtitle: String, symbol: String, path: String) -> some View {
        Link(destination: URL(string: "https://github.com/chrissotraidis/squirrelpad" + path)!) {
            HStack(spacing: 12) {
                Image(systemName: symbol).frame(width: 24).foregroundStyle(SquirrelPadTheme.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(.body, design: .rounded, weight: .semibold)).foregroundStyle(.white)
                    Text(subtitle).font(.caption).foregroundStyle(SquirrelPadTheme.secondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right").font(.caption.weight(.bold)).foregroundStyle(SquirrelPadTheme.accent)
            }
            .frame(minHeight: 48).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func settingsTab(_ title: String, symbol: String, section: SettingsSection, compact: Bool) -> some View {
        Button { settingsSection = section } label: {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .frame(width: 22)
                    .foregroundStyle(settingsSection == section ? SquirrelPadTheme.accent : SquirrelPadTheme.secondary)
                Text(title).lineLimit(1).minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .font(.system(size: compact ? 15 : 17, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .padding(.horizontal, 10)
            .background(settingsSection == section ? SquirrelPadTheme.accent.opacity(0.18) : .clear,
                        in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(settingsSection == section ? .isSelected : [])
        .accessibilityIdentifier("squirrelpad-settings-\(title.lowercased())")
    }

    private func restoreTouchDefaults() {
        touchEnabled = true
        touchTransparency = false
        touchOpacity = 1
        controlScale = 1
        showDpad = true
        showCButtons = true
        tabletLayout = ""
        phoneLayout = ""
        tabletControlSizes = ""
        phoneControlSizes = ""
        tabletHiddenControls = ""
        phoneHiddenControls = ""
    }

    private func toggleMenu() {
        if !menuOpen { clearTouchInput() }
        menuOpen.toggle()
    }

    private func updateCoreActivity(phase: ScenePhase? = nil) {
        let active = (phase ?? scenePhase) == .active && !showingLauncher && !menuOpen && !editingLayout && !audioInterrupted
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
