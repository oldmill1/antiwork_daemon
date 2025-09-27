import SwiftUI
import Vision
import AppKit

class VisionManager: ObservableObject {
    @Published var detectedText = ""
    @Published var visionResults: [VNRecognizedTextObservation] = []
    @Published var homeButtonCoordinates: CGPoint? = nil
    
    // MARK: - Image Analysis
    
    func analyzeImage(_ image: NSImage) -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Could not convert NSImage to CGImage")
            return []
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                print("Vision request error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text observations found")
                return
            }
            
            DispatchQueue.main.async {
                self?.visionResults = observations
                self?.processVisionResults(observations)
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
        
        return visionResults
    }
    
    // MARK: - Text Processing
    
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
                    let screenCoordinates = convertToScreenCoordinates(boundingBox)
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
    
    // MARK: - UI Element Detection
    
    func findHomeButton(in observations: [VNRecognizedTextObservation]) -> CGPoint? {
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let text = topCandidate.string
            let boundingBox = observation.boundingBox
            
            // Look for "Home" button in sidebar area
            if boundingBox.minX < 0.2 && text.lowercased().contains("home") {
                let screenCoordinates = convertToScreenCoordinates(boundingBox)
                homeButtonCoordinates = screenCoordinates
                return screenCoordinates
            }
        }
        return nil
    }
    
    // MARK: - Coordinate Conversion
    
    func convertToScreenCoordinates(_ normalizedRect: CGRect) -> CGPoint {
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
    
    // MARK: - Convenience Methods
    
    func analyzeImageWithVision() {
        guard let image = NSImage(named: "test_screenshot") else {
            print("Could not load test_screenshot image")
            return
        }
        
        _ = analyzeImage(image)
    }
    
    func getHomeButtonCoordinates() -> CGPoint? {
        return homeButtonCoordinates
    }
}
