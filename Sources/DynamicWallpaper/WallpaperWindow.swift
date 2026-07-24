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
        
        // Lower than desktop elements / level setup
        self.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        
        // Pass all mouse events to desktop icons
        self.ignoresMouseEvents = true
        
        // Stay stationary on all spaces / Mission Control
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        self.isOpaque = true
        self.backgroundColor = .black
        self.hasShadow = false
        self.isReleasedWhenClosed = false
        self.hidesOnDeactivate = false
        
        // Position exactly matching the screen
        self.setFrame(contentRect, display: true)
    }
}
