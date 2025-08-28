import Combine
import FirebaseAppCheck
import Foundation
import LFUtilities
import NetworkUtilities
import OnboardingDomain
import RecaptchaEnterprise

// swiftlint:disable force_unwrapping
struct AuthorizationAccessToken: Decodable, AccessTokensEntity {
  var accessToken: String
  var tokenType: String
  var refreshToken: String
  var portalSessionToken: String?
  var expiresIn: Int
  
  init(
    accessToken: String,
    tokenType: String,
    refreshToken: String,
    portalSessionToken: String?,
    expiresIn: Int
  ) {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.refreshToken = refreshToken
    self.portalSessionToken = portalSessionToken
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
    case portalSessionToken = "portal_session_token"
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
  private var subscriptions = Set<AnyCancellable>()
  
  private var enviroment: NetworkEnvironment {
    NetworkEnvironment(rawValue: UserDefaults.environmentSelection) ?? .productionLive
  }
  
  public var baseURL: URL {
    switch enviroment {
    case .productionLive:
      APIConstants.baseProdURL
    case .productionTest:
      APIConstants.baseDevURL
    }
  }
  
  private var recaptchaSiteKey: String {
    switch enviroment {
    case .productionTest:
      APIConstants.recaptchaDevSiteKey
    case .productionLive:
      APIConstants.recaptchaProdSiteKey
    }
  }
  
  var recaptchaClient: RecaptchaClient?
  
  public init() {
    NotificationCenter.default
      .publisher(
        for: .environmentChanage
      )
      .compactMap { ($0.userInfo?[Notification.Name.environmentChanage.rawValue] as? NetworkEnvironment)
      }
      .sink { [weak self] value in
        log.debug("Fetch reCaptcha client for environment: \(value)")
        self?.fetchReCaptchaClient()
      }
      .store(
        in: &subscriptions
      )
  }
  
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
  
  public func saveWalletExtenstionTokens(apiToken: AccessTokensEntity) {
    UserDefaults.walletExtensionAccessTokenExpiresAt = apiToken.expiresAt.timeIntervalSince1970
    UserDefaults.walletExtensionAccessToken = apiToken.accessToken
    UserDefaults.walletExtensionRefreshToken = apiToken.refreshToken
  }
  
  public func clearToken() {
    clear()
  }
  
  public func update() {
    accessToken = getToken()
    refreshToken = getRefreshToken()
    expiresAt = getExpirationDate()
  }
  
  public func savePortalSessionToken(token: String?) {
    guard let token else {
      return
    }
    
    UserDefaults.portalSessionToken = token
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
    UserDefaults.bearerAccessToken = .empty
    UserDefaults.portalSessionToken = .empty
    
    UserDefaults.walletExtensionAccessTokenExpiresAt = 0
    UserDefaults.walletExtensionAccessToken = .empty
    UserDefaults.walletExtensionRefreshToken = .empty
  }
}

// MARK: - reCaptcha Enterprise
extension AuthorizationManager {
  private func fetchReCaptchaClient() {
    // Only initialize reCaptcha client in production environment
    guard recaptchaClient == nil,
          enviroment == .productionLive
    else {
      return
    }
    
    Task {
      do {
        self.recaptchaClient = try await Recaptcha.fetchClient(withSiteKey: recaptchaSiteKey)
      } catch let error as RecaptchaError {
        log.error("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
      }
    }
  }
  
  public func getReCaptchaToken(for action: RecaptchaAction) async throws -> String {
    // Only get token in production environment
    guard enviroment == .productionLive
    else {
      return .empty
    }
    
    guard let recaptchaClient
    else {
      throw AuthError.missingToken
    }
    
    return try await recaptchaClient.execute(withAction: action)
  }
}

// MARK: - AppCheck
extension AuthorizationManager {
  public func getAppCheckToken() async throws -> String {
    // Only get token in production environment
    guard enviroment == .productionLive
    else {
      return .empty
    }
    
    return try await AppCheck.appCheck().token(forcingRefresh: false).token
  }
}
