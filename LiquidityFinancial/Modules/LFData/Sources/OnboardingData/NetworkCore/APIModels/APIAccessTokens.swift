import Foundation

public struct APIAccessTokens: Decodable, Equatable {
  
  public enum AccessTokenConstants {
      // Anticipate expiration by 5 minute to avoid race condition with network.
    static let expiryAnticipation = Double(60 * 5)
  }
  
  public let accessToken: String
  public let refreshToken: String?
  public let expiresIn: Date
  
  public var requiresRefresh: Bool {
    if expiresIn > Date() {
      return false
    }
    return true
  }
}
