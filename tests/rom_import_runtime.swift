import Foundation

@main
struct ROMImportTests {
    static func check(_ valid: Bool) { precondition(valid) }

    static func main() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }
        let storage = root.appendingPathComponent("Conker")
        try fm.createDirectory(at: storage, withIntermediateDirectories: true)
        let existing = storage.appendingPathComponent("baserom.us.z64")
        let saved = Data("previous imported ROM must survive a failed replacement".utf8)
        try saved.write(to: existing)
        let save = storage.appendingPathComponent("save.eep")
        try saved.write(to: save)

        func reject(_ url: URL, _ expected: ROMImport.ImportError? = nil) throws {
            do {
                _ = try ROMImport.importROM(from: url, into: storage)
                fatalError("Accepted invalid input: \(url.lastPathComponent)")
            } catch {
                if let expected {
                    check(error.localizedDescription == expected.localizedDescription)
                }
            }
            check(try Data(contentsOf: existing) == saved)
            check(try Data(contentsOf: save) == saved)
        }

        try reject(root, .unsupportedFormat)
        try reject(root.appendingPathComponent("missing.z64"))
        let small = root.appendingPathComponent("small.z64")
        try Data([0x80, 0x37, 0x12, 0x40]).write(to: small)
        try reject(small, .unsupportedFormat)
        let fixture = root.appendingPathComponent("fixture.z64")
        var bytes = Data(count: 67_108_864)
        bytes.replaceSubrange(0..<4, with: [0x37, 0x80, 0x40, 0x12])
        try bytes.write(to: fixture)
        try reject(fixture, .unsupportedFormat)
        bytes.replaceSubrange(0..<4, with: [0x80, 0x37, 0x12, 0x40])
        try bytes.write(to: fixture)
        try reject(fixture, .checksumMismatch)

        // Optional private input; never checked into the test suite.
        if let path = ProcessInfo.processInfo.environment["SQUIRRELPAD_TEST_ROM"] {
            let source = URL(fileURLWithPath: path)
            let original = try Data(contentsOf: source)
            let selected = root.appendingPathComponent("provider-file.unknown")
            try original.write(to: selected)
            let imported = try ROMImport.importROM(from: selected, into: storage)
            check(imported == existing)
            check(try Data(contentsOf: imported) == original)
            // The next launch verifies the existing import without overwriting it.
            check(try ROMImport.importROM(from: imported, into: storage) == imported)
            check(try Data(contentsOf: save) == saved)
            print("PASS: verified ROM, arbitrary extension, reimport, save preservation")
        }
        print("PASS: folder, missing file, size, byte order, checksum, failed replacement preservation")
    }
}
