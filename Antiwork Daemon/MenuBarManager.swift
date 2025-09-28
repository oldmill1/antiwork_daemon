import SwiftUI
import AppKit

extension Notification.Name {
    static let showScreenshotIndicator = Notification.Name("showScreenshotIndicator")
    static let showDemoWindow = Notification.Name("showDemoWindow")
}

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var indicatorTimer: Timer?
    
    init() {
        setupMenuBar()
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenshotIndicator),
            name: .showScreenshotIndicator,
            object: nil
        )
    }
    
    @objc private func handleScreenshotIndicator() {
        showScreenshotIndicator()
    }
    
    private func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem else { return }
        
        // Set the menu bar icon
        if let button = statusItem.button {
            // Use a system symbol for the icon - "circle.fill" as a simple icon
            let image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Antiwork Daemon")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "Antiwork Daemon"
        }
        
        // Create the menu
        let menu = NSMenu()
        
        // Add "Show Lotus" menu item
        let showLotusItem = NSMenuItem(title: "Show Lotus", action: #selector(showLotus), keyEquivalent: "")
        showLotusItem.target = self
        menu.addItem(showLotusItem)
        
        // Add "Show Demo Window" menu item
        let showDemoItem = NSMenuItem(title: "Show Demo Window", action: #selector(showDemoWindow), keyEquivalent: "")
        showDemoItem.target = self
        menu.addItem(showDemoItem)
        
        // Add separator
        menu.addItem(NSMenuItem.separator())
        
        // Add quit menu item
        let quitItem = NSMenuItem(title: "Quit Antiwork Daemon", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func showLotus() {
        // Bring all windows of this app to front
        NSApp.activate(ignoringOtherApps: true)
        
        // Focus on the main window (Lotus)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
        
        print("🎯 Showed Lotus window")
    }
    
    @objc private func showDemoWindow() {
        // Bring all windows of this app to front
        NSApp.activate(ignoringOtherApps: true)
        
        // Find and show the demo window
        for window in NSApp.windows {
            if window.title == "Demo Window" {
                window.makeKeyAndOrderFront(nil)
                print("🎯 Showed Demo window")
                return
            }
        }
        
        // If demo window doesn't exist, create it
        let demoWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        demoWindow.title = "Demo Window"
        demoWindow.contentView = NSHostingView(rootView: ContentView())
        demoWindow.center()
        demoWindow.makeKeyAndOrderFront(nil)
        
        print("🎯 Created and showed Demo window")
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Screenshot Indicator
    
    func showScreenshotIndicator() {
        guard let statusItem = statusItem, let button = statusItem.button else { return }
        
        // Create a red dot indicator
        let redDotImage = NSImage(size: NSSize(width: 8, height: 8))
        redDotImage.lockFocus()
        NSColor.red.setFill()
        NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 8, height: 8)).fill()
        redDotImage.unlockFocus()
        
        // Set the red dot as the button image
        button.image = redDotImage
        
        // Cancel any existing timer
        indicatorTimer?.invalidate()
        
        // Set timer to restore original icon after 2 seconds
        indicatorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.restoreOriginalIcon()
        }
        
        print("🔴 Showing screenshot indicator")
    }
    
    private func restoreOriginalIcon() {
        guard let statusItem = statusItem, let button = statusItem.button else { return }
        
        // Restore the original circle.fill icon
        let image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Antiwork Daemon")
        image?.isTemplate = true
        button.image = image
        
        print("⚪ Restored original menu bar icon")
    }
    
    deinit {
        indicatorTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}
