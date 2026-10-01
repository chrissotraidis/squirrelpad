import SwiftUI

@_silgen_name("squirrelpad_touch_button")
private func setTouchButton(_ mask: UInt16, _ pressed: Int32)
@_silgen_name("squirrelpad_touch_stick")
private func setTouchStick(_ x: Float, _ y: Float)
@_silgen_name("squirrelpad_touch_clear")
func clearTouchInput()

private struct TouchControl: Identifiable {
    let id: String
    let title: String
    let mask: UInt16
    let tablet: CGPoint
    let phone: CGPoint
    let tabletSize: CGFloat
    let phoneSize: CGFloat
    let tint: Color
    var shoulder = false
}

private struct TouchButton: View {
    let control: TouchControl
    let compact: Bool
    let scale: Double
    let editing: Bool
    let selected: Bool
    let select: (String) -> Void
    let move: (String, CGPoint) -> Void
    @State private var held = false

    private var size: CGFloat { (compact ? control.phoneSize : control.tabletSize) * scale }
    private var width: CGFloat { control.shoulder ? size * 1.9 : size }

    var body: some View {
        Text(control.title)
            .font(.system(size: compact ? 15 : 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: width, height: size)
            .background(control.tint.opacity(held ? 0.70 : 0.30),
                        in: RoundedRectangle(cornerRadius: size / 2))
            .overlay(RoundedRectangle(cornerRadius: size / 2)
                .stroke(selected ? Color(red: 1, green: 0.78, blue: 0.16) : .white.opacity(held ? 0.9 : 0.72),
                        lineWidth: selected ? 3 : 2))
            .contentShape(RoundedRectangle(cornerRadius: size / 2))
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("touchLayout"))
                .onChanged { _ in
                    if editing { select(control.id); return }
                    guard !held else { return }
                    held = true
                    setTouchButton(control.mask, 1)
                }
                .onEnded { value in
                    if editing && hypot(value.translation.width, value.translation.height) > 2 {
                        move(control.id, value.location)
                    }
                    release()
                })
            .onDisappear { release() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(control.id)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func release() {
        guard held else { return }
        held = false
        setTouchButton(control.mask, 0)
    }
}

private struct TouchStick: View {
    let size: CGFloat
    let editing: Bool
    let selected: Bool
    let select: (String) -> Void
    let center: CGPoint
    let move: (String, CGPoint) -> Void
    @State private var offset = CGSize.zero

    var body: some View {
        Circle()
            .fill(.black.opacity(0.30))
            .overlay(Circle().stroke(selected ? Color(red: 1, green: 0.78, blue: 0.16) : .white.opacity(0.42),
                                     lineWidth: selected ? 3 : 2))
            .overlay {
                Circle()
                    .fill(Color(red: 0.20, green: 0.52, blue: 0.73).opacity(0.80))
                    .overlay(Circle().stroke(.white.opacity(0.70), lineWidth: 1.5))
                    .frame(width: size * 0.43, height: size * 0.43)
                    .offset(offset)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("touchLayout"))
                .onChanged { value in
                    if editing { select("Stick"); return }
                    let radius = size * 0.35
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    let length = max(1, hypot(dx, dy))
                    let scale = min(1, radius / length)
                    offset = CGSize(width: dx * scale, height: dy * scale)
                    setTouchStick(Float(offset.width / radius),
                                  Float(-offset.height / radius))
                }
                .onEnded { value in
                    if editing && hypot(value.translation.width, value.translation.height) > 2 {
                        move("Stick", value.location)
                    }
                    reset()
                })
            .onDisappear { reset() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Control Stick")
            .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func reset() {
        offset = .zero
        setTouchStick(0, 0)
    }
}

struct TouchControlsView: View {
    let opacity: Double
    let scale: Double
    let showDpad: Bool
    let showCButtons: Bool
    let editing: Bool
    let selectedControl: String?
    let onSelect: (String) -> Void
    let layout: [String: CGPoint]
    let controlSizes: [String: Double]
    let onMove: (String, CGPoint) -> Void

    // The normalized centers follow HarkinianPad's accepted phone/tablet grip
    // layouts. Conker uses a continuous stick axis rather than eight key directions.
    private static let controls: [TouchControl] = [
        .init(id: "A", title: "A", mask: 0x8000, tablet: .init(x: 0.893, y: 0.693),
              phone: .init(x: 0.876, y: 0.798), tabletSize: 79, phoneSize: 52,
              tint: .blue),
        .init(id: "B", title: "B", mask: 0x4000, tablet: .init(x: 0.826, y: 0.635),
              phone: .init(x: 0.806, y: 0.725), tabletSize: 79, phoneSize: 52,
              tint: .green),
        .init(id: "Z", title: "Z", mask: 0x2000, tablet: .init(x: 0.193, y: 0.613),
              phone: .init(x: 0.242, y: 0.499), tabletSize: 79, phoneSize: 52,
              tint: .black),
        .init(id: "Start", title: "▶", mask: 0x1000, tablet: .init(x: 0.844, y: 0.440),
              phone: .init(x: 0.830, y: 0.205), tabletSize: 54, phoneSize: 44,
              tint: .red),
        .init(id: "L", title: "L", mask: 0x0020, tablet: .init(x: 0.924, y: 0.520),
              phone: .init(x: 0.925, y: 0.340), tabletSize: 54, phoneSize: 44,
              tint: .black, shoulder: true),
        .init(id: "R", title: "R", mask: 0x0010, tablet: .init(x: 0.924, y: 0.440),
              phone: .init(x: 0.925, y: 0.205), tabletSize: 54, phoneSize: 44,
              tint: .black, shoulder: true),
        .init(id: "D-pad Up", title: "▲", mask: 0x0800, tablet: .init(x: 0.080, y: 0.547),
              phone: .init(x: 0.131, y: 0.315), tabletSize: 52, phoneSize: 44,
              tint: .black),
        .init(id: "D-pad Down", title: "▼", mask: 0x0400, tablet: .init(x: 0.080, y: 0.663),
              phone: .init(x: 0.131, y: 0.502), tabletSize: 52, phoneSize: 44,
              tint: .black),
        .init(id: "D-pad Left", title: "◀", mask: 0x0200, tablet: .init(x: 0.040, y: 0.605),
              phone: .init(x: 0.086, y: 0.409), tabletSize: 52, phoneSize: 44,
              tint: .black),
        .init(id: "D-pad Right", title: "▶", mask: 0x0100, tablet: .init(x: 0.120, y: 0.605),
              phone: .init(x: 0.176, y: 0.409), tabletSize: 52, phoneSize: 44,
              tint: .black),
        .init(id: "C Up", title: "▲", mask: 0x0008, tablet: .init(x: 0.903, y: 0.805),
              phone: .init(x: 0.827, y: 0.398), tabletSize: 55, phoneSize: 40,
              tint: .orange),
        .init(id: "C Down", title: "▼", mask: 0x0004, tablet: .init(x: 0.902, y: 0.905),
              phone: .init(x: 0.827, y: 0.570), tabletSize: 55, phoneSize: 40,
              tint: .orange),
        .init(id: "C Left", title: "◀", mask: 0x0002, tablet: .init(x: 0.857, y: 0.854),
              phone: .init(x: 0.784, y: 0.485), tabletSize: 55, phoneSize: 40,
              tint: .orange),
        .init(id: "C Right", title: "▶", mask: 0x0001, tablet: .init(x: 0.948, y: 0.853),
              phone: .init(x: 0.871, y: 0.486), tabletSize: 55, phoneSize: 40,
              tint: .orange)
    ]

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 560
            let width = geometry.size.width
            let height = geometry.size.height
            let move: (String, CGPoint) -> Void = { id, point in
                onMove(id, CGPoint(x: min(max(point.x / width, 0.06), 0.94),
                                   y: min(max(point.y / height, compact ? 0.12 : 0.06),
                                          compact ? 0.88 : 0.94)))
            }
            ZStack {
                let stick = layout["Stick"] ?? CGPoint(x: compact ? 0.214 : 0.164,
                                                        y: compact ? 0.752 : 0.81)
                TouchStick(size: (compact ? 116 : 150) * scale * (controlSizes["Stick"] ?? 1),
                           editing: editing,
                           selected: editing && selectedControl == "Stick",
                           select: onSelect,
                           center: CGPoint(x: width * stick.x, y: height * stick.y),
                           move: move)
                    .position(x: width * stick.x, y: height * stick.y)
                ForEach(Self.controls) { control in
                    if (showDpad || !control.id.hasPrefix("D-pad")) &&
                       (showCButtons || !control.id.hasPrefix("C ")) {
                        let normalized = layout[control.id] ?? (compact ? control.phone : control.tablet)
                        let center = CGPoint(x: width * normalized.x, y: height * normalized.y)
                        TouchButton(control: control, compact: compact,
                                    scale: scale * (controlSizes[control.id] ?? 1),
                                    editing: editing,
                                    selected: editing && selectedControl == control.id,
                                    select: onSelect, move: move)
                            .position(center)
                    }
                }
            }
            .opacity(opacity)
            .coordinateSpace(name: "touchLayout")
        }
        .allowsHitTesting(true)
    }
}
