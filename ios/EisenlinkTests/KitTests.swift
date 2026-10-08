import XCTest
@testable import Eisenlink

final class KitTests: XCTestCase {
    func testPairList() {
        XCTAssertEqual(Kit.pair.map(\.w), Array(stride(from: 4, through: 28, by: 2)))
        XCTAssertEqual(Kit.pair.count, 13)
    }

    func testSoloList() {
        XCTAssertEqual(Kit.solo.map(\.w), Array(stride(from: 4, through: 50, by: 2)))
        XCTAssertEqual(Kit.solo.count, 24)
    }

    func testPairPlatesPerSide() {
        let table: [Int: (Int, Int)] = [6: (0, 0), 8: (0, 1), 10: (1, 0), 12: (1, 1), 14: (2, 0), 16: (2, 1),
                                        18: (3, 0), 20: (3, 1), 22: (4, 0), 24: (4, 1), 26: (5, 0), 28: (5, 1)]
        for (w, expected) in table {
            let c = Kit.pair.first { $0.w == w }!
            XCTAssertEqual(c.big, expected.0, "grandi a \(w) kg")
            XCTAssertEqual(c.small, expected.1, "piccole a \(w) kg")
            XCTAssertEqual(c.screw, 1)
        }
    }

    func testBareHandle() {
        let c = Kit.pair[0]
        XCTAssertEqual(c, Config(w: 4, screw: 0, big: 0, small: 0))
    }

    func testSixteenKg() {
        for list in [Kit.pair, Kit.solo] {
            let c = list.first { $0.w == 16 }!
            XCTAssertEqual(c.big, 2)
            XCTAssertEqual(c.small, 1)
        }
    }

    func testWeightFormula() {
        for c in Kit.solo where c.screw == 1 {
            XCTAssertEqual(c.w, 4 + 2 * 1 + c.big * 4 + c.small * 2)
        }
    }

    func testExtraKitFlag() {
        XCTAssertFalse(Kit.solo.filter { $0.w <= Kit.pairMax }.contains(where: Kit.needsExtraKit))
        XCTAssertTrue(Kit.solo.filter { $0.w > Kit.pairMax }.allSatisfy(Kit.needsExtraKit))
    }

    func testStateFallbackAndPersistence() {
        let d = UserDefaults(suiteName: "eisenlink.tests")!
        d.removePersistentDomain(forName: "eisenlink.tests")
        let s = AppState(defaults: d)
        XCTAssertEqual(s.mode, .pair)
        XCTAssertEqual(s.kg, 10)
        s.setMode(.solo); s.select(46)
        XCTAssertEqual(AppState(defaults: d).kg, 46)
        s.setMode(.pair)
        XCTAssertEqual(s.kg, 10)
    }
}
