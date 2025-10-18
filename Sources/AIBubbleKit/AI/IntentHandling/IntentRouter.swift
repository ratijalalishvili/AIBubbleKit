import Foundation

public class IntentRouter {
    private var registeredIntents: [String: AppIntent] = [:]
    weak var intentHandler: IntentHandling?

    public init(intentHandler: IntentHandling?) {
        self.intentHandler = intentHandler
    }

    public func registerIntent(_ intent: AppIntent) {
        registeredIntents[intent.id] = intent
    }

    public func getIntent(by id: String) -> AppIntent? {
        return registeredIntents[id]
    }

    public func allIntents() -> [AppIntent] {
        return Array(registeredIntents.values)
    }

    public func routeIntent(id: String, entities: [String: Any]) async {
        if let intent = registeredIntents[id] {
            await intent.handler(entities)
        } else {
            print("Intent with ID \(id) not found.")
        }
    }

    public func findLocalIntent(for text: String) -> (AppIntent, [String: Any])? {
        let lowercaseText = text.lowercased()
        for intent in registeredIntents.values {
            for keyword in intent.keywords {
                if lowercaseText.contains(keyword.lowercased()) {
                    // Simple entity extraction for now - can be expanded later
                    return (intent, ["query": text])
                }
            }
        }
        return nil
    }
}
