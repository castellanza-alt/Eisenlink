import SwiftUI
import UIKit

enum Tokens {
    private static func dyn(_ light: UInt32, _ dark: UInt32, _ la: Double = 1, _ da: Double = 1) -> Color {
        Color(uiColor: UIColor { tc in
            let dk = tc.userInterfaceStyle == .dark
            return UIColor(hex: dk ? dark : light, alpha: dk ? da : la)
        })
    }

    static let bg = dyn(0xEFEDE8, 0x232420)
    static let blob1 = dyn(0xE3E0D6, 0x2E302A)
    static let blob2 = dyn(0xDCE2DC, 0x2A322D)
    static let blob3 = dyn(0xE8E3DA, 0x33322B)
    static let glass = dyn(0xFFFFFF, 0xFFFFFF, 0.46, 0.07)
    static let line = dyn(0xFFFFFF, 0xFFFFFF, 0.72, 0.16)
    static let ink = dyn(0x1A1A18, 0xEDEBE4)
    static let muted = dyn(0x1A1A18, 0xEDEBE4, 0.48, 0.50)
    static let accent = dyn(0x1E4636, 0x8FBFA6)
    static let accent2 = dyn(0x2C6249, 0x6FA88C)
    static let onAccent = dyn(0xF4F2EC, 0x16241D)
    static let mark = dyn(0x8A6A3B, 0xC4A472)
    static let shadow = dyn(0x28261F, 0x000000, 0.13, 0.40)
    static let chipShadow = dyn(0x28261F, 0x000000, 0.07, 0.25)

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
    func label(_ size: CGFloat, em: CGFloat, color: Color = Tokens.muted, medium: Bool = true) -> some View {
        self.font(medium ? .medium(size) : .regular(size))
            .tracking(size * em)
            .foregroundStyle(color)
            .textCase(.uppercase)
    }
}
