import AppKit
import SwiftUI
import Combine

public final class WallpaperManager: ObservableObject {
    public static let shared = WallpaperManager()
    
    @Published public var currentWallpaper: WallpaperItem = WallpaperItem.presets[0] {
        didSet { applyWallpaperToAllScreens() }
    }
    @Published public var isAudioMuted: Bool = true {
        didSet { applyWallpaperToAllScreens() }
    }
    @Published public var customVideoURL: URL? {
        didSet {
            if let url = customVideoURL {
                currentWallpaper = WallpaperItem(
                    title: url.lastPathComponent,
                    subtitle: "自定义本地视频壁纸",
                    type: .video,
                    url: url
                )
            }
        }
    }

    private var wallpaperWindows: [NSScreen: WallpaperWindow] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupScreenNotifications()
        bindEnergySaver()
    }
    
    public func startEngine() {
        rebuildWindows()
    }
    
    private func bindEnergySaver() {
        EnergySaverManager.shared.$isPaused
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyWallpaperToAllScreens()
            }
            .store(in: &cancellables)

        EnergySaverManager.shared.$targetFPS
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyWallpaperToAllScreens()
            }
            .store(in: &cancellables)
    }
    
    private func setupScreenNotifications() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.rebuildWindows()
            }
            .store(in: &cancellables)
    }
    
    public func rebuildWindows() {
        // Close existing windows
        for (_, window) in wallpaperWindows {
            window.orderOut(nil)
            window.contentView = nil
        }
        wallpaperWindows.removeAll()
        
        // Recreate window for each attached display
        for screen in NSScreen.screens {
            let window = WallpaperWindow(screen: screen)
            wallpaperWindows[screen] = window
            window.orderFront(nil)
        }
        
        applyWallpaperToAllScreens()
    }
    
    public func applyWallpaperToAllScreens() {
        let isPaused = EnergySaverManager.shared.isPaused
        let targetFPS = EnergySaverManager.shared.targetFPS
        
        for (_, window) in wallpaperWindows {
            let rootView = buildViewForCurrentWallpaper(isPaused: isPaused, targetFPS: targetFPS)
            let hostingView = NSHostingView(rootView: rootView)
            hostingView.frame = window.contentView?.bounds ?? window.frame
            hostingView.autoresizingMask = [.width, .height]
            window.contentView = hostingView
        }
    }
    
    @ViewBuilder
    private func buildViewForCurrentWallpaper(isPaused: Bool, targetFPS: Int) -> some View {
        switch currentWallpaper.type {
        case .procedural:
            switch currentWallpaper.proceduralStyle ?? .cosmicNebula {
            case .cosmicNebula:
                CosmicNebulaView(isPaused: isPaused, targetFPS: targetFPS)
            case .matrixRain:
                MatrixRainView(isPaused: isPaused, targetFPS: targetFPS)
            case .cyberGrid:
                CyberGridView(isPaused: isPaused, targetFPS: targetFPS)
            case .minimalClock:
                MinimalClockView(isPaused: isPaused)
            }
            
        case .video:
            if let url = currentWallpaper.url {
                VideoWallpaperView(videoURL: url, isMuted: isAudioMuted, isPaused: isPaused, targetFPS: targetFPS)
            } else {
                CosmicNebulaView(isPaused: isPaused, targetFPS: targetFPS)
            }
            
        case .web:
            WebWallpaperView(htmlContent: currentWallpaper.htmlContent, webURL: currentWallpaper.url, isPaused: isPaused)
        }
    }
}
