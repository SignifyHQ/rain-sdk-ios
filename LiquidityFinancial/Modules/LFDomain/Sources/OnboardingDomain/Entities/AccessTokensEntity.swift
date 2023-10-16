import Foundation

public protocol AccessTokensEntity {
  var accessToken: String { set get }
  var tokenType: String { set get }
  var refreshToken: String { set get }
  var expiresIn: Int { set get }
  var expiresAt: Date { get }
  var bearerAccessToken: String { get }
  init(accessToken: String, tokenType: String, refreshToken: String, expiresIn: Int)
}
