import SwiftUI

@main
struct EisenlinkApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
                .preferredColorScheme(state.themeOverride)
        }
    }
}
