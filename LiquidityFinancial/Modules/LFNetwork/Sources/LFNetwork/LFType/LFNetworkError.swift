import Foundation

public typealias DesignatedError = Error & Decodable

public enum LFNetworkError: Error {
  
  case decoding
  case designated(DesignatedError)
  case underlying(Error)
}

extension LFNetworkError: CustomDebugStringConvertible {
  
  public var debugDescription: String {
    switch self {
    case .decoding: return "Failed to decode object"
    case let .designated(error): return error.localizedDescription
    case let .underlying(error): return error.localizedDescription
    }
  }
}

extension LFNetworkError: LocalizedError {
  
  public var errorDescription: String? { debugDescription }
}
