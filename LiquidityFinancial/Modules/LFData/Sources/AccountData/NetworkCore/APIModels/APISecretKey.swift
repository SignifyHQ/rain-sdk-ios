import Foundation
import AccountDomain

public struct APISecretKey: Decodable, SecretKeyEntity {
  public let secretKey: String
  
  public init(secretKey: String) {
    self.secretKey = secretKey
  }
}
