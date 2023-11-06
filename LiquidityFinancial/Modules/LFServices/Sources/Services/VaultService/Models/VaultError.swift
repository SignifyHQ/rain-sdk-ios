import Foundation

public enum VaultError: LocalizedError {
  case unknownError(message: String)
  case validationError(message: String)

  public var errorDescription: String? {
    switch self {
    case let .unknownError(message): return message
    case let .validationError(message): return message
    }
  }
}

struct APIError: Decodable, LocalizedError {
  let error: String
}

struct ValidationError: Decodable, LocalizedError {
  let message: String
}
