// Original SquirrelPad acorn mark; no game or reference artwork.
// Run from the repository root: swift scripts/generate-app-icon.swift
import AppKit

let context = CGContext(data: nil, width: 1024, height: 1024,
    bitsPerComponent: 8, bytesPerRow: 4096, space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
NSColor(red: 0.08, green: 0.20, blue: 0.34, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1024, height: 1024)).fill()

// The body tapers to a rounded point so the silhouette reads at Home-screen size.
let body = NSBezierPath()
body.move(to: NSPoint(x: 290, y: 565))
body.curve(to: NSPoint(x: 512, y: 205),
    controlPoint1: NSPoint(x: 290, y: 350), controlPoint2: NSPoint(x: 425, y: 220))
body.curve(to: NSPoint(x: 734, y: 565),
    controlPoint1: NSPoint(x: 599, y: 220), controlPoint2: NSPoint(x: 734, y: 350))
body.close()
NSColor(red: 0.98, green: 0.85, blue: 0.64, alpha: 1).setFill()
body.fill()

NSColor(red: 0.92, green: 0.43, blue: 0.17, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 481, y: 656, width: 62, height: 137),
    xRadius: 31, yRadius: 31).fill()
let cap = NSBezierPath()
cap.move(to: NSPoint(x: 254, y: 546))
cap.curve(to: NSPoint(x: 770, y: 546),
    controlPoint1: NSPoint(x: 267, y: 755), controlPoint2: NSPoint(x: 757, y: 755))
cap.curve(to: NSPoint(x: 254, y: 546),
    controlPoint1: NSPoint(x: 640, y: 508), controlPoint2: NSPoint(x: 384, y: 508))
cap.close()
cap.fill()
NSGraphicsContext.restoreGraphicsState()

let output = URL(fileURLWithPath:
    "Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
try bitmap.representation(using: .png, properties: [:])!.write(to: output)
