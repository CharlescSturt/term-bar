import AppKit

enum ToolLogos {
    static func logo(for toolName: String, size: CGFloat = 16) -> NSImage {
        switch toolName {
        case "Claude": return claudeLogo(size: size)
        case "Codex": return codexLogo(size: size)
        case "Kimi": return kimiLogo(size: size)
        case "Gemini": return geminiLogo(size: size)
        default: return NSImage()
        }
    }

    // MARK: - Claude (Anthropic sparkle/asterisk)
    private static func claudeLogo(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let color = NSColor(red: 0.85, green: 0.47, blue: 0.15, alpha: 1.0) // Anthropic orange/amber
        color.setFill()

        let center = NSPoint(x: size / 2, y: size / 2)
        let outerR = size * 0.45
        let innerR = size * 0.15
        let points = 6

        let path = NSBezierPath()
        for i in 0..<(points * 2) {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let r = i % 2 == 0 ? outerR : innerR
            let point = NSPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: point) } else { path.line(to: point) }
        }
        path.close()
        path.fill()

        image.unlockFocus()
        return image
    }

    // MARK: - Codex (OpenAI hexagon with dot)
    private static func codexLogo(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let color = NSColor(red: 0.06, green: 0.64, blue: 0.50, alpha: 1.0) // OpenAI green
        color.setStroke()
        color.setFill()

        let center = NSPoint(x: size / 2, y: size / 2)
        let r = size * 0.42

        // Hexagon
        let hex = NSBezierPath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3.0 - .pi / 6.0
            let point = NSPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { hex.move(to: point) } else { hex.line(to: point) }
        }
        hex.close()
        hex.lineWidth = size * 0.1
        hex.stroke()

        // Center dot
        let dotR = size * 0.12
        let dot = NSBezierPath(ovalIn: NSRect(x: center.x - dotR, y: center.y - dotR, width: dotR * 2, height: dotR * 2))
        dot.fill()

        image.unlockFocus()
        return image
    }

    // MARK: - Kimi (Moonshot crescent moon)
    private static func kimiLogo(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let color = NSColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1.0) // Kimi purple/indigo
        color.setFill()

        let center = NSPoint(x: size / 2, y: size / 2)
        let r = size * 0.42
        let cutR = r * 0.75
        let cutOffset = size * 0.18

        // Full circle
        let circle = NSBezierPath(ovalIn: NSRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        circle.fill()

        // Erase crescent cutout using compositing
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.setBlendMode(.clear)
            let cutRect = NSRect(
                x: center.x - cutR + cutOffset,
                y: center.y - cutR + cutOffset,
                width: cutR * 2,
                height: cutR * 2
            )
            ctx.fillEllipse(in: cutRect)
            ctx.setBlendMode(.normal)
        }

        image.unlockFocus()
        return image
    }

    // MARK: - Gemini (Google 4-pointed star)
    private static func geminiLogo(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let color = NSColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1.0) // Google blue
        color.setFill()

        let cx = size / 2
        let cy = size / 2
        let outer = size * 0.46
        let inner = size * 0.08

        // 4-pointed star using cubic curves for smooth shape
        let path = NSBezierPath()
        path.move(to: NSPoint(x: cx, y: cy + outer)) // top

        path.curve(to: NSPoint(x: cx + outer, y: cy), // right
                    controlPoint1: NSPoint(x: cx + inner, y: cy + inner),
                    controlPoint2: NSPoint(x: cx + inner, y: cy + inner))

        path.curve(to: NSPoint(x: cx, y: cy - outer), // bottom
                    controlPoint1: NSPoint(x: cx + inner, y: cy - inner),
                    controlPoint2: NSPoint(x: cx + inner, y: cy - inner))

        path.curve(to: NSPoint(x: cx - outer, y: cy), // left
                    controlPoint1: NSPoint(x: cx - inner, y: cy - inner),
                    controlPoint2: NSPoint(x: cx - inner, y: cy - inner))

        path.curve(to: NSPoint(x: cx, y: cy + outer), // back to top
                    controlPoint1: NSPoint(x: cx - inner, y: cy + inner),
                    controlPoint2: NSPoint(x: cx - inner, y: cy + inner))

        path.fill()

        image.unlockFocus()
        return image
    }
}
