import SwiftUI
import Vision
import AppKit

// MARK: - UI Element Model
struct UIElement {
    let text: String
    let type: ElementType
    let normalizedRect: CGRect
    let screenCoordinates: CGPoint
    let confidence: Float
}

enum ElementType {
    case button
    case text
    case navigation
    case input
    case other
}

class VisionManager: ObservableObject {
    @Published var detectedText = ""
    @Published var visionResults: [VNRecognizedTextObservation] = []
    @Published var detectedElements: [UIElement] = []
    
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
        var elements: [UIElement] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let text = topCandidate.string
            let boundingBox = observation.boundingBox
            let confidence = topCandidate.confidence
            
            allText += "\(text) at \(boundingBox)\n"
            
            // Determine element type based on text content and position
            let elementType = classifyElement(text: text, rect: boundingBox)
            let screenCoordinates = convertToScreenCoordinates(boundingBox)
            
            let element = UIElement(
                text: text,
                type: elementType,
                normalizedRect: boundingBox,
                screenCoordinates: screenCoordinates,
                confidence: confidence
            )
            
            elements.append(element)
            
            print("Element found: '\(text)' (\(elementType)) at \(screenCoordinates)")
        }
        
        detectedText = allText
        detectedElements = elements
        
        print("\n=== VISION ANALYSIS ===")
        print("Found \(elements.count) UI elements")
        for element in elements {
            print("\(element.type): '\(element.text)' at \(element.screenCoordinates)")
        }
    }
    
    // MARK: - Element Classification
    
    private func classifyElement(text: String, rect: CGRect) -> ElementType {
        let lowerText = text.lowercased()
        
        // Generic button detection based on common button words
        if lowerText.contains("send") || lowerText.contains("post") || 
           lowerText.contains("reply") || lowerText.contains("share") ||
           lowerText.contains("like") || lowerText.contains("react") ||
           lowerText.contains("submit") || lowerText.contains("save") ||
           lowerText.contains("cancel") || lowerText.contains("ok") ||
           lowerText.contains("yes") || lowerText.contains("no") {
            return .button
        }
        
        // Generic input field detection
        if lowerText.contains("type") || lowerText.contains("enter") ||
           lowerText.contains("search") || lowerText.contains("filter") ||
           lowerText.contains("input") || lowerText.contains("field") {
            return .input
        }
        
        // Generic navigation detection (left side elements)
        if rect.minX < 0.2 {
            return .navigation
        }
        
        // Default to text
        return .text
    }
    
    // MARK: - UI Element Detection
    
    func findElement(containing text: String, ofType type: ElementType? = nil) -> UIElement? {
        return detectedElements.first { element in
            let matchesText = element.text.lowercased().contains(text.lowercased())
            let matchesType = type == nil || element.type == type
            return matchesText && matchesType
        }
    }
    
    func findElements(ofType type: ElementType) -> [UIElement] {
        return detectedElements.filter { $0.type == type }
    }
    
    func findElements(in region: CGRect) -> [UIElement] {
        return detectedElements.filter { element in
            region.contains(element.screenCoordinates)
        }
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
    
    func analyzeImageFromPath(_ path: String) {
        guard let image = NSImage(contentsOfFile: path) else {
            print("Could not load image from path: \(path)")
            return
        }
        
        _ = analyzeImage(image)
    }
    
    func getElementCoordinates(containing text: String, ofType type: ElementType? = nil) -> CGPoint? {
        return findElement(containing: text, ofType: type)?.screenCoordinates
    }
    
}
