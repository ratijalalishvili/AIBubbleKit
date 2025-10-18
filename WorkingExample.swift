import SwiftUI
import AIBubbleKit

enum Route: Hashable {
    case transfers
    case payments
    case settings
}

struct ContentView: View {
    @State private var path = NavigationPath()
    
    @StateObject private var assistant = AIBubbleKit.createAssistant(
        configuration: AIBubbleKit.createDefaultConfiguration(
            appName: "My App",
            appVersion: "1.0.0",
            userId: "user123"
        )
    )

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.green.ignoresSafeArea()
                VStack {
                    Text("Hello world")
                        .font(.largeTitle)
                    Text("Try saying: 'transfer money', 'pay bills', or 'open settings'")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .aiBubble(assistant: assistant)
            .onAppear {
                // Attach Gemini
                assistant.attachGemini(
                    GeminiConfig(
                        apiKey: "AIzaSyBdG-I1ZUFx7c6H-pLBAyohsttxsLInR_c",
                        systemInstruction: "You are a helpful assistant. When users want to navigate to app features, use the navigate_to_intent function."
                    )
                )
                
                // Register intents
                setupIntents()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .transfers:
                    TransferView()
                case .payments:
                    PaymentView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }
    
    private func setupIntents() {
        // Transfer intent
        let transferIntent = AppIntent(
            id: "transfer",
            title: "Transfer Money",
            description: "Initiate a money transfer to another account.",
            sampleUtterances: ["transfer money", "send funds", "move cash", "wire money"],
            keywords: ["transfer", "send", "move", "wire", "money", "funds"]
        ) { _ in
            Task { @MainActor in
                path.append(Route.transfers)
            }
        }
        
        // Payment intent
        let paymentIntent = AppIntent(
            id: "pay_bills",
            title: "Pay Bills",
            description: "Pay utility bills or other outstanding payments.",
            sampleUtterances: ["pay bills", "settle payments", "make payment", "pay utilities"],
            keywords: ["pay", "bills", "payment", "utilities", "settle"]
        ) { _ in
            Task { @MainActor in
                path.append(Route.payments)
            }
        }
        
        // Settings intent
        let settingsIntent = AppIntent(
            id: "settings",
            title: "Open Settings",
            description: "Navigate to app settings and preferences.",
            sampleUtterances: ["open settings", "go to settings", "show preferences", "configure app"],
            keywords: ["settings", "preferences", "configure", "options"]
        ) { _ in
            Task { @MainActor in
                path.append(Route.settings)
            }
        }
        
        // Register all intents
        assistant.registerIntents([transferIntent, paymentIntent, settingsIntent])
    }
}

struct TransferView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("💸 Transfer Money")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("This is the transfer screen!")
                .foregroundColor(.secondary)
            Text("You can transfer money to other accounts here.")
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Transfer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaymentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("💳 Pay Bills")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("This is the payments screen!")
                .foregroundColor(.secondary)
            Text("Manage your bills and payments here.")
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("This is the settings screen!")
                .foregroundColor(.secondary)
            Text("Configure your app preferences here.")
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
