import Foundation

public struct DigitalWalletLinkToken {
  public var activationData: String?
  public var ephemeralPublicKey: String?
  public var encryptedCardData: String?
  
  public init(activationData: String?, ephemeralPublicKey: String?, encryptedCardData: String?) {
    self.activationData = activationData
    self.ephemeralPublicKey = ephemeralPublicKey
    self.encryptedCardData = encryptedCardData
  }
}
