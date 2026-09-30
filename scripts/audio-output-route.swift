// Read the active Core Audio output route without changing host or Simulator settings.
// Run on macOS 14.2+: swift scripts/audio-output-route.swift [bundle-id]
import Foundation
import CoreAudio
func ids(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector, _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> [UInt32] {
    var a = AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
    var size: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(object, &a, 0, nil, &size) == noErr else { return [] }
    guard size >= 4 else { return [] }
    var values = [UInt32](repeating: 0, count: Int(size)/4)
    let status = values.withUnsafeMutableBytes { AudioObjectGetPropertyData(object, &a, 0, nil, &size, $0.baseAddress!) }
    return status == noErr ? values : []
}
func name(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector) -> String {
    var a = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
    var value: Unmanaged<CFString>? = nil
    var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
    guard AudioObjectGetPropertyData(object, &a, 0, nil, &size, &value) == noErr else { return "?" }
    return value.map { $0.takeRetainedValue() as String } ?? "?"
}
let target = CommandLine.arguments.dropFirst().first ?? "com.chrissotraidis.squirrelpad"
var found = false
for p in ids(AudioObjectID(kAudioObjectSystemObject), kAudioHardwarePropertyProcessObjectList) {
    let pid = ids(p, kAudioProcessPropertyPID).first ?? 0
    let bundle = name(p, kAudioProcessPropertyBundleID)
    if bundle == target {
        found = true
        print("process object=\(p) pid=\(pid) bundle=\(bundle) outputRunning=\(ids(p,kAudioProcessPropertyIsRunningOutput))")
        for d in ids(p, kAudioProcessPropertyDevices, kAudioObjectPropertyScopeOutput) {
            print("output id=\(d) name=\(name(d,kAudioObjectPropertyName)) uid=\(name(d,kAudioDevicePropertyDeviceUID))")
            for s in ids(d,kAudioAggregateDevicePropertyActiveSubDeviceList) {
                print(" subdevice id=\(s) name=\(name(s,kAudioObjectPropertyName)) uid=\(name(s,kAudioDevicePropertyDeviceUID))")
            }
        }
    }
}

if !found { print("No Core Audio process found for \(target). Start game audio before querying."); exit(1) }
