import AVFoundation
import ScreenCaptureKit

// Diagnostic capture of system audio, including Simulator output. Pass an exact
// application name to capture only that process. Keep recordings under ignored work/.

final class AudioOutput: NSObject, SCStreamOutput {
    let writer: AVAssetWriter
    let input: AVAssetWriterInput
    private(set) var samples = 0
    private var started = false

    init(url: URL) throws {
        writer = try AVAssetWriter(outputURL: url, fileType: .m4a)
        input = AVAssetWriterInput(mediaType: .audio, outputSettings: [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 48_000,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 192_000,
        ])
        input.expectsMediaDataInRealTime = true
        writer.add(input)
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
                of outputType: SCStreamOutputType) {
        guard outputType == .audio, sampleBuffer.isValid else { return }
        if !started {
            guard writer.startWriting() else { return }
            writer.startSession(atSourceTime: sampleBuffer.presentationTimeStamp)
            started = true
        }
        if input.isReadyForMoreMediaData && input.append(sampleBuffer) {
            samples += 1
        }
    }

    func finish() async {
        input.markAsFinished()
        await writer.finishWriting()
        print("audio buffers: \(samples); writer status: \(writer.status.rawValue); error: \(String(describing: writer.error))")
    }
}

@main struct Capture {
    static func main() async throws {
        guard (CommandLine.arguments.count == 3 || CommandLine.arguments.count == 4),
              let seconds = UInt64(CommandLine.arguments[2]) else {
            fatalError("usage: capture-system-audio output.m4a seconds [application-name]")
        }
        let url = URL(fileURLWithPath: CommandLine.arguments[1])
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first else {
            fatalError("display not available")
        }
        let filter: SCContentFilter
        if CommandLine.arguments.count == 4 {
            let name = CommandLine.arguments[3]
            guard let app = content.applications.first(where: { $0.applicationName == name }) else {
                fatalError("application not found: \(name)")
            }
            filter = SCContentFilter(display: display, including: [app], exceptingWindows: [])
        } else {
            filter = SCContentFilter(display: display, excludingWindows: [])
        }
        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.excludesCurrentProcessAudio = true
        configuration.sampleRate = 48_000
        configuration.channelCount = 2
        configuration.width = 16
        configuration.height = 16
        let output = try AudioOutput(url: url)
        let stream = SCStream(filter: filter, configuration: configuration, delegate: nil)
        try stream.addStreamOutput(output, type: .audio, sampleHandlerQueue: DispatchQueue(label: "simulator-audio-capture"))
        try await stream.startCapture()
        print("capturing system audio for \(seconds) seconds")
        fflush(stdout)
        try await Task.sleep(for: .seconds(seconds))
        try await stream.stopCapture()
        await output.finish()
    }
}
