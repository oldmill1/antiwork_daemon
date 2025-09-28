import SwiftUI

struct LotusView: View {
    @StateObject private var automationController = AutomationController()
    
    var body: some View {
        VStack {
            Button("Standup") {
                openSlackStandup()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(width: 300, height: 600) // Portrait orientation, normal size
        .background(Color.clear)
    }
    
    private func openSlackStandup() {
        print("🎯 Opening Slack for standup...")
        
        // Check if Chrome is running
        if !automationController.isChromeRunning() {
            print("Chrome not running, starting it...")
            automationController.startChrome()
            // Give Chrome time to start
            Thread.sleep(forTimeInterval: 3.0)
        } else {
            print("Chrome is already running")
        }
        
        // Open the Slack URL
        let slackURL = "https://app.slack.com/client/T069D5CG1/C03K10RTDLL"
        automationController.openURL(slackURL)
        print("✅ Slack standup opened!")
        
        // Wait a few seconds for Slack to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            print("📸 Taking screenshot after Slack load...")
            if let screenshotPath = self.automationController.takeScreenshot() {
                print("✅ Screenshot saved to: \(screenshotPath)")
                // Show red dot indicator in menu bar
                NotificationCenter.default.post(name: .showScreenshotIndicator, object: nil)
            } else {
                print("❌ Failed to take screenshot")
            }
        }
    }
}

#Preview {
    LotusView()
}
