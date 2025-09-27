import SwiftUI
import Vision
import AppKit

struct ContentView: View {
    @State private var screenInfo = ""
    @State private var showImage = false
    @State private var detectedText = ""
    @State private var visionResults: [VNRecognizedTextObservation] = []
    @State private var homeButtonCoordinates: CGPoint? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Mouse Mover")
                .font(.largeTitle)
                .padding()
            
            // Display screen info
            Text(screenInfo)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .padding()
            
            // Display test screenshot image
            if showImage {
                Image("test_screenshot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 200)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            }
            
            // Display Vision analysis results
            if !detectedText.isEmpty {
                ScrollView {
                    Text("Vision Analysis Results:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(detectedText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button("Move Mouse to Top Left") {
                moveMouseToTopLeft()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Move Mouse to Top Right") {
                moveMouseToTopRight()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Update Screen Info") {
                updateScreenInfo()
            }
            .buttonStyle(.bordered)
            
            Button("Test Vision") {
                showImage.toggle()
                testVision()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Analyze Image with Vision") {
                analyzeImageWithVision()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Go To Home Button") {
                goToHomeButton()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Test Chrome Detection") {
                testChromeDetection()
            }
            .buttonStyle(.bordered)
            
            Button("Open Slack Environment") {
                openSlackEnvironment()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(width: 400, height: 800)
        .padding()
        .onAppear {
            updateScreenInfo()
        }
        Button("Test Coordinates") {
            testCoordinates()
        }
        .buttonStyle(.bordered)
        Button("Go to Home Button") {
            CGWarpMouseCursorPosition(CGPoint(x: 40, y: 320))
        }
        .buttonStyle(.bordered)
    }
    
    // Add this function
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
                // CGWarpMouseCursorPosition(point)
                // Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
    
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
    
    func moveMouseToTopLeft() {
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            // True top-left: (0, 0)
            let newLocation = CGPoint(x: screenFrame.minX, y: screenFrame.minY)
            CGWarpMouseCursorPosition(newLocation)
            print("Moving to top left: \(newLocation)")
        }
    }

    func moveMouseToTopRight() {
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            // True top-right: (maxX, 0)
            let newLocation = CGPoint(x: screenFrame.maxX, y: screenFrame.minY)
            CGWarpMouseCursorPosition(newLocation)
            print("Moving to top right: \(newLocation)")
        }
    }
    
    func testVision() {
        print("Image Test To Be Continued")
    }
    
    func analyzeImageWithVision() {
        guard let image = NSImage(named: "test_screenshot") else {
            print("Could not load test_screenshot image")
            return
        }
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Could not convert NSImage to CGImage")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Vision request error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text observations found")
                return
            }
            
            DispatchQueue.main.async {
                self.visionResults = observations
                self.processVisionResults(observations)
            }
        }
        
        // Configure the request for better accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform Vision request: \(error)")
        }
    }
    
    func processVisionResults(_ observations: [VNRecognizedTextObservation]) {
        var allText = ""
        var sidebarItems: [(String, CGRect)] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let text = topCandidate.string
            let boundingBox = observation.boundingBox
            
            allText += "\(text) at \(boundingBox)\n"
            
            // Look for sidebar items (left side of image, roughly 0-0.2 x coordinate)
            if boundingBox.minX < 0.2 {
                sidebarItems.append((text, boundingBox))
                print("Sidebar item found: '\(text)' at normalized coordinates: \(boundingBox)")
                
                // Specifically look for "Home" button
                if text.lowercased().contains("home") {
                    let screenCoordinates = convertNormalizedToScreenCoordinates(boundingBox)
                    homeButtonCoordinates = screenCoordinates
                    print("🏠 HOME BUTTON FOUND!")
                    print("Normalized: \(boundingBox)")
                    print("Screen coordinates: \(screenCoordinates)")
                }
            }
        }
        
        detectedText = allText
        
        // Print specific sidebar items we're looking for
        print("\n=== SIDEBAR ANALYSIS ===")
        for (text, rect) in sidebarItems {
            print("Text: '\(text)'")
            print("Normalized coordinates: \(rect)")
            print("---")
        }
    }
    
    func convertNormalizedToScreenCoordinates(_ normalizedRect: CGRect) -> CGPoint {
        guard let screen = NSScreen.main else {
            print("Could not get main screen")
            return CGPoint.zero
        }
        
        let screenFrame = screen.frame
        let screenWidth = screenFrame.width
        let screenHeight = screenFrame.height
        
        // Convert normalized coordinates (0-1) to screen coordinates
        // Vision coordinates are bottom-left origin, macOS is top-left origin
        let x = normalizedRect.midX * screenWidth
        let y = (1.0 - normalizedRect.midY) * screenHeight
        
        print("Converting coordinates:")
        print("Screen size: \(screenWidth) x \(screenHeight)")
        print("Normalized rect: \(normalizedRect)")
        print("Converted point: (\(x), \(y))")
        
        return CGPoint(x: x, y: y)
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
    
    // MARK: - Chrome Management
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
        do {
            try NSWorkspace.shared.launchApplication(at: chromeURL, options: [], configuration: [:])
            print("🚀 Starting Google Chrome... Success!")
        } catch {
            print("🚀 Starting Google Chrome... Error: \(error)")
        }
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
    
    func goToHomeButton() {
        if let homeCoords = homeButtonCoordinates {
            CGWarpMouseCursorPosition(homeCoords)
            print("🏠 Moving mouse to Home button at: \(homeCoords)")
        } else {
            print("❌ Home button coordinates not found. Please run Vision analysis first!")
            // Fallback to manual coordinates if Vision hasn't run yet
            let fallbackCoords = CGPoint(x: 40, y: 320)
            CGWarpMouseCursorPosition(fallbackCoords)
            print("🔄 Using fallback coordinates: \(fallbackCoords)")
        }
    }
    
}
