import Foundation

// sourcery: AutoMockable
public protocol AccessTokensEntity {
  var accessToken: String { get set }
  var tokenType: String { get set }
  var refreshToken: String { get set }
  var expiresIn: Int { get set }
  var expiresAt: Date { get }
  var bearerAccessToken: String { get }
  init(accessToken: String, tokenType: String, refreshToken: String, expiresIn: Int)
}
