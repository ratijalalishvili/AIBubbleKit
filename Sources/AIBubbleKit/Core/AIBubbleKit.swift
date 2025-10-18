import Foundation
import SwiftUI

/// AIBubbleKit - A comprehensive framework for embedding AI assistants in iOS apps
///
/// This framework provides a floating bubble interface for AI-powered chat and voice interactions.
/// It supports text and voice modes, function calling, and customizable configurations.
///
/// ## Quick Start
///
/// ```swift
/// import AIBubbleKit
///
/// // Create configuration
/// let config = AssistantConfiguration.defaultConfiguration(
///     appName: "My App",
///     appVersion: "1.0.0",
///     userId: "user123"
/// )
///
/// // Create assistant
/// let assistant = AIBubbleAssistant(configuration: config)
///
/// // Add to your view
/// AIBubbleView(assistant: assistant)
/// ```
///
/// ## Features
///
/// - **Floating Bubble UI**: Draggable, expandable chat interface
/// - **Text & Voice Chat**: Support for both text and voice interactions
/// - **Function Calling**: Built-in functions for tasks and knowledge search
/// - **Customizable**: Extensive configuration options for behavior and appearance
/// - **Privacy-First**: On-device processing with configurable data handling
///
/// ## Configuration
///
/// The framework uses a comprehensive configuration system that allows you to customize:
/// - Assistant behavior and personality
/// - Voice and speech settings
/// - Function availability
/// - Privacy and safety policies
/// - UI appearance and interaction patterns
///
/// ## Function Calling
///
/// The assistant supports function calling for enhanced capabilities:
/// - `search_knowledge_base`: Search app or domain knowledge
/// - `create_task`: Create reminders and tasks
/// - Custom functions can be registered via the AIFunctionManager
///
/// ## Voice Features
///
/// When voice mode is enabled:
/// - Speech-to-text transcription
/// - Text-to-speech synthesis
/// - Voice activity detection
/// - Barge-in support for interrupting responses
///
/// ## Privacy & Safety
///
/// - Configurable PII handling policies
/// - No sensitive data storage by default
/// - Content safety and refusal mechanisms
/// - Medical/legal/financial disclaimers
///
@available(iOS 15.0, *)
public struct AIBubbleKit {
    
    /// Current version of the AIBubbleKit framework
    public static let version = "1.0.0"
    
    /// Initialize the AIBubbleKit framework
    /// Call this method once when your app launches to set up the framework
    public static func initialize() {
        // Framework initialization logic
        print("AIBubbleKit v\(version) initialized")
    }
    
    /// Create a default assistant configuration
    /// - Parameters:
    ///   - appName: Name of your app
    ///   - appVersion: Version of your app
    ///   - userId: User identifier (can be anonymous)
    ///   - voiceEnabled: Whether to enable voice features
    ///   - ttsAllowed: Whether text-to-speech is allowed
    /// - Returns: A configured AssistantConfiguration object
    public static func createDefaultConfiguration(
        appName: String,
        appVersion: String,
        userId: String,
        voiceEnabled: Bool = false,
        ttsAllowed: Bool = true
    ) -> AssistantConfiguration {
        return AssistantConfiguration.defaultConfiguration(
            appName: appName,
            appVersion: appVersion,
            userId: userId,
            voiceEnabled: voiceEnabled,
            ttsAllowed: ttsAllowed
        )
    }
    
    /// Create an AI assistant instance
    /// - Parameter configuration: The assistant configuration
    /// - Returns: A configured AIBubbleAssistant instance
    @MainActor public static func createAssistant(configuration: AssistantConfiguration) -> AIBubbleAssistant {
        return AIBubbleAssistant(configuration: configuration)
    }
    
    /// Create the main bubble view for your app
    /// - Parameter assistant: The AI assistant instance
    /// - Returns: A SwiftUI view that can be added to your app
    public static func createBubbleView(assistant: AIBubbleAssistant) -> AIBubbleView {
        return AIBubbleView(assistant: assistant)
    }
}

// MARK: - Convenience Extensions

@available(iOS 15.0, *)
public extension View {
    
    /// Add the AI Bubble to any SwiftUI view
    /// - Parameters:
    ///   - assistant: The AI assistant instance
    ///   - position: Initial position of the bubble (optional)
    func aiBubble(assistant: AIBubbleAssistant) -> some View {
        ZStack {
            self
            AIBubbleView(assistant: assistant)
        }
    }
}

// MARK: - Error Types

/// Errors that can occur in AIBubbleKit
public enum AIBubbleKitError: Error, LocalizedError {
    case configurationInvalid(String)
    case permissionDenied(String)
    case speechRecognitionUnavailable
    case networkUnavailable
    case functionCallFailed(String)
    case initializationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .configurationInvalid(let message):
            return "Configuration invalid: \(message)"
        case .permissionDenied(let message):
            return "Permission denied: \(message)"
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available on this device"
        case .networkUnavailable:
            return "Network connection is not available"
        case .functionCallFailed(let message):
            return "Function call failed: \(message)"
        case .initializationFailed(let message):
            return "Initialization failed: \(message)"
        }
    }
}

// MARK: - Public Type Aliases
/// Convenience type alias for assistant response handlers
public typealias AIResponseHandler = (AssistantResponse) -> Void

/// Convenience type alias for error handlers
public typealias AIErrorHandler = (Error) -> Void
