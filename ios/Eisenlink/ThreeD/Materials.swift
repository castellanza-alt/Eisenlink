import SceneKit
import UIKit

enum Materials {
    private static func pbr(_ hex: UInt32, rough: CGFloat, metal: CGFloat) -> SCNMaterial {
        let m = SCNMaterial()
        m.lightingModel = .physicallyBased
        m.diffuse.contents = UIColor(hex: hex)
        m.roughness.contents = rough
        m.metalness.contents = metal
        return m
    }

    // Colori e valori dal file di riferimento (reference/index.html), non dalla tabella del handoff.
    static func fixed() -> SCNMaterial { pbr(0x0B0D0F, rough: 0.58, metal: 0.28) }
    static func big() -> SCNMaterial { pbr(0x15191B, rough: 0.50, metal: 0.34) }
    static func small() -> SCNMaterial { pbr(0x22282B, rough: 0.44, metal: 0.38) }
    static func shaft() -> SCNMaterial { pbr(0x8D9296, rough: 0.26, metal: 0.95) }
    static func chrome() -> SCNMaterial { pbr(0xDFE2E4, rough: 0.09, metal: 1.0) }

    static func bar() -> SCNMaterial {
        let m = pbr(0x2A2E31, rough: 0.44, metal: 0.80)
        m.diffuse.contents = knurl()
        m.diffuse.wrapS = .repeat
        m.diffuse.contentsTransform = SCNMatrix4MakeScale(26, 1, 1)
        return m
    }

    /// Righe sottili lungo l'asse (la texture si ripete 26 volte attorno al cilindro).
    private static func knurl() -> UIImage {
        let r = UIGraphicsImageRenderer(size: CGSize(width: 128, height: 8))
        // Nel riferimento il colore 0x2A2E31 moltiplica una mappa grigia (0x8D base, 0x4A righe): qui è già moltiplicato.
        return r.image { ctx in
            UIColor(hex: 0x202326).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 128, height: 8))
            UIColor(hex: 0x111314).setFill()
            var x: CGFloat = 0
            while x < 128 { ctx.fill(CGRect(x: x, y: 0, width: 1.4, height: 8)); x += 3 }
        }
    }

    /// Ambiente riflettente equirettangolare: chiaro in alto, scuro in basso, due macchie luminose.
    static func environment() -> UIImage {
        let size = CGSize(width: 512, height: 256)
        let r = UIGraphicsImageRenderer(size: size)
        return r.image { ctx in
            let cg = ctx.cgContext
            let cs = CGColorSpaceCreateDeviceRGB()
            let colors = [UIColor(hex: 0xFFFFFF), UIColor(hex: 0xCFCDC9), UIColor(hex: 0x5D5C5A), UIColor(hex: 0x141413)]
                .map(\.cgColor) as CFArray
            let grad = CGGradient(colorsSpace: cs, colors: colors, locations: [0, 0.40, 0.50, 1])!
            cg.drawLinearGradient(grad, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            UIColor.white.withAlphaComponent(0.95).setFill()
            cg.fillEllipse(in: CGRect(x: 140 - 110, y: 54 - 44, width: 220, height: 88))
            cg.fillEllipse(in: CGRect(x: 392 - 64, y: 86 - 26, width: 128, height: 52))
            UIColor.black.withAlphaComponent(0.30).setFill()
            cg.fillEllipse(in: CGRect(x: 250 - 150, y: 214 - 40, width: 300, height: 80))
        }
    }
}
