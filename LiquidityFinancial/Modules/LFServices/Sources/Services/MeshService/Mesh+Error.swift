import Foundation

public enum LFMeshError: Error {
  case unknown
  case customError(message: String)
}

extension LFMeshError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .unknown:
      return "An unknown error occurred."
    case .customError(let message):
      return message
    }
  }
}
