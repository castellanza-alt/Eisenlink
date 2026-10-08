import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        ZStack {
            BackdropField()
            VStack(spacing: 16) {
                Header()
                Stage()
                WeightGrid()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: 460 + 32)
        }
    }
}

struct Header: View {
    @Environment(AppState.self) private var state

    var body: some View {
        HStack {
            Text("Eisenlink")
                .label(11, em: 0.22)
                .padding(.leading, 6)
            Spacer()
            HStack(spacing: 0) {
                seg("Coppia", .pair)
                seg("Singolo", .solo)
            }
            .padding(3)
            .glass(Capsule())
        }
    }

    private func seg(_ title: String, _ m: Mode) -> some View {
        let on = state.mode == m
        return Button {
            guard state.mode != m else { return }
            Haptics.tap()
            state.setMode(m)
        } label: {
            Text(title)
                .label(11, em: 0.1, color: on ? Tokens.onAccent : Tokens.muted)
                .padding(.vertical, 7)
                .padding(.horizontal, 13)
                .background(on ? Tokens.accent : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}
