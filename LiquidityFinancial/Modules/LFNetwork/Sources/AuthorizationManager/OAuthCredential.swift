import Foundation
import OnboardingDomain
import Alamofire

public struct AuthCredential: Decodable {
  public let accessToken: String
  public let refreshToken: String?
  public let expiresIn: Date
  
  public init(
    accessToken: String,
    refreshToken: String?,
    expiresIn: Date
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.expiresIn = expiresIn
  }
}

extension AuthCredential: AuthenticationCredential {
  public var requiresRefresh: Bool {
    if expiresIn > Date() {
      return false
    }
    
    return true
  }
}
