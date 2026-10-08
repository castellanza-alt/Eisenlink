import SwiftUI
import UIKit

/// Palette: grafite verdastro (scuro) e avorio (chiaro), mai nero o bianco assoluti.
/// Il lime del marchio compare solo dove c'è una selezione.
enum Tokens {
    private static func dyn(_ light: UInt32, _ dark: UInt32, _ la: Double = 1, _ da: Double = 1) -> Color {
        Color(uiColor: UIColor { tc in
            let dk = tc.userInterfaceStyle == .dark
            return UIColor(hex: dk ? dark : light, alpha: dk ? da : la)
        })
    }

    static let bg = dyn(0xE8E7E1, 0x1B2624)
    static let glow = dyn(0xF3F2ED, 0x2B403B)
    static let card = dyn(0xF1F0EB, 0xF1F3EF, 1, 0.06)
    static let line = dyn(0x1B201D, 0xF1F3EF, 0.08, 0.10)
    static let ink = dyn(0x1B201D, 0xF1F3EF)
    static let muted = dyn(0x1B201D, 0xF1F3EF, 0.55, 0.55)
    static let sel = dyn(0x161B18, 0xBDE955)
    static let onSel = dyn(0xC6F060, 0x11190A)
    static let mark = dyn(0x9A7A3C, 0xB9955A)
    static let floorShadow = dyn(0x1E221C, 0x000000, 0.22, 0.45)

    static let wide = "Archivo-SemiExpandedSemiBold"
    static let medium = "Archivo-Medium"
    static let regular = "Archivo-Regular"
}

extension UIColor {
    convenience init(hex: UInt32, alpha: Double = 1) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: alpha)
    }
}

extension Font {
    static func wide(_ size: CGFloat) -> Font { .custom(Tokens.wide, fixedSize: size) }
    static func medium(_ size: CGFloat) -> Font { .custom(Tokens.medium, fixedSize: size) }
    static func regular(_ size: CGFloat) -> Font { .custom(Tokens.regular, fixedSize: size) }
}

extension Text {
    /// Maiuscoletto spaziato (em = frazione del corpo).
    func label(_ size: CGFloat, em: CGFloat, color: Color = Tokens.muted) -> some View {
        self.font(.medium(size))
            .tracking(size * em)
            .foregroundStyle(color)
            .textCase(.uppercase)
    }
}
