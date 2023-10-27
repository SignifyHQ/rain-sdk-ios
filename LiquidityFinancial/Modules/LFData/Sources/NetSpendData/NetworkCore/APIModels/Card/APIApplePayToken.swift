import Foundation
import NetspendDomain

public struct APIGetApplePayToken: Decodable, GetApplePayTokenEntity {
  public var tokens: [APIApplePayToken]
}

extension APIGetApplePayToken {
  public var tokenEntities: [NetspendDomain.ApplePayTokenEntity] {
    tokens
  }
}


public struct APIApplePayToken: Decodable, ApplePayTokenEntity {
  public var cardId: String?
  public var walletProvider: String?
  public var panReferenceId: String?
  public var tokenReferenceId: String?
  public var tokenStatus: String?
}

public struct APIPostApplePayToken: Decodable, PostApplePayTokenEntity {
  public var activationData: String?
  public var ephemeralPublicKey: String?
  public var encryptedCardData: String?
}
