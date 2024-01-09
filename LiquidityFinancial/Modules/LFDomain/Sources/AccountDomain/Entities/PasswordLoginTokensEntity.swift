import Foundation

// sourcery: AutoMockable
public protocol PasswordLoginTokensEntity {
  var accessToken: String { get }
  var refreshToken: String { get }
  var expiresIn: String { get }
}
