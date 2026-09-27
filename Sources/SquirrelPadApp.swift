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
    @State private var importing = false

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 20) {
                RT64Surface(renderer: renderer)
                    .frame(width: 160, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(renderer.message).font(.caption.monospaced())
                Text("SquirrelPad").font(.largeTitle.bold())
                Text(session.message).multilineTextAlignment(.center)
                Button("Choose ROM") { importing = true }
                    .buttonStyle(.borderedProminent)
                    .disabled(session.running)
                if let storedROM = session.storedROM {
                    Button("Continue Imported ROM") { session.importROM(storedROM) }
                        .disabled(session.running)
                }
                if session.running { ProgressView() }
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.09, green: 0.13, blue: 0.14))
            .foregroundStyle(.white)
            .fileImporter(isPresented: $importing, allowedContentTypes: [.n64ROM, .data]) { selection in
                switch selection {
                case .success(let url): session.importROM(url)
                case .failure(let error): session.message = "Could not choose ROM: \(error.localizedDescription)"
                }
            }
        }
    }
}
