import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Native macOS Preferences / Settings Window Style
public struct DashboardView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    @ObservedObject private var energySaver = EnergySaverManager.shared
    @State private var selectedTab = 0
    
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                // Tab 1: 壁纸画廊
                GalleryTabView()
                    .tabItem {
                        Label("壁纸画廊", systemImage: "photo.on.rectangle.angled")
                    }
                    .tag(0)
                
                // Tab 2: 低功耗与性能
                PerformanceTabView()
                    .tabItem {
                        Label("低功耗与性能", systemImage: "bolt.shield.fill")
                    }
                    .tag(1)
                
                // Tab 3: 多显示器配置
                DisplaysTabView()
                    .tabItem {
                        Label("多显示器", systemImage: "display")
                    }
                    .tag(2)
                
                // Tab 4: 关于应用
                AboutTabView()
                    .tabItem {
                        Label("关于", systemImage: "info.circle.fill")
                    }
                    .tag(3)
            }
            .padding(16)
            
            Divider()
            
            // Native macOS Bottom Status Bar
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(energySaver.isPaused ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(energySaver.isPaused ? "引擎已休眠 (\(energySaver.pauseReason))" : "引擎运行中 (\(energySaver.targetFPS) FPS - 0% 额外功耗)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: importLocalFile) {
                    Label("导入壁纸...", systemImage: "plus")
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 680, height: 460)
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

// MARK: - Tab 1: Gallery (Supports Deletion & Hover Actions)
struct GalleryTabView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(wallpaperManager.allWallpapers) { item in
                    let isSelected = wallpaperManager.currentWallpaper.id == item.id
                    
                    ZStack(alignment: .topTrailing) {
                        Button {
                            wallpaperManager.currentWallpaper = item
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(cardPreviewColor(for: item))
                                        .frame(height: 100)
                                    
                                    Image(systemName: iconName(for: item))
                                        .font(.system(size: 28))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    if isSelected {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(.white)
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
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(item.title)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(item.subtitle)
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 2)
                            }
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.accentColor : Color(NSColor.separatorColor), lineWidth: isSelected ? 2 : 1)
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
                                    Label("删除自定义壁纸", systemImage: "trash")
                                }
                            }
                        }
                        
                        // Explicit Trash Icon Button for Custom Wallpapers
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
                            .help("删除此导入壁纸")
                        }
                    }
                }
            }
            .padding(4)
        }
    }
    
    private func iconName(for item: WallpaperItem) -> String {
        switch item.type {
        case .procedural:
            switch item.proceduralStyle {
            case .cosmicNebula: return "sparkles"
            case .matrixRain: return "terminal.fill"
            case .cyberGrid: return "grid"
            case .minimalClock: return "clock.fill"
            case .none: return "wand.and.stars"
            }
        case .video: return "play.rectangle.fill"
        case .web: return "globe"
        }
    }
    
    private func cardPreviewColor(for item: WallpaperItem) -> Color {
        switch item.proceduralStyle {
        case .cosmicNebula: return Color(red: 0.2, green: 0.1, blue: 0.35)
        case .matrixRain: return Color(red: 0.05, green: 0.25, blue: 0.1)
        case .cyberGrid: return Color(red: 0.3, green: 0.1, blue: 0.25)
        case .minimalClock: return Color(red: 0.1, green: 0.2, blue: 0.35)
        default: return Color(red: 0.15, green: 0.25, blue: 0.35)
        }
    }
}

// MARK: - Tab 2: Performance (Native Form)
struct PerformanceTabView: View {
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
    }
}

// MARK: - Tab 3: Displays (Native Form)
struct DisplaysTabView: View {
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

// MARK: - Tab 4: About
struct AboutTabView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            
            AppleMinimalLogoView(size: 80)
            
            VStack(spacing: 4) {
                Text("Dynamic Wallpaper Studio")
                    .font(.title2.bold())
                
                Text("版本 1.0.0 (macOS 原生首选)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("专为 macOS 打造的高性能低功耗动态壁纸工具\n支持 0% 功耗全屏挂起、视频与 GPU 粒子特效")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
