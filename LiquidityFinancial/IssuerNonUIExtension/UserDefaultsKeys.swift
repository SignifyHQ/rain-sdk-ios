import Foundation

enum AppGroup {
  static let identifier = "group.com.rain-liquidity.avalanche"
}

enum UserDefaultsKeys {
  static let accessToken = "walletExtensionAccessToken"
  static let refreshToken = "walletExtensionRefreshToken"
  static let expiresAt = "walletExtensionAccessTokenExpiresAt"
}

struct SharedUserDefaults {
  static let current = SharedUserDefaults()
  
  private let sharedDefaults = UserDefaults(suiteName: AppGroup.identifier)
  
  var accessToken: String? {
    if let token = sharedDefaults?.string(forKey: UserDefaultsKeys.accessToken),
       !token.isEmpty {
      return token
    }
    
    return nil
  }
  
  var refreshToken: String? {
    if let token = sharedDefaults?.string(forKey: UserDefaultsKeys.refreshToken),
       !token.isEmpty {
      return token
    }
    
    return nil
  }
  
  var expiresAt: Double? {
    if let timestamp = sharedDefaults?.double(forKey: UserDefaultsKeys.expiresAt),
       timestamp > 0 {
      return timestamp
    }
    
    return nil
  }
}
