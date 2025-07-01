import Foundation

public enum PlacesError: Error {
  case failedToParseAddress
}

extension PlacesError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .failedToParseAddress:
      return "Could not extract address fields"
    }
  }
}
