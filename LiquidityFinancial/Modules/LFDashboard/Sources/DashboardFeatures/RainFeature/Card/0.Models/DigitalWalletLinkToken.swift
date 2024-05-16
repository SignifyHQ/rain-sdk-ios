import Foundation

struct DigitalWalletLinkToken {
  var activationData: String?
  var ephemeralPublicKey: String?
  var encryptedCardData: String?
  
  init(activationData: String?, ephemeralPublicKey: String?, encryptedCardData: String?) {
    self.activationData = activationData
    self.ephemeralPublicKey = ephemeralPublicKey
    self.encryptedCardData = encryptedCardData
  }
}
