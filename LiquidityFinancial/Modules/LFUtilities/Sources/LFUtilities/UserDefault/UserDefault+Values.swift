import Foundation

public extension UserDefaults {
  
  @LFUserDefault(key: Key.hasRegisterPushToken, defaultValue: false)
  static var hasRegisterPushToken: Bool
  
  @LFUserDefault(key: Key.didShowPushTokenPopup, defaultValue: false)
  static var didShowPushTokenPopup: Bool
  
  @LFUserDefault(key: Key.lastestFCMToken, defaultValue: "")
  static var lastestFCMToken: String
  
  @LFUserDefault(key: Key.accessTokenExpiresAt, defaultValue: 0)
  static var accessTokenExpiresAt: TimeInterval
  
  @LFUserDefault(key: Key.bearerAccessToken, defaultValue: "")
  static var bearerAccessToken: String
  
  @LFUserDefault(key: Key.bearerRefreshToken, defaultValue: "")
  static var bearerRefreshToken: String
  
  @LFUserDefault(key: Key.portalSessionToken, defaultValue: "")
  static var portalSessionToken: String
  
  @LFUserDefault(key: Key.environmentSelection, defaultValue: "")
  static var environmentSelection: String
  
  @LFUserDefault(key: Key.phoneCode, defaultValue: "")
  static var phoneCode: String
  
  @LFUserDefault(key: Key.phoneNumber, defaultValue: "")
  static var phoneNumber: String
  
  @LFUserDefault(key: Key.userSessionID, defaultValue: [:])
  static var userSessionID: [String: String]
  
  @LFUserDefault(key: Key.userNameDisplay, defaultValue: "")
  static var userNameDisplay: String
  
  @LFUserDefault(key: Key.userEmail, defaultValue: "")
  static var userEmail: String
  
  @LFUserDefault(key: Key.showRoundUpForCause, defaultValue: false)
  static var showRoundUpForCause: Bool
  
  @LFUserDefault(key: Key.userCompleteOnboarding, defaultValue: false)
  static var userCompleteOnboarding: Bool
  
  @LFUserDefault(key: Key.isFirstRun, defaultValue: true)
  static var isFirstRun: Bool
  
  @LFUserDefault(key: Key.isBiometricUsageEnabled, defaultValue: false, parameter: UserDefaults.phoneNumber)
  static var isBiometricUsageEnabled: Bool
  
  @LFUserDefault(key: Key.isStartedWithLoginFlow, defaultValue: true)
  static var isStartedWithLoginFlow: Bool
}
