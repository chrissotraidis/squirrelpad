import Foundation
import SwiftUI

@_silgen_name("squirrelpad_validate_texture_pack")
private func validateTexturePack(_ path: UnsafePointer<CChar>) -> Int32
@_silgen_name("squirrelpad_set_texture_pack")
private func setTexturePack(_ path: UnsafePointer<CChar>)
@_silgen_name("squirrelpad_texture_status")
private func textureStatus() -> Int32
@_silgen_name("squirrelpad_texture_matches")
private func textureMatches() -> UInt32

@MainActor
final class TexturePackStore: ObservableObject {
    @Published private(set) var name = ""
    @Published private(set) var importing = false
    @Published var message = ""
    @Published var enabled = false { didSet { persist(); apply() } }
    private var filename = ""
    private var directory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TexturePacks", isDirectory: true)
    }
    init() {
        let defaults = UserDefaults.standard
        filename = defaults.string(forKey: "SquirrelPad.TexturePack.File") ?? ""
        name = defaults.string(forKey: "SquirrelPad.TexturePack.Name") ?? ""
        enabled = defaults.bool(forKey: "SquirrelPad.TexturePack.Enabled")
        if filename.contains("/") || !FileManager.default.fileExists(atPath: directory.appendingPathComponent(filename).path) {
            filename = ""; name = ""; enabled = false
        }
        // Only collect obsolete imported archives at launch, before RT64 opens them.
        if let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "rtz" && file.lastPathComponent != filename {
                try? FileManager.default.removeItem(at: file)
            }
        }
        apply()
    }
    var hasPack: Bool { !filename.isEmpty }
    var statusText: String {
        guard enabled else { return hasPack ? "Original textures · pack switched off" : "No pack imported" }
        switch textureStatus() {
        case 2: return "Pack loaded · \(textureMatches()) cached replacements matched in game"
        case -1: return "Could not load pack. Original textures are active."
        default: return "Ready · applies when you play or resume"
        }
    }
    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(filename, forKey: "SquirrelPad.TexturePack.File")
        defaults.set(name, forKey: "SquirrelPad.TexturePack.Name")
        defaults.set(enabled, forKey: "SquirrelPad.TexturePack.Enabled")
    }
    private func apply() {
        let path = enabled && hasPack ? directory.appendingPathComponent(filename).path : ""
        path.withCString { setTexturePack($0) }
    }
    func importPack(_ url: URL) {
        guard !importing else { return }
        importing = true
        message = "Checking texture pack…"
        let folder = directory
        let newName = UUID().uuidString + ".rtz"
        let destination = folder.appendingPathComponent(newName)
        Task {
            let result: Result<Int32, Error> = await Task.detached(priority: .userInitiated) {
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                do {
                    let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    guard size > 0, size <= 256 * 1024 * 1024 else { return .success(-1) }
                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                    try FileManager.default.copyItem(at: url, to: destination)
                    let count = destination.path.withCString { validateTexturePack($0) }
                    if count < 0 { try? FileManager.default.removeItem(at: destination) }
                    return .success(count)
                } catch {
                    try? FileManager.default.removeItem(at: destination)
                    return .failure(error)
                }
            }.value
            importing = false
            switch result {
            case .success(let count) where count > 0:
                filename = newName
                name = url.deletingPathExtension().lastPathComponent
                enabled = true
                message = "Imported \(count) textures. Resume to apply."
                // Old archives remain until the next launch: the renderer may still
                // hold an open mapping while the game is paused.
            case .success(let code):
                let reasons: [Int32: String] = [
                    -1: "Choose an RTZ pack smaller than 256 MB.",
                    -2: "That archive is damaged or is not an RT64 pack.",
                    -3: "This pack exceeds the iPad texture limits or has unsafe file paths.",
                    -4: "Use an RT64 v3/hash-v5 pack with rt64.json at its root, without mip caches. Rice/HTC packs need conversion.",
                    -5: "The pack has missing textures or invalid RT64 hashes.",
                    -6: "This build accepts PNG textures up to 4096 × 4096. A texture is unsupported or damaged.",
                    -7: "Texture packs require a build with the RT64 renderer."
                ]
                message = reasons[code] ?? "Could not import this texture pack."
            case .failure(let error): message = "Import failed: \(error.localizedDescription)"
            }
        }
    }
}
