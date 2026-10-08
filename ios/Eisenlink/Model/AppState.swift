import Foundation
import Observation

@Observable
final class AppState {
    private(set) var mode: Mode
    private(set) var kg: Int
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let m = Mode(rawValue: defaults.string(forKey: "el-mode") ?? "") ?? .pair
        let stored = defaults.integer(forKey: "el-kg")
        mode = m
        kg = stored == 0 ? 10 : stored
        normalize()
    }

    var config: Config { mode.configs.first { $0.w == kg } ?? mode.configs[3] }

    func select(_ w: Int) { kg = w; save() }
    func setMode(_ m: Mode) { mode = m; normalize(); save() }

    /// Se il peso non esiste nella modalità corrente, ripiega sul quarto valore (10 kg).
    private func normalize() {
        let list = mode.configs
        if !list.contains(where: { $0.w == kg }) { kg = list[min(3, list.count - 1)].w }
    }

    private func save() {
        defaults.set(mode.rawValue, forKey: "el-mode")
        defaults.set(kg, forKey: "el-kg")
    }
}
