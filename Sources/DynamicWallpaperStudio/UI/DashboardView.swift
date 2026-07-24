import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Liquid Glass Visual Effect Blur View (macOS Liquid Material)
public struct LiquidGlassBlurView: NSViewRepresentable {
    public var material: NSVisualEffectView.Material
    public var blendingMode: NSVisualEffectView.BlendingMode
    
    public init(material: NSVisualEffectView.Material = .hudWindow, blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Main Dashboard View (Apple Liquid Glass Design Language)
public struct DashboardView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    @ObservedObject private var energySaver = EnergySaverManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedTab = 0
    @State private var presets: [WallpaperItem] = WallpaperItem.presets
    
    private let tabs = [
        ("photo.on.rectangle.angled", "壁纸画廊"),
        ("bolt.shield.fill", "低功耗与性能"),
        ("display", "多显示器"),
        ("info.circle.fill", "关于应用")
    ]

    public init() {}

    public var body: some View {
        ZStack {
            // Liquid Glass Translucent Window Background
            LiquidGlassBlurView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            // Ambient Liquid Aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.15), Color.purple.opacity(0.12), Color.clear],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 400
                    )
                )
                .blur(radius: 30)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Liquid Glass Segmented Navigation Bar
                liquidGlassHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                
                Divider()
                    .opacity(0.2)
                
                // Tab Detail Views
                Group {
                    switch selectedTab {
                    case 0:
                        LiquidGalleryTabView()
                    case 1:
                        LiquidPerformanceTabView()
                    case 2:
                        LiquidDisplaysTabView()
                    default:
                        LiquidAboutTabView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .opacity(0.2)
                
                // Bottom Liquid Glass Status Bar
                liquidGlassFooter
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: 720, height: 490)
    }
    
    // MARK: - Liquid Glass Header Bar
    private var liquidGlassHeader: some View {
        HStack {
            // App Branding Title
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Dynamic Wallpaper")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Liquid Glass Floating Tab Segmented Control
            HStack(spacing: 4) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    let isSelected = selectedTab == index
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = index
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tabs[index].0)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tabs[index].1)
                                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            ZStack {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.accentColor.opacity(0.85))
                                        .shadow(color: Color.accentColor.opacity(0.3), radius: 4, y: 2)
                                }
                            }
                        )
                        .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                    )
            )
        }
    }
    
    // MARK: - Liquid Glass Footer
    private var liquidGlassFooter: some View {
        HStack {
            // Live Status Capsule Badge
            HStack(spacing: 6) {
                Circle()
                    .fill(energySaver.isPaused ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                    .shadow(color: (energySaver.isPaused ? Color.orange : Color.green).opacity(0.8), radius: 4)
                
                Text(energySaver.isPaused ? "引擎已休眠 (\(energySaver.pauseReason))" : "引擎极速运行 (\(energySaver.targetFPS) FPS - 0% 全屏开销)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.05))
                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.5))
            )
            
            Spacer()
            
            // Liquid Import Button
            Button(action: importLocalFile) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                    Text("导入壁纸...")
                }
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: .blue.opacity(0.3), radius: 6, y: 2)
                )
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func importLocalFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [
            UTType.movie,
            UTType.mpeg4Movie,
            UTType.quickTimeMovie,
            UTType.html
        ]
        
        if panel.runModal() == .OK, let url = panel.url {
            let newItem: WallpaperItem
            if url.pathExtension.lowercased() == "html" || url.pathExtension.lowercased() == "htm" {
                newItem = WallpaperItem(
                    title: url.deletingPathExtension().lastPathComponent,
                    subtitle: "自定义 HTML 网页",
                    type: .web,
                    url: url,
                    isPreset: false
                )
            } else {
                newItem = WallpaperItem(
                    title: url.deletingPathExtension().lastPathComponent,
                    subtitle: "自定义 HD 视频",
                    type: .video,
                    url: url,
                    isPreset: false
                )
            }
            wallpaperManager.addCustomWallpaper(newItem)
        }
    }
}

// MARK: - Liquid Gallery Tab (Fluid Glass Cards)
struct LiquidGalleryTabView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(wallpaperManager.allWallpapers) { item in
                    let isSelected = wallpaperManager.currentWallpaper.id == item.id
                    
                    ZStack(alignment: .topTrailing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                wallpaperManager.currentWallpaper = item
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(liquidGradient(for: item))
                                        .frame(height: 110)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                        )
                                    
                                    Image(systemName: iconName(for: item))
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 6)
                                    
                                    if isSelected {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.white)
                                                        .frame(width: 22, height: 22)
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(.blue)
                                                }
                                                .padding(6)
                                            }
                                            Spacer()
                                        }
                                    }
                                    
                                    if !item.isPreset {
                                        VStack {
                                            HStack {
                                                Text("自定义")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Capsule().fill(Color.blue))
                                                    .foregroundColor(.white)
                                                    .padding(6)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(item.subtitle)
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 0.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            if !item.isPreset {
                                Button(role: .destructive) {
                                    withAnimation {
                                        wallpaperManager.deleteWallpaper(item)
                                    }
                                } label: {
                                    Label("删除壁纸", systemImage: "trash")
                                }
                            }
                        }
                        
                        if !item.isPreset {
                            Button {
                                withAnimation {
                                    wallpaperManager.deleteWallpaper(item)
                                }
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                    .background(Circle().fill(Color.white))
                                    .shadow(radius: 2)
                            }
                            .buttonStyle(.plain)
                            .padding(4)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
    
    private func iconName(for item: WallpaperItem) -> String {
        switch item.type {
        case .procedural:
            switch item.proceduralStyle {
            case .cosmicNebula: return "sparkles"
            case .auroraFlow: return "wind"
            case .ambientBokeh: return "sun.max.fill"
            case .cyberGlow: return "horizon.fill"
            case .minimalClock: return "clock.fill"
            case .none: return "wand.and.stars"
            }
        case .video: return "play.rectangle.fill"
        case .web: return "globe"
        }
    }
    
    private func liquidGradient(for item: WallpaperItem) -> LinearGradient {
        switch item.proceduralStyle {
        case .cosmicNebula:
            return LinearGradient(colors: [Color(red: 0.3, green: 0.15, blue: 0.6), Color(red: 0.1, green: 0.05, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .auroraFlow:
            return LinearGradient(colors: [Color(red: 0.05, green: 0.45, blue: 0.35), Color(red: 0.02, green: 0.15, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ambientBokeh:
            return LinearGradient(colors: [Color(red: 0.15, green: 0.25, blue: 0.5), Color(red: 0.25, green: 0.1, blue: 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cyberGlow:
            return LinearGradient(colors: [Color.pink.opacity(0.8), Color.purple.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .minimalClock:
            return LinearGradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.05, green: 0.1, blue: 0.25)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Liquid Performance Tab (Glass Grouped Form)
struct LiquidPerformanceTabView: View {
    @ObservedObject private var energySaver = EnergySaverManager.shared
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    var body: some View {
        Form {
            Section("智能休眠与节能策略") {
                Toggle(isOn: $energySaver.pauseOnFullscreen) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("全屏应用/游戏自动暂停")
                            .font(.system(size: 13, weight: .medium))
                        Text("全屏视频、全屏游戏或 IDE 激活时自动冻结壁纸，实现 0% CPU/GPU 占用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: $energySaver.lowerFPSOnBattery) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("电池供电自动降帧 (60 ➔ 30 FPS)")
                            .font(.system(size: 13, weight: .medium))
                        Text("未连接电源时限制最大帧率，节省电池电量")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: $energySaver.pauseOnBattery) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("低电量模式完全暂停壁纸")
                            .font(.system(size: 13, weight: .medium))
                        Text("电池进入低电量模式时暂停所有动画")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("声音与解码") {
                Toggle("视频全局静音 (降低 CPU 音频解码开销)", isOn: $wallpaperManager.isAudioMuted)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Liquid Displays Tab
struct LiquidDisplaysTabView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    var body: some View {
        Form {
            Section("显示设备管理") {
                ForEach(NSScreen.screens, id: \.self) { screen in
                    LabeledContent {
                        Text("已应用: \(wallpaperManager.currentWallpaper.title)")
                            .foregroundColor(.secondary)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "display")
                                .foregroundColor(.accentColor)
                            Text(screen.localizedName)
                                .font(.system(size: 13, weight: .medium))
                            Text("(\(Int(screen.frame.width))×\(Int(screen.frame.height)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Apple Minimalist Logo View
public struct AppleMinimalLogoView: View {
    var size: CGFloat = 64
    
    public init(size: CGFloat = 64) {
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.16, blue: 0.32),
                            Color(red: 0.06, green: 0.08, blue: 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.12), radius: size * 0.08, x: 0, y: size * 0.04)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            
            // Minimalist Display Frame with Sparkles
            VStack(spacing: size * 0.03) {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.85), Color.purple.opacity(0.85), Color.blue.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.52, height: size * 0.34)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.2, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.4))
                    .frame(width: size * 0.18, height: size * 0.03)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Liquid About Tab
struct LiquidAboutTabView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            
            AppleMinimalLogoView(size: 84)
            
            VStack(spacing: 4) {
                Text("Dynamic Wallpaper Studio")
                    .font(.title2.bold())
                
                Text("版本 1.0.0 (Liquid Glass Edition)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("专为 macOS 打造的高性能低功耗动态壁纸工具\n全面融入 Apple 液态玻璃 (Liquid Glass) 设计语言")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
