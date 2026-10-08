import SwiftUI

struct WeightGrid: View {
    @Environment(AppState.self) private var state
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 9), count: 5)

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: cols, spacing: 9) {
                ForEach(state.mode.configs) { c in
                    Chip(config: c, selected: c.w == state.kg) {
                        Haptics.tap()
                        state.select(c.w)
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

struct Chip: View {
    let config: Config
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(config.w)")
                .font(.wide(25)).tracking(-25 * 0.02).monospacedDigit()
                .foregroundStyle(selected ? Tokens.onAccent : Tokens.ink)
                .padding(.top, 15).padding(.bottom, 13)
                .frame(maxWidth: .infinity)
                .background {
                    let s = RoundedRectangle(cornerRadius: 16, style: .continuous)
                    if selected { s.fill(Tokens.accent) } else { s.fill(.ultraThinMaterial); s.fill(Tokens.glass) }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    if !selected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Tokens.line, lineWidth: 1)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if config.w > Kit.pairMax {
                        Circle().fill(Tokens.mark).frame(width: 5, height: 5).padding(7)
                    }
                }
                .shadow(color: Tokens.chipShadow, radius: 9, x: 0, y: 8)
        }
        .buttonStyle(ChipPress())
        .accessibilityLabel("\(config.w) kg")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct ChipPress: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduce
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduce ? 0.95 : 1)
            .animation(reduce ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
