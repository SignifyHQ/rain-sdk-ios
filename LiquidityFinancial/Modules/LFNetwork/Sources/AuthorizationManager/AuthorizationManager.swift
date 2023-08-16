import Foundation
import OnboardingDomain
import LFUtilities
import NetworkUtilities

// swiftlint:disable force_unwrapping

public protocol AuthorizationManagerProtocol {
  var logOutForcedName: Notification.Name { get }
  func isTokenValid() -> Bool
  func fetchToken() -> String
  func fetchRefreshToken() -> String
  func refreshWith(apiToken: AccessTokens)
  func refreshToken() async throws
  func clearToken()
  func update()
  func forcedLogout()
}

public class AuthorizationManager {
  
  public var logOutForcedName: Notification.Name {
    Notification.Name("liquidity.authorizationManager.logOutForced")
  }
  
  private var accessToken: String?
  private var expiresAt = Date()
  private var refreshToken: String?
  
  private var currentDate: Date {
    Date()
  }
  private var session = URLSession.shared
  
  public init() {}
  
  public func forcedLogout() {
    NotificationCenter.default.post(name: logOutForcedName, object: nil)
  }
}

  // MARK: - RefreshTokenManager
public extension AuthorizationManager {
  func refreshToken() async throws {
    guard let refreshToken = refreshToken else {
      throw AuthError.missingToken
    }
    var components = URLComponents(string: APIConstants.baseDevURL.absoluteString)!
    components.path = "/v1/password-less/refresh-token"
    
    var body: [String: Any] {
      [
        "refreshToken": refreshToken
      ]
    }
    
    var headers: [String: String] {
      [
        "Content-Type": "application/json",
        "productId": NetworkUtilities.productID
      ]
    }
    
    guard let url = components.url else {
      throw AuthError.urlInvalid
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    } catch {
      throw AuthError.invalidBody
    }
    log.debug("AuthorizationManager: refreshToken \n \(request)")
    do {
      
      let (data, response) = try await session.data(for: request)
      log.debug("AuthorizationManager: refreshToken \n \(response)")
      
      if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == APIConstants.StatusCodes.unauthorized {
        //The server has forcibly logged out the user
        self.forcedLogout()
      }
      
      let accessTokens = try JSONDecoder().decode(AuthorizationAccessTokens.self, from: data)
      refreshWith(apiToken: accessTokens)
      
    } catch {
      log.error("AuthorizationManager: refreshToken \n \(error)")
      throw error
    }
  }
}

  // MARK: - AccessTokenManagerProtocol
extension AuthorizationManager: AuthorizationManagerProtocol {
  public func isTokenValid() -> Bool {
    update()
    return accessToken != nil && expiresAt > currentDate
  }
  
  public func fetchToken() -> String {
    guard let token = accessToken else {
      return ""
    }
    return token
  }
  
  public func fetchRefreshToken() -> String {
    guard let token = refreshToken else {
      return ""
    }
    return token
  }
  
  public func refreshWith(apiToken: AccessTokens) {
    let expiresAt = apiToken.expiresAt
    let token = apiToken.bearerAccessToken
    let refreshToken = apiToken.refreshToken
    save(token: apiToken)
    self.expiresAt = expiresAt
    self.accessToken = token
    self.refreshToken = refreshToken
  }
  
  public func clearToken() {
    clear()
  }
  
  public func update() {
    accessToken = getToken()
    refreshToken = getRefreshToken()
    expiresAt = getExpirationDate()
  }
}

  // MARK: - Token Expiration
private extension AuthorizationManager {
  func save(token: AccessTokens) {
    UserDefaults.accessTokenExpiresAt = token.expiresAt.timeIntervalSince1970
    UserDefaults.bearerAccessToken = token.bearerAccessToken
    UserDefaults.bearerRefreshToken = token.refreshToken
  }
  
  func getExpirationDate() -> Date {
    Date(timeIntervalSince1970: UserDefaults.accessTokenExpiresAt)
  }
  
  func getToken() -> String? {
    UserDefaults.bearerAccessToken
  }
  
  func getRefreshToken() -> String? {
    UserDefaults.bearerRefreshToken
  }
  
  func clear() {
    UserDefaults.accessTokenExpiresAt = 0
    UserDefaults.bearerAccessToken = ""
  }
}
