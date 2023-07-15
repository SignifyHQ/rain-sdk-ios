import Foundation

public struct APIAccessTokens: Decodable, Equatable {
  public let accessToken: String
  public let tokenType: String
  public let refreshToken: String
  public let expiresIn: Int
  
  private var requestedAt = Date()
  
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
