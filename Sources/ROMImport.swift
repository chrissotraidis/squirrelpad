import CryptoKit
import Foundation

enum ROMImport {
    enum ImportError: LocalizedError {
        case unsupportedFormat
        case checksumMismatch
        case unavailable

        var errorDescription: String? {
            switch self {
            case .unsupportedFormat:
                return "Choose the uncompressed 64 MiB big-endian US ROM, usually named .z64."
            case .checksumMismatch:
                return "ROM checksum does not match the supported US revision."
            case .unavailable:
                return "The file provider did not make the ROM available. Try downloading it in Files first."
            }
        }
    }

    // Run away from the main actor: a Files provider may need to download the
    // selection before it can be read. Keep access and coordination alive until
    // the verified bytes have been copied into our own storage.
    static func importROM(from source: URL, into directory: URL) throws -> URL {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        var coordinationError: NSError?
        var result: Result<URL, Error>?
        NSFileCoordinator().coordinate(readingItemAt: source, options: .withoutChanges,
                                       error: &coordinationError) { url in
            result = Result {
                let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
                guard values.isRegularFile == true, values.fileSize == 67_108_864 else {
                    throw ImportError.unsupportedFormat
                }
                let data = try Data(contentsOf: url)
                guard data.count == 67_108_864,
                      Array(data.prefix(4)) == [0x80, 0x37, 0x12, 0x40] else {
                    throw ImportError.unsupportedFormat
                }
                let digest = Insecure.SHA1.hash(data: data).map { String(format: "%02x", $0) }.joined()
                guard digest == "4cbadd3c4e0729dec46af64ad018050eada4f47a" else {
                    throw ImportError.checksumMismatch
                }
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                let imported = directory.appendingPathComponent("baserom.us.z64")
                if source.standardizedFileURL != imported.standardizedFileURL {
                    try data.write(to: imported, options: .atomic)
                }
                return imported
            }
        }
        if let error = coordinationError { throw error }
        guard let result else { throw ImportError.unavailable }
        return try result.get()
    }
}
