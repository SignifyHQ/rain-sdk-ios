import Foundation

enum AddressInfoError: Error, LocalizedError {
  case invalidAddress1
  case invalidAddress2
  case invalidCity
  case invalidState
  case invalidZip

  /// API related custom error title
  var errorDescription: String? {
    switch self {
    case .invalidAddress1:
      return "Invalid address line1"
    case .invalidAddress2:
      return "Invalid address line2"
    case .invalidCity:
      return "Invalid city"
    case .invalidState:
      return "Invalid state"
    case .invalidZip:
      return "Invalid SSN"
    }
  }
}
