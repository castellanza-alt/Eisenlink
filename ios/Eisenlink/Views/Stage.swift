import SwiftUI

/// Manubrio a tutta larghezza con il peso in grande in alto a sinistra.
struct Stage: View {
    @Environment(AppState.self) private var state
    @Environment(\.scenePhase) private var phase

    var body: some View {
        let cfg = state.config
        ZStack(alignment: .topLeading) {
            DumbbellView(config: cfg, wide: state.mode == .solo, active: phase == .active)
                .padding(.top, 90)

            VStack(alignment: .leading, spacing: 10) {
                Text("\(cfg.w)")
                    .font(.wide(124))
                    .tracking(-124 * 0.035)
                    .monospacedDigit()
                    .foregroundStyle(Tokens.ink)
                    .frame(height: 100, alignment: .bottom)
                Text(state.mode.unitLabel).label(12, em: 0.16)
            }
            .padding(.leading, 8)
            .padding(.top, 14)
            .allowsHitTesting(false)
            .accessibilityElement(children: .combine)

            Text("un manubrio")
                .label(11, em: 0.16, color: Tokens.mark)
                .padding(.vertical, 5).padding(.horizontal, 10)
                .overlay(Capsule().strokeBorder(Tokens.mark, lineWidth: 1))
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, 22)
                .padding(.trailing, 8)
                .opacity(state.mode == .solo && Kit.needsExtraKit(cfg) ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: cfg)
                .allowsHitTesting(false)
        }
        .frame(minHeight: 260, maxHeight: 400)
    }
}

/// Piastre da montare per lato, con i nomi «Grande» (2 kg) e «Piccola» (1 kg).
struct LoadRow: View {
    let config: Config

    var body: some View {
        VStack(spacing: 8) {
            if config.big > 0 {
                card(width: 14, height: 42, count: config.big, name: config.big == 1 ? "Grande" : "Grandi", kg: 2)
            }
            if config.small > 0 {
                card(width: 8, height: 36, count: config.small, name: config.small == 1 ? "Piccola" : "Piccole", kg: 1)
            }
            if config.big == 0 && config.small == 0 {
                Text("Nessuna piastra, solo maniglia e viti")
                    .label(12, em: 0.12)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Tokens.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Tokens.line, lineWidth: 1))
            }
        }
        // Altezza fissa per due riquadri: il manubrio non cambia dimensione da un peso all'altro.
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .top)
        .animation(.easeOut(duration: 0.18), value: config)
    }

    private func card(width: CGFloat, height: CGFloat, count: Int, name: String, kg: Int) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3).fill(Tokens.ink)
                .frame(width: width, height: height)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(count) \(name)").font(.medium(15)).foregroundStyle(Tokens.ink)
                Text("\(kg) kg l’una").font(.regular(12)).foregroundStyle(Tokens.muted)
            }
            Spacer(minLength: 0)
            Text("×\(count)")
                .font(.wide(34)).tracking(-34 * 0.03).monospacedDigit()
                .foregroundStyle(Tokens.accent)
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(Tokens.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Tokens.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(count) \(name), \(kg) chili l’una, per lato")
    }
}
