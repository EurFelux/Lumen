#!/usr/bin/env swift
import AppKit
import Foundation

struct Palette {
    let bgTop: NSColor
    let bgBottom: NSColor
    let accent: NSColor
}

func hex(_ s: String) -> NSColor {
    var str = s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if str.hasPrefix("#") { str.removeFirst() }
    guard str.count == 6, let value = Int(str, radix: 16) else { return .magenta }
    let r = CGFloat((value >> 16) & 0xFF) / 255.0
    let g = CGFloat((value >> 8) & 0xFF) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0
    return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1)
}

func ensureDir(_ url: URL) throws {
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
}

func writePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "assets", code: 1)
    }
    try png.write(to: url, options: .atomic)
}

func drawImage(size: CGSize, _ draw: (CGRect) -> Void) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocusFlipped(false)
    NSGraphicsContext.current?.imageInterpolation = .high
    draw(CGRect(origin: .zero, size: size))
    image.unlockFocus()
    return image
}

func linearGradient(in rect: CGRect, top: NSColor, bottom: NSColor, angleDegrees: CGFloat = 35) {
    let gradient = NSGradient(colors: [top, bottom])!
    gradient.draw(in: rect, angle: angleDegrees)
}

func softNoise(in rect: CGRect, amount: Int = 900, alpha: CGFloat = 0.08) {
    for _ in 0..<amount {
        let x = CGFloat.random(in: rect.minX...rect.maxX)
        let y = CGFloat.random(in: rect.minY...rect.maxY)
        let r = CGFloat.random(in: 0.6...1.4)
        let c = NSColor(white: CGFloat.random(in: 0.85...1.0), alpha: alpha)
        c.setFill()
        NSBezierPath(ovalIn: CGRect(x: x, y: y, width: r, height: r)).fill()
    }
}

func glowDot(_ center: CGPoint, radius: CGFloat, color: NSColor, alpha: CGFloat = 0.9) {
    let g = NSGradient(colors: [color.withAlphaComponent(alpha), color.withAlphaComponent(0)])!
    g.draw(fromCenter: center, radius: 0, toCenter: center, radius: radius, options: [])
}

func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func addShadow(_ blur: CGFloat, offset: CGSize, color: NSColor, _ body: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowBlurRadius = blur
    shadow.shadowOffset = offset
    shadow.shadowColor = color
    shadow.set()
    body()
    NSGraphicsContext.restoreGraphicsState()
}

func avatar(name: String, palette: Palette, mood: String) -> NSImage {
    // Fun, polished, human-ish portrait: gradient bg + soft bokeh + simple character shapes + mood prop.
    let size = CGSize(width: 512, height: 512)
    return drawImage(size: size) { rect in
        linearGradient(in: rect, top: palette.bgTop, bottom: palette.bgBottom, angleDegrees: 35)
        softNoise(in: rect, amount: 1400, alpha: 0.07)

        // Bokeh lights
        for _ in 0..<18 {
            let p = CGPoint(x: CGFloat.random(in: 80...432), y: CGFloat.random(in: 130...460))
            let r = CGFloat.random(in: 18...62)
            glowDot(p, radius: r, color: palette.accent, alpha: 0.35)
        }

        // Character base
        let headCenter = CGPoint(x: 256, y: 290)
        let headR: CGFloat = 102
        let skin = NSColor(calibratedRed: 0.98, green: 0.87, blue: 0.78, alpha: 1)
        addShadow(14, offset: CGSize(width: 0, height: -6), color: NSColor.black.withAlphaComponent(0.25)) {
            skin.setFill()
            NSBezierPath(ovalIn: CGRect(x: headCenter.x - headR, y: headCenter.y - headR, width: headR * 2, height: headR * 2)).fill()
        }

        // Hair
        let hair = NSColor(calibratedWhite: 0.12, alpha: 1)
        hair.setFill()
        let hairPath = NSBezierPath()
        hairPath.move(to: CGPoint(x: 150, y: 330))
        hairPath.curve(to: CGPoint(x: 362, y: 332), controlPoint1: CGPoint(x: 190, y: 420), controlPoint2: CGPoint(x: 310, y: 420))
        hairPath.curve(to: CGPoint(x: 150, y: 330), controlPoint1: CGPoint(x: 382, y: 300), controlPoint2: CGPoint(x: 120, y: 300))
        hairPath.close()
        hairPath.fill()

        // Hoodie / shirt
        let torso = roundedRect(CGRect(x: 142, y: 70, width: 228, height: 170), radius: 44)
        NSColor.black.withAlphaComponent(0.55).setFill()
        addShadow(18, offset: CGSize(width: 0, height: -8), color: NSColor.black.withAlphaComponent(0.35)) {
            torso.fill()
        }
        palette.accent.withAlphaComponent(0.25).setStroke()
        torso.lineWidth = 3
        torso.stroke()

        // Eyes
        let eyeW: CGFloat = 22
        let eyeH: CGFloat = 14
        NSColor.black.withAlphaComponent(0.75).setFill()
        NSBezierPath(roundedRect: CGRect(x: 208, y: 302, width: eyeW, height: eyeH), xRadius: 7, yRadius: 7).fill()
        NSBezierPath(roundedRect: CGRect(x: 282, y: 302, width: eyeW, height: eyeH), xRadius: 7, yRadius: 7).fill()

        // Highlight
        NSColor.white.withAlphaComponent(0.7).setFill()
        NSBezierPath(ovalIn: CGRect(x: 216, y: 309, width: 6, height: 6)).fill()
        NSBezierPath(ovalIn: CGRect(x: 290, y: 309, width: 6, height: 6)).fill()

        // Mouth
        NSColor.black.withAlphaComponent(0.35).setStroke()
        let mouth = NSBezierPath()
        mouth.move(to: CGPoint(x: 232, y: 266))
        mouth.curve(to: CGPoint(x: 280, y: 266), controlPoint1: CGPoint(x: 246, y: 252), controlPoint2: CGPoint(x: 266, y: 252))
        mouth.lineWidth = 3
        mouth.stroke()

        // Mood prop
        switch mood {
        case "lantern":
            let lanternRect = CGRect(x: 350, y: 150, width: 86, height: 86)
            addShadow(20, offset: .zero, color: palette.accent.withAlphaComponent(0.55)) {
                palette.accent.setFill()
                NSBezierPath(roundedRect: lanternRect, xRadius: 18, yRadius: 18).fill()
            }
            NSColor.white.withAlphaComponent(0.9).setStroke()
            NSBezierPath(rect: lanternRect.insetBy(dx: 14, dy: 14)).stroke()
            glowDot(CGPoint(x: lanternRect.midX, y: lanternRect.midY), radius: 90, color: palette.accent, alpha: 0.45)
        case "candle":
            let candle = roundedRect(CGRect(x: 360, y: 135, width: 60, height: 90), radius: 18)
            NSColor.white.withAlphaComponent(0.85).setFill()
            candle.fill()
            let flameCenter = CGPoint(x: 390, y: 240)
            glowDot(flameCenter, radius: 70, color: hex("#ffb703"), alpha: 0.65)
            hex("#ffb703").setFill()
            NSBezierPath(ovalIn: CGRect(x: flameCenter.x - 10, y: flameCenter.y - 14, width: 20, height: 28)).fill()
        case "coffee":
            let mug = roundedRect(CGRect(x: 355, y: 140, width: 78, height: 74), radius: 18)
            NSColor.white.withAlphaComponent(0.82).setFill()
            mug.fill()
            NSColor.white.withAlphaComponent(0.75).setStroke()
            NSBezierPath(ovalIn: CGRect(x: 420, y: 156, width: 26, height: 40)).stroke()
            glowDot(CGPoint(x: 394, y: 212), radius: 60, color: hex("#ffd166"), alpha: 0.22)
        case "headphones":
            NSColor.black.withAlphaComponent(0.55).setStroke()
            let band = NSBezierPath()
            band.appendArc(withCenter: CGPoint(x: 256, y: 330), radius: 138, startAngle: 210, endAngle: -30, clockwise: true)
            band.lineWidth = 10
            band.stroke()
            NSColor.black.withAlphaComponent(0.65).setFill()
            NSBezierPath(roundedRect: CGRect(x: 128, y: 276, width: 42, height: 70), xRadius: 16, yRadius: 16).fill()
            NSBezierPath(roundedRect: CGRect(x: 342, y: 276, width: 42, height: 70), xRadius: 16, yRadius: 16).fill()
        case "sunglasses":
            NSColor.black.withAlphaComponent(0.75).setFill()
            NSBezierPath(roundedRect: CGRect(x: 186, y: 306, width: 62, height: 28), xRadius: 10, yRadius: 10).fill()
            NSBezierPath(roundedRect: CGRect(x: 264, y: 306, width: 62, height: 28), xRadius: 10, yRadius: 10).fill()
            NSColor.black.withAlphaComponent(0.6).setStroke()
            let bridge = NSBezierPath()
            bridge.move(to: CGPoint(x: 248, y: 320))
            bridge.line(to: CGPoint(x: 264, y: 320))
            bridge.lineWidth = 5
            bridge.stroke()
        case "visor":
            let visor = roundedRect(CGRect(x: 178, y: 308, width: 156, height: 34), radius: 16)
            addShadow(16, offset: .zero, color: palette.accent.withAlphaComponent(0.45)) {
                palette.accent.withAlphaComponent(0.35).setFill()
                visor.fill()
            }
            palette.accent.withAlphaComponent(0.8).setStroke()
            visor.lineWidth = 2
            visor.stroke()
        default:
            break
        }

        // Subtle vignette
        let vignette = NSGradient(colors: [NSColor.black.withAlphaComponent(0.0), NSColor.black.withAlphaComponent(0.35)])!
        vignette.draw(in: rect, relativeCenterPosition: NSPoint(x: 0, y: -0.2))
    }
}

func backdrop(name: String, palette: Palette, motif: String) -> NSImage {
    let size = CGSize(width: 1200, height: 400)
    return drawImage(size: size) { rect in
        linearGradient(in: rect, top: palette.bgTop, bottom: palette.bgBottom, angleDegrees: 20)
        softNoise(in: rect, amount: 2200, alpha: 0.06)

        // Big soft glow areas for "atmosphere"
        for _ in 0..<10 {
            let p = CGPoint(x: CGFloat.random(in: 80...1120), y: CGFloat.random(in: 80...320))
            glowDot(p, radius: CGFloat.random(in: 90...160), color: palette.accent, alpha: 0.18)
        }

        // Simple silhouettes per motif for identity.
        NSColor.black.withAlphaComponent(0.25).setFill()
        switch motif {
        case "cave":
            // Cave arches
            let arch = NSBezierPath()
            arch.move(to: CGPoint(x: 0, y: 0))
            arch.curve(to: CGPoint(x: 280, y: 260), controlPoint1: CGPoint(x: 60, y: 220), controlPoint2: CGPoint(x: 160, y: 300))
            arch.curve(to: CGPoint(x: 520, y: 70), controlPoint1: CGPoint(x: 360, y: 210), controlPoint2: CGPoint(x: 450, y: 140))
            arch.curve(to: CGPoint(x: 780, y: 300), controlPoint1: CGPoint(x: 600, y: 10), controlPoint2: CGPoint(x: 690, y: 210))
            arch.curve(to: CGPoint(x: 1200, y: 120), controlPoint1: CGPoint(x: 930, y: 400), controlPoint2: CGPoint(x: 1050, y: 220))
            arch.line(to: CGPoint(x: 1200, y: 0))
            arch.close()
            arch.fill()

            // Bioluminescent "fungi" dots
            for _ in 0..<70 {
                let p = CGPoint(x: CGFloat.random(in: 40...1160), y: CGFloat.random(in: 40...220))
                glowDot(p, radius: CGFloat.random(in: 6...16), color: palette.accent, alpha: 0.5)
            }
        case "theater":
            // Screen glow
            let screen = roundedRect(CGRect(x: 760, y: 90, width: 360, height: 220), radius: 22)
            addShadow(24, offset: .zero, color: palette.accent.withAlphaComponent(0.45)) {
                palette.accent.withAlphaComponent(0.25).setFill()
                screen.fill()
            }
            // Seats
            NSColor.black.withAlphaComponent(0.3).setFill()
            for i in 0..<8 {
                roundedRect(CGRect(x: 40 + CGFloat(i) * 130, y: 40, width: 110, height: 70), radius: 18).fill()
            }
        case "fireplace":
            // Fireplace block
            let box = roundedRect(CGRect(x: 90, y: 70, width: 320, height: 250), radius: 26)
            NSColor.black.withAlphaComponent(0.25).setFill()
            box.fill()
            // Flame glow
            glowDot(CGPoint(x: 240, y: 190), radius: 220, color: hex("#ffb703"), alpha: 0.22)
            glowDot(CGPoint(x: 240, y: 160), radius: 140, color: hex("#fb8500"), alpha: 0.28)
        case "cafe":
            // Window panes
            NSColor.black.withAlphaComponent(0.25).setStroke()
            for x in stride(from: 80 as CGFloat, through: 1120, by: 130) {
                let line = NSBezierPath()
                line.move(to: CGPoint(x: x, y: 50))
                line.line(to: CGPoint(x: x, y: 350))
                line.lineWidth = 2
                line.stroke()
            }
            // Warm blobs as lights
            for _ in 0..<24 {
                let p = CGPoint(x: CGFloat.random(in: 120...1080), y: CGFloat.random(in: 110...330))
                glowDot(p, radius: CGFloat.random(in: 40...90), color: hex("#ffd166"), alpha: 0.18)
            }
        case "office":
            // Ceiling strips
            NSColor.white.withAlphaComponent(0.10).setFill()
            for y in stride(from: 320 as CGFloat, through: 380, by: 20) {
                roundedRect(CGRect(x: 0, y: y, width: 1200, height: 10), radius: 5).fill()
            }
            // Desks
            NSColor.black.withAlphaComponent(0.25).setFill()
            for i in 0..<6 {
                roundedRect(CGRect(x: 120 + CGFloat(i) * 170, y: 55, width: 140, height: 50), radius: 14).fill()
            }
        case "library":
            // Tall windows + lamps
            NSColor.white.withAlphaComponent(0.08).setFill()
            for i in 0..<6 {
                roundedRect(CGRect(x: 100 + CGFloat(i) * 170, y: 150, width: 110, height: 220), radius: 18).fill()
            }
            for i in 0..<7 {
                glowDot(CGPoint(x: 110 + CGFloat(i) * 170, y: 120), radius: 70, color: hex("#58d68d"), alpha: 0.14)
            }
        case "city":
            // Skyline
            NSColor.black.withAlphaComponent(0.28).setFill()
            for i in 0..<28 {
                let w = CGFloat.random(in: 20...55)
                let h = CGFloat.random(in: 60...210)
                let x = CGFloat(i) * 45 + CGFloat.random(in: -6...6)
                roundedRect(CGRect(x: x, y: 40, width: w, height: h), radius: 8).fill()
            }
            // Overcast haze
            glowDot(CGPoint(x: 520, y: 300), radius: 320, color: NSColor.white, alpha: 0.06)
        case "countryside":
            // Rolling hills
            NSColor.black.withAlphaComponent(0.16).setFill()
            let hill = NSBezierPath()
            hill.move(to: CGPoint(x: 0, y: 100))
            hill.curve(to: CGPoint(x: 400, y: 160), controlPoint1: CGPoint(x: 120, y: 200), controlPoint2: CGPoint(x: 260, y: 70))
            hill.curve(to: CGPoint(x: 860, y: 120), controlPoint1: CGPoint(x: 540, y: 250), controlPoint2: CGPoint(x: 700, y: 60))
            hill.curve(to: CGPoint(x: 1200, y: 150), controlPoint1: CGPoint(x: 980, y: 180), controlPoint2: CGPoint(x: 1120, y: 230))
            hill.line(to: CGPoint(x: 1200, y: 0))
            hill.line(to: CGPoint(x: 0, y: 0))
            hill.close()
            hill.fill()
        case "tropical":
            // Palm silhouettes
            NSColor.black.withAlphaComponent(0.24).setStroke()
            for x in [140, 320, 980, 1100] {
                let trunk = NSBezierPath()
                trunk.move(to: CGPoint(x: CGFloat(x), y: 40))
                trunk.curve(to: CGPoint(x: CGFloat(x) + 30, y: 240), controlPoint1: CGPoint(x: CGFloat(x) - 10, y: 110), controlPoint2: CGPoint(x: CGFloat(x) + 55, y: 160))
                trunk.lineWidth = 10
                trunk.stroke()
                for i in 0..<6 {
                    let leaf = NSBezierPath()
                    leaf.move(to: CGPoint(x: CGFloat(x) + 30, y: 240))
                    leaf.curve(to: CGPoint(x: CGFloat(x) + CGFloat.random(in: -120...120), y: 270 + CGFloat(i) * 5),
                               controlPoint1: CGPoint(x: CGFloat(x) + CGFloat.random(in: -30...30), y: 290),
                               controlPoint2: CGPoint(x: CGFloat(x) + CGFloat.random(in: -90...90), y: 300))
                    leaf.lineWidth = 5
                    leaf.stroke()
                }
            }
        case "mediterranean":
            // Cliff blocks
            NSColor.black.withAlphaComponent(0.20).setFill()
            roundedRect(CGRect(x: 40, y: 60, width: 520, height: 260), radius: 32).fill()
            NSColor.white.withAlphaComponent(0.06).setFill()
            for i in 0..<12 {
                roundedRect(CGRect(x: 80 + CGFloat(i%6)*70, y: 220 - CGFloat(i/6)*70, width: 58, height: 58), radius: 16).fill()
            }
        case "desert":
            // Heat shimmer bands
            NSColor.white.withAlphaComponent(0.06).setFill()
            for i in 0..<12 {
                roundedRect(CGRect(x: 0, y: 70 + CGFloat(i) * 16, width: 1200, height: 9), radius: 5).fill()
            }
            glowDot(CGPoint(x: 820, y: 120), radius: 260, color: palette.accent, alpha: 0.12)
        case "space":
            // Stars
            for _ in 0..<120 {
                let p = CGPoint(x: CGFloat.random(in: 0...1200), y: CGFloat.random(in: 0...400))
                NSColor.white.withAlphaComponent(CGFloat.random(in: 0.12...0.55)).setFill()
                NSBezierPath(ovalIn: CGRect(x: p.x, y: p.y, width: 2, height: 2)).fill()
            }
            // Solar array slabs
            NSColor.black.withAlphaComponent(0.24).setFill()
            for i in 0..<5 {
                let r = roundedRect(CGRect(x: 140 + CGFloat(i) * 210, y: 90 + CGFloat(i%2) * 40, width: 190, height: 80), radius: 16)
                r.fill()
                palette.accent.withAlphaComponent(0.15).setFill()
                roundedRect(r.bounds.insetBy(dx: 10, dy: 10), radius: 12).fill()
            }
        default:
            break
        }

        // Soft blur surrogate: overlay translucent layer
        NSColor.black.withAlphaComponent(0.10).setFill()
        rect.fill(using: .sourceOver)
    }
}

func icon(type: String, palette: Palette) -> NSImage {
    let size = CGSize(width: 256, height: 256)
    return drawImage(size: size) { rect in
        linearGradient(in: rect, top: palette.bgTop, bottom: palette.bgBottom, angleDegrees: 45)
        softNoise(in: rect, amount: 700, alpha: 0.06)

        // Inner shadow ring
        NSColor.black.withAlphaComponent(0.18).setStroke()
        let ring = NSBezierPath(ovalIn: rect.insetBy(dx: 12, dy: 12))
        ring.lineWidth = 10
        ring.stroke()

        NSColor.white.setFill()
        switch type {
        case "moon":
            // Crescent moon
            let moonRect = CGRect(x: 74, y: 74, width: 108, height: 108)
            NSBezierPath(ovalIn: moonRect).fill()
            NSColor(calibratedRed: palette.bgTop.redComponent, green: palette.bgTop.greenComponent, blue: palette.bgTop.blueComponent, alpha: 1).setFill()
            NSBezierPath(ovalIn: moonRect.offsetBy(dx: 26, dy: 10)).fill()
            // Stars
            NSColor.white.withAlphaComponent(0.92).setFill()
            for p in [CGPoint(x: 190, y: 172), CGPoint(x: 170, y: 206), CGPoint(x: 206, y: 194)] {
                NSBezierPath(ovalIn: CGRect(x: p.x, y: p.y, width: 8, height: 8)).fill()
            }
        case "sun":
            let sunRect = CGRect(x: 92, y: 92, width: 72, height: 72)
            NSBezierPath(ovalIn: sunRect).fill()
            NSColor.white.withAlphaComponent(0.9).setStroke()
            for i in 0..<12 {
                let angle = CGFloat(i) * (CGFloat.pi * 2 / 12)
                let inner = CGPoint(x: rect.midX + cos(angle) * 56, y: rect.midY + sin(angle) * 56)
                let outer = CGPoint(x: rect.midX + cos(angle) * 78, y: rect.midY + sin(angle) * 78)
                let ray = NSBezierPath()
                ray.move(to: inner)
                ray.line(to: outer)
                ray.lineWidth = 6
                ray.stroke()
            }
        default:
            break
        }

        // Subtle vignette
        let vignette = NSGradient(colors: [NSColor.black.withAlphaComponent(0.0), NSColor.black.withAlphaComponent(0.32)])!
        vignette.draw(in: rect, relativeCenterPosition: NSPoint(x: 0, y: -0.1))
    }
}

let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outRoot = repoRoot.appendingPathComponent("Lumen/Sources/Resources/Images")
let avatarsDir = outRoot.appendingPathComponent("avatars", isDirectory: true)
let backdropsDir = outRoot.appendingPathComponent("backdrops", isDirectory: true)
let iconsDir = outRoot.appendingPathComponent("icons", isDirectory: true)

try ensureDir(avatarsDir)
try ensureDir(backdropsDir)
try ensureDir(iconsDir)

let levelPalettes: [String: Palette] = [
    "cave_dweller_dark": Palette(bgTop: hex("#0a0a1a"), bgBottom: hex("#1a1a3e"), accent: hex("#2dd4bf")),
    "cave_dweller_light": Palette(bgTop: hex("#1e1e3f"), bgBottom: hex("#2d2d5a"), accent: hex("#8ecae6")),
    "cozy_corner_dark": Palette(bgTop: hex("#1a0f0a"), bgBottom: hex("#3d2317"), accent: hex("#ffb703")),
    "cozy_corner_light": Palette(bgTop: hex("#4a2c1a"), bgBottom: hex("#6b3e26"), accent: hex("#ffd166")),
    "office_warrior_dark": Palette(bgTop: hex("#0f1f2e"), bgBottom: hex("#1a3a4f"), accent: hex("#80ed99")),
    "office_warrior_light": Palette(bgTop: hex("#2a5298"), bgBottom: hex("#1e3c72"), accent: hex("#a2d2ff")),
    "cloud_browsing_dark": Palette(bgTop: hex("#1a2530"), bgBottom: hex("#2a3a4a"), accent: hex("#cdb4db")),
    "cloud_browsing_light": Palette(bgTop: hex("#89a8c4"), bgBottom: hex("#b8d4e3"), accent: hex("#ffafcc")),
    "beach_mode_dark": Palette(bgTop: hex("#1a3028"), bgBottom: hex("#2a5040"), accent: hex("#48cae4")),
    "beach_mode_light": Palette(bgTop: hex("#00b4db"), bgBottom: hex("#0083b0"), accent: hex("#fefae0")),
    "solar_panel_dark": Palette(bgTop: hex("#3a1f15"), bgBottom: hex("#5a3020"), accent: hex("#ff6b6b")),
    "solar_panel_light": Palette(bgTop: hex("#ff9966"), bgBottom: hex("#ff5e62"), accent: hex("#ffe66d"))
]

let avatars: [(file: String, key: String, mood: String)] = [
    ("avatar_cave_dweller_dark.png", "cave_dweller_dark", "visor"),
    ("avatar_cave_dweller_light.png", "cave_dweller_light", "lantern"),
    ("avatar_cozy_corner_dark.png", "cozy_corner_dark", "candle"),
    ("avatar_cozy_corner_light.png", "cozy_corner_light", "coffee"),
    ("avatar_office_warrior_dark.png", "office_warrior_dark", "coffee"),
    ("avatar_office_warrior_light.png", "office_warrior_light", "coffee"),
    ("avatar_cloud_browsing_dark.png", "cloud_browsing_dark", "headphones"),
    ("avatar_cloud_browsing_light.png", "cloud_browsing_light", "headphones"),
    ("avatar_beach_mode_dark.png", "beach_mode_dark", "sunglasses"),
    ("avatar_beach_mode_light.png", "beach_mode_light", "sunglasses"),
    ("avatar_solar_panel_dark.png", "solar_panel_dark", "visor"),
    ("avatar_solar_panel_light.png", "solar_panel_light", "visor")
]

for a in avatars {
    guard let palette = levelPalettes[a.key] else { continue }
    let image = avatar(name: a.file, palette: palette, mood: a.mood)
    try writePNG(image, to: avatarsDir.appendingPathComponent(a.file))
}

let backdrops: [(file: String, key: String, motif: String)] = [
    ("backdrop_cave_dweller_a.png", "cave_dweller_dark", "cave"),
    ("backdrop_cave_dweller_b.png", "cave_dweller_dark", "theater"),
    ("backdrop_cozy_corner_a.png", "cozy_corner_dark", "fireplace"),
    ("backdrop_cozy_corner_b.png", "cozy_corner_dark", "cafe"),
    ("backdrop_office_warrior_a.png", "office_warrior_dark", "office"),
    ("backdrop_office_warrior_b.png", "office_warrior_dark", "library"),
    ("backdrop_cloud_browsing_a.png", "cloud_browsing_dark", "city"),
    ("backdrop_cloud_browsing_b.png", "cloud_browsing_light", "countryside"),
    ("backdrop_beach_mode_a.png", "beach_mode_light", "tropical"),
    ("backdrop_beach_mode_b.png", "beach_mode_light", "mediterranean"),
    ("backdrop_solar_panel_a.png", "solar_panel_dark", "desert"),
    ("backdrop_solar_panel_b.png", "solar_panel_light", "space")
]

for b in backdrops {
    guard let palette = levelPalettes[b.key] else { continue }
    let image = backdrop(name: b.file, palette: palette, motif: b.motif)
    try writePNG(image, to: backdropsDir.appendingPathComponent(b.file))
}

let darkIcon = icon(type: "moon", palette: Palette(bgTop: hex("#1a1a3e"), bgBottom: hex("#2d2b55"), accent: .white))
let lightIcon = icon(type: "sun", palette: Palette(bgTop: hex("#f4a261"), bgBottom: hex("#e76f51"), accent: .white))
try writePNG(darkIcon, to: iconsDir.appendingPathComponent("icon_dark_side.png"))
try writePNG(lightIcon, to: iconsDir.appendingPathComponent("icon_light_side.png"))

print("Generated assets at \(outRoot.path)")

