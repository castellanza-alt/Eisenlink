import Foundation

/// Una combinazione montabile: peso totale e pezzi (piastre = coppie, cioè per lato).
struct Config: Equatable, Identifiable {
    let w: Int
    let screw: Int
    let big: Int
    let small: Int
    var id: Int { w }
}

enum Mode: String {
    case pair
    case solo

    var configs: [Config] { self == .pair ? Kit.pair : Kit.solo }
    var unitLabel: String { self == .pair ? "kg per mano" : "kg totali" }
}

/// Modello di calcolo identico al JS di riferimento (reference/index.html).
enum Kit {
    static let body = 4, screw = 1, big = 2, small = 1
    static let kitBig = 5, kitSmall = 1

    static func configs(bigPairs bp: Int, smallPairs sp: Int) -> [Config] {
        var out = [Config(w: body, screw: 0, big: 0, small: 0)]
        var seen: Set<Int> = [body]
        for b in stride(from: bp, through: 0, by: -1) {
            for s in 0...sp {
                let w = body + 2 * screw + b * 2 * big + s * 2 * small
                if seen.contains(w) { continue }
                seen.insert(w)
                out.append(Config(w: w, screw: 1, big: b, small: s))
            }
        }
        return out.sorted { $0.w < $1.w }
    }

    static let pair = configs(bigPairs: kitBig, smallPairs: kitSmall)
    static let solo = configs(bigPairs: kitBig * 2, smallPairs: kitSmall * 2)
    static let pairMax = pair.last!.w

    /// Peso oltre un singolo kit: serve prendere piastre dall'altro manubrio.
    static func needsExtraKit(_ c: Config) -> Bool { c.big > kitBig || c.small > kitSmall }
}
