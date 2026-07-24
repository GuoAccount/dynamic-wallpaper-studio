import AppKit
import CoreGraphics

func createEdgeToEdgeMinimalAppleIcon() -> NSImage {
    let size: CGFloat = 1024
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        img.unlockFocus()
        return img
    }
    
    let bounds = CGRect(x: 0, y: 0, width: size, height: size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // 1. Edge-to-Edge Corner Clipping (macOS App Icon squircle format)
    let cornerRadius = size * 0.225
    let clipPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
    clipPath.addClip()
    
    // 2. Full Background Gradient (Deep Royal Blue to Sapphire Midnight)
    let bgColors = [
        NSColor(calibratedRed: 0.12, green: 0.18, blue: 0.42, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.04, green: 0.06, blue: 0.16, alpha: 1.0).cgColor
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])
    
    // 3. Elegant Ambient Light Fluid Wave across canvas
    let wavePath = CGMutablePath()
    wavePath.move(to: CGPoint(x: 0, y: size * 0.35))
    wavePath.addCurve(
        to: CGPoint(x: size, y: size * 0.75),
        control1: CGPoint(x: size * 0.4, y: size * 0.9),
        control2: CGPoint(x: size * 0.7, y: size * 0.2)
    )
    wavePath.addLine(to: CGPoint(x: size, y: 0))
    wavePath.addLine(to: CGPoint(x: 0, y: 0))
    wavePath.closeSubpath()
    
    ctx.saveGState()
    let waveColors = [
        NSColor(calibratedRed: 0.2, green: 0.5, blue: 0.95, alpha: 0.45).cgColor,
        NSColor(calibratedRed: 0.6, green: 0.25, blue: 0.9, alpha: 0.1).cgColor
    ] as CFArray
    let waveGradient = CGGradient(colorsSpace: colorSpace, colors: waveColors, locations: [0.0, 1.0])!
    ctx.addPath(wavePath)
    ctx.clip()
    ctx.drawLinearGradient(waveGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])
    ctx.restoreGState()
    
    // 4. Subtle Inner Border Outline
    let borderPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), xRadius: cornerRadius, yRadius: cornerRadius)
    borderPath.lineWidth = 4
    NSColor.white.withAlphaComponent(0.18).setStroke()
    borderPath.stroke()
    
    // 5. Minimalist Display Frame (Centered)
    let screenW: CGFloat = 560
    let screenH: CGFloat = 360
    let screenX = (size - screenW) * 0.5
    let screenY = size * 0.36
    let screenRect = CGRect(x: screenX, y: screenY, width: screenW, height: screenH)
    
    // Screen Outer Silver Frame
    let screenPath = NSBezierPath(roundedRect: screenRect, xRadius: 28, yRadius: 28)
    screenPath.lineWidth = 18
    NSColor.white.withAlphaComponent(0.95).setStroke()
    screenPath.stroke()
    
    // Screen Stand Base
    let standW: CGFloat = 200
    let standH: CGFloat = 18
    let standX = (size - standW) * 0.5
    let standY = screenY - 48
    let standPath = NSBezierPath(roundedRect: CGRect(x: standX, y: standY, width: standW, height: standH), xRadius: 4, yRadius: 4)
    NSColor.white.withAlphaComponent(0.85).setFill()
    standPath.fill()
    
    // Screen Neck
    let neckW: CGFloat = 24
    let neckH: CGFloat = 42
    let neckX = (size - neckW) * 0.5
    let neckY = standY + standH
    NSColor.white.withAlphaComponent(0.7).setFill()
    NSBezierPath(rect: CGRect(x: neckX, y: neckY, width: neckW, height: neckH)).fill()
    
    // Glowing Gradient Fill inside Display Screen
    ctx.saveGState()
    screenPath.addClip()
    let innerColors = [
        NSColor(calibratedRed: 0.1, green: 0.82, blue: 0.98, alpha: 0.95).cgColor,
        NSColor(calibratedRed: 0.65, green: 0.3, blue: 0.98, alpha: 0.95).cgColor
    ] as CFArray
    let innerGrad = CGGradient(colorsSpace: colorSpace, colors: innerColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(innerGrad, start: CGPoint(x: screenX, y: screenY + screenH), end: CGPoint(x: screenX + screenW, y: screenY), options: [])
    
    // Minimal Sparkle Star in Display Center
    let starCenter = CGPoint(x: screenX + screenW * 0.5, y: screenY + screenH * 0.5)
    let starPath = NSBezierPath()
    let r1: CGFloat = 46
    let r2: CGFloat = 12
    for i in 0..<8 {
        let angle = CGFloat(i) * .pi / 4.0
        let r = (i % 2 == 0) ? r1 : r2
        let pt = CGPoint(x: starCenter.x + r * cos(angle), y: starCenter.y + r * sin(angle))
        if i == 0 { starPath.move(to: pt) } else { starPath.line(to: pt) }
    }
    starPath.close()
    NSColor.white.setFill()
    starPath.fill()
    
    ctx.restoreGState()
    
    img.unlockFocus()
    return img
}

// Generate image & save PNG
let image = createEdgeToEdgeMinimalAppleIcon()
guard let tiffData = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiffData),
      let pngData = rep.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode PNG")
}

let fm = FileManager.default
let iconsetDir = URL(fileURLWithPath: "AppIcon.iconset")
try? fm.removeItem(at: iconsetDir)
try? fm.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

// Save 1024x1024 base PNG
let masterURL = iconsetDir.appendingPathComponent("icon_512x512@2x.png")
try? pngData.write(to: masterURL)

print("Edge-to-Edge Master 1024x1024 PNG created successfully!")
