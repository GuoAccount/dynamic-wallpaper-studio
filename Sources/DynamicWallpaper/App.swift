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
        // Run as a menu bar accessory app
        NSApp.setActivationPolicy(.accessory)
        
        // Start wallpaper engine
        WallpaperManager.shared.startEngine()
        
        // Setup Menu Bar Item & Dashboard
        self.menuBarController = MenuBarController()
        
        // Show dashboard window on launch for easy configuration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.menuBarController?.openDashboard()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources
    }
}
