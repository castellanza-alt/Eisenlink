import SwiftUI

extension View {
    /// Pannello in vetro: sfocatura dello sfondo, velo bianco, bordo 1 pt, ombra morbida.
    func glass<S: InsettableShape>(_ shape: S, shadow: Bool = true) -> some View {
        self
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(Tokens.glass)
                }
            }
            .clipShape(shape)
            .overlay { shape.strokeBorder(Tokens.line, lineWidth: 1) }
            .shadow(color: shadow ? Tokens.shadow : .clear, radius: 22, x: 0, y: 20)
    }
}

/// Tre grandi cerchi sfocati dietro al vetro.
struct BackdropField: View {
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack {
                Circle().fill(Tokens.blob1).frame(width: w * 0.70, height: w * 0.70)
                    .position(x: -0.20 * w + w * 0.35, y: -0.18 * w + w * 0.35)
                Circle().fill(Tokens.blob2).frame(width: w * 0.60, height: w * 0.60)
                    .position(x: w + 0.24 * w - w * 0.30, y: 0.40 * h + w * 0.30)
                Circle().fill(Tokens.blob3).frame(width: w * 0.56, height: w * 0.56)
                    .position(x: 0.14 * w + w * 0.28, y: h + 0.20 * w - w * 0.28)
            }
            .blur(radius: 80)
        }
        .background(Tokens.bg)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
