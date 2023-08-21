import Foundation
import LFUtilities

public typealias DesignatedError = Error & Decodable

public enum LFNetworkError: Error, Equatable {
  public static func == (lhs: LFNetworkError, rhs: LFNetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.decoding, .decoding): return true
    case (.designated, .designated): return true
    case (.underlying, .underlying): return true
    case (.unAuthorized, .unAuthorized): return true
    case (.custom(let messageA), .custom(let messageB)): return messageA == messageB
    default: return false
    }
  }
  
  case decoding
  case designated(DesignatedError)
  case underlying(Error)
  case unAuthorized
  case custom(message: String)
}

extension LFNetworkError: CustomDebugStringConvertible {
  
  public var debugDescription: String {
    switch self {
    case .decoding: return "Failed to decode object"
    case let .designated(error): return error.localizedDescription
    case let .underlying(error): return error.localizedDescription
    case .unAuthorized: return "unauthorized"
    case .custom(let message): return message
    }
  }
}

extension LFNetworkError: LocalizedError {
  
  public var errorDescription: String? { debugDescription }
}
