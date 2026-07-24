import AppKit
import SwiftUI
import Combine

public final class MenuBarController: NSObject, NSWindowDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var dashboardWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    public override init() {
        super.init()
        setupStatusItem()
        bindEnergySaver()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles.tv", accessibilityDescription: "Dynamic Wallpaper Studio")
        }
        
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        
        rebuildMenu()
    }
    
    private func bindEnergySaver() {
        EnergySaverManager.shared.$isPaused
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.rebuildMenu()
            }
            .store(in: &cancellables)
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
    }
    
    public func rebuildMenu() {
        guard let menu = statusItem.menu else { return }
        menu.removeAllItems()
        
        let title = WallpaperManager.shared.currentWallpaper.title
        let energyState = EnergySaverManager.shared.isPaused ? "💤 \(EnergySaverManager.shared.pauseReason)" : "⚡️ 运行中 (\(EnergySaverManager.shared.targetFPS) FPS)"
        
        let headerItem = NSMenuItem(title: "壁纸: \(title)", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        
        let statusSubItem = NSMenuItem(title: "状态: \(energyState)", action: nil, keyEquivalent: "")
        statusSubItem.isEnabled = false
        menu.addItem(statusSubItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Play / Pause toggle
        let pauseTitle = EnergySaverManager.shared.userManualPause ? "▶️ 恢复播放" : "⏸ 暂停壁纸"
        let pauseItem = NSMenuItem(title: pauseTitle, action: #selector(togglePause), keyEquivalent: "p")
        pauseItem.target = self
        menu.addItem(pauseItem)
        
        // Mute / Unmute
        let muteTitle = WallpaperManager.shared.isAudioMuted ? "🔊 开启声音" : "🔇 静音壁纸"
        let muteItem = NSMenuItem(title: muteTitle, action: #selector(toggleMute), keyEquivalent: "m")
        muteItem.target = self
        menu.addItem(muteItem)
        
        // Next Wallpaper
        let nextItem = NSMenuItem(title: "⏭ 切换下一张预设", action: #selector(nextWallpaper), keyEquivalent: "n")
        nextItem.target = self
        menu.addItem(nextItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Open Dashboard
        let dashboardItem = NSMenuItem(title: "🖥 打开控制中心...", action: #selector(openDashboard), keyEquivalent: "d")
        dashboardItem.target = self
        menu.addItem(dashboardItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "🚪 退出应用", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func togglePause() {
        EnergySaverManager.shared.userManualPause.toggle()
        rebuildMenu()
    }
    
    @objc private func toggleMute() {
        WallpaperManager.shared.isAudioMuted.toggle()
        rebuildMenu()
    }
    
    @objc private func nextWallpaper() {
        let presets = WallpaperItem.presets
        if let idx = presets.firstIndex(where: { $0.id == WallpaperManager.shared.currentWallpaper.id }) {
            let nextIdx = (idx + 1) % presets.count
            WallpaperManager.shared.currentWallpaper = presets[nextIdx]
        } else {
            WallpaperManager.shared.currentWallpaper = presets[0]
        }
        rebuildMenu()
    }
    
    @objc public func openDashboard() {
        if dashboardWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 680, height: 460),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "动态壁纸大师 偏好设置"
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.contentView = NSHostingView(rootView: DashboardView())
            window.center()
            self.dashboardWindow = window
        }
        
        NSApp.activate(ignoringOtherApps: true)
        dashboardWindow?.makeKeyAndOrderFront(nil)
    }
    
    public func windowWillClose(_ notification: Notification) {
        dashboardWindow = nil
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
