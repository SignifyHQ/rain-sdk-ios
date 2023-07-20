import Foundation

public extension UserDefaults {
  
  @LFUserDefault(key: Key.hasRegisterPushToken, defaultValue: false)
  static var hasRegisterPushToken: Bool
  
  @LFUserDefault(key: Key.accessTokenExpiresAt, defaultValue: 0)
  static var accessTokenExpiresAt: TimeInterval
  
  @LFUserDefault(key: Key.bearerAccessToken, defaultValue: "")
  static var bearerAccessToken: String
  
  @LFUserDefault(key: Key.environmentSelection, defaultValue: "")
  static var environmentSelection: String
  
  @LFUserDefault(key: Key.phoneNumber, defaultValue: "")
  static var phoneNumber: String
  
  @LFUserDefault(key: Key.userSessionID, defaultValue: "")
  static var userSessionID: String
}
