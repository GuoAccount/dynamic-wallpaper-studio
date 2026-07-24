import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct DashboardView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    @ObservedObject private var energySaver = EnergySaverManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var presets: [WallpaperItem] = WallpaperItem.presets
    
    public init() {}

    public var body: some View {
        ZStack {
            // Dark Frosted Glass Background
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Bar
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 14)
                
                Divider().background(Color.white.opacity(0.15))
                
                // Tab Picker
                Picker("", selection: $selectedTab) {
                    Text("🖼️ 壁纸画廊").tag(0)
                    Text("⚡️ 低功耗与性能").tag(1)
                    Text("🖥️ 多显示器配置").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                // Tab Content
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            galleryView
                        } else if selectedTab == 1 {
                            performanceView
                        } else {
                            displaysView
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 760, height: 520)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles.tv.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.6), radius: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Dynamic Wallpaper Studio")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(energySaver.isPaused ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(energySaver.isPaused ? "休眠中: \(energySaver.pauseReason)" : "运行中: \(energySaver.targetFPS) FPS (极低开销)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Button(action: importLocalFile) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("导入本地视频/网页")
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.blue))
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Gallery View
    private var galleryView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("预设动态壁纸库")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(presets) { item in
                    WallpaperCard(
                        item: item,
                        isSelected: wallpaperManager.currentWallpaper.id == item.id
                    ) {
                        wallpaperManager.currentWallpaper = item
                    }
                }
            }
        }
    }
    
    // MARK: - Performance & Energy View
    private var performanceView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("⚡️ 0% 功耗智能策略控制")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text("通过自动全屏检测与硬件硬解码，保障 Mac 最佳电池续航与极温表现。")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Toggle(isOn: $energySaver.pauseOnFullscreen) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🎮 全屏应用/游戏自动暂停 (推荐开启)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("检测到全屏视频、全屏游戏或编辑器时，完全冻结壁纸，GPU/CPU 占用降至 0%")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
                
                Divider().background(Color.white.opacity(0.1))
                
                Toggle(isOn: $energySaver.lowerFPSOnBattery) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🔋 电池供电自动降帧 (60 -> 30 FPS)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("当拔掉电源切至电池供电时，自动限制渲染上限以节省功耗")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
                
                Divider().background(Color.white.opacity(0.1))
                
                Toggle(isOn: $energySaver.pauseOnBattery) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🪫 低电量模式完全暂停壁纸")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("仅在电源模式下播放，电池状态完全挂起")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .cyan))

                Divider().background(Color.white.opacity(0.1))
                
                Toggle(isOn: $wallpaperManager.isAudioMuted) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🔇 视频静音 (节省音频解码器 CPU 开销)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.3)))
        }
    }
    
    // MARK: - Displays View
    private var displaysView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("🖥️ 已检测到的屏幕")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(NSScreen.screens, id: \.self) { screen in
                HStack {
                    Image(systemName: "display")
                        .font(.title2)
                        .foregroundColor(.cyan)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(screen.localizedName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("分辨率: \(Int(screen.frame.width)) x \(Int(screen.frame.height))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("已应用: \(wallpaperManager.currentWallpaper.title)")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.15)))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.06)))
            }
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
                    subtitle: "本地网页壁纸",
                    type: .web,
                    url: url
                )
            } else {
                newItem = WallpaperItem(
                    title: url.deletingPathExtension().lastPathComponent,
                    subtitle: "本地高清视频壁纸",
                    type: .video,
                    url: url
                )
            }
            presets.insert(newItem, at: 0)
            wallpaperManager.currentWallpaper = newItem
        }
    }
}

// MARK: - Subviews & Visual Effects
struct WallpaperCard: View {
    let item: WallpaperItem
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(cardGradient(for: item))
                        .frame(height: 110)
                    
                    Image(systemName: iconName(for: item))
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.4), radius: 4)
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
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
    
    private func cardGradient(for item: WallpaperItem) -> LinearGradient {
        switch item.proceduralStyle {
        case .cosmicNebula:
            return LinearGradient(colors: [.indigo, .purple, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .matrixRain:
            return LinearGradient(colors: [Color.black, Color(red: 0, green: 0.3, blue: 0.1)], startPoint: .top, endPoint: .bottom)
        case .cyberGrid:
            return LinearGradient(colors: [.pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .minimalClock:
            return LinearGradient(colors: [.blue, .cyan, .black], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.gray.opacity(0.4), .black], startPoint: .top, endPoint: .bottom)
        }
    }
}

public struct VisualEffectBlur: NSViewRepresentable {
    public var material: NSVisualEffectView.Material
    public var blendingMode: NSVisualEffectView.BlendingMode
    
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
