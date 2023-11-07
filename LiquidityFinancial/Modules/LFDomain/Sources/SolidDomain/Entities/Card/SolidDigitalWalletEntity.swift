import Foundation

// sourcery: AutoMockable
public protocol SolidDigitalWalletEntity {
  var wallet: String { get }
  var applePayEntity: SolidApplePayEntity? { get }
}

// sourcery: AutoMockable
public protocol SolidApplePayEntity {
  var paymentAccountReference: String { get }
  var activationData: String { get }
  var encryptedPassData: String { get }
  var ephemeralPublicKey: String { get }
}
