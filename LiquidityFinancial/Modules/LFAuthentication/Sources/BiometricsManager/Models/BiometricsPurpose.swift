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
      return L10N.Common.Authentication.BiometricsEnableLocalizedFallback.title
    case .authentication:
      return L10N.Common.Authentication.BiometricsAuthenticationLocalizedFallback.title
    case .backup:
      return L10N.Common.Authentication.BiometricsBackupLocalizedFallback.title
    }
  }
}
