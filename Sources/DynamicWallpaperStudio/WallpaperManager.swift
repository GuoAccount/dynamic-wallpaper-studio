import AppKit
import SwiftUI
import Combine

public final class WallpaperManager: ObservableObject {
    public static let shared = WallpaperManager()
    
    private static let storageKey = "UserCustomWallpapers_v1"
    
    @Published public private(set) var customWallpapers: [WallpaperItem] = []
    @Published public private(set) var allWallpapers: [WallpaperItem] = WallpaperItem.presets
    
    @Published public var currentWallpaper: WallpaperItem = WallpaperItem.presets[0] {
        didSet { applyWallpaperToAllScreens() }
    }
    @Published public var isAudioMuted: Bool = true {
        didSet { applyWallpaperToAllScreens() }
    }

    private var wallpaperWindows: [NSScreen: WallpaperWindow] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadCustomWallpapers()
        setupScreenNotifications()
        bindEnergySaver()
    }
    
    public func addCustomWallpaper(_ item: WallpaperItem) {
        customWallpapers.insert(item, at: 0)
        saveCustomWallpapers()
        updateAllWallpapers()
        currentWallpaper = item
    }
    
    public func deleteWallpaper(_ item: WallpaperItem) {
        customWallpapers.removeAll { $0.id == item.id }
        saveCustomWallpapers()
        updateAllWallpapers()
        
        if currentWallpaper.id == item.id {
            currentWallpaper = WallpaperItem.presets[0]
        }
    }
    
    private func loadCustomWallpapers() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([WallpaperItem].self, from: data) {
            self.customWallpapers = saved
        }
        updateAllWallpapers()
    }
    
    private func saveCustomWallpapers() {
        if let data = try? JSONEncoder().encode(customWallpapers) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
    
    private func updateAllWallpapers() {
        allWallpapers = customWallpapers + WallpaperItem.presets
    }
    
    public func startEngine() {
        rebuildWindows()
    }
    
    public func stopEngine() {
        for (_, window) in wallpaperWindows {
            window.orderOut(nil)
            window.contentView = nil
            window.close()
        }
        wallpaperWindows.removeAll()
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
        
        for (screen, window) in wallpaperWindows {
            let rootView = buildViewForCurrentWallpaper(isPaused: isPaused, targetFPS: targetFPS)
            let hostingView = NSHostingView(rootView: rootView)
            hostingView.frame = window.contentView?.bounds ?? window.frame
            hostingView.autoresizingMask = [.width, .height]
            window.contentView = hostingView
            
            // Sync system wallpaper image so left/right Space swipe transition never exposes factory system wallpaper
            syncSystemWallpaperBackground(for: screen)
        }
    }
    
    private func syncSystemWallpaperBackground(for screen: NSScreen) {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let bgDir = appSupport.appendingPathComponent("DynamicWallpaperStudio")
        try? fileManager.createDirectory(at: bgDir, withIntermediateDirectories: true)
        let bgURL = bgDir.appendingPathComponent("system_bg_placeholder.png")
        
        if !fileManager.fileExists(atPath: bgURL.path) {
            let img = NSImage(size: NSSize(width: 1920, height: 1080))
            img.lockFocus()
            NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.11, alpha: 1.0).setFill()
            NSRect(x: 0, y: 0, width: 1920, height: 1080).fill()
            img.unlockFocus()
            
            if let tiff = img.tiffRepresentation,
               let rep = NSBitmapImageRep(data: tiff),
               let png = rep.representation(using: .png, properties: [:]) {
                try? png.write(to: bgURL)
            }
        }
        
        // Asynchronously set system desktop wallpaper for all Spaces
        DispatchQueue.global(qos: .background).async {
            try? NSWorkspace.shared.setDesktopImageURL(bgURL, for: screen, options: [:])
        }
    }
    
    @ViewBuilder
    private func buildViewForCurrentWallpaper(isPaused: Bool, targetFPS: Int) -> some View {
        switch currentWallpaper.type {
        case .procedural:
            switch currentWallpaper.proceduralStyle ?? .cosmicNebula {
            case .cosmicNebula:
                CosmicNebulaView(isPaused: isPaused, targetFPS: targetFPS)
            case .auroraFlow:
                AuroraFlowView(isPaused: isPaused, targetFPS: targetFPS)
            case .ambientBokeh:
                AmbientBokehView(isPaused: isPaused, targetFPS: targetFPS)
            case .cyberGlow:
                CyberGlowView(isPaused: isPaused, targetFPS: targetFPS)
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
