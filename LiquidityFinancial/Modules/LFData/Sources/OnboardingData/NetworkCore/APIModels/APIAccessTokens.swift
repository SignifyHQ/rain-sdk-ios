import Foundation

public struct APIAccessTokens: Decodable, Equatable {
  public var accessToken: String
  public var tokenType: String
  public var refreshToken: String
  public var expiresIn: Int
  
  public init(accessToken: String, tokenType: String, refreshToken: String, expiresIn: Int) {
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
  
  public var expiresAt: Date {
    Calendar.current.date(byAdding: .second, value: expiresIn, to: requestedAt) ?? Date()
  }
  
  public var bearerAccessToken: String {
    "\(tokenType) \(accessToken)"
  }
}
