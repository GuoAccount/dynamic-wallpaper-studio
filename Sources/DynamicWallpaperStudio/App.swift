import AppKit
import SwiftUI

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as a status bar accessory app
        NSApp.setActivationPolicy(.accessory)
        
        // Start dynamic wallpaper engine
        WallpaperManager.shared.startEngine()
        
        // Setup Menu Bar Item & Controller
        self.menuBarController = MenuBarController()
        
        // Show dashboard control window on launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.menuBarController?.openDashboard()
        }
    }
    
    // Automatically pop open control center window whenever user clicks App icon in Finder/Dock/Launchpad
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        menuBarController?.openDashboard()
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources
    }
}
