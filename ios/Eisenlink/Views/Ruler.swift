import SwiftUI

/// Righello orizzontale: scorri e il peso cambia mentre passi sui valori.
/// Si cambia peso solo con lo swipe, con un clic aptico per ogni valore. Lo scorrimento è quello nativo (inerzia e aggancio di sistema); il numero sotto il dito si ingrandisce in modo continuo.
struct Ruler: View {
    @Environment(AppState.self) private var state
    @State private var selID: Int?
    @State private var offset: CGFloat = 0
    @State private var margin: CGFloat = 0
    private let tw: CGFloat = 62

    var body: some View {
        let list = state.mode.configs
        GeometryReader { g in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(list.enumerated()), id: \.element.id) { i, c in
                            Tick(config: c, k: weight(i))
                                .frame(width: tw, height: 120)
                                .contentShape(Rectangle())
                                .onTapGesture { go(c.w) }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, max(0, g.size.width / 2 - tw / 2), for: .scrollContent)
                .onAppear { margin = max(0, g.size.width / 2 - tw / 2) }
                .onChange(of: g.size.width) { _, w in margin = max(0, w / 2 - tw / 2) }
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
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
                    Triangle().fill(Tokens.accent).frame(width: 14, height: 9).padding(.bottom, 18)
                }
            }
        .frame(height: 120)
        .padding(.bottom, 30)
        .onAppear { selID = state.kg }
        .onChange(of: selID) { _, new in
            if let new, new != state.kg {
                Haptics.shared.tick()
                state.select(new)
            }
        }
        .onChange(of: state.mode) { _, _ in
            var t = Transaction(); t.disablesAnimations = true
            withTransaction(t) { selID = state.kg }
        }
    }

    /// 0 lontano dal centro, 1 al centro (curva morbida).
    private func weight(_ i: Int) -> CGFloat {
        // contentOffset parte da -margine: il valore i è al centro quando offset + margine = i * tw.
        let d = abs(CGFloat(i) * tw - (offset + margin)) / tw
        let x = max(0, 1 - d / 1.6)
        return x * x * (3 - 2 * x)
    }

    private func go(_ w: Int) {
        withAnimation(.snappy(duration: 0.28)) { selID = w }
    }

}

private struct Tick: View {
    let config: Config
    let k: CGFloat

    var body: some View {
        VStack(spacing: 10) {
            // Il numero è disegnato alla dimensione massima e rimpicciolito: ingrandire un testo piccolo lo sfoca.
            Text("\(config.w)")
                .font(.wide(46)).tracking(-46 * 0.03).monospacedDigit()
                .foregroundStyle(k > 0.5 ? Tokens.ink : Tokens.muted)
                .fixedSize()
                .scaleEffect(0.53 + 0.47 * k, anchor: .bottom)
                .frame(height: 28, alignment: .bottom)
            Capsule()
                .fill(k > 0.5 ? Tokens.accent : (config.w > Kit.pairMax ? Tokens.mark : Tokens.muted))
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
