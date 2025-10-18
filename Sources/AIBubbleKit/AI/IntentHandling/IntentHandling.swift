import Foundation

public protocol IntentHandling: AnyObject {
    func handleIntent(id: String, entities: [String: Any]) async
}
