import Metal
import QuartzCore
import SwiftUI
import UIKit

@_silgen_name("squirrelpad_rt64_initialize")
private func initializeRT64(_ window: UnsafeMutableRawPointer, _ view: UnsafeMutableRawPointer) -> UnsafePointer<CChar>?
@_silgen_name("squirrelpad_rt64_shutdown")
private func shutdownRT64()

@MainActor
final class RendererStatus: ObservableObject {
    @Published private(set) var message = "Metal renderer: waiting for surface"
    private var initialized = false

    func attach(_ view: UIView) {
        guard !initialized, view.bounds.width > 0, view.bounds.height > 0,
              let layer = view.layer as? CAMetalLayer else { return }
        initialized = true
        let window = Unmanaged.passUnretained(view).toOpaque()
        let metalLayer = Unmanaged.passUnretained(layer).toOpaque()
        if let result = initializeRT64(window, metalLayer) {
            message = String(cString: result)
        } else {
            message = "Metal renderer: device setup failed"
        }
    }

    func detach() {
        guard initialized else { return }
        shutdownRT64()
        initialized = false
    }
}

final class MetalHostView: UIView {
    override class var layerClass: AnyClass { CAMetalLayer.self }
    var onLayout: ((UIView) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Follow the actual scene when iPadOS moves the window to another display.
        if let screen = window?.screen { contentScaleFactor = screen.scale }
        onLayout?(self)
    }
}

struct RT64Surface: UIViewRepresentable {
    @ObservedObject var renderer: RendererStatus

    func makeCoordinator() -> RendererStatus { renderer }

    func makeUIView(context: Context) -> MetalHostView {
        let view = MetalHostView()
        view.isOpaque = true
        if let layer = view.layer as? CAMetalLayer {
            layer.pixelFormat = .bgra8Unorm
        }
        view.onLayout = { [weak renderer] surface in renderer?.attach(surface) }
        return view
    }

    func updateUIView(_ view: MetalHostView, context: Context) {
        renderer.attach(view)
    }

    static func dismantleUIView(_ view: MetalHostView, coordinator: RendererStatus) {
        view.onLayout = nil
        coordinator.detach()
    }
}
