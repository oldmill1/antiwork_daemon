import SwiftUI
import AppKit

class SlackManager: ObservableObject {
    @Published var isConnected = false
    @Published var currentChannel = ""
    @Published var homeButtonCoordinates: CGPoint? = nil
    
    private let automationController: AutomationController
    private let visionManager: VisionManager
    
    init(automationController: AutomationController, visionManager: VisionManager) {
        self.automationController = automationController
        self.visionManager = visionManager
    }
    
    // MARK: - Slack Environment Setup
    
    func openSlackEnvironment() {
        print("🎯 Setting up Slack environment...")
        
        // Step 1: Check if Chrome is running
        if !automationController.isChromeRunning() {
            print("Chrome not running, starting it...")
            automationController.startChrome()
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
    
    // MARK: - Slack Navigation
    
    func goToHome() {
        if let homeCoords = homeButtonCoordinates {
            automationController.moveMouse(to: homeCoords)
            print("🏠 Moving to Slack Home at: \(homeCoords)")
        } else {
            print("❌ Home button coordinates not found. Please run Vision analysis first!")
            // Fallback to manual coordinates if Vision hasn't run yet
            let fallbackCoords = CGPoint(x: 40, y: 320)
            automationController.moveMouse(to: fallbackCoords)
            print("🔄 Using fallback coordinates: \(fallbackCoords)")
        }
    }
    
    func findHomeButton() {
        // Use Vision to analyze the current Slack interface
        visionManager.analyzeImageWithVision()
        
        // Look for Home button using Slack-specific logic
        if let homeElement = visionManager.findElement(containing: "home", ofType: .navigation) {
            homeButtonCoordinates = homeElement.screenCoordinates
            print("🏠 Found Slack Home button at: \(homeElement.screenCoordinates)")
        } else {
            print("❌ Could not find Home button in Slack interface")
        }
    }
    
    // MARK: - Slack-Specific Actions
    
    func sendMessage(_ message: String) {
        // TODO: Implement message sending
        print("📤 Sending message: \(message)")
    }
    
    func switchToChannel(_ channelName: String) {
        // TODO: Implement channel switching
        print("🔄 Switching to channel: \(channelName)")
        currentChannel = channelName
    }
    
    func markAsRead() {
        // TODO: Implement mark as read
        print("✅ Marking messages as read")
    }
    
    // MARK: - Status and Connection
    
    func checkConnection() -> Bool {
        // TODO: Implement connection checking
        isConnected = true
        return isConnected
    }
    
    func disconnect() {
        isConnected = false
        currentChannel = ""
        print("🔌 Disconnected from Slack")
    }
}
