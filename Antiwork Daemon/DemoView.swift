import SwiftUI

struct DemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Demo Window")
                .font(.largeTitle)
                .padding()
            
            Text("This is the demo window for testing purposes.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Button("Demo Button") {
                print("Demo button tapped")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}

#Preview {
    DemoView()
}
