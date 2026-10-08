import SwiftUI

struct Stage: View {
    @Environment(AppState.self) private var state
    @Environment(\.scenePhase) private var phase

    var body: some View {
        let cfg = state.config
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {
                Text("\(cfg.w)")
                    .font(.wide(72))
                    .tracking(-72 * 0.035)
                    .monospacedDigit()
                    .foregroundStyle(Tokens.ink)
                    .frame(height: 61, alignment: .bottom)
                Text(state.mode.unitLabel)
                    .label(10, em: 0.2)
                    .padding(.bottom, 9)
                Spacer(minLength: 0)
            }
            .allowsHitTesting(false)
            .zIndex(2)
            .accessibilityElement(children: .combine)

            ZStack(alignment: .bottom) {
                RadialGradient(colors: [Color(red: 0.12, green: 0.11, blue: 0.09).opacity(0.26), .clear],
                               center: .center, startRadius: 0, endRadius: 80)
                    .frame(height: 20)
                    .padding(.horizontal, 54)
                    .padding(.bottom, 40)
                    .allowsHitTesting(false)
                DumbbellView(config: cfg, wide: state.mode == .solo, active: phase == .active)
            }
            .frame(height: 236)
            .padding(.top, -44)
            .padding(.bottom, -20)
            .zIndex(1)

            PerSide(config: cfg)
                .zIndex(2)
        }
        .padding(.top, 20).padding(.horizontal, 20).padding(.bottom, 16)
        .overlay(alignment: .topTrailing) {
            Text("un manubrio")
                .label(9, em: 0.16, color: Tokens.mark)
                .padding(.vertical, 5).padding(.horizontal, 10)
                .overlay(Capsule().strokeBorder(Tokens.mark, lineWidth: 1))
                .padding(20)
                .opacity(state.mode == .solo && Kit.needsExtraKit(cfg) ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: cfg)
                .allowsHitTesting(false)
        }
        .glass(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

struct PerSide: View {
    let config: Config

    var body: some View {
        let has = config.big > 0 || config.small > 0
        VStack(spacing: 9) {
            Text("per lato")
                .label(9, em: 0.22)
                .opacity(has ? 1 : 0)
            if has {
                HStack(spacing: 30) {
                    if config.big > 0 { group(width: 15, count: config.big, kg: 2) }
                    if config.small > 0 { group(width: 9, count: config.small, kg: 1) }
                }
            } else {
                Text("nessuna piastra").label(11, em: 0.16)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 66)
        .accessibilityElement(children: .combine)
    }

    private func group(width: CGFloat, count: Int, kg: Int) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3).fill(Tokens.ink).opacity(0.88)
                .frame(width: width, height: 40)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(count)")
                    .font(.wide(26)).tracking(-26 * 0.03).monospacedDigit()
                    .foregroundStyle(Tokens.ink)
                Text("× \(kg) kg").label(9, em: 0.16)
            }
        }
    }
}
