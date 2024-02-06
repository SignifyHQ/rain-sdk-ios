import Foundation
import OnboardingDomain

struct TestAccessTokens: AccessTokensEntity {
  var accessToken: String
  
  var tokenType: String
  
  var refreshToken: String
  
  var expiresIn: Int
  
  var expiresAt: Date {
    Date()
  }
  
  var bearerAccessToken: String {
    "Bearer " + accessToken
  }
  
  init(accessToken: String, tokenType: String, refreshToken: String, expiresIn: Int) {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.refreshToken = refreshToken
    self.expiresIn = expiresIn
  }
  
}
