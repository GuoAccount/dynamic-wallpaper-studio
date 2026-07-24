import SwiftUI

// MARK: - 1. Cosmic Nebula Particle View (浩瀚星云 - 60 FPS)
public struct CosmicNebulaView: View {
    public let isPaused: Bool
    public let targetFPS: Int
    
    public init(isPaused: Bool = false, targetFPS: Int = 60) {
        self.isPaused = isPaused
        self.targetFPS = targetFPS
    }
    
    struct Star: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var radius: Double
        var opacity: Double
        var speedX: Double
        var speedY: Double
        var hue: Double
    }
    
    @State private var stars: [Star] = (0..<100).map { _ in
        Star(
            x: Double.random(in: 0...1),
            y: Double.random(in: 0...1),
            radius: Double.random(in: 1...3.5),
            opacity: Double.random(in: 0.3...0.9),
            speedX: Double.random(in: -0.0003...0.0003),
            speedY: Double.random(in: -0.0005...0.0005),
            hue: Double.random(in: 0.55...0.85) // Blue to Purple
        )
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 999999 : (1.0 / Double(targetFPS)))) { timeline in
            Canvas { context, size in
                // Deep Midnight Cosmic Background
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .color(Color(red: 0.05, green: 0.05, blue: 0.12)))
                
                // Ambient Radial Nebulas
                let centerPoint = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                var nebulaPath = Path()
                nebulaPath.addEllipse(in: CGRect(x: size.width * 0.15, y: size.height * 0.15, width: size.width * 0.7, height: size.height * 0.7))
                context.fill(nebulaPath, with: .radialGradient(
                    Gradient(colors: [Color.purple.opacity(0.28), Color.blue.opacity(0.18), Color.clear]),
                    center: centerPoint,
                    startRadius: 0,
                    endRadius: size.width * 0.45
                ))
                
                // Render Stars
                for star in stars {
                    let posX = star.x * size.width
                    let posY = star.y * size.height
                    let rect = CGRect(x: posX, y: posY, width: star.radius * 2, height: star.radius * 2)
                    let starColor = Color(hue: star.hue, saturation: 0.75, brightness: 0.95, opacity: star.opacity)
                    context.fill(Path(ellipseIn: rect), with: .color(starColor))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                if !isPaused {
                    updateStars()
                }
            }
        }
    }
    
    private func updateStars() {
        for i in stars.indices {
            stars[i].x += stars[i].speedX
            stars[i].y += stars[i].speedY
            if stars[i].x < 0 { stars[i].x = 1.0 }
            if stars[i].x > 1.0 { stars[i].x = 0.0 }
            if stars[i].y < 0 { stars[i].y = 1.0 }
            if stars[i].y > 1.0 { stars[i].y = 0.0 }
        }
    }
}

// MARK: - 2. Aurora Flow View (极光流彩 - 60 FPS Butter Smooth)
public struct AuroraFlowView: View {
    public let isPaused: Bool
    public let targetFPS: Int
    
    public init(isPaused: Bool = false, targetFPS: Int = 60) {
        self.isPaused = isPaused
        self.targetFPS = targetFPS
    }
    
    @State private var phase: Double = 0.0
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 999999 : (1.0 / Double(targetFPS)))) { timeline in
            Canvas { context, size in
                // Night Sky Gradient
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .color(Color(red: 0.03, green: 0.06, blue: 0.12)))
                
                // Fluid Aurora Ribbons
                let h = size.height
                let w = size.width
                
                for i in 0..<3 {
                    var path = Path()
                    let shift = phase + Double(i) * 1.5
                    let yOffset = h * (0.3 + Double(i) * 0.15)
                    
                    path.move(to: CGPoint(x: 0, y: yOffset + sin(shift) * 40))
                    path.addCurve(
                        to: CGPoint(x: w, y: yOffset + cos(shift * 0.8) * 50),
                        control1: CGPoint(x: w * 0.35, y: yOffset - sin(shift * 1.2) * 90),
                        control2: CGPoint(x: w * 0.7, y: yOffset + cos(shift * 1.1) * 80)
                    )
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                    
                    let colors: [Color] = i == 0 ?
                        [Color.teal.opacity(0.35), Color.green.opacity(0.1), Color.clear] :
                        [Color.purple.opacity(0.3), Color.blue.opacity(0.1), Color.clear]
                    
                    context.fill(path, with: .linearGradient(
                        Gradient(colors: colors),
                        startPoint: CGPoint(x: 0, y: yOffset - 50),
                        endPoint: CGPoint(x: 0, y: h)
                    ))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                if !isPaused {
                    phase += 0.008
                }
            }
        }
    }
}

// MARK: - 3. Ambient Bokeh View (极简光斑 - 60 FPS Calm & Relaxing)
public struct AmbientBokehView: View {
    public let isPaused: Bool
    public let targetFPS: Int
    
    public init(isPaused: Bool = false, targetFPS: Int = 60) {
        self.isPaused = isPaused
        self.targetFPS = targetFPS
    }
    
    struct Orb: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var radius: Double
        var speedX: Double
        var speedY: Double
        var hue: Double
        var opacity: Double
    }
    
    @State private var orbs: [Orb] = (0..<18).map { _ in
        Orb(
            x: Double.random(in: 0.1...0.9),
            y: Double.random(in: 0.1...0.9),
            radius: Double.random(in: 80...220),
            speedX: Double.random(in: -0.0002...0.0002),
            speedY: Double.random(in: -0.0003...0.0003),
            hue: Double.random(in: 0.5...0.8), // Cyan to Purple
            opacity: Double.random(in: 0.12...0.25)
        )
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 999999 : (1.0 / Double(targetFPS)))) { timeline in
            Canvas { context, size in
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .color(Color(red: 0.04, green: 0.05, blue: 0.09)))
                
                for orb in orbs {
                    let center = CGPoint(x: orb.x * size.width, y: orb.y * size.height)
                    let rect = CGRect(x: center.x - orb.radius, y: center.y - orb.radius, width: orb.radius * 2, height: orb.radius * 2)
                    let orbColor = Color(hue: orb.hue, saturation: 0.8, brightness: 0.9, opacity: orb.opacity)
                    
                    context.fill(Path(ellipseIn: rect), with: .radialGradient(
                        Gradient(colors: [orbColor, orbColor.opacity(0.3), Color.clear]),
                        center: center,
                        startRadius: 0,
                        endRadius: orb.radius
                    ))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                if !isPaused {
                    updateOrbs()
                }
            }
        }
    }
    
    private func updateOrbs() {
        for i in orbs.indices {
            orbs[i].x += orbs[i].speedX
            orbs[i].y += orbs[i].speedY
            if orbs[i].x < 0.05 || orbs[i].x > 0.95 { orbs[i].speedX *= -1 }
            if orbs[i].y < 0.05 || orbs[i].y > 0.95 { orbs[i].speedY *= -1 }
        }
    }
}

// MARK: - 4. Cyber Glow View (赛博夜色 - 60 FPS Smooth)
public struct CyberGlowView: View {
    public let isPaused: Bool
    public let targetFPS: Int
    
    public init(isPaused: Bool = false, targetFPS: Int = 60) {
        self.isPaused = isPaused
        self.targetFPS = targetFPS
    }
    
    @State private var offset: Double = 0.0
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 999999 : (1.0 / Double(targetFPS)))) { timeline in
            Canvas { context, size in
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .color(Color(red: 0.06, green: 0.03, blue: 0.12)))
                
                // Horizon Neon Sun Aura
                let horizonY = size.height * 0.6
                let sunCenter = CGPoint(x: size.width * 0.5, y: horizonY)
                let sunRect = CGRect(x: sunCenter.x - 140, y: horizonY - 140, width: 280, height: 280)
                
                context.fill(Path(ellipseIn: sunRect), with: .radialGradient(
                    Gradient(colors: [Color.pink.opacity(0.85), Color.purple.opacity(0.5), Color.clear]),
                    center: sunCenter,
                    startRadius: 5,
                    endRadius: 180
                ))
                
                // Horizon Line
                var linePath = Path()
                linePath.move(to: CGPoint(x: 0, y: horizonY))
                linePath.addLine(to: CGPoint(x: size.width, y: horizonY))
                context.stroke(linePath, with: .color(Color.cyan.opacity(0.6)), lineWidth: 2)
            }
            .onChange(of: timeline.date) { _, _ in
                if !isPaused {
                    offset += 0.02
                }
            }
        }
    }
}

// MARK: - 5. Minimal Clock View (极简数字时钟 - 60 FPS)
public struct MinimalClockView: View {
    public let isPaused: Bool
    
    public init(isPaused: Bool = false) {
        self.isPaused = isPaused
    }
    
    @State private var currentTime = Date()

    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 60 : 1.0)) { _ in
            ZStack {
                // Soft Ambient Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.09, blue: 0.18),
                        Color(red: 0.12, green: 0.06, blue: 0.16),
                        Color(red: 0.04, green: 0.04, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Glowing Ambient Aura
                Circle()
                    .fill(RadialGradient(colors: [Color.cyan.opacity(0.18), Color.purple.opacity(0.1), Color.clear], center: .center, startRadius: 10, endRadius: 280))
                    .frame(width: 560, height: 560)
                
                // Clock Display
                VStack(spacing: 6) {
                    Text(timeFormatter.string(from: currentTime))
                        .font(.system(size: 84, weight: .thin, design: .rounded))
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(color: .cyan.opacity(0.4), radius: 16, x: 0, y: 2)
                    
                    Text(dateFormatter.string(from: currentTime))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(3)
                }
            }
            .onAppear {
                currentTime = Date()
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }
}
