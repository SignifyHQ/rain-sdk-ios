import Foundation
import LocalAuthentication
import LFLocalizable
import LFStyleGuide
import SwiftUI

public enum BiometricsPurpose {
  case enable
  case authentication
  case backup
  
  var localizedFallbackTitle: String {
    switch self {
    case .enable:
      return LFLocalizable.Authentication.BiometricsEnableLocalizedFallback.title
    case .authentication:
      return LFLocalizable.Authentication.BiometricsAuthenticationLocalizedFallback.title
    case .backup:
      return LFLocalizable.Authentication.BiometricsBackupLocalizedFallback.title
    }
  }
}
