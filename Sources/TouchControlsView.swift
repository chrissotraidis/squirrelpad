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
    @State private var held = false

    private var size: CGFloat { compact ? control.phoneSize : control.tabletSize }
    private var width: CGFloat { control.shoulder ? size * 1.9 : size }

    var body: some View {
        Text(control.title)
            .font(.system(size: compact ? 15 : 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: width, height: size)
            .background(control.tint.opacity(held ? 0.86 : 0.48),
                        in: RoundedRectangle(cornerRadius: size / 2))
            .overlay(RoundedRectangle(cornerRadius: size / 2)
                .stroke(.white.opacity(held ? 0.9 : 0.58), lineWidth: 2))
            .contentShape(RoundedRectangle(cornerRadius: size / 2))
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !held else { return }
                    held = true
                    setTouchButton(control.mask, 1)
                }
                .onEnded { _ in release() })
            .onDisappear { release() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(control.id)
            .accessibilityAddTraits(.isButton)
    }

    private func release() {
        guard held else { return }
        held = false
        setTouchButton(control.mask, 0)
    }
}

private struct TouchStick: View {
    let size: CGFloat
    @State private var offset = CGSize.zero

    var body: some View {
        Circle()
            .fill(.black.opacity(0.30))
            .overlay(Circle().stroke(.white.opacity(0.42), lineWidth: 2))
            .overlay {
                Circle()
                    .fill(Color(red: 0.20, green: 0.52, blue: 0.73).opacity(0.80))
                    .overlay(Circle().stroke(.white.opacity(0.70), lineWidth: 1.5))
                    .frame(width: size * 0.43, height: size * 0.43)
                    .offset(offset)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let radius = size * 0.35
                    let dx = value.location.x - size / 2
                    let dy = value.location.y - size / 2
                    let length = max(1, hypot(dx, dy))
                    let scale = min(1, radius / length)
                    offset = CGSize(width: dx * scale, height: dy * scale)
                    setTouchStick(Float(offset.width / radius),
                                  Float(-offset.height / radius))
                }
                .onEnded { _ in reset() })
            .onDisappear { reset() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Control Stick")
    }

    private func reset() {
        offset = .zero
        setTouchStick(0, 0)
    }
}

struct TouchControlsView: View {
    let opacity: Double
    let showDpad: Bool
    let showCButtons: Bool

    // The normalized centers follow HarkinianPad's accepted phone/tablet grip
    // layouts. Conker uses a continuous stick axis rather than eight key directions.
    private static let controls: [TouchControl] = [
        .init(id: "A", title: "A", mask: 0x8000, tablet: .init(x: 0.893, y: 0.693),
              phone: .init(x: 0.876, y: 0.738), tabletSize: 79, phoneSize: 52,
              tint: .blue),
        .init(id: "B", title: "B", mask: 0x4000, tablet: .init(x: 0.826, y: 0.635),
              phone: .init(x: 0.806, y: 0.665), tabletSize: 79, phoneSize: 52,
              tint: .green),
        .init(id: "Z", title: "Z", mask: 0x2000, tablet: .init(x: 0.193, y: 0.613),
              phone: .init(x: 0.242, y: 0.499), tabletSize: 79, phoneSize: 52,
              tint: .black),
        .init(id: "Start", title: "▶", mask: 0x1000, tablet: .init(x: 0.844, y: 0.440),
              phone: .init(x: 0.840, y: 0.205), tabletSize: 54, phoneSize: 44,
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
              phone: .init(x: 0.847, y: 0.398), tabletSize: 55, phoneSize: 40,
              tint: .orange),
        .init(id: "C Down", title: "▼", mask: 0x0004, tablet: .init(x: 0.902, y: 0.905),
              phone: .init(x: 0.847, y: 0.570), tabletSize: 55, phoneSize: 40,
              tint: .orange),
        .init(id: "C Left", title: "◀", mask: 0x0002, tablet: .init(x: 0.857, y: 0.854),
              phone: .init(x: 0.804, y: 0.485), tabletSize: 55, phoneSize: 40,
              tint: .orange),
        .init(id: "C Right", title: "▶", mask: 0x0001, tablet: .init(x: 0.948, y: 0.853),
              phone: .init(x: 0.891, y: 0.486), tabletSize: 55, phoneSize: 40,
              tint: .orange)
    ]

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 560
            ZStack {
                TouchStick(size: compact ? 116 : 150)
                    .position(x: geometry.size.width * (compact ? 0.214 : 0.164),
                              y: geometry.size.height * (compact ? 0.722 : 0.745))
                ForEach(Self.controls) { control in
                    if (showDpad || !control.id.hasPrefix("D-pad")) &&
                       (showCButtons || !control.id.hasPrefix("C ")) {
                        let center = compact ? control.phone : control.tablet
                        TouchButton(control: control, compact: compact)
                            .position(x: geometry.size.width * center.x,
                                      y: geometry.size.height * center.y)
                    }
                }
            }
            .opacity(opacity)
        }
        .allowsHitTesting(true)
    }
}
