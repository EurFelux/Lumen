import AppKit

/// Menu bar glyph, drawn in code so it stays crisp at any scale and tints as a template image.
/// A diagonally split disc (light/dark appearance) ringed by ambient-light rays: full rays in
/// Light mode, dimmed to dots in Dark mode.
enum StatusBarIcon {

    private static let canvasSize = NSSize(width: 18, height: 18)
    private static let strokeWidth: CGFloat = 1.25
    private static let discRadius: CGFloat = 4.75
    private static let rayCount = 8

    static func image(for mode: AppearanceMode) -> NSImage {
        let image = NSImage(size: canvasSize, flipped: false) { rect in
            drawGlyph(in: rect, mode: mode)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Lumen (\(mode.displayName))"
        return image
    }

    private static func drawGlyph(in rect: NSRect, mode: AppearanceMode) {
        let center = NSPoint(x: rect.midX, y: rect.midY)
        NSColor.black.setFill()
        NSColor.black.setStroke()

        let disc = NSBezierPath(ovalIn: NSRect(
            x: center.x - discRadius, y: center.y - discRadius,
            width: discRadius * 2, height: discRadius * 2
        ))
        disc.lineWidth = strokeWidth
        disc.stroke()

        // Lower-right half filled, split along the diagonal
        let darkHalf = NSBezierPath()
        darkHalf.appendArc(withCenter: center, radius: discRadius, startAngle: 45, endAngle: 225, clockwise: true)
        darkHalf.close()
        darkHalf.fill()

        for index in 0..<rayCount {
            let angle = CGFloat(index) * 2 * .pi / CGFloat(rayCount)
            let direction = CGVector(dx: cos(angle), dy: sin(angle))
            func point(at radius: CGFloat) -> NSPoint {
                NSPoint(x: center.x + direction.dx * radius, y: center.y + direction.dy * radius)
            }

            switch mode {
            case .light:
                let ray = NSBezierPath()
                ray.move(to: point(at: 7.0))
                ray.line(to: point(at: 8.25))
                ray.lineWidth = strokeWidth
                ray.lineCapStyle = .round
                ray.stroke()
            case .dark:
                let dotRadius: CGFloat = 0.8
                let dotCenter = point(at: 7.6)
                NSBezierPath(ovalIn: NSRect(
                    x: dotCenter.x - dotRadius, y: dotCenter.y - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                )).fill()
            }
        }
    }
}
