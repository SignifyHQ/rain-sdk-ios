import Foundation
import LocalAuthentication
import LFLocalizable

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
  
  public var title: String {
    switch self {
    case .faceID:
      return LFLocalizable.Authentication.BiometricsFaceID.title
    case .touchID:
      return LFLocalizable.Authentication.BiometricsTouchID.title
    default:
      return ""
    }
  }
}
