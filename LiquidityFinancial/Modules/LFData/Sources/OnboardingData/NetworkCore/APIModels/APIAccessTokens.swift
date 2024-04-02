import Foundation

public struct APIAccessTokens: Decodable, Equatable {
  public var accessToken: String
  public var tokenType: String
  public var refreshToken: String
  public var expiresIn: Int
  public var portalSessionToken: String?
  
  public init(
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
  
  public var expiresAt: Date {
    Calendar.current.date(byAdding: .second, value: expiresIn, to: requestedAt) ?? Date()
  }
  
  public var bearerAccessToken: String {
    "\(tokenType) \(accessToken)"
  }
}
