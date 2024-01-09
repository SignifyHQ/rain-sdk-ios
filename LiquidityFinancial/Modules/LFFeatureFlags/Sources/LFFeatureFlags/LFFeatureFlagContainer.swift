import Foundation
import LFUtilities

// All feature flags we must define inside the `LFFeatureFlagContainer`
//swiftlint: disable identifier_name
public struct LFFeatureFlagContainer {
  
  // MARK: Expose feature flag
  public static var isPasswordLoginFeatureFlagEnabled: Bool {
    switch LFUtilities.target {
    case .PrideCard:
      return enablePasswordLoginFlagPrideCard.value
    case .CauseCard:
      return enablePasswordLoginFlagCauseCard.value
    case .PawsCard:
      return enablePasswordLoginFlagPawsCard.value
    case .DogeCard:
      return enablePasswordLoginFlagDogeCard.value
    default:
      return false
    }
  }
  
  public static var isMultiFactorAuthFeatureFlagEnabled: Bool {
    switch LFUtilities.target {
    case .PrideCard:
      return enableMultiFactorAuthFlagPrideCard.value
    case .CauseCard:
      return enableMultiFactorAuthFlagCauseCard.value
    case .PawsCard:
      return enableMultiFactorAuthFlagPawsCard.value
    case .DogeCard:
      return enableMultiFactorAuthFlagDogeCard.value
    default:
      return false
    }
  }
  
  // MARK: Define feature flag for each target
  static let enablePasswordLoginFlagPrideCard = ToggleFeatureFlag(
    title: "Password-Login-PrideCard", defaultValue: true, group: "Authentication"
  )
  
  static let enablePasswordLoginFlagCauseCard = ToggleFeatureFlag(
    title: "Password-Login-CauseCard", defaultValue: true, group: "Authentication"
  )
  
  static let enablePasswordLoginFlagDogeCard = ToggleFeatureFlag(
    title: "Password-Login-DogeCard", defaultValue: false, group: "Authentication"
  )
  
  static let enablePasswordLoginFlagPawsCard = ToggleFeatureFlag(
    title: "Password-Login-PawsCard", defaultValue: false, group: "Authentication"
  )
  
  static let enableMultiFactorAuthFlagPrideCard = ToggleFeatureFlag(
    title: "MFA-PrideCard", defaultValue: true, group: "Authentication"
  )
  
  static let enableMultiFactorAuthFlagCauseCard = ToggleFeatureFlag(
    title: "MFA-CauseCard", defaultValue: true, group: "Authentication"
  )
  
  static let enableMultiFactorAuthFlagDogeCard = ToggleFeatureFlag(
    title: "MFA-DogeCard", defaultValue: false, group: "Authentication"
  )
  
  static let enableMultiFactorAuthFlagPawsCard = ToggleFeatureFlag(
    title: "MFA-PawsCard", defaultValue: false, group: "Authentication"
  )
  
  // MARK: register/unregister the feature flag (It supports show hub flag setting UI)
  // PawsCard
  public static func registerViewFactoryPawscard() {
    LFFeatureFlagsController.shared.addViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagPawsCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagPawsCard
      ]
    )
  }
  
  public static func unregisterViewFactoryPawscard() {
    LFFeatureFlagsController.shared.removeViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagPawsCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagPawsCard
      ]
    )
  }
  
  // PrideCard
  public static func registerViewFactoryPridecard() {
    LFFeatureFlagsController.shared.addViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagPrideCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagPrideCard
      ]
    )
  }
  
  public static func unregisterViewFactoryPridecard() {
    LFFeatureFlagsController.shared.removeViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagPrideCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagPrideCard
      ]
    )
  }
  
  // DogeCard
  public static func registerViewFactoryDogecard() {
    LFFeatureFlagsController.shared.addViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagDogeCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagDogeCard
      ]
    )
  }
  
  public static func unregisterViewFactoryDogecard() {
    LFFeatureFlagsController.shared.removeViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagDogeCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagDogeCard
      ]
    )
  }
  
  // CauseCard
  public static func registerViewFactoryCausecard() {
    LFFeatureFlagsController.shared.addViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagCauseCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagCauseCard
      ]
    )
  }
  
  public static func unregisterViewFactoryCausecard() {
    LFFeatureFlagsController.shared.removeViewFactory(
      [
        LFFeatureFlagContainer.enablePasswordLoginFlagCauseCard,
        LFFeatureFlagContainer.enableMultiFactorAuthFlagCauseCard
      ]
    )
  }
}
