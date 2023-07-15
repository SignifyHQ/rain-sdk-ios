import Foundation

public protocol AccessTokens {
  var accessToken: String { get }
  var tokenType: String { get }
  var refreshToken: String { get }
  var expiresIn: Int { get }
  var expiresAt: Date { get }
  var bearerAccessToken: String { get }
}
