import Foundation
import SwiftUI

// MARK: - Assistant Models

public enum AssistantMode: String, CaseIterable {
    case text = "text"
    case voice = "voice"
    case functionCall = "function_call"
}

public struct AssistantResponse {
    public let mode: AssistantMode
    public let title: String?
    public let text: String
    public let speak: String
    public let followUp: [String]
    public let functionCall: FunctionCall?
    public let safety: SafetyInfo
    
    public init(
        mode: AssistantMode,
        title: String? = nil,
        text: String,
        speak: String,
        followUp: [String],
        functionCall: FunctionCall? = nil,
        safety: SafetyInfo
    ) {
        self.mode = mode
        self.title = title
        self.text = text
        self.speak = speak
        self.followUp = followUp
        self.functionCall = functionCall
        self.safety = safety
    }
}

public struct FunctionCall {
    public let name: String
    public let arguments: [String: Any]
    
    public init(name: String, arguments: [String: Any]) {
        self.name = name
        self.arguments = arguments
    }
}

public struct SafetyInfo {
    public let piiPresent: Bool
    public let needsDisclaimer: Bool
    public let refusal: Bool
    public let refusalReason: String?
    
    public init(
        piiPresent: Bool = false,
        needsDisclaimer: Bool = false,
        refusal: Bool = false,
        refusalReason: String? = nil
    ) {
        self.piiPresent = piiPresent
        self.needsDisclaimer = needsDisclaimer
        self.refusal = refusal
        self.refusalReason = refusalReason
    }
}
