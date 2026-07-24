import SwiftUI

// MARK: - 1. Cosmic Nebula Particle View
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
    
    @State private var stars: [Star] = (0..<120).map { _ in
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
                // Dark cosmic background
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .color(Color(red: 0.05, green: 0.05, blue: 0.12)))
                
                // Draw Ambient Nebulas
                let centerPoint = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                var nebulaPath = Path()
                nebulaPath.addEllipse(in: CGRect(x: size.width * 0.2, y: size.height * 0.2, width: size.width * 0.6, height: size.height * 0.6))
                context.fill(nebulaPath, with: .radialGradient(
                    Gradient(colors: [Color.purple.opacity(0.25), Color.blue.opacity(0.15), Color.clear]),
                    center: centerPoint,
                    startRadius: 0,
                    endRadius: size.width * 0.4
                ))
                
                // Render Stars
                for star in stars {
                    let posX = star.x * size.width
                    let posY = star.y * size.height
                    let rect = CGRect(x: posX, y: posY, width: star.radius * 2, height: star.radius * 2)
                    let starColor = Color(hue: star.hue, saturation: 0.7, brightness: 0.95, opacity: star.opacity)
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

// MARK: - 2. Matrix Rain Code View
public struct MatrixRainView: View {
    public let isPaused: Bool
    public let targetFPS: Int
    
    public init(isPaused: Bool = false, targetFPS: Int = 60) {
        self.isPaused = isPaused
        self.targetFPS = targetFPS
    }
    
    struct MatrixColumn: Identifiable {
        let id = UUID()
        var x: Double // ratio 0...1
        var y: Double // ratio 0...1
        var speed: Double
        var chars: [Character]
    }
    
    private static let sampleChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$#@%&*アイウエオカキクケコサシスセソ")
    
    @State private var columns: [MatrixColumn] = (0..<45).map { i in
        MatrixColumn(
            x: Double(i) / 45.0,
            y: Double.random(in: -1.0...0),
            speed: Double.random(in: 0.008...0.02),
            chars: (0..<15).map { _ in sampleChars.randomElement()! }
        )
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 999999 : (1.0 / Double(targetFPS)))) { timeline in
            Canvas { context, size in
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .color(Color(red: 0.02, green: 0.03, blue: 0.02)))
                
                for col in columns {
                    let colX = col.x * size.width
                    for (idx, char) in col.chars.enumerated() {
                        let charY = (col.y * size.height) + Double(idx * 22)
                        guard charY >= 0 && charY <= size.height else { continue }
                        
                        let opacity = idx == 0 ? 1.0 : (1.0 - Double(idx) / Double(col.chars.count))
                        let charColor = idx == 0 ? Color.white : Color(red: 0.1, green: 0.95, blue: 0.3, opacity: opacity)
                        
                        let resolved = context.resolve(Text(String(char)).font(.system(size: 18, weight: .bold, design: .monospaced)).foregroundColor(charColor))
                        context.draw(resolved, at: CGPoint(x: colX, y: charY))
                    }
                }
            }
            .onChange(of: timeline.date) { _, _ in
                if !isPaused {
                    updateMatrix()
                }
            }
        }
    }
    
    private func updateMatrix() {
        for i in columns.indices {
            columns[i].y += columns[i].speed
            if columns[i].y > 1.2 {
                columns[i].y = -0.3
                columns[i].chars = (0..<15).map { _ in Self.sampleChars.randomElement()! }
            }
        }
    }
}

// MARK: - 3. Cyberpunk Grid View
public struct CyberGridView: View {
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
                context.fill(Path(bgRect), with: .color(Color(red: 0.05, green: 0.02, blue: 0.09)))
                
                // Neon Horizon Sun Glow
                let horizonY = size.height * 0.55
                let sunRect = CGRect(x: size.width * 0.5 - 120, y: horizonY - 120, width: 240, height: 240)
                context.fill(Path(ellipseIn: sunRect), with: .radialGradient(
                    Gradient(colors: [Color.pink.opacity(0.9), Color.orange.opacity(0.6), Color.clear]),
                    center: CGPoint(x: size.width * 0.5, y: horizonY),
                    startRadius: 10,
                    endRadius: 160
                ))
                
                // Perspective Grid Lines
                var gridPath = Path()
                let numVertical = 20
                for i in 0...numVertical {
                    let ratio = Double(i) / Double(numVertical)
                    let startX = size.width * ratio
                    gridPath.move(to: CGPoint(x: size.width * 0.5 + (startX - size.width * 0.5) * 0.1, y: horizonY))
                    gridPath.addLine(to: CGPoint(x: startX, y: size.height))
                }
                
                // Horizontal moving lines
                let numHorizontal = 15
                for i in 0..<numHorizontal {
                    let progress = (Double(i) + offset).truncatingRemainder(dividingBy: Double(numHorizontal)) / Double(numHorizontal)
                    let lineY = horizonY + pow(progress, 2.2) * (size.height - horizonY)
                    gridPath.move(to: CGPoint(x: 0, y: lineY))
                    gridPath.addLine(to: CGPoint(x: size.width, y: lineY))
                }
                
                context.stroke(gridPath, with: .color(Color.cyan.opacity(0.7)), lineWidth: 1.5)
            }
            .onChange(of: timeline.date) { _, _ in
                if !isPaused {
                    offset += 0.05
                }
            }
        }
    }
}

// MARK: - 4. Minimal Clock & Ambient Wallpaper
public struct MinimalClockView: View {
    public let isPaused: Bool
    
    public init(isPaused: Bool = false) {
        self.isPaused = isPaused
    }
    
    @State private var currentTime = Date()

    public var body: some View {
        TimelineView(.periodic(from: .now, by: isPaused ? 60 : 1.0)) { _ in
            ZStack {
                // Animated Soft Ambient Background
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.12, blue: 0.22),
                        Color(red: 0.15, green: 0.08, blue: 0.20),
                        Color(red: 0.05, green: 0.06, blue: 0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Ambient Glow Ring
                Circle()
                    .fill(RadialGradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1), Color.clear], center: .center, startRadius: 20, endRadius: 300))
                    .frame(width: 600, height: 600)
                
                // Elegant Clock Display
                VStack(spacing: 8) {
                    Text(timeFormatter.string(from: currentTime))
                        .font(.system(size: 88, weight: .thin, design: .rounded))
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 4)
                    
                    Text(dateFormatter.string(from: currentTime))
                        .font(.system(size: 22, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(3)
                }
            }
            .onAppear {
                currentTime = Date()
            }
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if !isPaused {
                        currentTime = Date()
                    }
                }
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
