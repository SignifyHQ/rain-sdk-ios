import Foundation
import OnboardingDomain

struct AuthorizationAccessTokens: Decodable, AccessTokens {
  let accessToken: String
  let tokenType: String
  let refreshToken: String
  let expiresIn: Int
  
  private var requestedAt = Date()
  
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
