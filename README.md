# AIBubbleKit

A comprehensive iOS framework for embedding AI assistants with floating bubble UI into your apps. AIBubbleKit provides a modern, draggable chat interface with support for text and voice interactions, function calling, and extensive customization options.

## Features

- 🫧 **Floating Bubble UI** - Draggable, expandable chat interface that doesn't interfere with your app's main UI
- 💬 **Text & Voice Chat** - Support for both text messages and voice interactions with speech recognition
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

```swift
// Create configuration
let config = AIBubbleKit.createDefaultConfiguration(
    appName: "My App",
    appVersion: "1.0.0",
    userId: "user123",
    voiceEnabled: true,
    ttsAllowed: true
)

// Create assistant
let assistant = AIBubbleKit.createAssistant(configuration: config)
```

### 4. Add the Bubble to Your View

```swift
import SwiftUI
import AIBubbleKit

struct ContentView: View {
    @StateObject private var assistant = AIBubbleKit.createAssistant(
        configuration: AIBubbleKit.createDefaultConfiguration(
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
    appName: "My App",
    appVersion: "1.0.0",
    userId: "user123",
    voiceEnabled: true,
    ttsAllowed: true
)
```

### Advanced Configuration

```swift
let config = AssistantConfiguration(
    agentProfile: AgentProfile(
        name: "My AI Assistant",
        purpose: "Help users with app-specific tasks",
        audience: "End-users of My App"
    ),
    capabilities: Capabilities(
        modes: [.text, .voice],
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
    voiceMode: VoiceMode(
        enabled: true,
        transcriptionLatencyPreference: "low",
        bargeIn: true,
        tts: TTS(allowed: true, summarizeLongOutputs: true)
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
            // Function definitions
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
    )
)
```

## Function Calling

AIBubbleKit includes built-in functions and supports custom function registration:

### Built-in Functions

- **`search_knowledge_base`** - Search app or domain knowledge
- **`create_task`** - Create reminders and tasks
- **`get_time`** - Get current time and date
- **`get_weather`** - Get weather information (mock implementation)

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

## Voice Features

When voice mode is enabled, AIBubbleKit provides:

- **Speech Recognition** - Convert speech to text
- **Text-to-Speech** - Convert responses to speech
- **Voice Activity Detection** - Automatic speech detection
- **Barge-in Support** - Interrupt ongoing speech

### Permissions

Add these to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone for voice interactions with the AI assistant.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to understand your voice commands.</string>
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
- Voice recording controls

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
- **On-Device Processing** - Local speech recognition and processing
- **Medical/Legal/Financial Disclaimers** - Automatic disclaimers for sensitive topics

## Example App

The repository includes a complete example app (`AIBubbleExample`) demonstrating:

- Basic integration
- Voice features
- Function calling
- Custom configuration
- UI customization

To run the example:

1. Open `Examples/AIBubbleExample/AIBubbleExample.xcodeproj`
2. Build and run on iOS 15.0+ device or simulator
3. Grant microphone and speech recognition permissions when prompted

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
- **`FunctionHandler`** - Function calling system
- **`SpeechManager`** - Voice processing

### Key Protocols

- **`ObservableObject`** - Assistant state management
- **`FunctionHandler`** - Custom function implementation
- **`AIFunctionHandler`** - Function call handling

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
- Text and voice chat
- Function calling system
- Comprehensive configuration
- Privacy and safety features
- SwiftUI integration
- Example app

---

**AIBubbleKit** - Making AI assistants accessible and beautiful in iOS apps. 🫧✨
