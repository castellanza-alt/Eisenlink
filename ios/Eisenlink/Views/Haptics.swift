import CoreHaptics
import UIKit

/// Clic aptico per ogni valore del righello. Usa Core Haptics (colpo secco) e, se non disponibile, il feedback di selezione di sistema.
final class Haptics {
    static let shared = Haptics()
    private var engine: CHHapticEngine?
    private let selection = UISelectionFeedbackGenerator()

    private init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let e = try CHHapticEngine()
            e.isAutoShutdownEnabled = false
            e.resetHandler = { [weak self] in try? self?.engine?.start() }
            e.stoppedHandler = { _ in }
            try e.start()
            engine = e
        } catch {
            engine = nil
        }
    }

    /// Da chiamare quando l'app torna in primo piano: il motore si ferma in background.
    func wake() {
        try? engine?.start()
        selection.prepare()
    }

    func tick(intensity: Float = 0.75, sharpness: Float = 0.9) {
        if let e = engine {
            do {
                let ev = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)],
                                       relativeTime: 0)
                let player = try e.makePlayer(with: try CHHapticPattern(events: [ev], parameters: []))
                try player.start(atTime: CHHapticTimeImmediate)
                return
            } catch {
                try? e.start()
            }
        }
        selection.selectionChanged()
        selection.prepare()
    }
}
