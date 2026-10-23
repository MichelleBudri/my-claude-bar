import AppKit

/// A starburst in the style of the Claude logo.
enum ClaudeIcon {
    private static let rayLengths: [CGFloat] = [1.0, 0.78, 0.93, 0.7, 0.97, 0.82, 0.74, 0.99, 0.8, 0.9, 0.72, 0.86]

    static func image(size: CGFloat = 16) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            NSColor.black.setFill()
            for (index, length) in rayLengths.enumerated() {
                let angle = 0.2 + 2 * .pi * CGFloat(index) / CGFloat(rayLengths.count)
                drawRay(in: rect, angle: angle, length: length)
            }
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func drawRay(in rect: NSRect, angle: CGFloat, length: CGFloat) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseWidth = rect.width * 0.04
        let tipWidth = rect.width * 0.13
        let reach = (rect.width / 2 - 0.5) * length - tipWidth / 2

        let direction = CGVector(dx: cos(angle), dy: sin(angle))
        let side = CGVector(dx: -direction.dy, dy: direction.dx)
        let tip = center.moved(direction, by: reach)

        let ray = NSBezierPath()
        ray.move(to: center.moved(side, by: baseWidth / 2))
        ray.line(to: tip.moved(side, by: tipWidth / 2))
        ray.line(to: tip.moved(side, by: -tipWidth / 2))
        ray.line(to: center.moved(side, by: -baseWidth / 2))
        ray.close()
        ray.fill()

        let roundTip = NSRect(x: tip.x - tipWidth / 2, y: tip.y - tipWidth / 2, width: tipWidth, height: tipWidth)
        NSBezierPath(ovalIn: roundTip).fill()
    }
}

private extension CGPoint {
    func moved(_ direction: CGVector, by distance: CGFloat) -> CGPoint {
        CGPoint(x: x + direction.dx * distance, y: y + direction.dy * distance)
    }
}
