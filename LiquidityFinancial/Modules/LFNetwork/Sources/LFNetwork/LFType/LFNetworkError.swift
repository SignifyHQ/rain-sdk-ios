import Foundation
import LFUtilities

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

public struct LFErrorObject: Codable, LocalizedError {
  let requestId: String
  let message: String
  let key: String?
  let sysMessage: String?
  let code: String?
  let errorDetail: [String: AnyCodable]?
  
  public var errorDescription: String? {
    if message.isEmpty {
      return "\(sysMessage ?? ""), reqId: \(requestId)"
    }
    return "\(message) , reqId: \(requestId)"
  }
}

extension Error {
  var asErrorObject: LFErrorObject? {
    self as? LFErrorObject
  }
}
