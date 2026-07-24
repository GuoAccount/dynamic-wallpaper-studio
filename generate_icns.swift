import AppKit
import CoreGraphics

func createMinimalAppleIcon() -> NSImage {
    let size: CGFloat = 1024
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        img.unlockFocus()
        return img
    }
    
    // 1. Draw Apple macOS Squircle Path (Superellipse)
    let margin: CGFloat = size * 0.08
    let iconSize = size - margin * 2
    let iconRect = CGRect(x: margin, y: margin, width: iconSize, height: iconSize)
    let cornerRadius = iconSize * 0.225
    
    let path = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // Shadow under the squircle
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -size * 0.03), blur: size * 0.05, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.24, alpha: 1.0).set()
    path.fill()
    ctx.restoreGState()
    
    // 2. Background Gradient (Deep Royal Blue to Sapphire Indigo)
    path.addClip()
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        NSColor(calibratedRed: 0.12, green: 0.18, blue: 0.38, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.05, green: 0.07, blue: 0.18, alpha: 1.0).cgColor
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: margin, y: margin + iconSize), end: CGPoint(x: margin + iconSize, y: margin), options: [])
    
    // 3. Subtle Ambient Fluid Light Wave in Background
    let wavePath = CGMutablePath()
    wavePath.move(to: CGPoint(x: margin, y: margin + iconSize * 0.3))
    wavePath.addCurve(
        to: CGPoint(x: margin + iconSize, y: margin + iconSize * 0.7),
        control1: CGPoint(x: margin + iconSize * 0.4, y: margin + iconSize * 0.85),
        control2: CGPoint(x: margin + iconSize * 0.7, y: margin + iconSize * 0.15)
    )
    wavePath.addLine(to: CGPoint(x: margin + iconSize, y: margin))
    wavePath.addLine(to: CGPoint(x: margin, y: margin))
    wavePath.closeSubpath()
    
    ctx.saveGState()
    let waveColors = [
        NSColor(calibratedRed: 0.2, green: 0.45, blue: 0.9, alpha: 0.4).cgColor,
        NSColor(calibratedRed: 0.5, green: 0.2, blue: 0.8, alpha: 0.1).cgColor
    ] as CFArray
    let waveGradient = CGGradient(colorsSpace: colorSpace, colors: waveColors, locations: [0.0, 1.0])!
    ctx.addPath(wavePath)
    ctx.clip()
    ctx.drawLinearGradient(waveGradient, start: CGPoint(x: margin, y: margin + iconSize), end: CGPoint(x: margin + iconSize, y: margin), options: [])
    ctx.restoreGState()
    
    // 4. Inner Subtle Border Glow
    let borderPath = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    borderPath.lineWidth = size * 0.008
    NSColor.white.withAlphaComponent(0.2).setStroke()
    borderPath.stroke()
    
    // 5. Minimalist Screen Emblem (Clean Silver Line-Art Monitor)
    let screenW = iconSize * 0.52
    let screenH = iconSize * 0.34
    let screenX = margin + (iconSize - screenW) * 0.5
    let screenY = margin + iconSize * 0.4
    let screenRect = CGRect(x: screenX, y: screenY, width: screenW, height: screenH)
    
    // Monitor Frame
    let screenPath = NSBezierPath(roundedRect: screenRect, xRadius: size * 0.025, yRadius: size * 0.025)
    screenPath.lineWidth = size * 0.016
    NSColor.white.withAlphaComponent(0.95).setStroke()
    screenPath.stroke()
    
    // Monitor Stand Base
    let standW = iconSize * 0.18
    let standH = size * 0.016
    let standX = margin + (iconSize - standW) * 0.5
    let standY = screenY - size * 0.05
    let standPath = NSBezierPath(roundedRect: CGRect(x: standX, y: standY, width: standW, height: standH), xRadius: 2, yRadius: 2)
    NSColor.white.withAlphaComponent(0.85).setFill()
    standPath.fill()
    
    // Monitor Neck
    let neckW = size * 0.02
    let neckH = size * 0.04
    let neckX = margin + (iconSize - neckW) * 0.5
    let neckY = standY + standH
    let neckRect = CGRect(x: neckX, y: neckY, width: neckW, height: neckH)
    NSColor.white.withAlphaComponent(0.7).setFill()
    NSBezierPath(rect: neckRect).fill()
    
    // Glowing Iridescent Wave inside Monitor Screen
    ctx.saveGState()
    screenPath.addClip()
    let innerColors = [
        NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.95, alpha: 0.9).cgColor,
        NSColor(calibratedRed: 0.6, green: 0.3, blue: 0.95, alpha: 0.9).cgColor
    ] as CFArray
    let innerGrad = CGGradient(colorsSpace: colorSpace, colors: innerColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(innerGrad, start: CGPoint(x: screenX, y: screenY + screenH), end: CGPoint(x: screenX + screenW, y: screenY), options: [])
    
    // Sparkling star in center of screen
    let starCenter = CGPoint(x: screenX + screenW * 0.5, y: screenY + screenH * 0.5)
    let starPath = NSBezierPath()
    let r1 = size * 0.045
    let r2 = size * 0.012
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
let image = createMinimalAppleIcon()
guard let tiffData = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiffData),
      let pngData = rep.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode PNG")
}

let fm = FileManager.default
let iconsetDir = URL(fileURLWithPath: "AppIcon.iconset")
try? fm.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

// Save 1024x1024 base PNG
let masterURL = iconsetDir.appendingPathComponent("icon_512x512@2x.png")
try? pngData.write(to: masterURL)

print("Master 1024x1024 PNG created successfully!")
