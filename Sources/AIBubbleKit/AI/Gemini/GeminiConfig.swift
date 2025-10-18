import Foundation

public struct GeminiConfig {
    public var apiKey: String
    public var model: String
    public var systemInstruction: String?
    public var safety: [GeminiClient.SafetySetting]
    public init(apiKey: String,
                model: String = "models/gemini-2.5-flash",
                systemInstruction: String? = nil,
                safety: [GeminiClient.SafetySetting] = []) {
        self.apiKey = apiKey
        self.model = model
        self.systemInstruction = systemInstruction
        self.safety = safety
    }
}
