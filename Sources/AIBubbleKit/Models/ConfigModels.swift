import Foundation
import SwiftUI
import UIKit

// MARK: - Assistant Configuration

public struct AssistantConfiguration {
    public let agentProfile: AgentProfile
    public let capabilities: Capabilities
    public let hostContext: HostContext
    public let conversationPrefs: ConversationPreferences
    public let voiceMode: VoiceMode
    public let behavior: Behavior
    public let toolUse: ToolUse
    public let responseContract: ResponseContract
    public let constraints: Constraints
    public let refusals: RefusalPolicy
    public let telemetry: Telemetry
    
    public init(
        agentProfile: AgentProfile,
        capabilities: Capabilities,
        hostContext: HostContext,
        conversationPrefs: ConversationPreferences,
        voiceMode: VoiceMode,
        behavior: Behavior,
        toolUse: ToolUse,
        responseContract: ResponseContract,
        constraints: Constraints,
        refusals: RefusalPolicy,
        telemetry: Telemetry
    ) {
        self.agentProfile = agentProfile
        self.capabilities = capabilities
        self.hostContext = hostContext
        self.conversationPrefs = conversationPrefs
        self.voiceMode = voiceMode
        self.behavior = behavior
        self.toolUse = toolUse
        self.responseContract = responseContract
        self.constraints = constraints
        self.refusals = refusals
        self.telemetry = telemetry
    }
}

public struct AgentProfile {
    public let name: String
    public let purpose: String
    public let audience: String
    
    public init(name: String, purpose: String, audience: String) {
        self.name = name
        self.purpose = purpose
        self.audience = audience
    }
}

public struct Capabilities {
    public let modes: [AssistantMode]
    public let supportsStreaming: Bool
    public let supportsFunctionCalls: Bool
    
    public init(modes: [AssistantMode], supportsStreaming: Bool, supportsFunctionCalls: Bool) {
        self.modes = modes
        self.supportsStreaming = supportsStreaming
        self.supportsFunctionCalls = supportsFunctionCalls
    }
}

public struct HostContext {
    public let appName: String
    public let appVersion: String
    public let userId: String
    public let userLocale: String
    public let userTimezone: String
    public let device: String
    public let osVersion: String
    
    public init(
        appName: String,
        appVersion: String,
        userId: String,
        userLocale: String,
        userTimezone: String,
        device: String,
        osVersion: String
    ) {
        self.appName = appName
        self.appVersion = appVersion
        self.userId = userId
        self.userLocale = userLocale
        self.userTimezone = userTimezone
        self.device = device
        self.osVersion = osVersion
    }
}

public struct ConversationPreferences {
    public let style: ConversationStyle
    public let formatting: Formatting
    public let safetyAndPrivacy: SafetyAndPrivacy
    
    public init(style: ConversationStyle, formatting: Formatting, safetyAndPrivacy: SafetyAndPrivacy) {
        self.style = style
        self.formatting = formatting
        self.safetyAndPrivacy = safetyAndPrivacy
    }
}

public struct ConversationStyle {
    public let tone: String
    public let avoid: [String]
    public let emojis: String
    public let links: String
    
    public init(tone: String, avoid: [String], emojis: String, links: String) {
        self.tone = tone
        self.avoid = avoid
        self.emojis = emojis
        self.links = links
    }
}

public struct Formatting {
    public let markdown: Bool
    public let codeBlocks: String
    public let lists: String
    
    public init(markdown: Bool, codeBlocks: String, lists: String) {
        self.markdown = markdown
        self.codeBlocks = codeBlocks
        self.lists = lists
    }
}

public struct SafetyAndPrivacy {
    public let noSensitiveStorage: Bool
    public let piiPolicy: String
    public let medicalLegalFinancialDisclaimer: String
    
    public init(noSensitiveStorage: Bool, piiPolicy: String, medicalLegalFinancialDisclaimer: String) {
        self.noSensitiveStorage = noSensitiveStorage
        self.piiPolicy = piiPolicy
        self.medicalLegalFinancialDisclaimer = medicalLegalFinancialDisclaimer
    }
}

public struct VoiceMode {
    public let enabled: Bool
    public let transcriptionLatencyPreference: String
    public let bargeIn: Bool
    public let tts: TTS
    
    public init(enabled: Bool, transcriptionLatencyPreference: String, bargeIn: Bool, tts: TTS) {
        self.enabled = enabled
        self.transcriptionLatencyPreference = transcriptionLatencyPreference
        self.bargeIn = bargeIn
        self.tts = tts
    }
}

public struct TTS {
    public let allowed: Bool
    public let summarizeLongOutputs: Bool
    
    public init(allowed: Bool, summarizeLongOutputs: Bool) {
        self.allowed = allowed
        self.summarizeLongOutputs = summarizeLongOutputs
    }
}

public struct Behavior {
    public let general: [String]
    public let errorRecovery: [String]
    public let offline: [String]
    public let sensitiveTopics: [String]
    
    public init(general: [String], errorRecovery: [String], offline: [String], sensitiveTopics: [String]) {
        self.general = general
        self.errorRecovery = errorRecovery
        self.offline = offline
        self.sensitiveTopics = sensitiveTopics
    }
}

public struct ToolUse {
    public let policy: [String]
    public let availableFunctions: [FunctionDefinition]
    
    public init(policy: [String], availableFunctions: [FunctionDefinition]) {
        self.policy = policy
        self.availableFunctions = availableFunctions
    }
}

public struct FunctionDefinition {
    public let name: String
    public let description: String
    public let schema: FunctionSchema
    
    public init(name: String, description: String, schema: FunctionSchema) {
        self.name = name
        self.description = description
        self.schema = schema
    }
}

public struct FunctionSchema {
    public let type: String
    public let properties: [String: PropertyDefinition]
    public let required: [String]
    
    public init(type: String, properties: [String: PropertyDefinition], required: [String]) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

public struct PropertyDefinition {
    public let type: String
    public let description: String?
    public let minimum: Int?
    public let maximum: Int?
    
    public init(type: String, description: String? = nil, minimum: Int? = nil, maximum: Int? = nil) {
        self.type = type
        self.description = description
        self.minimum = minimum
        self.maximum = maximum
    }
}

public struct ResponseContract {
    public let mustFollowSchema: Bool
    public let schema: ResponseSchema
    
    public init(mustFollowSchema: Bool, schema: ResponseSchema) {
        self.mustFollowSchema = mustFollowSchema
        self.schema = schema
    }
}

public struct ResponseSchema {
    public let type: String
    public let properties: [String: PropertyDefinition]
    public let required: [String]
    
    public init(type: String, properties: [String: PropertyDefinition], required: [String]) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

public struct Constraints {
    public let maxTokensHint: Int
    public let targetLatencyMs: Int
    public let streamingTokens: Bool
    public let neverBreakSchema: Bool
    
    public init(maxTokensHint: Int, targetLatencyMs: Int, streamingTokens: Bool, neverBreakSchema: Bool) {
        self.maxTokensHint = maxTokensHint
        self.targetLatencyMs = targetLatencyMs
        self.streamingTokens = streamingTokens
        self.neverBreakSchema = neverBreakSchema
    }
}

public struct RefusalPolicy {
    public let policy: String
    
    public init(policy: String) {
        self.policy = policy
    }
}

public struct Telemetry {
    public let events: [String]
    public let includeRequestIds: Bool
    
    public init(events: [String], includeRequestIds: Bool) {
        self.events = events
        self.includeRequestIds = includeRequestIds
    }
}

// MARK: - Default Configuration Factory

public extension AssistantConfiguration {
    static func defaultConfiguration(
        appName: String,
        appVersion: String,
        userId: String,
        voiceEnabled: Bool = false,
        ttsAllowed: Bool = true
    ) -> AssistantConfiguration {
        
        let agentProfile = AgentProfile(
            name: "AIBubble Assistant",
            purpose: "On-device chat and optional voice assistant embedded via AIBubbleKit.",
            audience: "End-users of the host iOS app \(appName)"
        )
        
        let capabilities = Capabilities(
            modes: [.text, .voice],
            supportsStreaming: true,
            supportsFunctionCalls: true
        )
        
        let hostContext = HostContext(
            appName: appName,
            appVersion: appVersion,
            userId: userId,
            userLocale: Locale.current.identifier,
            userTimezone: TimeZone.current.identifier,
            device: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion
        )
        
        let conversationPrefs = ConversationPreferences(
            style: ConversationStyle(
                tone: "friendly, concise, professional",
                avoid: ["jargon unless asked", "overly long replies"],
                emojis: "minimal",
                links: "only if helpful; include short explanation"
            ),
            formatting: Formatting(
                markdown: true,
                codeBlocks: "use when returning code; include language tags",
                lists: "use for steps or multiple options"
            ),
            safetyAndPrivacy: SafetyAndPrivacy(
                noSensitiveStorage: true,
                piiPolicy: "Do not ask for or store PII. If user shares PII, use it only for the current turn and do not retain.",
                medicalLegalFinancialDisclaimer: "Add light disclaimers when providing guidance in these domains."
            )
        )
        
        let voiceMode = VoiceMode(
            enabled: voiceEnabled,
            transcriptionLatencyPreference: "low",
            bargeIn: true,
            tts: TTS(
                allowed: ttsAllowed,
                summarizeLongOutputs: true
            )
        )
        
        let behavior = Behavior(
            general: [
                "Be a helpful, accurate assistant inside a small floating UI bubble.",
                "Prefer short answers first; offer to expand if needed.",
                "If the user request is ambiguous, ask a brief clarifying question.",
                "Respect the host app's theme and context provided above."
            ],
            errorRecovery: [
                "If a tool/API call fails, explain briefly and propose a next step.",
                "Never invent results when a tool is required—state limitation and offer alternatives."
            ],
            offline: [
                "If network appears unavailable (per tool signal), provide offline-friendly suggestions and defer network actions."
            ],
            sensitiveTopics: [
                "Avoid generating unsafe content. Refuse with a brief reason and offer a safe alternative."
            ]
        )
        
        let toolUse = ToolUse(
            policy: [
                "Use tools/functions only when they materially help.",
                "Return function arguments in JSON strictly matching the provided schema.",
                "Do not include explanatory prose inside function arguments."
            ],
            availableFunctions: [
                FunctionDefinition(
                    name: "search_knowledge_base",
                    description: "Search app or domain knowledge",
                    schema: FunctionSchema(
                        type: "object",
                        properties: [
                            "query": PropertyDefinition(type: "string"),
                            "top_k": PropertyDefinition(type: "integer", minimum: 1, maximum: 10)
                        ],
                        required: ["query"]
                    )
                ),
                FunctionDefinition(
                    name: "create_task",
                    description: "Create a reminder/task inside the host app",
                    schema: FunctionSchema(
                        type: "object",
                        properties: [
                            "title": PropertyDefinition(type: "string"),
                            "when": PropertyDefinition(type: "string", description: "ISO 8601")
                        ],
                        required: ["title", "when"]
                    )
                )
            ]
        )
        
        let responseContract = ResponseContract(
            mustFollowSchema: true,
            schema: ResponseSchema(
                type: "object",
                properties: [
                    "mode": PropertyDefinition(type: "string"),
                    "title": PropertyDefinition(type: "string", description: "Short heading for the UI; optional"),
                    "text": PropertyDefinition(type: "string", description: "Primary markdown response for text/voice"),
                    "speak": PropertyDefinition(type: "string", description: "If voice_mode is enabled and short spoken form is useful; otherwise empty"),
                    "follow_up": PropertyDefinition(type: "array", description: "Up to 3 short suggested follow-ups"),
                    "function_call": PropertyDefinition(type: "object"),
                    "safety": PropertyDefinition(type: "object")
                ],
                required: ["mode", "text", "follow_up"]
            )
        )
        
        let constraints = Constraints(
            maxTokensHint: 800,
            targetLatencyMs: 200,
            streamingTokens: true,
            neverBreakSchema: true
        )
        
        let refusals = RefusalPolicy(
            policy: "If a request is unsafe or disallowed, set safety.refusal=true and provide a brief explanation and a safe alternative in 'text'. Do not call tools in this case."
        )
        
        let telemetry = Telemetry(
            events: [
                "message_received",
                "response_stream_started",
                "response_stream_completed",
                "function_call_started",
                "function_call_completed",
                "error"
            ],
            includeRequestIds: true
        )
        
        return AssistantConfiguration(
            agentProfile: agentProfile,
            capabilities: capabilities,
            hostContext: hostContext,
            conversationPrefs: conversationPrefs,
            voiceMode: voiceMode,
            behavior: behavior,
            toolUse: toolUse,
            responseContract: responseContract,
            constraints: constraints,
            refusals: refusals,
            telemetry: telemetry
        )
    }
}
