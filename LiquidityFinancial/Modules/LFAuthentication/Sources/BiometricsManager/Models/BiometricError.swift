import Foundation
import LocalAuthentication

public enum BiometricError: LocalizedError {
  case authenticationFailed
  case userCancel
  case userFallback
  case biometryNotAvailable
  case biometryNotEnrolled
  case biometryLockout
  case unknown
  
  static func biometricError(from error: NSError?) -> BiometricError {
    guard let error else {
      return .unknown
    }
    
    switch error {
    case LAError.authenticationFailed:
      return .authenticationFailed
    case LAError.userCancel:
      return .userCancel
    case LAError.userFallback:
      return .userFallback
    case LAError.biometryNotAvailable:
      return .biometryNotAvailable
    case LAError.biometryNotEnrolled:
      return .biometryNotEnrolled
    case LAError.biometryLockout:
      return .biometryLockout
    default:
      return .unknown
    }
  }
}
