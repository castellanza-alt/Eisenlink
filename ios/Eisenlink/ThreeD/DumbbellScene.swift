import SceneKit
import SwiftUI
import UIKit

/// Vista SceneKit del manubrio (scelta: SceneKit, non RealityKit — l'asola si ottiene con SCNShape + foro).
struct DumbbellView: UIViewRepresentable {
    let config: Config
    let wide: Bool
    let active: Bool

    func makeCoordinator() -> DumbbellScene { DumbbellScene() }

    func makeUIView(context: Context) -> SceneHost {
        let v = SceneHost(frame: .zero, options: nil)
        context.coordinator.attach(to: v)
        return v
    }

    func updateUIView(_ v: SceneHost, context: Context) {
        let c = context.coordinator
        c.setWide(wide)
        c.apply(config)
        v.isPlaying = active
    }
}

final class SceneHost: SCNView {
    var onLayout: (() -> Void)?
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}

final class DumbbellScene: NSObject, SCNSceneRendererDelegate {
    private let scene = SCNScene()
    private let root = SCNNode()
    private let camNode = SCNNode()
    private weak var view: SceneHost?

    private let mFix = Materials.fixed(), mBig = Materials.big(), mSmall = Materials.small()
    private let mShaft = Materials.shaft(), mChrome = Materials.chrome()
    private lazy var gFix = Geometry.plate(thickness: Dim.tFix, material: mFix)
    private lazy var gBig = Geometry.plate(thickness: Dim.tBig, material: mBig)
    private lazy var gSmall = Geometry.plate(thickness: Dim.tSmall, material: mSmall)

    private let lock = NSLock()
    private var anim: [(node: SCNNode, to: CGFloat)] = []
    private var current: Config?
    private var wide = false

    // Rotazione
    private var rot = 0.0, aim = 0.0, vel = 0.0
    private var dragging = false, dragStartAim = 0.0, lastMove = CACurrentMediaTime()
    private var lastTime: TimeInterval = 0

    private static let dirv: SCNVector3 = {
        let (x, y, z) = (0.24, 0.28, 1.0)
        let n = (x * x + y * y + z * z).squareRoot()
        return SCNVector3(x / n, y / n, z / n)
    }()

    func attach(to v: SceneHost) {
        view = v
        v.scene = scene
        v.backgroundColor = .clear
        v.isOpaque = false
        v.antialiasingMode = .multisampling4X
        v.preferredFramesPerSecond = 60
        v.autoenablesDefaultLighting = false
        v.allowsCameraControl = false
        v.delegate = self
        v.isPlaying = true
        v.onLayout = { [weak self] in self?.updateCamera() }

        scene.lightingEnvironment.contents = Materials.environment()
        scene.lightingEnvironment.intensity = 1.0

        let cam = SCNCamera()
        cam.fieldOfView = 28
        cam.projectionDirection = .vertical
        cam.zNear = 0.1
        cam.zFar = 60
        camNode.camera = cam
        scene.rootNode.addChildNode(camNode)

        let amb = SCNNode(); amb.light = SCNLight(); amb.light!.type = .ambient
        amb.light!.intensity = 180; amb.light!.color = UIColor.white
        scene.rootNode.addChildNode(amb)
        scene.rootNode.addChildNode(directional(at: SCNVector3(3, 5, 4), intensity: 900))
        scene.rootNode.addChildNode(directional(at: SCNVector3(-4, 1, -3), intensity: 350))

        scene.rootNode.addChildNode(root)
        let bar = Geometry.cylinderX(radius: Dim.barR, length: Dim.barHalf * 2, material: Materials.bar(), segments: 28)
        root.addChildNode(bar)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        v.addGestureRecognizer(pan)
        updateCamera()
    }

    private func directional(at p: SCNVector3, intensity: CGFloat) -> SCNNode {
        let n = SCNNode()
        let l = SCNLight(); l.type = .directional; l.intensity = intensity; l.color = UIColor.white
        n.light = l
        n.position = p
        n.look(at: SCNVector3Zero)
        return n
    }

    func setWide(_ w: Bool) {
        guard w != wide else { return }
        wide = w
        updateCamera()
    }

    func updateCamera() {
        guard let v = view, v.bounds.width > 0, v.bounds.height > 0 else { return }
        let aspect = v.bounds.width / v.bounds.height
        let half: CGFloat = wide ? 2.70 : 1.88
        let need = half / (tan(28 * .pi / 360) * aspect) * 1.06
        let d = Float(max(4.6, need))
        let u = Self.dirv
        camNode.position = SCNVector3(u.x * d, u.y * d, u.z * d)
        camNode.look(at: SCNVector3(0, 0.10, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
    }

    // MARK: montaggio

    func apply(_ c: Config) {
        guard c != current else { return }
        let animate = current != nil && !UIAccessibility.isReduceMotionEnabled
        current = c
        lock.lock(); defer { lock.unlock() }
        root.childNodes.filter { $0.name == "piece" }.forEach { $0.removeFromParentNode() }
        anim.removeAll()

        for d in [CGFloat(-1), CGFloat(1)] {
            var x = d * Dim.barHalf
            x += d * Dim.tFix / 2
            add(gFix, at: x)
            x += d * (Dim.tFix / 2 + Dim.gap)
            for _ in 0..<c.big {
                x += d * Dim.tBig / 2
                add(gBig, at: x, animateFrom: animate ? d * 0.9 : nil)
                x += d * (Dim.tBig / 2 + Dim.gap)
            }
            for _ in 0..<c.small {
                x += d * Dim.tSmall / 2
                add(gSmall, at: x, animateFrom: animate ? d * 0.9 : nil)
                x += d * (Dim.tSmall / 2 + Dim.gap)
            }
            if c.screw > 0 {
                let sh = Geometry.cylinderX(radius: Dim.shaftR, length: Dim.shaftL, material: mShaft, segments: 24)
                sh.name = "piece"; sh.position.x = Float(x + d * Dim.shaftL / 2)
                root.addChildNode(sh)
                let dc = Geometry.cylinderX(radius: Dim.discR, length: Dim.discT, material: mChrome, segments: 64)
                dc.name = "piece"; dc.position.x = Float(x + d * (Dim.shaftL + Dim.discT / 2))
                root.addChildNode(dc)
            }
        }
    }

    private func add(_ g: SCNGeometry, at x: CGFloat, animateFrom offset: CGFloat? = nil) {
        // Il guscio ruota di 90° attorno a Y: la lastra (estrusa su Z) ha lo spessore lungo X.
        let shell = SCNNode()
        shell.name = "piece"
        shell.eulerAngles.y = .pi / 2
        let body = SCNNode(geometry: g)
        let depth = ((g as? SCNShape)?.extrusionDepth ?? 0)
        body.position.z = Float(-depth / 2)
        shell.addChildNode(body)
        shell.position.x = Float(x + (offset ?? 0))
        root.addChildNode(shell)
        if offset != nil { anim.append((shell, x)) }
    }

    // MARK: rotazione

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        switch g.state {
        case .began:
            lock.lock(); dragging = true; dragStartAim = aim; vel = 0; lastMove = CACurrentMediaTime(); lock.unlock()
        case .changed:
            let nx = max(-1.2, min(1.2, dragStartAim + Double(g.translation(in: g.view).x) * 0.009))
            let now = CACurrentMediaTime()
            let dtMs = max(8, (now - lastMove) * 1000)
            lock.lock(); vel = (nx - aim) / dtMs * 16; aim = nx; lastMove = now; lock.unlock()
        case .ended, .cancelled, .failed:
            lock.lock(); dragging = false
            if UIAccessibility.isReduceMotionEnabled { vel = 0 }
            lock.unlock()
        default: break
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime t: TimeInterval) {
        let dt = lastTime == 0 ? 1.0 / 60 : min(t - lastTime, 0.1)
        lastTime = t
        let f = dt * 60   // fattori espressi per frame a 60 fps
        lock.lock(); defer { lock.unlock() }

        let k = CGFloat(1 - pow(1 - 0.18, f))
        anim.removeAll { item in
            let x = CGFloat(item.node.position.x)
            let nx = x + (item.to - x) * k
            if abs(item.to - nx) < 0.002 { item.node.position.x = Float(item.to); return true }
            item.node.position.x = Float(nx)
            return false
        }
        if !dragging && abs(vel) > 0.0004 {
            aim = max(-1.2, min(1.2, aim + vel * f))
            vel *= pow(0.93, f)
        }
        rot += (aim - rot) * (1 - pow(1 - 0.32, f))
        root.eulerAngles.y = Float(rot)
    }
}
