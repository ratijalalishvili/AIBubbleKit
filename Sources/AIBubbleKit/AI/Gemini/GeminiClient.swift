import Foundation

public enum CodableValue: Codable, Equatable {
    case string(String), number(Double), bool(Bool), object([String: CodableValue]), array([CodableValue]), null
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let b = try? c.decode(Bool.self) { self = .bool(b) }
        else if let n = try? c.decode(Double.self) { self = .number(n) }
        else if let s = try? c.decode(String.self) { self = .string(s) }
        else if let a = try? c.decode([CodableValue].self) { self = .array(a) }
        else if let o = try? c.decode([String: CodableValue].self) { self = .object(o) }
        else { throw DecodingError.typeMismatch(CodableValue.self, .init(codingPath: decoder.codingPath, debugDescription: "Unsupported")) }
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null: try c.encodeNil()
        case .bool(let v): try c.encode(v)
        case .number(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        case .object(let v): try c.encode(v)
        }
    }
}

/// Minimal REST client for Gemini `models.generateContent`
public final class GeminiClient {
    public struct Part: Codable {
        public var text: String?
        public var functionCall: FunctionCallPart?
        public var functionResponse: FunctionResponsePart?
        public init(text: String? = nil, functionCall: FunctionCallPart? = nil, functionResponse: FunctionResponsePart? = nil) {
            self.text = text; self.functionCall = functionCall; self.functionResponse = functionResponse
        }
        public struct FunctionCallPart: Codable { public let name: String; public let args: [String: CodableValue] }
        public struct FunctionResponsePart: Codable { public let name: String; public let response: [String: CodableValue] }
    }

    public struct Content: Codable { public let role: String; public let parts: [Part] }

    public struct FunctionDeclaration: Codable {
        public let name: String
        public let description: String?
        public let parameters: [String: CodableValue]?
    }

    public struct Tool: Codable { public let functionDeclarations: [FunctionDeclaration]? }

    public struct SafetySetting: Codable { public let category: String; public let threshold: String }

    public struct GenerateContentRequest: Codable {
        public let contents: [Content]
        public let tools: [Tool]?
        public let toolConfig: ToolConfig?
        public let safetySettings: [SafetySetting]?
        public let systemInstruction: Content?
        public let generationConfig: GenerationConfig?
        public struct ToolConfig: Codable {
            public let functionCallingConfig: FunctionCallingConfig?
            public struct FunctionCallingConfig: Codable { public let mode: String?; public let allowedFunctionNames: [String]? }
        }
        public struct GenerationConfig: Codable { public let temperature: Double?; public let topP: Double?; public let topK: Int?; public let responseMimeType: String? }
    }

    public struct GenerateContentResponse: Codable {
        public struct Candidate: Codable { public let content: Content; public let finishReason: String? }
        public let candidates: [Candidate]?
        public let promptFeedback: PromptFeedback?
        public struct PromptFeedback: Codable { public let blockReason: String? }
    }

    public enum ClientError: Error { case api(String), network(Error), decoding(Error), noCandidates, blocked(String) }

    private let base = URL(string: "https://generativelanguage.googleapis.com/v1beta")!
    private let apiKey: String
    private let model: String
    private let safety: [SafetySetting]
    private let systemInstruction: String?

    public init(config: GeminiConfig) {
        self.apiKey = config.apiKey
        self.model = config.model
        self.safety = config.safety
        self.systemInstruction = config.systemInstruction
    }

    public func generate(
        messages: [Content],
        tools: [Tool]? = nil,
        toolConfig: GenerateContentRequest.ToolConfig? = nil,
        generation: GenerateContentRequest.GenerationConfig? = nil
    ) async throws -> GenerateContentResponse {
        var url = base.appendingPathComponent("\(model):generateContent")
        url.append(queryItems: [URLQueryItem(name: "key", value: apiKey)])
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let body = GenerateContentRequest(
            contents: messages,
            tools: tools,
            toolConfig: toolConfig,
            safetySettings: safety.isEmpty ? nil : safety,
            systemInstruction: systemInstruction.map { Content(role: "system", parts: [.init(text: $0)]) },
            generationConfig: generation
        )

        do {
            req.httpBody = try JSONEncoder().encode(body)
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode ?? 500 < 300 else {
                let msg = String(data: data, encoding: .utf8) ?? "HTTP error"
                throw ClientError.api(msg)
            }
            let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: data)
            if let reason = decoded.promptFeedback?.blockReason { throw ClientError.blocked(reason) }
            guard decoded.candidates?.isEmpty == false else { throw ClientError.noCandidates }
            return decoded
        } catch let e as ClientError { throw e }
        catch let e as DecodingError { throw ClientError.decoding(e) }
        catch { throw ClientError.network(error) }
    }
}
