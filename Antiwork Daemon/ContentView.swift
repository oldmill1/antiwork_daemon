import SwiftUI
import Vision
import AppKit

struct ContentView: View {
    @State private var screenInfo = ""
    @State private var showImage = false
    @State private var detectedText = ""
    @State private var visionResults: [VNRecognizedTextObservation] = []
    
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
    
}
