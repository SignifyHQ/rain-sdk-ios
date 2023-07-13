import Foundation

public protocol AccessTokens {
  var accessToken: String { get }
  var refreshToken: String? { get }
  var expiresIn: Date { get }
  
  var requiresRefresh: Bool { get }
}
