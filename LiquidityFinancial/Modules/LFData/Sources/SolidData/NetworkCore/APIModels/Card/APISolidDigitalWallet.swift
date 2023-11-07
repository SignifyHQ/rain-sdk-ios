import SolidDomain

public struct APISolidDigitalWallet: Codable {
  public var wallet: String
  public var applePay: APISolidApplePay?
}

extension APISolidDigitalWallet: SolidDigitalWalletEntity {
  public var applePayEntity: SolidApplePayEntity? {
    applePay
  }
}

public struct APISolidApplePay: Codable, SolidApplePayEntity {
  public var paymentAccountReference: String
  public var activationData: String
  public var encryptedPassData: String
  public var ephemeralPublicKey: String
}
