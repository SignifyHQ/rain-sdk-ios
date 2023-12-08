import Foundation
import LocalAuthentication

public enum BiometricType {
  case none
  case touchID
  case faceID
  case unknown
  
  static func getType(from type: LABiometryType) -> BiometricType {
    switch type {
    case .none:
      return .none
    case .touchID:
      return .touchID
    case .faceID:
      return .faceID
    @unknown default:
      return .unknown
    }
  }
}
