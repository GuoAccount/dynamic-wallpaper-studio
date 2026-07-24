import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Main Dashboard View (Apple System Settings Style)
public struct DashboardView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    @ObservedObject private var energySaver = EnergySaverManager.shared
    
    @State private var selectedTab: SidebarItem = .gallery
    @State private var presets: [WallpaperItem] = WallpaperItem.presets
    
    enum SidebarItem: String, CaseIterable, Identifiable {
        case gallery = "壁纸画廊"
        case performance = "低功耗与性能"
        case displays = "多显示器配置"
        case about = "关于应用"
        
        var id: String { rawValue }
        
        var iconName: String {
            switch self {
            case .gallery: return "photo.on.rectangle.angled"
            case .performance: return "bolt.shield.fill"
            case .displays: return "display"
            case .about: return "info.circle.fill"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .gallery: return .cyan
            case .performance: return .green
            case .displays: return .blue
            case .about: return .purple
            }
        }
    }
    
    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            // Left Sidebar
            sidebarView
                .frame(width: 220)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
            
            Divider()
                .opacity(0.4)
            
            // Right Content Detail View
            VStack(spacing: 0) {
                topNavigationBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                
                Divider()
                    .opacity(0.3)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedTab {
                        case .gallery:
                            galleryContentView
                        case .performance:
                            performanceContentView
                        case .displays:
                            displaysContentView
                        case .about:
                            aboutContentView
                        }
                    }
                    .padding(24)
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 780, minHeight: 520)
    }
    
    // MARK: - Left Sidebar
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // App Identity Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: "sparkles.tv.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("壁纸大师")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Dynamic Wallpaper")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 4)
            
            Divider()
                .padding(.horizontal, 12)
                .opacity(0.4)
            
            // Sidebar Menu Items List
            VStack(spacing: 4) {
                ForEach(SidebarItem.allCases) { item in
                    let isSelected = selectedTab == item
                    Button {
                        selectedTab = item
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? Color.white.opacity(0.2) : item.iconColor)
                                    .frame(width: 22, height: 22)
                                
                                Image(systemName: item.iconName)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(item.rawValue)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.accentColor : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            // Sidebar Footer Engine Live Status Pill
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(energySaver.isPaused ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(energySaver.isPaused ? "引擎已休眠" : "运行中: \(energySaver.targetFPS) FPS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Text(energySaver.pauseReason)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Text(selectedTab.rawValue)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: importLocalFile) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("导入本地视频/网页")
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor)
                )
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Gallery View Content
    private var galleryContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择并立即应用动态壁纸，支持视频、网页与原生特效。")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(presets) { item in
                    AppleStyleWallpaperCard(
                        item: item,
                        isSelected: wallpaperManager.currentWallpaper.id == item.id
                    ) {
                        wallpaperManager.currentWallpaper = item
                    }
                }
            }
        }
    }
    
    // MARK: - Performance & Energy View Content (Apple Grouped Card Style)
    private var performanceContentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("智能调节运行开销，确保全屏游戏与看剧时 0% 显卡/处理器占用。")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // System Settings Card Group
            VStack(spacing: 0) {
                ToggleRow(
                    title: "🎮 全屏应用/游戏自动暂停 (推荐)",
                    subtitle: "当游戏、视频或IDE全屏运行时，壁纸冻结，CPU/GPU占用降至 0%",
                    isOn: $energySaver.pauseOnFullscreen
                )
                
                Divider()
                    .padding(.leading, 16)
                
                ToggleRow(
                    title: "🔋 电池供电自动降帧 (60 ➔ 30 FPS)",
                    subtitle: "未连接电源时，限制渲染最大帧率以延长 Mac 续航",
                    isOn: $energySaver.lowerFPSOnBattery
                )
                
                Divider()
                    .padding(.leading, 16)
                
                ToggleRow(
                    title: "🪫 低电量模式完全暂停壁纸",
                    subtitle: "电池处于低电量模式时暂停所有壁纸渲染",
                    isOn: $energySaver.pauseOnBattery
                )
                
                Divider()
                    .padding(.leading, 16)
                
                ToggleRow(
                    title: "🔇 视频静音 (节省音频解码开销)",
                    subtitle: "完全关闭视频音频流，降低音频采样转化开销",
                    isOn: $wallpaperManager.isAudioMuted
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Displays View Content
    private var displaysContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("已检测到以下显示设备，壁纸引擎将自动全屏覆盖匹配。")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(NSScreen.screens, id: \.self) { screen in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 42, height: 42)
                            
                            Image(systemName: "display")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(screen.localizedName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("分辨率: \(Int(screen.frame.width)) × \(Int(screen.frame.height))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("当前壁纸: \(wallpaperManager.currentWallpaper.title)")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.primary.opacity(0.06))
                            )
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - About Content
    private var aboutContentView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles.tv.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            VStack(spacing: 4) {
                Text("Dynamic Wallpaper Studio")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("版本 1.0.0 (Build 1)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("专为 macOS 设计的极简低功耗动态壁纸引擎，支持视频、网页与原生 GPU 粒子特效。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
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

// MARK: - Apple Style Toggle Row
struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Apple Style Wallpaper Card
struct AppleStyleWallpaperCard: View {
    let item: WallpaperItem
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(cardGradient(for: item))
                        .frame(height: 120)
                    
                    Image(systemName: iconName(for: item))
                        .font(.system(size: 38))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 6)
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.blue : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.02), radius: 6, x: 0, y: 2)
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
            return LinearGradient(colors: [.indigo, .purple, Color(red: 0.1, green: 0.1, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .matrixRain:
            return LinearGradient(colors: [Color(red: 0.05, green: 0.15, blue: 0.05), Color(red: 0, green: 0.35, blue: 0.15)], startPoint: .top, endPoint: .bottom)
        case .cyberGrid:
            return LinearGradient(colors: [.pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .minimalClock:
            return LinearGradient(colors: [.blue, .cyan, Color(red: 0.1, green: 0.15, blue: 0.3)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        }
    }
}
