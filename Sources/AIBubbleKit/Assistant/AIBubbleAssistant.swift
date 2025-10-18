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
    public let speechManager: SpeechManager?
    public let functionHandler: AIFunctionManager
    
    // MARK: - Initialization
    public init(configuration: AssistantConfiguration) {
        self.configuration = configuration
        self.functionHandler = AIFunctionManager()
        
        // Initialize speech manager if voice is enabled
        if configuration.voiceMode.enabled {
            self.speechManager = SpeechManager()
        } else {
            self.speechManager = nil
        }
        
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
    
    /// Process voice input (transcribe and then process as text)
    public func processVoiceInput(audioData: Data) async {
        guard let speechManager = speechManager else {
            await processTextInput("Voice input is not available")
            return
        }
        
        isProcessing = true
        
        do {
            let transcription = try await speechManager.transcribe(audioData)
            await processTextInput(transcription)
        } catch {
            isProcessing = false
            handleError(error)
        }
    }
    
    /// Start voice recording for input
    public func startVoiceRecording() {
        speechManager?.startRecording()
    }
    
    /// Stop voice recording and process the audio
    public func stopVoiceRecording() async {
        guard let speechManager = speechManager else { return }
        
        let audioData = speechManager.stopRecording()
        await processVoiceInput(audioData: audioData)
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
    
    // MARK: - Private Methods
    
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
        return [GeminiClient.Tool(functionDeclarations: [createTask, searchKB])]
    }
    
    private func setupFunctionHandler() {
        functionHandler.registerFunction("search_knowledge_base") { [weak self] args in
            return await self?.searchKnowledgeBase(args) ?? .failure(.functionNotFound)
        }
        
        functionHandler.registerFunction("create_task") { [weak self] args in
            return await self?.createTask(args) ?? .failure(.functionNotFound)
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

        // 3) Plain text
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
