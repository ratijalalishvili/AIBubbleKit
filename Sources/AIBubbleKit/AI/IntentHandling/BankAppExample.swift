import Foundation

// Example host app intent handling
public class BankAppRouter: IntentHandling {
    public func handleIntent(id: String, entities: [String : Any]) async {
        switch id {
        case "transfer":
            let recipient = entities["recipient"] as? String ?? "unknown"
            let amount = entities["amount"] as? Double ?? 0.0
            print("\(type(of: self)): Navigating to transfer for \(recipient) with amount \(amount)")
        case "top_up":
            let amount = entities["amount"] as? Double ?? 0.0
            print("\(type(of: self)): Navigating to top-up with amount \(amount)")
        case "pay_bills":
            let biller = entities["biller"] as? String ?? "unknown"
            print("\(type(of: self)): Navigating to pay bills for \(biller)")
        default:
            print("\(type(of: self)): Unknown intent: \(id)")
        }
    }
}

// Example usage within a host app's entry point or setup
/*
// In your AppDelegate or SceneDelegate:
func setupAIBubbleKit() {
    let bankAppRouter = BankAppRouter()

    let transferIntent = AppIntent(
        id: "transfer",
        title: "Transfer Money",
        description: "Initiate a money transfer to another account.",
        sampleUtterances: ["transfer money", "send funds", "move cash"],
        keywords: ["transfer", "send", "move"]
    ) { entities in
        let recipient = entities["recipient"] as? String ?? ""
        let amount = entities["amount"] as? Double ?? 0.0
        // Perform actual navigation or action in your host app
        print("Host app received transfer intent for \(recipient) with \(amount)")
    }

    let topUpIntent = AppIntent(
        id: "top_up",
        title: "Top Up Mobile",
        description: "Recharge your mobile phone balance.",
        sampleUtterances: ["top up mobile", "recharge phone", "add credit"],
        keywords: ["top up", "recharge", "add credit"]
    ) { entities in
        let amount = entities["amount"] as? Double ?? 0.0
        print("Host app received top-up intent for \(amount)")
    }

    let payBillsIntent = AppIntent(
        id: "pay_bills",
        title: "Pay Bills",
        description: "Pay utility or other recurring bills.",
        sampleUtterances: ["pay bills", "settle bills", "make payment"],
        keywords: ["pay bills", "bills", "payment"]
    ) { entities in
        let biller = entities["biller"] as? String ?? ""
        print("Host app received pay bills intent for \(biller)")
    }

    let config = AssistantConfiguration.defaultConfiguration(
        apiKey: "YOUR_GEMINI_API_KEY",
        systemInstructions: "You are an AI assistant for a banking application. You can help users with financial tasks like transferring money, topping up mobile, and paying bills.",
        appName: "BankApp",
        appVersion: "1.0",
        userId: "user123",
        appIntents: [transferIntent, topUpIntent, payBillsIntent]
    )

    let assistant = AIBubbleAssistant(configuration: config, intentHandler: bankAppRouter)

    // Present AIBubbleView
}
*/
