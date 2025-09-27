import SwiftUI
import AppKit

class AutomationController: ObservableObject {
    @Published var screenInfo = ""
    
    // MARK: - Mouse Control
    
    func moveMouse(to point: CGPoint) {
        CGWarpMouseCursorPosition(point)
        print("Moving mouse to: \(point)")
    }
    
    func moveMouseToTopLeft() {
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            // True top-left: (0, 0)
            let newLocation = CGPoint(x: screenFrame.minX, y: screenFrame.minY)
            moveMouse(to: newLocation)
            print("Moving to top left: \(newLocation)")
        }
    }
    
    func moveMouseToTopRight() {
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            // True top-right: (maxX, 0)
            let newLocation = CGPoint(x: screenFrame.maxX, y: screenFrame.minY)
            moveMouse(to: newLocation)
            print("Moving to top right: \(newLocation)")
        }
    }
    
    // MARK: - Application Management
    
    func isChromeRunning() -> Bool {
        // Use NSWorkspace to check if Chrome is running
        let runningApps = NSWorkspace.shared.runningApplications
        let chromeApps = runningApps.filter { $0.bundleIdentifier == "com.google.Chrome" }
        
        let isRunning = !chromeApps.isEmpty
        print("Chrome running check result: '\(isRunning)'")
        if isRunning {
            print("Chrome bundle ID found: \(chromeApps.first?.bundleIdentifier ?? "unknown")")
        }
        return isRunning
    }
    
    func startChrome() {
        // Use NSWorkspace to launch Chrome
        let chromeURL = URL(fileURLWithPath: "/Applications/Google Chrome.app")
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        
        NSWorkspace.shared.openApplication(at: chromeURL, configuration: config) { app, error in
            if let error = error {
                print("🚀 Starting Google Chrome... Error: \(error)")
            } else {
                print("🚀 Starting Google Chrome... Success!")
            }
        }
    }
    
    // MARK: - URL and Tab Management
    
    func openSlackEnvironment() {
        print("🎯 Setting up Slack environment...")
        
        // Step 1: Check if Chrome is running
        if !isChromeRunning() {
            print("Chrome not running, starting it...")
            startChrome()
            // Give Chrome time to start
            Thread.sleep(forTimeInterval: 3.0)
        } else {
            print("Chrome is already running")
        }
        
        // Step 2: Check if Slack tab is open
        if isSlackTabOpen() {
            print("Slack tab found, switching to it...")
            switchToSlackTab()
        } else {
            print("Slack tab not found, opening new tab...")
            openSlackTab()
        }
        
        print("✅ Slack environment ready!")
    }
    
    func isSlackTabOpen() -> Bool {
        // For now, assume we need to open a new tab
        // We'll implement proper tab detection later
        return false
    }
    
    func openSlackTab() {
        // Use NSWorkspace to open the URL directly
        let slackURL = URL(string: "https://app.slack.com/client/T069D5CG1/C03K10RTDLL")!
        NSWorkspace.shared.open(slackURL)
        print("📱 Opening Slack tab...")
    }
    
    func switchToSlackTab() {
        // For now, just open a new tab
        openSlackTab()
        print("🔄 Opening new Slack tab...")
    }
    
    // MARK: - Screen Information
    
    func updateScreenInfo() {
        if let screen = NSScreen.main {
            let frame = screen.frame
            let visibleFrame = screen.visibleFrame
            let backingScaleFactor = screen.backingScaleFactor
            
            screenInfo = """
            Screen Resolution: \(Int(frame.width)) × \(Int(frame.height))
            Visible Area: \(Int(visibleFrame.width)) × \(Int(visibleFrame.height))
            Scale Factor: \(backingScaleFactor)x
            Origin: (\(Int(frame.origin.x)), \(Int(frame.origin.y)))
            """
            
            // For multiple screens
            if NSScreen.screens.count > 1 {
                screenInfo += "\nTotal Screens: \(NSScreen.screens.count)"
            }
        }
    }
    
    // MARK: - Testing and Debugging
    
    func testChromeDetection() {
        print("🔍 Testing Chrome detection...")
        
        // Test NSWorkspace approach
        let runningApps = NSWorkspace.shared.runningApplications
        print("Total running apps: \(runningApps.count)")
        
        // Show all Chrome-related apps
        let chromeApps = runningApps.filter { 
            $0.bundleIdentifier?.contains("Chrome") == true || 
            $0.localizedName?.contains("Chrome") == true 
        }
        print("Chrome-related apps found: \(chromeApps.count)")
        for app in chromeApps {
            print("  - \(app.localizedName ?? "Unknown"): \(app.bundleIdentifier ?? "No bundle ID")")
        }
        
        let isRunning = isChromeRunning()
        print("Chrome is running: \(isRunning)")
        
        if isRunning {
            print("✅ Chrome is detected as running")
        } else {
            print("❌ Chrome is not running")
        }
    }
    
    func testCoordinates() {
        if let screen = NSScreen.main {
            print("Screen frame: \(screen.frame)")
            print("Screen origin: \(screen.frame.origin)")
            print("Screen size: \(screen.frame.size)")
            
            // Test different Y values
            let testPoints = [
                CGPoint(x: 100, y: 0),
                CGPoint(x: 100, y: 100),
                CGPoint(x: 100, y: screen.frame.height - 100),
                CGPoint(x: 100, y: screen.frame.height)
            ]
            
            for point in testPoints {
                print("Testing point: \(point)")
                // You could uncomment this to see where each point goes
                // moveMouse(to: point)
                // Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
    
    // MARK: - AppleScript Helper
    
    func runAppleScript(_ script: String) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
