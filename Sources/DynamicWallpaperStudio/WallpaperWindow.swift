import AppKit
import SwiftUI

public final class WallpaperWindow: NSWindow {
    public let screenTarget: NSScreen
    
    public init(screen: NSScreen) {
        self.screenTarget = screen
        let contentRect = screen.frame
        
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Position exactly beneath desktop icons (-2147483641)
        let desktopIconLevel = Int(CGWindowLevelForKey(.desktopIconWindow))
        self.level = NSWindow.Level(desktopIconLevel - 1)
        
        // Pass all mouse events through to desktop icons and desktop right-click menu
        self.ignoresMouseEvents = true
        
        // Lock window across all virtual desktops / Spaces / Mission Control / Expose
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary
        ]
        
        // Disable window animation & transition delays
        self.animationBehavior = .none
        
        // CRITICAL: Prevent macOS WindowServer from hiding wallpaper during "Show Desktop" gesture / Cmd+F3 / Space switching
        self.canHide = false
        self.hidesOnDeactivate = false
        self.isOpaque = true
        self.backgroundColor = .black
        self.hasShadow = false
        self.isReleasedWhenClosed = false
        
        // Fit exact screen dimensions
        self.setFrame(contentRect, display: true)
        self.orderFrontRegardless()
    }
    
    // Override canBecomeKey & canBecomeMain so it never steals focus from desktop
    override public var canBecomeKey: Bool { false }
    override public var canBecomeMain: Bool { false }
}
