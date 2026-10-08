import SceneKit
import UIKit

/// Misure del modello: unità = lato del blocco quadrato.
enum Dim {
    static let size: CGFloat = 1
    static let radius: CGFloat = 0.15
    static let tFix: CGFloat = 0.12, tBig: CGFloat = 0.12, tSmall: CGFloat = 0.075
    static let gap: CGFloat = 0.024
    static let barHalf: CGFloat = 0.60, barR: CGFloat = 0.082
    static let shaftL: CGFloat = 0.17, shaftR: CGFloat = 0.055
    static let discR: CGFloat = 0.27, discT: CGFloat = 0.085
}

enum Geometry {
    /// Lastra quadrata con angoli arrotondati, bordo smussato e asola in alto, centrata sull'origine.
    static func plate(thickness t: CGFloat, material: SCNMaterial) -> SCNGeometry {
        let w = Dim.size
        let path = UIBezierPath(roundedRect: CGRect(x: -w / 2, y: -w / 2, width: w, height: w), cornerRadius: Dim.radius)
        let hw = w * 0.16, hh = w * 0.042, hy = w * 0.29
        let slot = UIBezierPath(roundedRect: CGRect(x: -(hw + hh), y: hy - hh, width: 2 * (hw + hh), height: 2 * hh),
                                cornerRadius: hh)
        path.append(slot)
        path.usesEvenOddFillRule = true
        path.flatness = 0.002
        let g = SCNShape(path: path, extrusionDepth: t - 0.028)
        g.chamferRadius = 0.014
        g.materials = [material]
        return g
    }

    static func cylinderX(radius: CGFloat, length: CGFloat, material: SCNMaterial, segments: Int = 48) -> SCNNode {
        let c = SCNCylinder(radius: radius, height: length)
        c.radialSegmentCount = segments
        c.materials = [material]
        let n = SCNNode(geometry: c)
        n.eulerAngles.z = .pi / 2
        return n
    }
}
