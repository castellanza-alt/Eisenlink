import SwiftUI

/// Fondo piatto con un alone dietro al manubrio.
struct Backdrop: View {
    var body: some View {
        ZStack {
            Tokens.bg
            RadialGradient(colors: [Tokens.glow, Tokens.glow.opacity(0)],
                           center: UnitPoint(x: 0.5, y: 0.34), startRadius: 0, endRadius: 420)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
