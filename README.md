# AIBubbleKit

A comprehensive iOS framework for embedding AI assistants with floating bubble UI into your apps. AIBubbleKit provides a modern, draggable chat interface with support for text interactions, function calling, and extensive customization options.

## Features

- 🫧 **Floating Bubble UI** - Draggable, expandable chat interface that doesn't interfere with your app's main UI
- 💬 **Text Chat** - Support for text messages
- 🎯 **Intent-Aware Navigation** - AI can navigate to specific features within your app based on user intent
- 🔧 **Function Calling** - AI can call functions to perform tasks like creating reminders or searching knowledge
- 🎨 **Highly Customizable** - Extensive configuration options for behavior, appearance, and functionality
- 🔒 **Privacy-First** - On-device processing with configurable data handling and PII policies
- ⚡ **SwiftUI Native** - Built with SwiftUI for seamless integration into modern iOS apps
- 🎯 **iOS 15+** - Supports iOS 15.0 and later with modern Swift features

## Quick Start

### 1. Add AIBubbleKit to Your Project

Add AIBubbleKit as a Swift Package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/AIBubbleKit.git", from: "1.0.0")
]
```

### 2. Initialize the Framework

In your app's main entry point:

```swift
import AIBubbleKit

@main
struct MyApp: App {
    init() {
        AIBubbleKit.initialize()
    }
    
    var body: some Scene {
        // Your app content
    }
}
```

### 3. Create and Configure the Assistant

First, define a class to handle your app's intents:

```swift
import Foundation
import AIBubbleKit // Assuming AIBubbleKit is imported for AppIntent and IntentHandling

class BankAppRouter: IntentHandling {
    func handleIntent(id: String, entities: [String : Any]) async {
        switch id {
        case "transfer":
            let recipient = entities["recipient"] as? String ?? "unknown"
            let amount = entities["amount"] as? Double ?? 0.0
            print("\(type(of: self)): Navigating to transfer for \(recipient) with amount \(amount)")
            // Implement your app's navigation logic here
        case "top_up":
            let amount = entities["amount"] as? Double ?? 0.0
            print("\(type(of: self)): Navigating to top-up with amount \(amount)")
            // Implement your app's navigation logic here
        case "pay_bills":
            let biller = entities["biller"] as? String ?? "unknown"
            print("\(type(of: self)): Navigating to pay bills for \(biller)")
            // Implement your app's navigation logic here
        default:
            print("\(type(of: self)): Unknown intent: \(id)")
        }
    }
}
```

Then, create your `AppIntent` objects and the `AssistantConfiguration`:

```swift
// Define your app-specific intents
let transferIntent = AppIntent(
    id: "transfer",
    title: "Transfer Money",
    description: "Initiate a money transfer to another account.",
    sampleUtterances: ["transfer money", "send funds", "move cash"],
    keywords: ["transfer", "send", "move"]
) { entities in
    // This closure will be executed when the 'transfer' intent is triggered
    let recipient = entities["recipient"] as? String ?? ""
    let amount = entities["amount"] as? Double ?? 0.0
    print("Host app received transfer intent for \(recipient) with \(amount)")
    // Navigate to transfer screen, pre-fill data, etc.
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
    // Navigate to top-up screen, pre-fill data, etc.
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
    // Navigate to pay bills screen, pre-fill data, etc.
}

// Create configuration with your Gemini API key and registered intents
let config = AIBubbleKit.createDefaultConfiguration(
    apiKey: "YOUR_GEMINI_API_KEY", // IMPORTANT: Replace with your actual Gemini API Key
    systemInstruction: "You are an AI assistant for a banking application. You can help users with financial tasks like transferring money, topping up mobile, and paying bills.",
    appName: "My App",
    appVersion: "1.0.0",
    userId: "user123",
    appIntents: [transferIntent, topUpIntent, payBillsIntent] // Pass your defined intents
)

// Create the intent handler instance
let bankAppRouter = BankAppRouter()

// Create assistant with the configuration and intent handler
let assistant = AIBubbleKit.createAssistant(configuration: config, intentHandler: bankAppRouter)
```

### 4. Add the Bubble to Your View

```swift
import SwiftUI
import AIBubbleKit

struct ContentView: View {
    @StateObject private var assistant = AIBubbleKit.createAssistant(
        configuration: AIBubbleKit.createDefaultConfiguration(
            apiKey: "YOUR_GEMINI_API_KEY",
            systemInstruction: "You are an AI assistant.",
            appName: "My App",
            appVersion: "1.0.0",
            userId: "user123"
        )
    )
    
    var body: some View {
        VStack {
            // Your app content
            Text("Hello, World!")
        }
        .aiBubble(assistant: assistant)
    }
}
```

## Configuration

AIBubbleKit uses a comprehensive configuration system based on your provided specification:

### Basic Configuration

```swift
let config = AssistantConfiguration.defaultConfiguration(
    apiKey: "YOUR_GEMINI_API_KEY",
    systemInstructions: "You are an AI assistant.",
    appName: "My App",
    appVersion: "1.0.0",
    userId: "user123",
    appIntents: [] // Optional: Register AppIntent objects here
)
```

### Advanced Configuration

```swift
let config = AssistantConfiguration(
    apiKey: "YOUR_GEMINI_API_KEY",
    systemInstruction: "You are an AI assistant embedded inside a mobile app. When the user expresses intent to use a supported feature (listed in configuration), call the function 'navigate_to_intent' with that intent id and any extracted entities. Otherwise, respond normally.",
    agentProfile: AgentProfile(
        name: "My AI Assistant",
        purpose: "Help users with app-specific tasks",
        audience: "End-users of My App"
    ),
    capabilities: Capabilities(
        modes: [.text],
        supportsStreaming: true,
        supportsFunctionCalls: true
    ),
    hostContext: HostContext(
        appName: "My App",
        appVersion: "1.0.0",
        userId: "user123",
        userLocale: "en-US",
        userTimezone: "America/New_York",
        device: "iPhone",
        osVersion: "17.0"
    ),
    conversationPrefs: ConversationPreferences(
        style: ConversationStyle(
            tone: "friendly, helpful",
            avoid: ["jargon", "long responses"],
            emojis: "minimal",
            links: "helpful only"
        ),
        formatting: Formatting(
            markdown: true,
            codeBlocks: "with language tags",
            lists: "for steps and options"
        ),
        safetyAndPrivacy: SafetyAndPrivacy(
            noSensitiveStorage: true,
            piiPolicy: "No PII storage",
            medicalLegalFinancialDisclaimer: "Add disclaimers when needed"
        )
    ),
    behavior: Behavior(
        general: ["Be helpful and concise"],
        errorRecovery: ["Explain errors briefly"],
        offline: ["Provide offline suggestions"],
        sensitiveTopics: ["Refuse unsafe content"]
    ),
    toolUse: ToolUse(
        policy: ["Use tools when helpful"],
        availableFunctions: [
            // You can define custom FunctionDefinitions here if needed
            // For intent navigation, the schema is dynamically generated from `appIntents`
        ]
    ),
    responseContract: ResponseContract(
        mustFollowSchema: true,
        schema: ResponseSchema(
            type: "object",
            properties: [:],
            required: ["mode", "text", "follow_up"]
        )
    ),
    constraints: Constraints(
        maxTokensHint: 800,
        targetLatencyMs: 200,
        streamingTokens: true,
        neverBreakSchema: true
    ),
    refusals: RefusalPolicy(
        policy: "Refuse unsafe requests with explanation"
    ),
    telemetry: Telemetry(
        events: ["message_received", "response_completed"],
        includeRequestIds: true
    ),
    appIntents: [transferIntent, topUpIntent, payBillsIntent] // Example intents
)
```

## Intent-Aware Navigation

AIBubbleKit now supports intent-aware navigation, allowing your AI assistant to trigger specific actions or navigate to screens within your host application based on user input. This is achieved through a combination of Gemini's function calling capabilities and local keyword fallback.

### How it Works

1.  **Define `AppIntent`s**: You define `AppIntent` objects, each representing a high-level user intent (e.g., "Transfer Money", "Pay Bills"). Each `AppIntent` includes a unique ID, a title, a description, sample utterances, keywords, and a closure (`handler`) that your app executes when the intent is triggered.
2.  **`IntentHandling` Protocol**: Your host application provides a class that conforms to the `IntentHandling` protocol. This class implements the `handleIntent` method, which acts as a central dispatcher for all triggered intents.
3.  **`IntentRouter`**: Internally, `AIBubbleAssistant` uses an `IntentRouter` to manage your registered `AppIntent`s and to route intent calls to your `IntentHandling` instance.
4.  **Gemini Function Calling**: The SDK dynamically generates a Gemini function tool named `navigate_to_intent`. The schema for this tool is built from the IDs of your registered `AppIntent`s. When Gemini detects a user's intent matching one of your `AppIntent`s, it calls `navigate_to_intent` with the `intent_id` and any extracted `entities`.
5.  **Local Keyword Fallback**: If Gemini does not return a function call, `AIBubbleAssistant` performs a local check against the `keywords` you defined in your `AppIntent`s. If a match is found, the corresponding intent is triggered.

### Usage

#### 1. Define Your Intents and Handler

As shown in the "Quick Start" section (Step 3), define your `AppIntent` objects and create a class that conforms to `IntentHandling`. The `handleIntent` method in your `IntentHandling` class will contain the logic to navigate within your app or perform specific actions based on the `intent_id` and `entities`.

```swift
// Example AppIntent definition (see Quick Start for full example)
let transferIntent = AppIntent(
    id: "transfer",
    title: "Transfer Money",
    description: "Initiate a money transfer to another account.",
    sampleUtterances: ["transfer money", "send funds", "move cash"],
    keywords: ["transfer", "send", "move"]
) { entities in
    // Logic to handle transfer in your app
    let recipient = entities["recipient"] as? String ?? ""
    let amount = entities["amount"] as? Double ?? 0.0
    print("Handling transfer for \(recipient) with \(amount)")
}

// Example IntentHandling conformance
class MyAppIntentHandler: IntentHandling {
    func handleIntent(id: String, entities: [String : Any]) async {
        // Dispatch to appropriate app logic
        print("Received intent: \(id) with entities: \(entities)")
    }
}
```

#### 2. Configure Assistant with Intents

When creating your `AssistantConfiguration`, pass your array of `AppIntent` objects and your `IntentHandling` instance:

```swift
let myAppIntentHandler = MyAppIntentHandler()

let config = AIBubbleKit.createDefaultConfiguration(
    apiKey: "YOUR_GEMINI_API_KEY",
    systemInstruction: "You are an AI assistant for a banking application.",
    appName: "My App",
    appVersion: "1.0.0",
    userId: "user123",
    appIntents: [transferIntent] // Pass your defined AppIntent objects here
)

let assistant = AIBubbleKit.createAssistant(configuration: config, intentHandler: myAppIntentHandler)
```

## Function Calling

AIBubbleKit includes built-in functions and supports custom function registration:

### Built-in Functions

- **`search_knowledge_base`** - Search app or domain knowledge
- **`create_task`** - Create reminders and tasks
- **`navigate_to_intent`** - Navigate to a specific feature or screen within the application based on user intent (handled by your registered `AppIntent`s)

### Custom Functions

```swift
assistant.functionHandler.registerFunction("custom_function") { args in
    // Your custom function implementation
    return .success(["result": "custom response"])
}
```

### Function Schema

Functions follow a strict schema system:

```swift
let function = FunctionDefinition(
    name: "my_function",
    description: "Does something useful",
    schema: FunctionSchema(
        type: "object",
        properties: [
            "param1": PropertyDefinition(type: "string"),
            "param2": PropertyDefinition(type: "integer", minimum: 1, maximum: 100)
        ],
        required: ["param1"]
    )
)
```

## UI Customization

The floating bubble UI is highly customizable:

### Bubble Appearance

- Gradient colors based on assistant state
- Draggable positioning with edge snapping
- Smooth animations and transitions
- Shadow and visual effects

### Chat Interface

- Expandable chat view
- Message bubbles with timestamps
- Typing indicators
- Follow-up suggestions

### Integration Options

```swift
// Option 1: Use the convenience modifier
ContentView()
    .aiBubble(assistant: assistant)

// Option 2: Manual integration
ZStack {
    ContentView()
    AIBubbleView(assistant: assistant)
}
```

## Privacy & Safety

AIBubbleKit is designed with privacy and safety in mind:

- **No Sensitive Storage** - Configurable data retention policies
- **PII Handling** - Strict policies for personally identifiable information
- **Content Safety** - Built-in refusal mechanisms for unsafe content
- **Medical/Legal/Financial Disclaimers** - Automatic disclaimers for sensitive topics

## Example App

The repository includes a complete example app (`AIBubbleExample`) demonstrating:

- Basic integration
- Function calling
- Intent-aware navigation
- Custom configuration
- UI customization

To run the example:

1. Open `Examples/AIBubbleExample/AIBubbleExample.xcodeproj`
2. Build and run on iOS 15.0+ device or simulator

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

### Swift Package Manager

Add AIBubbleKit to your Xcode project:

1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version requirements
4. Add to your target

### Manual Installation

1. Download the source code
2. Add `AIBubbleKit.xcodeproj` to your workspace
3. Link the framework to your target
4. Import in your Swift files

## API Reference

### Main Classes

- **`AIBubbleKit`** - Main framework class with static methods
- **`AIBubbleAssistant`** - Core assistant functionality
- **`AIBubbleView`** - SwiftUI view for the floating bubble
- **`AssistantConfiguration`** - Configuration management
- **`AIFunctionManager`** - Function calling system
- **`AppIntent`** - Represents a high-level user intent
- **`IntentRouter`** - Manages and routes registered intents

### Key Protocols

- **`ObservableObject`** - Assistant state management
- **`AIFunctionHandler`** - Function call handling
- **`IntentHandling`** - Protocol for host apps to handle intents

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

AIBubbleKit is released under the MIT License. See [LICENSE](LICENSE) for details.

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/your-org/AIBubbleKit/issues)
- 💬 [Discussions](https://github.com/your-org/AIBubbleKit/discussions)
- 📧 [Email Support](mailto:support@example.com)

## Changelog

### Version 1.0.0
- Initial release
- Floating bubble UI
- Text chat
- Intent-aware navigation
- Function calling system
- Comprehensive configuration
- Privacy and safety features
- SwiftUI integration
- Example app

---

**AIBubbleKit** - Making AI assistants accessible and beautiful in iOS apps. 🫧✨
