import Foundation

// All feature flags we must define inside the `LFFeatureFlagContainer`
public struct LFFeatureFlagContainer {
  
  //MARK: Define feature flag
  public static let enableMultiFactorAuthenticationFlag = ToggleFeatureFlag(
    title: "Multi-Factor Authentication", defaultValue: false, group: "Authentication"
  )
  
  //MARK: register/unregister the feature flag (It supports show hub flag setting UI)
  public static func registerViewFactory() {
    LFFeatureFlagsController.shared.addViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlag)
  }
  
  public static func unregisterViewFactory() {
    LFFeatureFlagsController.shared.removeViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlag)
  }
  
}
