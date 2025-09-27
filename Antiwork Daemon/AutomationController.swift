import SwiftUI
import AppKit
import ScreenCaptureKit

class AutomationController: ObservableObject {
    @Published var screenInfo = ""
    
    // MARK: - Mouse Controlgma
    
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
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        NSWorkspace.shared.open(url)
        print("🌐 Opening URL: \(urlString)")
    }
    
    func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
        print("🌐 Opening URL: \(url.absoluteString)")
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
    
    // MARK: - Screenshot Capture
    
    func takeScreenshot() -> String? {
        // Create screenshots directory in user's Documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "/Users/ataxali/Documents"
        let screenshotsDir = "\(documentsPath)/AntiworkDaemon_Screenshots"
        
        // Create directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: screenshotsDir) {
            do {
                try fileManager.createDirectory(atPath: screenshotsDir, withIntermediateDirectories: true, attributes: nil)
                print("📁 Created screenshots directory: \(screenshotsDir)")
            } catch {
                print("❌ Failed to create screenshots directory: \(error)")
                return nil
            }
        }
        
        // Generate filename with timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "screenshot_\(timestamp).png"
        let filePath = "\(screenshotsDir)/\(filename)"
        
        // Take screenshot using ScreenCaptureKit
        let semaphore = DispatchSemaphore(value: 0)
        var screenshotData: Data?
        var errorMessage: String?
        
        Task {
            do {
                // Get available content
                let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                
                // Find the main display
                guard let mainDisplay = availableContent.displays.first else {
                    errorMessage = "No displays found"
                    semaphore.signal()
                    return
                }
                
                // Create content filter
                let contentFilter = SCContentFilter(display: mainDisplay, excludingWindows: [])
                
                // Create capture configuration
                let config = SCStreamConfiguration()
                config.width = Int(mainDisplay.width)
                config.height = Int(mainDisplay.height)
                config.minimumFrameInterval = CMTime(value: 1, timescale: 1)
                config.queueDepth = 1
                
                // Capture the screen
                let cgImage = try await SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: config)
                
                // Convert CGImage to NSImage
                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                
                // Convert to PNG data
                guard let tiffData = nsImage.tiffRepresentation,
                      let bitmapRep = NSBitmapImageRep(data: tiffData),
                      let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
                    errorMessage = "Failed to convert image to PNG"
                    semaphore.signal()
                    return
                }
                
                screenshotData = pngData
                semaphore.signal()
                
            } catch {
                errorMessage = "Screenshot failed: \(error.localizedDescription)"
                semaphore.signal()
            }
        }
        
        // Wait for the async operation to complete
        semaphore.wait()
        
        if let error = errorMessage {
            print("❌ \(error)")
            return nil
        }
        
        guard let data = screenshotData else {
            print("❌ No screenshot data received")
            return nil
        }
        
        // Save the screenshot
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            print("📸 Screenshot saved: \(filePath)")
            return filePath
        } catch {
            print("❌ Failed to save screenshot: \(error)")
            return nil
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
