import Foundation
import LocalAuthentication
import LFLocalizable
import LFStyleGuide
import SwiftUI

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
    default:
      return .unknown
    }
  }
  
  public var title: String {
    switch self {
    case .faceID:
      return L10N.Common.Authentication.BiometricsFaceID.title
    case .touchID:
      return L10N.Common.Authentication.BiometricsTouchID.title
    default:
      return ""
    }
  }
  
  public var image: Image? {
    switch self {
    case .faceID:
      return GenImages.CommonImages.faceID.swiftUIImage
    case .touchID:
      return GenImages.CommonImages.touchID.swiftUIImage
    default:
      return nil
    }
  }
}
