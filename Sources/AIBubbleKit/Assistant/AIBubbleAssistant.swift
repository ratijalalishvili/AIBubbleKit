import Foundation
import AsyncAlgorithms
import SwiftUI
import GoogleGenerativeAI

/// Main AI Bubble Assistant class that handles chat interactions, voice processing, and function calls
@MainActor
public class AIBubbleAssistant: ObservableObject {
    
    // MARK: - Published Properties
    var gemini: GeminiClient?
    @Published public var isActive: Bool = false
    @Published public var currentMode: AssistantMode = .text
    @Published public var isProcessing: Bool = false
    @Published public var lastResponse: AssistantResponse?
    @Published public var conversationHistory: [ConversationMessage] = []
    
    // MARK: - Configuration
    public let configuration: AssistantConfiguration
    public let functionHandler: AIFunctionManager
    
    // MARK: - Intent Handling
    private var registeredIntents: [String: AppIntent] = [:]
    private var pendingIntent: (AppIntent, [String: Any])?
    
    // MARK: - Initialization
    public init(configuration: AssistantConfiguration) {
        self.configuration = configuration
        self.functionHandler = AIFunctionManager()
        
        setupFunctionHandler()
    }
    
    /// Attach Gemini at startup or after creating the assistant.
    public func attachGemini(_ config: GeminiConfig) {
        self.gemini = GeminiClient(config: config)
    }

    // MARK: - Public Methods
    
    /// Process a text input from the user
    public func processTextInput(_ input: String) async {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Check if user is responding to a pending intent confirmation
        if pendingIntent != nil {
            await handleIntentConfirmation(input)
            return
        }
        
        isProcessing = true
        let userMessage = ConversationMessage(
            id: UUID(),
            role: .user,
            content: input,
            timestamp: Date()
        )
        
        conversationHistory.append(userMessage)
        
        do {
            let response = try await generateResponse(for: input)
            lastResponse = response
            isProcessing = false
            
            // Add assistant response to conversation history
            let assistantMessage = ConversationMessage(
                id: UUID(),
                role: .assistant,
                content: response.text,
                timestamp: Date()
            )
            conversationHistory.append(assistantMessage)
            
            // Handle function calls if present
            if let functionCall = response.functionCall {
                await handleFunctionCall(functionCall)
            }
            
        } catch {
            isProcessing = false
            handleError(error)
        }
    }
    
    /// Toggle assistant active state
    public func toggleActive() {
        isActive.toggle()
    }
    
    /// Clear conversation history
    public func clearConversation() {
        conversationHistory.removeAll()
        lastResponse = nil
    }
    
    /// Register an intent with the assistant
    public func registerIntent(_ intent: AppIntent) {
        registeredIntents[intent.id] = intent
    }
    
    /// Register multiple intents at once
    public func registerIntents(_ intents: [AppIntent]) {
        for intent in intents {
            registeredIntents[intent.id] = intent
        }
    }
    
    /// Collapse the chat view
    public func collapseChat() {
        isActive = false
    }
    
    /// Confirm and execute pending intent
    public func confirmIntent() {
        guard let (intent, args) = pendingIntent else { return }
        
        // Add a friendly confirmation message before collapsing
        let confirmMessage = ConversationMessage(
            id: UUID(),
            role: .assistant,
            content: "Perfect! Taking you to \(intent.title)...",
            timestamp: Date()
        )
        conversationHistory.append(confirmMessage)
        
        // Update the last response to show the confirmation
        lastResponse = AssistantResponse(
            mode: .text,
            title: "Navigating",
            text: "Perfect! Taking you to \(intent.title)...",
            speak: configuration.voiceMode.enabled ? generateSpeechText(for: "Perfect! Taking you to \(intent.title)...") : "",
            followUp: [],
            functionCall: nil,
            safety: SafetyInfo()
        )
        
        Task {
            // Small delay to show the confirmation message
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Collapse the chat view before executing the intent
            collapseChat()
            
            // Small delay to allow the UI to animate the collapse
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            await intent.handler(args)
            pendingIntent = nil
        }
    }
    
    /// Cancel pending intent
    public func cancelIntent() {
        guard pendingIntent != nil else { return }
        
        // Add a friendly cancellation message
        let cancelMessage = ConversationMessage(
            id: UUID(),
            role: .assistant,
            content: "No problem! I'm here if you need anything else.",
            timestamp: Date()
        )
        conversationHistory.append(cancelMessage)
        
        // Update the last response to show the cancellation
        lastResponse = AssistantResponse(
            mode: .text,
            title: "Cancelled",
            text: "No problem! I'm here if you need anything else.",
            speak: configuration.voiceMode.enabled ? generateSpeechText(for: "No problem! I'm here if you need anything else.") : "",
            followUp: [],
            functionCall: nil,
            safety: SafetyInfo()
        )
        
        pendingIntent = nil
        // Don't collapse the chat when cancelling - let user continue the conversation
    }
    
    // MARK: - Private Methods
    
    /// Handle intent confirmation using Gemini to understand user's actual intent
    private func handleIntentConfirmation(_ input: String) async {
        guard let (intent, _) = pendingIntent else { return }
        
        // Add user's input to conversation history first
        let userMessage = ConversationMessage(
            id: UUID(),
            role: .user,
            content: input,
            timestamp: Date()
        )
        conversationHistory.append(userMessage)
        
        // Create a focused prompt for intent confirmation
        let confirmationPrompt = """
        The user is being asked to confirm if they want to navigate to "\(intent.title)".
        
        User response: "\(input)"
        
        Analyze the user's response and determine if they want to proceed with the navigation or not.
        
        Respond with ONLY one of these exact words:
        - "YES" if the user wants to proceed
        - "NO" if the user wants to cancel or decline
        - "UNCLEAR" if the response is ambiguous
        
        Consider context clues like:
        - Positive words: yes, sure, go ahead, proceed, navigate, take me there, let's go
        - Negative words: no, cancel, stop, don't, never mind, not now, later
        - Ambiguous responses that need clarification
        """
        
        do {
            guard let gemini = gemini else {
                // Fallback to simple keyword matching if Gemini is not available
                handleSimpleConfirmation(input)
                return
            }
            
            let response = try await gemini.generate(
                messages: [GeminiClient.Content(role: "user", parts: [.init(text: confirmationPrompt)])]
            )
            
            // Extract the text from the response
            let responseText = response.candidates?.first?.content.parts.first?.text ?? ""
            
            switch responseText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            case "yes":
                confirmIntent()
            case "no":
                cancelIntent()
            case "unclear":
                await handleUnclearConfirmation(input)
            default:
                // If Gemini returns something unexpected, ask for clarification
                await handleUnclearConfirmation(input)
            }
        } catch {
            // Fallback to simple keyword matching if Gemini fails
            handleSimpleConfirmation(input)
        }
    }
    
    /// Fallback simple confirmation handler
    private func handleSimpleConfirmation(_ input: String) {
        let lowercaseInput = input.lowercased()
        
        // More sophisticated keyword matching
        let positiveKeywords = ["yes", "y", "sure", "ok", "okay", "go", "navigate", "proceed", "continue", "let's go", "take me there"]
        let negativeKeywords = ["no", "n", "cancel", "stop", "don't", "not now", "later", "never mind", "nevermind"]
        
        let hasPositive = positiveKeywords.contains { lowercaseInput.contains($0) }
        let hasNegative = negativeKeywords.contains { lowercaseInput.contains($0) }
        
        if hasPositive && !hasNegative {
            confirmIntent()
        } else if hasNegative && !hasPositive {
            cancelIntent()
        } else {
            // Ambiguous - ask for clarification
            Task {
                await handleUnclearConfirmation(input)
            }
        }
    }
    
    /// Handle unclear confirmation responses
    private func handleUnclearConfirmation(_ input: String) async {
        let clarificationMessage = ConversationMessage(
            id: UUID(),
            role: .assistant,
            content: "I'm not sure if you want to proceed. Please say 'yes' to continue or 'no' to cancel.",
            timestamp: Date()
        )
        conversationHistory.append(clarificationMessage)
        
        lastResponse = AssistantResponse(
            mode: .text,
            title: "Clarification Needed",
            text: "I'm not sure if you want to proceed. Please say 'yes' to continue or 'no' to cancel.",
            speak: configuration.voiceMode.enabled ? generateSpeechText(for: "I'm not sure if you want to proceed. Please say 'yes' to continue or 'no' to cancel.") : "",
            followUp: [],
            functionCall: nil,
            safety: SafetyInfo()
        )
    }
    
    // MARK: - Gemini helpers
    func asGeminiContents(_ userTurn: String, functionEcho: GeminiClient.Part? = nil) -> [GeminiClient.Content] {
        var contents: [GeminiClient.Content] = conversationHistory.map { msg in
            GeminiClient.Content(
                role: msg.role == .user ? "user" : "model",
                parts: [ .init(text: msg.content) ]
            )
        }
        contents.append(.init(role: "user", parts: [.init(text: userTurn)]))
        if let functionEcho { contents.append(.init(role: "user", parts: [functionEcho])) }
        return contents
    }

    var geminiTools: [GeminiClient.Tool] {
        let createTask = GeminiClient.FunctionDeclaration(
            name: "create_task",
            description: "Create a reminder/task at a specific time.",
            parameters: [
                "type": .string("object"),
                "properties": .object([
                    "title": .object(["type": .string("string"), "description": .string("Task title")]),
                    "when":  .object(["type": .string("string"), "description": .string("ISO8601 datetime")])
                ]),
                "required": .array([.string("title"), .string("when")])
            ]
        )
        let searchKB = GeminiClient.FunctionDeclaration(
            name: "search_knowledge_base",
            description: "Search internal KB for a query string.",
            parameters: [
                "type": .string("object"),
                "properties": .object(["query": .object(["type": .string("string")])]),
                "required": .array([.string("query")])
            ]
        )
        // Add navigate_to_intent function if we have registered intents
        var functionDeclarations = [createTask, searchKB]
        
        if !registeredIntents.isEmpty {
            let intentNames = Array(registeredIntents.keys)
            let navigateToIntent = GeminiClient.FunctionDeclaration(
                name: "navigate_to_intent",
                description: "Navigate to a specific feature or screen within the application based on user intent.",
                parameters: [
                    "type": .string("object"),
                    "properties": .object([
                        "intent_id": .object([
                            "type": .string("string"),
                            "description": .string("The ID of the application intent to navigate to."),
                            "enum": .array(intentNames.map { .string($0) })
                        ])
                    ]),
                    "required": .array([.string("intent_id")])
                ]
            )
            functionDeclarations.append(navigateToIntent)
        }
        
        return [GeminiClient.Tool(functionDeclarations: functionDeclarations)]
    }
    
    private func setupFunctionHandler() {
        functionHandler.registerFunction("search_knowledge_base") { [weak self] args in
            return await self?.searchKnowledgeBase(args) ?? .failure(.functionNotFound)
        }
        
        functionHandler.registerFunction("create_task") { [weak self] args in
            return await self?.createTask(args) ?? .failure(.functionNotFound)
        }
        
        functionHandler.registerFunction("navigate_to_intent") { [weak self] args in
            return await self?.handleNavigateToIntent(args) ?? .failure(.functionNotFound)
        }
    }
    
    private func generateResponse(for input: String) async throws -> AssistantResponse {
        guard let gemini else { // Fallback to existing rule-based reply if not attached
            let responseText = await generateResponseText(for: input)
            return AssistantResponse(
                mode: currentMode,
                title: generateTitle(for: input),
                text: responseText,
                speak: configuration.voiceMode.enabled ? generateSpeechText(for: responseText) : "",
                followUp: generateFollowUpSuggestions(for: input),
                functionCall: nil,
                safety: SafetyInfo()
            )
        }

        // 1) Ask the model with history
        let contents = asGeminiContents(input)
        let first = try await gemini.generate(
            messages: contents,
            tools: geminiTools,
            toolConfig: .init(functionCallingConfig: .init(mode: "AUTO", allowedFunctionNames: nil)),
            generation: .init(temperature: 0.3, topP: nil, topK: nil, responseMimeType: nil)
        )
        let parts = first.candidates!.first!.content.parts

        // 2) Tool call path
        if let fc = parts.first(where: { $0.functionCall != nil })?.functionCall {
            let args: [String: Any] = fc.args.reduce(into: [:]) { acc, kv in
                switch kv.value {
                case .string(let s): acc[kv.key] = s
                case .number(let d): acc[kv.key] = d
                case .bool(let b):   acc[kv.key] = b
                case .object(let o): acc[kv.key] = o
                case .array(let a):  acc[kv.key] = a
                case .null:          acc[kv.key] = NSNull()
                }
            }
            let result = try await self.functionHandler.callFunction(name: fc.name, arguments: args)

            let functionResponse = GeminiClient.Part(
                text: nil,
                functionCall: nil,
                functionResponse: .init(name: fc.name, response: ["result": .object((try? result.getDictionary()) ?? [:])])
            )

            let follow = try await gemini.generate(
                messages: asGeminiContents(input, functionEcho: functionResponse),
                tools: geminiTools,
                toolConfig: .init(functionCallingConfig: .init(mode: "AUTO", allowedFunctionNames: nil)),
                generation: .init(temperature: 0.3, topP: nil, topK: nil, responseMimeType: nil)
            )
            let finalText = follow.candidates?.first?.content.parts.compactMap { $0.text }.joined() ?? ""
            return AssistantResponse(
                mode: .text,
                title: generateTitle(for: input),
                text: finalText,
                speak: configuration.voiceMode.enabled ? generateSpeechText(for: finalText) : "",
                followUp: generateFollowUpSuggestions(for: input),
                functionCall: nil,
                safety: SafetyInfo()
            )
        }

        // 3) Check for local intent fallback if no function call
        if let (localIntent, entities) = findLocalIntent(for: input) {
            // Local fallback: if no function call from Gemini, check for local intent matches
            // Store the pending intent for confirmation
            pendingIntent = (localIntent, ["intent_id": localIntent.id])
            
            return AssistantResponse(
                mode: .text,
                title: "Navigation Request",
                text: "Would you like me to navigate to '\(localIntent.title)'?",
                speak: configuration.voiceMode.enabled ? generateSpeechText(for: "Would you like me to navigate to '\(localIntent.title)'?") : "",
                followUp: ["Yes, navigate", "No, cancel"],
                functionCall: nil,
                safety: SafetyInfo()
            )
        }

        // 4) Plain text
        let text = parts.compactMap { $0.text }.joined()
        return AssistantResponse(
            mode: .text,
            title: generateTitle(for: input),
            text: text,
            speak: configuration.voiceMode.enabled ? generateSpeechText(for: text) : "",
            followUp: generateFollowUpSuggestions(for: input),
            functionCall: nil,
            safety: SafetyInfo()
        )
    }
    
    private func generateResponseText(for input: String) async -> String {
        // Simple response generation - in a real implementation, this would call an AI model
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("hello") || lowercaseInput.contains("hi") {
            return "Hello! I'm your AI assistant. How can I help you today?"
        } else if lowercaseInput.contains("help") {
            return "I can help you with:\n• Answering questions\n• Creating reminders\n• Searching information\n• General assistance"
        } else if lowercaseInput.contains("remind") || lowercaseInput.contains("task") {
            return "I can help you create a reminder. Just tell me what you'd like to be reminded about and when."
        } else if lowercaseInput.contains("search") {
            return "I can search for information for you. What would you like me to look up?"
        } else {
            return "I understand you're asking about: \(input). How can I assist you with this?"
        }
    }
    
    private func generateSpeechText(for text: String) -> String {
        // Simplify text for speech synthesis
        return text.replacingOccurrences(of: "**", with: "")
                  .replacingOccurrences(of: "*", with: "")
                  .replacingOccurrences(of: "•", with: "")
    }
    
    private func generateTitle(for input: String) -> String {
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("hello") || lowercaseInput.contains("hi") {
            return "Greeting"
        } else if lowercaseInput.contains("help") {
            return "Help Available"
        } else if lowercaseInput.contains("remind") || lowercaseInput.contains("task") {
            return "Reminder Setup"
        } else if lowercaseInput.contains("search") {
            return "Search Request"
        } else {
            return "Response"
        }
    }
    
    private func generateFollowUpSuggestions(for input: String) -> [String] {
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("hello") || lowercaseInput.contains("hi") {
            return ["What can you help me with?", "Show me your capabilities", "How do I get started?"]
        } else if lowercaseInput.contains("help") {
            return ["Create a reminder", "Search for something", "Ask a question"]
        } else {
            return ["Tell me more", "Can you help with something else?", "What else can you do?"]
        }
    }
    
    private func determineFunctionCall(for input: String) async throws -> FunctionCall? {
        let lowercaseInput = input.lowercased()
        
        // Simple pattern matching for function calls
        if lowercaseInput.contains("remind") && (lowercaseInput.contains("tomorrow") || lowercaseInput.contains("today") || lowercaseInput.contains("at")) {
            return FunctionCall(
                name: "create_task",
                arguments: extractTaskArguments(from: input)
            )
        } else if lowercaseInput.contains("search") && lowercaseInput.count > 10 {
            return FunctionCall(
                name: "search_knowledge_base",
                arguments: ["query": input]
            )
        }
        
        return nil
    }
    
    private func extractTaskArguments(from input: String) -> [String: Any] {
        // Simple extraction - in a real implementation, this would use NLP
        var title = "Task"
        var when = "2024-01-01T09:00:00Z"
        
        // Extract title (everything before "tomorrow", "today", "at", etc.)
        let timeKeywords = ["tomorrow", "today", "at", "on"]
        for keyword in timeKeywords {
            if let range = input.lowercased().range(of: keyword) {
                title = String(input[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        // Extract time (simplified)
        if input.lowercased().contains("tomorrow") {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            when = ISO8601DateFormatter().string(from: tomorrow)
        } else if input.lowercased().contains("today") {
            when = ISO8601DateFormatter().string(from: Date())
        }
        
        return [
            "title": title,
            "when": when
        ]
    }
    
    private func handleFunctionCall(_ functionCall: FunctionCall) async {
        do {
            let result = try await functionHandler.callFunction(
                name: functionCall.name,
                arguments: functionCall.arguments
            )
            
            // Handle the function result
            switch result {
            case .success(let data):
                print("Function call successful: \(data)")
            case .failure(let error):
                print("Function call failed: \(error)")
            }
        } catch {
            print("Function call error: \(error)")
        }
    }
    
    private func handleError(_ error: Error) {
        let errorResponse = AssistantResponse(
            mode: .text,
            title: "Error",
            text: "Sorry, I encountered an error. Please try again.",
            speak: "Sorry, I encountered an error. Please try again.",
            followUp: ["Try again", "What else can you help with?"],
            functionCall: nil,
            safety: SafetyInfo()
        )
        
        lastResponse = errorResponse
    }
    
    // MARK: - Function Implementations
    
    private func searchKnowledgeBase(_ args: [String: Any]) async -> FunctionResult {
        guard let query = args["query"] as? String else {
            return .failure(.invalidArguments)
        }
        
        // Simulate knowledge base search
        let results = [
            "Result 1: Information about \(query)",
            "Result 2: Related to \(query)",
            "Result 3: Additional details on \(query)"
        ]
        
        return .success(["results": results])
    }
    
    private func createTask(_ args: [String: Any]) async -> FunctionResult {
        guard let title = args["title"] as? String,
              let when = args["when"] as? String else {
            return .failure(.invalidArguments)
        }
        
        // Simulate task creation
        let task = [
            "id": UUID().uuidString,
            "title": title,
            "when": when,
            "created": ISO8601DateFormatter().string(from: Date())
        ]
        
        return .success(["task": task])
    }
    
    private func handleNavigateToIntent(_ args: [String: Any]) async -> FunctionResult {
        guard let intentId = args["intent_id"] as? String else {
            return .failure(.invalidArguments)
        }
        
        if let intent = registeredIntents[intentId] {
            // Store the pending intent for confirmation
            pendingIntent = (intent, args)
            
            // Return a more user-friendly confirmation message
            let confirmationMessage = "I can help you with \(intent.title.lowercased()). Would you like me to take you there?"
            
            return .success([
                "status": "confirmation_required",
                "intent_id": intentId,
                "message": confirmationMessage,
                "intent_title": intent.title
            ])
        } else {
            return .failure(.functionNotFound)
        }
    }
    
    private func findLocalIntent(for input: String) -> (AppIntent, [String: Any])? {
        let lowercaseInput = input.lowercased()
        
        // Score each intent based on keyword matches and context
        var intentScores: [(AppIntent, Int, [String: Any])] = []
        
        for intent in registeredIntents.values {
            var score = 0
            var matchedKeywords: [String] = []
            
            // Check for exact keyword matches
            for keyword in intent.keywords {
                let keywordLower = keyword.lowercased()
                if lowercaseInput.contains(keywordLower) {
                    score += 2
                    matchedKeywords.append(keyword)
                }
            }
            
            // Check for sample utterances (partial matches)
            for utterance in intent.sampleUtterances {
                let utteranceLower = utterance.lowercased()
                if lowercaseInput.contains(utteranceLower) || utteranceLower.contains(lowercaseInput) {
                    score += 3
                }
            }
            
            // Check for title relevance
            let titleLower = intent.title.lowercased()
            if lowercaseInput.contains(titleLower) || titleLower.contains(lowercaseInput) {
                score += 1
            }
            
            // Only consider intents with a minimum score
            if score > 0 {
                intentScores.append((intent, score, ["query": input, "matched_keywords": matchedKeywords]))
            }
        }
        
        // Return the highest scoring intent
        if let bestMatch = intentScores.max(by: { $0.1 < $1.1 }) {
            return (bestMatch.0, bestMatch.2)
        }
        
        return nil
    }
}

private extension FunctionResult {
    func getDictionary() throws -> [String: CodableValue] {
        switch self {
        case .success(let d):
            func wrap(_ any: Any) -> CodableValue {
                switch any {
                case let s as String: return .string(s)
                case let b as Bool:   return .bool(b)
                case let n as NSNumber: return .number(n.doubleValue)
                case let d as [String: Any]: return .object(d.mapValues(wrap))
                case let a as [Any]:  return .array(a.map(wrap))
                default: return .string(String(describing: any))
                }
            }
            return d.mapValues(wrap)
        case .failure(let e):
            return ["error": .string("\(e)")]
        }
    }
}
