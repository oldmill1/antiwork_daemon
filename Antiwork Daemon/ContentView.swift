import SwiftUI
import Vision
import AppKit

struct ContentView: View {
    @StateObject private var visionManager = VisionManager()
    @StateObject private var automationController = AutomationController()
    @StateObject private var slackManager: SlackManager
    @State private var showImage = false
    
    init() {
        let visionManager = VisionManager()
        let automationController = AutomationController()
        let slackManager = SlackManager(automationController: automationController, visionManager: visionManager)
        
        _visionManager = StateObject(wrappedValue: visionManager)
        _automationController = StateObject(wrappedValue: automationController)
        _slackManager = StateObject(wrappedValue: slackManager)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Mouse Mover")
                .font(.largeTitle)
                .padding()
            
            // Display screen info
            Text(automationController.screenInfo)
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
            if !visionManager.detectedText.isEmpty {
                ScrollView {
                    Text("Vision Analysis Results:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(visionManager.detectedText)
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
                automationController.moveMouseToTopLeft()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Move Mouse to Top Right") {
                automationController.moveMouseToTopRight()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Update Screen Info") {
                automationController.updateScreenInfo()
            }
            .buttonStyle(.bordered)
            
            Button("Test Vision") {
                showImage.toggle()
                testVision()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Analyze Image with Vision") {
                visionManager.analyzeImageWithVision()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Go To Home Button") {
                slackManager.goToHome()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Test Chrome Detection") {
                automationController.testChromeDetection()
            }
            .buttonStyle(.bordered)
            
            Button("Open Slack Environment") {
                slackManager.openSlackEnvironment()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Find Home Button") {
                slackManager.findHomeButton()
            }
            .buttonStyle(.bordered)
        }
        .frame(width: 400, height: 800)
        .padding()
        .onAppear {
            automationController.updateScreenInfo()
        }
        Button("Test Coordinates") {
            automationController.testCoordinates()
        }
        .buttonStyle(.bordered)
        Button("Go to Home Button") {
            automationController.moveMouse(to: CGPoint(x: 40, y: 320))
        }
        .buttonStyle(.bordered)
    }
    
    // MARK: - UI Helper Functions
    
    func testVision() {
        print("Image Test To Be Continued")
    }
    
}
