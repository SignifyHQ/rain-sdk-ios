import Foundation
import OnboardingDomain
import LFUtilities
import NetworkUtilities

// sourcery: AutoMockable
public protocol AuthorizationManagerProtocol {
  var logOutForcedName: Notification.Name { get }
  func isTokenValid() -> Bool
  func fetchAccessToken() -> String
  func fetchRefreshToken() -> String
  func refreshWith(apiToken: AccessTokensEntity)
  func savePortalSessionToken(token: String?)
  func refreshToken() async throws
  func clearToken()
  func update()
  func forcedLogout()
  func refresh(with accessTokens: OAuthCredential, completion: @escaping (Result<OAuthCredential, Error>) -> Void)
  func fetchTokens() -> OAuthCredential?
}
