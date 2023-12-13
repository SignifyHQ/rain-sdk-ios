import Foundation

// All feature flags we must define inside the `LFFeatureFlagContainer`
//swiftlint: disable identifier_name
public struct LFFeatureFlagContainer {
  
  // MARK: Define feature flag
  public static let enableMultiFactorAuthenticationFlagPrideCard = ToggleFeatureFlag(
    title: "Authentication-PrideCard", defaultValue: false, group: "Authentication"
  )
  
  public static let enableMultiFactorAuthenticationFlagCauseCard = ToggleFeatureFlag(
    title: "Authentication-CauseCard", defaultValue: false, group: "Authentication"
  )
  
  public static let enableMultiFactorAuthenticationFlagDogeCard = ToggleFeatureFlag(
    title: "Authentication-DogeCard", defaultValue: false, group: "Authentication"
  )
  
  // MARK: register/unregister the feature flag (It supports show hub flag setting UI)
  // PrideCard
  public static func registerViewFactoryPridecard() {
    LFFeatureFlagsController.shared.addViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagPrideCard)
  }
  
  public static func unregisterViewFactoryPridecard() {
    LFFeatureFlagsController.shared.removeViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagPrideCard)
  }
  
  // DogeCard
  public static func registerViewFactoryDogecard() {
    LFFeatureFlagsController.shared.addViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagDogeCard)
  }
  
  public static func unregisterViewFactoryDogecard() {
    LFFeatureFlagsController.shared.removeViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagDogeCard)
  }
  
  // CauseCard
  public static func registerViewFactoryCausecard() {
    LFFeatureFlagsController.shared.addViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagCauseCard)
  }
  
  public static func unregisterViewFactoryCausecard() {
    LFFeatureFlagsController.shared.removeViewFactory(LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagCauseCard)
  }
  
}
