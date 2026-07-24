import AppKit
import Combine
import IOKit.pwr_mgt
import IOKit.ps

public final class EnergySaverManager: ObservableObject {
    public static let shared = EnergySaverManager()
    
    @Published public private(set) var isPaused: Bool = false
    @Published public private(set) var pauseReason: String = ""
    @Published public private(set) var isBatteryMode: Bool = false
    @Published public private(set) var isLowPowerMode: Bool = false
    @Published public private(set) var targetFPS: Int = 60
    
    // Low Power Configuration Switches
    @Published public var pauseOnFullscreen: Bool = true {
        didSet { reevaluateState() }
    }
    @Published public var pauseOnBattery: Bool = false {
        didSet { reevaluateState() }
    }
    @Published public var lowerFPSOnBattery: Bool = true {
        didSet { reevaluateState() }
    }
    @Published public var userManualPause: Bool = false {
        didSet { reevaluateState() }
    }

    private var cancellables = Set<AnyCancellable>()
    private var displaySleep: Bool = false
    private var screenLocked: Bool = false
    private var isFullscreenAppActive: Bool = false
    
    private init() {
        setupListeners()
        checkPowerSource()
        reevaluateState()
    }
    
    private func setupListeners() {
        let center = NSWorkspace.shared.notificationCenter
        
        // 1. Monitor display sleep / wake
        center.publisher(for: NSWorkspace.screensDidSleepNotification)
            .sink { [weak self] _ in
                self?.displaySleep = true
                self?.reevaluateState()
            }
            .store(in: &cancellables)
            
        center.publisher(for: NSWorkspace.screensDidWakeNotification)
            .sink { [weak self] _ in
                self?.displaySleep = false
                self?.reevaluateState()
            }
            .store(in: &cancellables)
            
        // 2. Monitor Application Active / Deactive for Fullscreen Detection
        center.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] _ in
                self?.checkFullscreenActiveApp()
            }
            .store(in: &cancellables)

        // 3. System Screen Saver & Screen Lock Distribute Notifications
        DistributedNotificationCenter.default().publisher(for: Notification.Name("com.apple.screensaver.didstart"))
            .sink { [weak self] _ in
                self?.screenLocked = true
                self?.reevaluateState()
            }
            .store(in: &cancellables)

        DistributedNotificationCenter.default().publisher(for: Notification.Name("com.apple.screensaver.didstop"))
            .sink { [weak self] _ in
                self?.screenLocked = false
                self?.reevaluateState()
            }
            .store(in: &cancellables)

        DistributedNotificationCenter.default().publisher(for: Notification.Name("com.apple.screenIsLocked"))
            .sink { [weak self] _ in
                self?.screenLocked = true
                self?.reevaluateState()
            }
            .store(in: &cancellables)

        DistributedNotificationCenter.default().publisher(for: Notification.Name("com.apple.screenIsUnlocked"))
            .sink { [weak self] _ in
                self?.screenLocked = false
                self?.reevaluateState()
            }
            .store(in: &cancellables)
            
        // 4. Low Power Mode Switch
        NotificationCenter.default.publisher(for: NSNotification.Name.NSProcessInfoPowerStateDidChange)
            .sink { [weak self] _ in
                self?.checkPowerSource()
            }
            .store(in: &cancellables)
            
        // Check active app periodically or when activated
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkFullscreenActiveApp()
                self?.checkPowerSource()
            }
            .store(in: &cancellables)
    }
    
    public func checkPowerSource() {
        self.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        
        // High performance process info check
        var onBattery = false
        if let processInfo = ProcessInfo.processInfo.environment["__POWER_SOURCE_BATTERY__"] {
            onBattery = processInfo == "1"
        } else {
            // Check using pmset output or thermal state
            let thermalState = ProcessInfo.processInfo.thermalState
            if thermalState == .serious || thermalState == .critical {
                self.targetFPS = 30
            }
        }
        
        if self.isBatteryMode != onBattery {
            self.isBatteryMode = onBattery
            self.reevaluateState()
        }
    }
    
    private func checkFullscreenActiveApp() {
        guard pauseOnFullscreen else {
            if isFullscreenAppActive {
                isFullscreenAppActive = false
                reevaluateState()
            }
            return
        }
        
        // Inspect active app window frame
        guard let activeApp = NSWorkspace.shared.menuBarOwningApplication ?? NSWorkspace.shared.frontmostApplication else {
            return
        }
        
        // Ignore self Finder or System UI
        let selfBundleID = Bundle.main.bundleIdentifier ?? ""
        if activeApp.bundleIdentifier == selfBundleID || activeApp.bundleIdentifier == "com.apple.finder" {
            if isFullscreenAppActive {
                isFullscreenAppActive = false
                reevaluateState()
            }
            return
        }
        
        // Check window options using CGWindowListCopyWindowInfo
        var foundFullscreen = false
        
        if let windowInfoList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] {
            for windowInfo in windowInfoList {
                guard let pid = windowInfo[kCGWindowOwnerPID as String] as? pid_t, pid == activeApp.processIdentifier else {
                    continue
                }
                guard let boundsDict = windowInfo[kCGWindowBounds as String] as? [String: Any],
                      let windowFrame = CGRect(dictionaryRepresentation: boundsDict as CFDictionary) else {
                    continue
                }
                
                // If window size equals or exceeds screen size (e.g. Fullscreen video, game, editor)
                for screen in NSScreen.screens {
                    let sFrame = screen.frame
                    if abs(windowFrame.width - sFrame.width) < 5 && abs(windowFrame.height - sFrame.height) < 5 {
                        foundFullscreen = true
                        break
                    }
                }
                if foundFullscreen { break }
            }
        }
        
        if isFullscreenAppActive != foundFullscreen {
            isFullscreenAppActive = foundFullscreen
            reevaluateState()
        }
    }
    
    public func reevaluateState() {
        if userManualPause {
            isPaused = true
            pauseReason = "手动已暂停"
            return
        }
        
        if displaySleep {
            isPaused = true
            pauseReason = "显示器已休眠 (0% GPU)"
            return
        }
        
        if screenLocked {
            isPaused = true
            pauseReason = "屏幕已锁定 (0% GPU)"
            return
        }
        
        if isFullscreenAppActive && pauseOnFullscreen {
            isPaused = true
            pauseReason = "全屏应用激活中 (0% CPU/GPU)"
            return
        }
        
        if isBatteryMode && pauseOnBattery {
            isPaused = true
            pauseReason = "电池供电模式暂停"
            return
        }
        
        // Active!
        isPaused = false
        pauseReason = "正常极速运行中"
        
        // FPS throttling
        if (isBatteryMode && lowerFPSOnBattery) || isLowPowerMode {
            targetFPS = 30
        } else {
            targetFPS = 60
        }
    }
}
