import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Backdrop()
            VStack(spacing: 12) {
                Header()
                Stage()
                LoadRow(config: state.config)
                Spacer(minLength: 12)
                Ruler()
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .frame(maxWidth: 460 + 32)
        }
        .onChange(of: scenePhase) { _, new in if new == .active { Haptics.shared.wake() } }
        .onAppear { Haptics.shared.wake() }
    }
}

struct Header: View {
    @Environment(AppState.self) private var state

    var body: some View {
        HStack {
            Text("Eisenlink")
                .label(12, em: 0.2, color: Tokens.ink.opacity(0.8))
                .padding(.leading, 6)
            Spacer()
            ThemeButton()
            HStack(spacing: 0) {
                seg("Coppia", .pair)
                seg("Singolo", .solo)
            }
            .padding(3)
            .background(Tokens.card, in: Capsule())
            .overlay(Capsule().strokeBorder(Tokens.line, lineWidth: 1))
        }
    }

    private func seg(_ title: String, _ m: Mode) -> some View {
        let on = state.mode == m
        return Button {
            guard state.mode != m else { return }
            Haptics.shared.tick(intensity: 0.9, sharpness: 0.6)
            state.setMode(m)
        } label: {
            Text(title)
                .label(11, em: 0.1, color: on ? Tokens.onSel : Tokens.muted)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(on ? Tokens.sel : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

/// Icona per passare da tema chiaro a scuro (mostra il tema verso cui si va).
struct ThemeButton: View {
    @Environment(AppState.self) private var state
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button {
            Haptics.shared.tick(intensity: 0.9, sharpness: 0.6)
            state.setTheme(scheme == .dark ? .light : .dark)
        } label: {
            Image(systemName: scheme == .dark ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Tokens.ink)
                .frame(width: 38, height: 38)
                .background(Tokens.card, in: Circle())
                .overlay(Circle().strokeBorder(Tokens.line, lineWidth: 1))
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .padding(.trailing, 6)
        .accessibilityLabel(scheme == .dark ? "Passa al tema chiaro" : "Passa al tema scuro")
    }
}
