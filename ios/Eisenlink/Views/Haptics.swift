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

    /// Prova: vibrazione continua di 0,3 s più un clic. Si attiva toccando la scritta «Eisenlink».
    func test() {
        if let e = engine {
            do {
                try e.start()
                let ev = CHHapticEvent(eventType: .hapticContinuous,
                                       parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)],
                                       relativeTime: 0, duration: 0.3)
                let player = try e.makePlayer(with: try CHHapticPattern(events: [ev], parameters: []))
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {}
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Da chiamare quando l'app torna in primo piano: il motore si ferma in background.
    func wake() {
        try? engine?.start()
        selection.prepare()
    }

    func tick(intensity: Float = 1.0, sharpness: Float = 1.0) {
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
