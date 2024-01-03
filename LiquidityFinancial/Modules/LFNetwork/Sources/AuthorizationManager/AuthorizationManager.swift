import Foundation
import OnboardingDomain
import LFUtilities
import NetworkUtilities

// swiftlint:disable force_unwrapping
struct AuthorizationAccessToken: Decodable, AccessTokensEntity {
  var accessToken: String
  var tokenType: String
  var refreshToken: String
  var expiresIn: Int
  
  init(accessToken: String, tokenType: String, refreshToken: String, expiresIn: Int) {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.refreshToken = refreshToken
    self.expiresIn = expiresIn
  }
  
  private var requestedAt: Date {
    Date()
  }
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
  }
  
  var expiresAt: Date {
    Calendar.current.date(byAdding: .second, value: expiresIn, to: requestedAt) ?? Date()
  }
  
  var bearerAccessToken: String {
    "\(tokenType) \(accessToken)"
  }
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
  
  private var enviroment: NetworkEnvironment {
    NetworkEnvironment(rawValue: UserDefaults.environmentSelection) ?? .productionLive
  }
  
  public var baseURL: URL {
    switch enviroment {
    case .productionLive: return APIConstants.baseProdURL
    case .productionTest: return APIConstants.baseDevURL
    }
  }
  
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
    var components = URLComponents(string: baseURL.absoluteString)!
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
    
    let (data, response) = try await session.data(for: request)
    
    if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == APIConstants.StatusCodes.unauthorized {
      throw AuthError.unauthorized
    } else {
      let accessTokens = try JSONDecoder().decode(AuthorizationAccessToken.self, from: data)
      refreshWith(apiToken: accessTokens)
    }
  }
}

// MARK: - AccessTokenProvider
extension AuthorizationManager {
  public func refresh(with accessTokens: OAuthCredential, completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
    Task {
      do {
        try await refreshToken()
        update() // Update new token before refresh
        let credential = OAuthCredential(accessToken: fetchAccessToken(), refreshToken: fetchRefreshToken(), expiresIn: expiresAt)
        completion(.success(credential))
      } catch {
        log.error(error.userFriendlyMessage)
        completion(.failure(error))
        if error is AuthError {
          forcedLogout() //The server has forcibly logged out the user
        }
      }
    }
  }
  
  public func fetchTokens() -> OAuthCredential? {
    update()
    let accessToken = fetchAccessToken()
    let refreshToken = fetchRefreshToken()
    if accessToken.isEmpty {
      return nil
    }
    return OAuthCredential(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresAt)
  }
}

// MARK: - AccessTokenManagerProtocol
extension AuthorizationManager: AuthorizationManagerProtocol {
  public func isTokenValid() -> Bool {
    update()
    return accessToken != nil && expiresAt > currentDate
  }
  
  public func fetchAccessToken() -> String {
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
  
  public func refreshWith(apiToken: AccessTokensEntity) {
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
  func save(token: AccessTokensEntity) {
    UserDefaults.accessTokenExpiresAt = token.expiresAt.timeIntervalSince1970
    UserDefaults.bearerAccessToken = token.accessToken
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
