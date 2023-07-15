import Foundation
import OnboardingDomain
import LFUtilities
import LFNetwork

public protocol AuthorizationManagerProtocol {
  func isTokenValid() -> Bool
  func fetchToken() -> String
  func refreshWith(apiToken: AccessTokens)
}

public class AuthorizationManager {
  
  private var accessToken: String?
  private var expiresAt = Date()
  
  public init() {
    update()
  }
}

  // MARK: - AccessTokenManagerProtocol
extension AuthorizationManager: AuthorizationManagerProtocol {
  public func isTokenValid() -> Bool {
    update()
    return accessToken != nil && expiresAt.compare(Date()) == .orderedDescending
  }
  
  public func fetchToken() -> String {
    guard let token = accessToken else {
      return ""
    }
    return token
  }
  
  public func refreshWith(apiToken: AccessTokens) {
    let expiresAt = apiToken.expiresAt
    let token = apiToken.bearerAccessToken
    
    save(token: apiToken)
    self.expiresAt = expiresAt
    self.accessToken = token
  }
}

  // MARK: - Token Expiration
private extension AuthorizationManager {
  func save(token: AccessTokens) {
    UserDefaults.accessTokenExpiresAt = token.expiresAt.timeIntervalSince1970
    UserDefaults.bearerAccessToken = token.bearerAccessToken
  }
  
  func getExpirationDate() -> Date {
    Date(timeIntervalSince1970: UserDefaults.accessTokenExpiresAt)
  }
  
  func getToken() -> String? {
    UserDefaults.bearerAccessToken
  }
  
  func update() {
    accessToken = getToken()
    expiresAt = getExpirationDate()
  }
}
