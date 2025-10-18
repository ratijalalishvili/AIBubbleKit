import Foundation

/// Handles function calls for the AI assistant
public class AIFunctionManager {
    private var registeredFunctions: [String: AIFunctionHandler] = [:]
    
    public init() {}
    
    /// Register a function with the handler
    public func registerFunction(_ name: String, handler: @escaping AIFunctionHandler) {
        registeredFunctions[name] = handler
    }
    
    /// Call a registered function with the given arguments
    public func callFunction(name: String, arguments: [String: Any]) async throws -> FunctionResult {
        guard let handler = registeredFunctions[name] else {
            return .failure(.functionNotFound)
        }
        
        return await handler(arguments)
    }
    
    /// Get list of available function names
    public var availableFunctions: [String] {
        return Array(registeredFunctions.keys)
    }
    
    /// Check if a function is registered
    public func isFunctionRegistered(_ name: String) -> Bool {
        return registeredFunctions[name] != nil
    }
    
    /// Unregister a function
    public func unregisterFunction(_ name: String) {
        registeredFunctions.removeValue(forKey: name)
    }
    
    /// Clear all registered functions
    public func clearAllFunctions() {
        registeredFunctions.removeAll()
    }
}

// MARK: - Built-in Function Implementations

public extension AIFunctionManager {
    /// Create a default function handler with built-in functions
    static func createDefault() -> AIFunctionManager {
        let manager = AIFunctionManager()
        
        // Register built-in functions
        manager.registerFunction("search_knowledge_base") { args in
            return await manager.searchKnowledgeBase(args)
        }
        
        manager.registerFunction("create_task") { args in
            return await manager.createTask(args)
        }
        
        manager.registerFunction("get_time") { args in
            return await manager.getCurrentTime(args)
        }
        
        manager.registerFunction("get_weather") { args in
            return await manager.getWeather(args)
        }
        
        return manager
    }
    
    private func searchKnowledgeBase(_ args: [String: Any]) async -> FunctionResult {
        guard let query = args["query"] as? String else {
            return .failure(.invalidArguments)
        }
        
        let topK = args["top_k"] as? Int ?? 5
        
        // Simulate knowledge base search
        let mockResults = [
            "Document 1: Comprehensive guide about \(query)",
            "Document 2: Best practices for \(query)",
            "Document 3: Troubleshooting \(query)",
            "Document 4: Advanced techniques in \(query)",
            "Document 5: Getting started with \(query)"
        ]
        
        let results = Array(mockResults.prefix(topK))
        
        return .success([
            "query": query,
            "results": results,
            "count": results.count,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }
    
    private func createTask(_ args: [String: Any]) async -> FunctionResult {
        guard let title = args["title"] as? String,
              let when = args["when"] as? String else {
            return .failure(.invalidArguments)
        }
        
        // Validate ISO 8601 date format
        let formatter = ISO8601DateFormatter()
        guard formatter.date(from: when) != nil else {
            return .failure(.executionFailed("Invalid date format. Expected ISO 8601 format."))
        }
        
        let taskId = UUID().uuidString
        let task = [
            "id": taskId,
            "title": title,
            "when": when,
            "created": formatter.string(from: Date()),
            "status": "pending"
        ]
        
        return .success([
            "task": task,
            "message": "Task '\(title)' created successfully for \(when)"
        ])
    }
    
    private func getCurrentTime(_ args: [String: Any]) async -> FunctionResult {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let timeString = formatter.string(from: Date())
        let isoString = ISO8601DateFormatter().string(from: Date())
        
        return .success([
            "time": timeString,
            "iso": isoString,
            "timezone": TimeZone.current.identifier,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    private func getWeather(_ args: [String: Any]) async -> FunctionResult {
        // Mock weather data - in a real implementation, this would call a weather API
        let mockWeather = [
            "location": "Current Location",
            "temperature": "72°F",
            "condition": "Partly Cloudy",
            "humidity": "65%",
            "wind": "5 mph NW",
            "forecast": [
                "Today: Partly Cloudy, 72°F",
                "Tomorrow: Sunny, 75°F",
                "Day After: Cloudy, 68°F"
            ]
        ] as [String : Any]
        
        return .success([
            "weather": mockWeather,
            "last_updated": ISO8601DateFormatter().string(from: Date())
        ])
    }
}
