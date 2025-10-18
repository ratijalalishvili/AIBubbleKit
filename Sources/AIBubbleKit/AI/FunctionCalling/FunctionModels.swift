import Foundation

public enum FunctionResult {
    case success([String: Any])
    case failure(FunctionError)
}

public enum FunctionError: Error {
    case functionNotFound
    case invalidArguments
    case executionFailed(String)
}

public typealias AIFunctionHandler = ([String: Any]) async -> FunctionResult
