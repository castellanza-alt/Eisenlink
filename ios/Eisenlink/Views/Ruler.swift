import SwiftUI

/// Righello orizzontale: scorri e il peso cambia mentre passi sui valori.
/// Lo scorrimento è quello nativo (inerzia e aggancio di sistema); il numero sotto il dito si ingrandisce in modo continuo.
struct Ruler: View {
    @Environment(AppState.self) private var state
    @State private var selID: Int?
    @State private var offset: CGFloat = 0
    private let tw: CGFloat = 62

    var body: some View {
        let list = state.mode.configs
        HStack(spacing: 0) {
            StepButton(symbol: "minus", label: "Meno 2 kg") { move(-1) }
            GeometryReader { g in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(list.enumerated()), id: \.element.id) { i, c in
                            Tick(config: c, k: weight(i))
                                .frame(width: tw, height: 100)
                                .contentShape(Rectangle())
                                .onTapGesture { go(c.w) }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, max(0, g.size.width / 2 - tw / 2), for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selID, anchor: .center)
                .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.x }) { _, new in
                    offset = new
                }
                .mask(
                    LinearGradient(stops: [.init(color: .clear, location: 0),
                                           .init(color: .black, location: 0.2),
                                           .init(color: .black, location: 0.8),
                                           .init(color: .clear, location: 1)],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .overlay(alignment: .bottom) {
                    Triangle().fill(Tokens.sel).frame(width: 14, height: 9).padding(.bottom, 2)
                }
            }
            .frame(height: 100)
            StepButton(symbol: "plus", label: "Più 2 kg") { move(1) }
        }
        .onAppear { selID = state.kg }
        .onChange(of: selID) { _, new in
            if let new, new != state.kg { state.select(new) }
        }
        .onChange(of: state.mode) { _, _ in
            var t = Transaction(); t.disablesAnimations = true
            withTransaction(t) { selID = state.kg }
        }
    }

    /// 0 lontano dal centro, 1 al centro (curva morbida).
    private func weight(_ i: Int) -> CGFloat {
        let d = abs(CGFloat(i) * tw - offset) / tw
        let x = max(0, 1 - d / 1.6)
        return x * x * (3 - 2 * x)
    }

    private func go(_ w: Int) {
        withAnimation(.snappy(duration: 0.28)) { selID = w }
    }

    private func move(_ d: Int) {
        let list = state.mode.configs
        guard let i = list.firstIndex(where: { $0.w == state.kg }) else { return }
        go(list[max(0, min(list.count - 1, i + d))].w)
    }
}

private struct Tick: View {
    let config: Config
    let k: CGFloat

    var body: some View {
        VStack(spacing: 10) {
            Text("\(config.w)")
                .font(.wide(24)).tracking(-24 * 0.03).monospacedDigit()
                .foregroundStyle(k > 0.5 ? Tokens.ink : Tokens.muted)
                .scaleEffect(1 + 0.9 * k, anchor: .bottom)
            Capsule()
                .fill(k > 0.5 ? Tokens.sel : (config.w > Kit.pairMax ? Tokens.mark : Tokens.muted))
                .frame(width: 3, height: 26)
                .scaleEffect(x: 1 + 0.5 * k, y: 1 + 0.7 * k, anchor: .bottom)
                .opacity(0.5 + 0.5 * k)
        }
        .padding(.bottom, 30)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .opacity(0.55 + 0.45 * k)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(config.w) kg")
    }
}

private struct StepButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Tokens.ink)
                .frame(width: 58, height: 58)
                .background(Tokens.card, in: Circle())
                .overlay(Circle().strokeBorder(Tokens.line, lineWidth: 1))
        }
        .buttonStyle(PressScale())
        .padding(.bottom, 24)
        .accessibilityLabel(label)
    }
}

private struct PressScale: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduce
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduce ? 0.94 : 1)
            .animation(reduce ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct Triangle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}
