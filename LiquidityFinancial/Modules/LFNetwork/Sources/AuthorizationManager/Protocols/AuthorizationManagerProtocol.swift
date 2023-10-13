import Foundation
import OnboardingDomain
import LFUtilities
import NetworkUtilities

public protocol AuthorizationManagerProtocol {
  var logOutForcedName: Notification.Name { get }
  func isTokenValid() -> Bool
  func fetchAccessToken() -> String
  func fetchRefreshToken() -> String
  func refreshWith(apiToken: AccessTokens)
  func refreshToken() async throws
  func clearToken()
  func update()
  func forcedLogout()
  func refresh(with accessTokens: OAuthCredential, completion: @escaping (Result<OAuthCredential, Error>) -> Void)
  func fetchTokens() -> OAuthCredential?
}
