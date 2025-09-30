import Foundation

public extension Key {
  static let hasRegisterPushToken: Key = "hasRegisterPushToken"
  static let didShowPushTokenPopup: Key = "didShowPushTokenPopup"
  static let lastestFCMToken: Key = "lastestFCMToken"
  static let accessTokenExpiresAt: Key = "accessTokenExpiresAt"
  static let bearerAccessToken: Key = "bearerAccessToken"
  static let bearerRefreshToken: Key = "bearerRefreshToken"
  static let portalSessionToken: Key = "portalSessionToken"
  static let environmentSelection: Key = "EnvironmentSelection"
  static let phoneCode: Key = "UserPhoneCode"
  static let phoneNumber: Key = "UserPhoneNumber"
  static let userEmail: Key = "UserEmail"
  static let userSessionID: Key = "UserSessionID"
  static let userNameDisplay: Key = "userNameDisplay"
  static let showRoundUpForCause: Key = "showRoundUpForCause"
  static let userCompleteOnboarding: Key = "userCompleteOnboarding"
  static let isFirstRun: Key = "isFirstRun"
  static let isBiometricUsageEnabled: Key = "isBiometricUsageEnabled"
  static let isStartedWithLoginFlow: Key = "isStartedWithLoginFlow"
  static let hasFrntCard: Key = "hasFrntCard"
  static let hasShownApplePayPopup: Key = "hasShownApplePayPopup"
  
  // Walelt extension keys
  static let walletExtensionAccessTokenExpiresAt: Key = "walletExtensionAccessTokenExpiresAt"
  static let walletExtensionAccessToken: Key = "walletExtensionAccessToken"
  static let walletExtensionRefreshToken: Key = "walletExtensionRefreshToken"
}
