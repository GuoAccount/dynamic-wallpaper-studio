import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Sidebar Categories
public enum SidebarCategory: String, CaseIterable, Identifiable {
    case gallery = "壁纸画廊"
    case performance = "低功耗与性能"
    case displays = "多显示器配置"
    case about = "关于应用"
    
    public var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .gallery: return "photo.on.rectangle.angled"
        case .performance: return "bolt.shield.fill"
        case .displays: return "display"
        case .about: return "info.circle.fill"
        }
    }
}

// MARK: - Main Dashboard View (HSplitView - 60 FPS Zero-Lag Resizing)
public struct DashboardView: View {
    @State private var selectedCategory: SidebarCategory = .gallery
    @State private var presets: [WallpaperItem] = WallpaperItem.presets
    
    public init() {}

    public var body: some View {
        HSplitView {
            // Left Sidebar Column
            SidebarListView(selectedCategory: $selectedCategory)
                .frame(minWidth: 180, idealWidth: 200, maxWidth: 240)
            
            // Right Detail Column
            DetailContentView(selectedCategory: selectedCategory, presets: $presets)
                .frame(minWidth: 500, idealWidth: 580)
        }
        .frame(minWidth: 720, minHeight: 460)
    }
}

// MARK: - Sidebar List View
struct SidebarListView: View {
    @Binding var selectedCategory: SidebarCategory
    @ObservedObject private var energySaver = EnergySaverManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            List(SidebarCategory.allCases, id: \.self, selection: $selectedCategory) { category in
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .foregroundColor(selectedCategory == category ? .accentColor : .secondary)
                    Text(category.rawValue)
                        .font(.system(size: 13, weight: selectedCategory == category ? .semibold : .regular))
                }
                .padding(.vertical, 2)
                .tag(category)
            }
            .listStyle(.sidebar)
            
            Divider()
            
            // Engine Status Badge
            HStack(spacing: 8) {
                Circle()
                    .fill(energySaver.isPaused ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(energySaver.isPaused ? "引擎休眠中" : "运行中 (\(energySaver.targetFPS) FPS)")
                        .font(.system(size: 11, weight: .semibold))
                    Text(energySaver.pauseReason)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
}

// MARK: - Detail Content Router
struct DetailContentView: View {
    let selectedCategory: SidebarCategory
    @Binding var presets: [WallpaperItem]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(selectedCategory.rawValue)
                    .font(.title2.bold())
                Spacer()
                
                Button(action: importLocalFile) {
                    Label("导入本地文件", systemImage: "plus")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Selected View Content
            Group {
                switch selectedCategory {
                case .gallery:
                    GalleryDetailView(presets: $presets)
                case .performance:
                    PerformanceDetailView()
                case .displays:
                    DisplaysDetailView()
                case .about:
                    AboutDetailView()
                }
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
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
            WallpaperManager.shared.currentWallpaper = newItem
        }
    }
}

// MARK: - 1. Gallery Detail View
struct GalleryDetailView: View {
    @Binding var presets: [WallpaperItem]
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("点击壁纸卡片以立即切换当前桌面背景。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(presets) { item in
                        let isSelected = wallpaperManager.currentWallpaper.id == item.id
                        
                        Button {
                            wallpaperManager.currentWallpaper = item
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(cardColor(for: item))
                                        .frame(height: 110)
                                    
                                    Image(systemName: iconName(for: item))
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                    
                                    if isSelected {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(NSColor.controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? Color.accentColor : Color(NSColor.separatorColor), lineWidth: isSelected ? 2 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
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
    
    private func cardColor(for item: WallpaperItem) -> Color {
        switch item.proceduralStyle {
        case .cosmicNebula: return .purple
        case .matrixRain: return Color(red: 0, green: 0.35, blue: 0.1)
        case .cyberGrid: return .indigo
        case .minimalClock: return .blue
        default: return .cyan
        }
    }
}

// MARK: - 2. Performance Detail View
struct PerformanceDetailView: View {
    @ObservedObject private var energySaver = EnergySaverManager.shared
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    var body: some View {
        Form {
            Section("功耗与智能休眠策略") {
                Toggle(isOn: $energySaver.pauseOnFullscreen) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("全屏应用/游戏自动暂停")
                            .font(.system(size: 13, weight: .medium))
                        Text("检测到全屏视频、全屏游戏或 IDE 时自动休眠，实现 0% CPU/GPU 占用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: $energySaver.lowerFPSOnBattery) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("电池供电自动降帧 (60 ➔ 30 FPS)")
                            .font(.system(size: 13, weight: .medium))
                        Text("未连接电源时，限制渲染上限以延长 Mac 续航")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: $energySaver.pauseOnBattery) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("低电量模式完全暂停壁纸")
                            .font(.system(size: 13, weight: .medium))
                        Text("电池处于低电量状态时暂停渲染")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("音频与音效设置") {
                Toggle("视频全局静音", isOn: $wallpaperManager.isAudioMuted)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - 3. Displays Detail View
struct DisplaysDetailView: View {
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    var body: some View {
        Form {
            Section("硬件显示设备") {
                ForEach(NSScreen.screens, id: \.self) { screen in
                    LabeledContent {
                        Text("已应用: \(wallpaperManager.currentWallpaper.title)")
                            .foregroundColor(.secondary)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "display")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(screen.localizedName)
                                    .font(.system(size: 13, weight: .semibold))
                                Text("分辨率: \(Int(screen.frame.width)) × \(Int(screen.frame.height))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - 4. About Detail View
struct AboutDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "sparkles.tv.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("Dynamic Wallpaper Studio")
                    .font(.title2.bold())
                Text("版本 1.0.0 (原生 macOS 极简版)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("专为 macOS 设计的极简低功耗动态壁纸引擎，全面支持 0% 功耗全屏挂起、视频与原生 GPU 粒子特效。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}
