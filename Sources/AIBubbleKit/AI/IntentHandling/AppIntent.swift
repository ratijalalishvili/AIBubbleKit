import Foundation

public struct AppIntent: Identifiable {
    public let id: String // Unique identifier for the intent
    public let title: String // User-friendly title for the intent
    public let description: String // Detailed description of what the intent does
    public let sampleUtterances: [String] // Examples of how a user might express this intent
    public let keywords: [String] // Keywords for local fallback routing
    public let handler: ([String: Any]) async -> Void // Closure to be executed when the intent is triggered

    public init(
        id: String,
        title: String,
        description: String,
        sampleUtterances: [String],
        keywords: [String],
        handler: @escaping ([String: Any]) async -> Void
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.sampleUtterances = sampleUtterances
        self.keywords = keywords
        self.handler = handler
    }
}
